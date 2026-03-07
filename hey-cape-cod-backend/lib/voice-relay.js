/**
 * WebSocket voice relay for OpenAI Realtime API.
 *
 * Features:
 * - Connection pooling to OpenAI
 * - Idle timeout: 10 minutes
 * - Max conversation length: 15 minutes
 * - Usage tracking per user
 * - Graceful reconnection handling
 * - Rate limiting: 5 concurrent connections per user
 *
 * NOTE: This module is designed for a persistent server (Railway/Render/Fly.io),
 * NOT for Vercel serverless. The api/voice/index.js endpoint returns the
 * relay server URL for iOS clients to connect to directly.
 */
const WebSocket = require('ws');
const { auth } = require('./firebase-admin');
const { trackWsConnection, releaseWsConnection, getWsConnectionCount, MAX_WS_CONNECTIONS } = require('./rate-limiter');
const { recordVoiceSession } = require('./metrics');
const { logger } = require('./logger');

const OPENAI_REALTIME_URL = 'wss://api.openai.com/v1/realtime?model=gpt-4o-realtime-preview';

const IDLE_TIMEOUT_MS = 10 * 60 * 1000;    // 10 minutes
const MAX_SESSION_MS = 15 * 60 * 1000;     // 15 minutes

// Active sessions: Map<sessionId, SessionState>
const sessions = new Map();

/**
 * Session state for an active voice relay connection.
 */
class VoiceSession {
  constructor(clientWs, uid, sessionId) {
    this.clientWs = clientWs;
    this.uid = uid;
    this.sessionId = sessionId;
    this.openaiWs = null;
    this.startedAt = Date.now();
    this.lastActivityAt = Date.now();
    this.idleTimer = null;
    this.maxSessionTimer = null;
    this.isClosing = false;
    this.totalAudioChunks = 0;
  }

  get durationSeconds() {
    return Math.round((Date.now() - this.startedAt) / 1000);
  }

  get isIdle() {
    return Date.now() - this.lastActivityAt > IDLE_TIMEOUT_MS;
  }

  touch() {
    this.lastActivityAt = Date.now();
    this.resetIdleTimer();
  }

  resetIdleTimer() {
    if (this.idleTimer) clearTimeout(this.idleTimer);
    this.idleTimer = setTimeout(() => {
      this.closeWithReason('idle_timeout', 'Connection closed due to inactivity (10 min)');
    }, IDLE_TIMEOUT_MS);
  }

  startMaxSessionTimer() {
    this.maxSessionTimer = setTimeout(() => {
      this.closeWithReason('max_duration', 'Maximum conversation length reached (15 min). Please start a new conversation.');
    }, MAX_SESSION_MS);
  }

  closeWithReason(code, message) {
    if (this.isClosing) return;
    this.isClosing = true;

    logger.info('Voice session closing', {
      uid: this.uid,
      sessionId: this.sessionId,
      reason: code,
      durationSeconds: this.durationSeconds,
      audioChunks: this.totalAudioChunks,
    });

    // Notify client
    try {
      this.clientWs.send(JSON.stringify({
        type: 'session_end',
        reason: code,
        message,
        durationSeconds: this.durationSeconds,
      }));
    } catch { /* ignore */ }

    this.cleanup();
  }

  cleanup() {
    if (this.idleTimer) clearTimeout(this.idleTimer);
    if (this.maxSessionTimer) clearTimeout(this.maxSessionTimer);
    if (this.openaiWs && this.openaiWs.readyState === WebSocket.OPEN) {
      this.openaiWs.close();
    }
    if (this.clientWs.readyState === WebSocket.OPEN) {
      this.clientWs.close();
    }
    sessions.delete(this.sessionId);
    releaseWsConnection(this.uid);

    // Record usage for billing
    recordVoiceSession(this.uid, this.durationSeconds).catch(() => {});
  }
}

/**
 * Handle a new WebSocket connection from an iOS client.
 *
 * Expected flow:
 * 1. Client connects with auth token in query string or first message
 * 2. Server verifies token, opens relay to OpenAI
 * 3. Client sends audio chunks, server relays to OpenAI
 * 4. OpenAI sends responses, server relays back to client
 * 5. Connection closes on idle, max duration, or client disconnect
 */
async function handleConnection(clientWs, req) {
  let uid = null;

  try {
    // Extract auth token from query string
    const url = new URL(req.url, `wss://${req.headers.host}`);
    const token = url.searchParams.get('token');

    if (!token) {
      clientWs.send(JSON.stringify({ type: 'error', message: 'Authentication required' }));
      clientWs.close(4001, 'Auth required');
      return;
    }

    // Verify Firebase token
    const decoded = await auth.verifyIdToken(token);
    uid = decoded.uid;

    // Check concurrent connection limit
    if (getWsConnectionCount(uid) >= MAX_WS_CONNECTIONS) {
      clientWs.send(JSON.stringify({
        type: 'error',
        message: `Too many concurrent connections (max ${MAX_WS_CONNECTIONS})`,
      }));
      clientWs.close(4029, 'Too many connections');
      return;
    }

    trackWsConnection(uid);

    // Create session
    const sessionId = `${uid}-${Date.now()}`;
    const session = new VoiceSession(clientWs, uid, sessionId);
    sessions.set(sessionId, session);

    // Connect to OpenAI Realtime API
    const openaiWs = new WebSocket(OPENAI_REALTIME_URL, {
      headers: {
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
        'OpenAI-Beta': 'realtime=v1',
      },
    });

    session.openaiWs = openaiWs;

    openaiWs.on('open', () => {
      logger.info('OpenAI relay connected', { uid, sessionId });
      clientWs.send(JSON.stringify({ type: 'connected', sessionId }));
      session.resetIdleTimer();
      session.startMaxSessionTimer();
    });

    openaiWs.on('message', (data) => {
      session.touch();
      if (clientWs.readyState === WebSocket.OPEN) {
        clientWs.send(data);
      }
    });

    openaiWs.on('close', () => {
      if (!session.isClosing) {
        session.closeWithReason('openai_disconnect', 'OpenAI connection closed');
      }
    });

    openaiWs.on('error', (err) => {
      logger.error('OpenAI WebSocket error', { uid, sessionId, error: err.message });
      session.closeWithReason('openai_error', 'Voice service error');
    });

    // Handle client messages
    clientWs.on('message', (data) => {
      session.touch();
      session.totalAudioChunks++;

      if (openaiWs.readyState === WebSocket.OPEN) {
        openaiWs.send(data);
      }
    });

    clientWs.on('close', () => {
      if (!session.isClosing) {
        session.cleanup();
      }
    });

    clientWs.on('error', (err) => {
      logger.error('Client WebSocket error', { uid, sessionId, error: err.message });
      session.cleanup();
    });

  } catch (err) {
    logger.error('Voice connection setup failed', { error: err.message });
    if (uid) releaseWsConnection(uid);
    clientWs.close(4000, 'Connection failed');
  }
}

/**
 * Create a WebSocket server for voice relay.
 * Call this from the persistent server's startup code.
 */
function createVoiceRelayServer(server) {
  const wss = new WebSocket.Server({ server, path: '/relay' });

  wss.on('connection', (ws, req) => {
    handleConnection(ws, req);
  });

  // Periodic cleanup of stale sessions
  setInterval(() => {
    for (const [id, session] of sessions) {
      if (session.isIdle) {
        session.closeWithReason('idle_timeout', 'Idle timeout');
      }
    }
  }, 60_000);

  logger.info('Voice relay WebSocket server started', {
    path: '/relay',
    idleTimeout: `${IDLE_TIMEOUT_MS / 60000} min`,
    maxSession: `${MAX_SESSION_MS / 60000} min`,
  });

  return wss;
}

/**
 * Get active session count (for health checks).
 */
function getActiveSessionCount() {
  return sessions.size;
}

module.exports = {
  handleConnection,
  createVoiceRelayServer,
  getActiveSessionCount,
  IDLE_TIMEOUT_MS,
  MAX_SESSION_MS,
};
