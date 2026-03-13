"use strict";

require("dotenv").config();

const http = require("http");
const { WebSocketServer, WebSocket } = require("ws");
const { v4: uuidv4 } = require("uuid");
const admin = require("firebase-admin");

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const PORT = parseInt(process.env.PORT, 10) || 8080;
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
const OPENAI_REALTIME_URL =
  "wss://api.openai.com/v1/realtime?model=gpt-4o-mini-realtime-preview";

const SESSION_TIMEOUT_MS = 15 * 60 * 1000; // 15 minutes
const IDLE_TIMEOUT_MS = 10 * 60 * 1000; // 10 minutes
const PING_INTERVAL_MS = 30 * 1000; // 30 seconds
const MAX_CONNECTIONS_PER_USER = 5;

const CAPTAIN_COD_INSTRUCTIONS = `You are Captain Cod, a friendly and knowledgeable AI travel assistant for Cape Cod, Massachusetts. You speak with warmth and occasional nautical flair. You help visitors and locals with:
- Beach recommendations and conditions
- Restaurant and dining suggestions
- Local events and activities
- Historical sites and lighthouses
- Traffic and bridge conditions
- Weather and tide information
- Wildlife and nature (whales, seals, birds)
- Shopping and galleries
Keep responses concise for voice — aim for 2-3 sentences unless the user asks for detail. Be enthusiastic about Cape Cod!`;

// ---------------------------------------------------------------------------
// Firebase Admin
// ---------------------------------------------------------------------------

if (!admin.apps.length) {
  const firebaseConfig = {
    projectId: process.env.FIREBASE_PROJECT_ID,
  };

  if (process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
    firebaseConfig.credential = admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
    });
  }

  admin.initializeApp(firebaseConfig);
}

// ---------------------------------------------------------------------------
// Logging
// ---------------------------------------------------------------------------

function log(sessionId, ...args) {
  const ts = new Date().toISOString();
  const prefix = sessionId ? `[${ts}] [${sessionId.slice(0, 8)}]` : `[${ts}]`;
  console.log(prefix, ...args);
}

function logError(sessionId, ...args) {
  const ts = new Date().toISOString();
  const prefix = sessionId ? `[${ts}] [${sessionId.slice(0, 8)}]` : `[${ts}]`;
  console.error(prefix, ...args);
}

// ---------------------------------------------------------------------------
// Connection tracking
// ---------------------------------------------------------------------------

/** @type {Map<string, Set<string>>} userId -> Set of sessionIds */
const userConnections = new Map();

/** @type {Map<string, object>} sessionId -> session object */
const sessions = new Map();

function trackConnection(userId, sessionId) {
  if (!userConnections.has(userId)) {
    userConnections.set(userId, new Set());
  }
  userConnections.get(userId).add(sessionId);
}

function untrackConnection(userId, sessionId) {
  const conns = userConnections.get(userId);
  if (conns) {
    conns.delete(sessionId);
    if (conns.size === 0) {
      userConnections.delete(userId);
    }
  }
}

function getUserConnectionCount(userId) {
  const conns = userConnections.get(userId);
  return conns ? conns.size : 0;
}

// ---------------------------------------------------------------------------
// HTTP Server + Health Check
// ---------------------------------------------------------------------------

const httpServer = http.createServer((req, res) => {
  if (req.method === "GET" && req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(
      JSON.stringify({
        status: "ok",
        uptime: process.uptime(),
        activeSessions: sessions.size,
        activeUsers: userConnections.size,
        timestamp: new Date().toISOString(),
      })
    );
    return;
  }

  res.writeHead(404, { "Content-Type": "text/plain" });
  res.end("Not found");
});

// ---------------------------------------------------------------------------
// WebSocket Server
// ---------------------------------------------------------------------------

const wss = new WebSocketServer({ noServer: true });

httpServer.on("upgrade", async (req, socket, head) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

  if (url.pathname !== "/relay") {
    socket.write("HTTP/1.1 404 Not Found\r\n\r\n");
    socket.destroy();
    return;
  }

  // Authenticate
  const authHeader = req.headers["authorization"];
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    socket.write("HTTP/1.1 401 Unauthorized\r\n\r\n");
    socket.destroy();
    return;
  }

  const token = authHeader.slice(7);
  let userId;

  try {
    const decoded = await admin.auth().verifyIdToken(token);
    userId = decoded.uid;
  } catch (err) {
    logError(null, "Auth failed:", err.message);
    socket.write("HTTP/1.1 401 Unauthorized\r\n\r\n");
    socket.destroy();
    return;
  }

  // Per-user connection limit
  if (getUserConnectionCount(userId) >= MAX_CONNECTIONS_PER_USER) {
    socket.write("HTTP/1.1 429 Too Many Requests\r\n\r\n");
    socket.destroy();
    return;
  }

  wss.handleUpgrade(req, socket, head, (ws) => {
    wss.emit("connection", ws, req, userId);
  });
});

// ---------------------------------------------------------------------------
// Session Management
// ---------------------------------------------------------------------------

wss.on("connection", (clientWs, req, userId) => {
  const sessionId = uuidv4();
  log(sessionId, `Client connected (user=${userId})`);

  trackConnection(userId, sessionId);

  const session = {
    id: sessionId,
    userId,
    clientWs,
    openaiWs: null,
    openaiReady: false,
    sessionTimer: null,
    idleTimer: null,
    pingInterval: null,
    alive: true,
    cleanedUp: false,
  };

  sessions.set(sessionId, session);

  // Session timeout (absolute max duration)
  session.sessionTimer = setTimeout(() => {
    log(sessionId, "Session timeout (15 min max)");
    sendToClient(session, {
      type: "error",
      message: "Session expired (15 minute limit). Please reconnect.",
    });
    cleanup(session);
  }, SESSION_TIMEOUT_MS);

  // Idle timeout
  resetIdleTimer(session);

  // Ping/pong keep-alive
  session.pingInterval = setInterval(() => {
    if (!session.alive) {
      log(sessionId, "Client unresponsive, closing");
      cleanup(session);
      return;
    }
    session.alive = false;
    if (clientWs.readyState === WebSocket.OPEN) {
      clientWs.ping();
    }
  }, PING_INTERVAL_MS);

  clientWs.on("pong", () => {
    session.alive = true;
  });

  // Connect to OpenAI Realtime API
  connectToOpenAI(session);

  // Handle messages from iOS client
  clientWs.on("message", (raw) => {
    resetIdleTimer(session);

    let msg;
    try {
      msg = JSON.parse(raw.toString());
    } catch {
      logError(sessionId, "Invalid JSON from client");
      return;
    }

    handleClientMessage(session, msg);
  });

  clientWs.on("close", (code, reason) => {
    log(sessionId, `Client disconnected (code=${code})`);
    cleanup(session);
  });

  clientWs.on("error", (err) => {
    logError(sessionId, "Client WS error:", err.message);
    cleanup(session);
  });
});

// ---------------------------------------------------------------------------
// OpenAI Realtime Connection
// ---------------------------------------------------------------------------

function connectToOpenAI(session) {
  if (!OPENAI_API_KEY) {
    logError(session.id, "OPENAI_API_KEY not set");
    sendToClient(session, {
      type: "error",
      message: "Server configuration error. Please try again later.",
    });
    cleanup(session);
    return;
  }

  const openaiWs = new WebSocket(OPENAI_REALTIME_URL, {
    headers: {
      Authorization: `Bearer ${OPENAI_API_KEY}`,
      "OpenAI-Beta": "realtime=v1",
    },
  });

  session.openaiWs = openaiWs;

  openaiWs.on("open", () => {
    log(session.id, "Connected to OpenAI Realtime API");
    session.openaiReady = true;

    // Configure the session
    sendToOpenAI(session, {
      type: "session.update",
      session: {
        voice: "alloy",
        instructions: CAPTAIN_COD_INSTRUCTIONS,
        input_audio_format: "pcm16",
        output_audio_format: "pcm16",
        input_audio_transcription: {
          model: "whisper-1",
        },
        turn_detection: {
          type: "server_vad",
          threshold: 0.5,
          prefix_padding_ms: 300,
          silence_duration_ms: 500,
        },
      },
    });

    sendToClient(session, { type: "status", state: "listening" });
  });

  openaiWs.on("message", (raw) => {
    let msg;
    try {
      msg = JSON.parse(raw.toString());
    } catch {
      logError(session.id, "Invalid JSON from OpenAI");
      return;
    }

    handleOpenAIMessage(session, msg);
  });

  openaiWs.on("close", (code, reason) => {
    log(session.id, `OpenAI disconnected (code=${code})`);
    session.openaiReady = false;

    // If client is still connected, notify and clean up
    if (
      session.clientWs &&
      session.clientWs.readyState === WebSocket.OPEN &&
      !session.cleanedUp
    ) {
      sendToClient(session, {
        type: "error",
        message: "Voice service disconnected. Please reconnect.",
      });
      cleanup(session);
    }
  });

  openaiWs.on("error", (err) => {
    logError(session.id, "OpenAI WS error:", err.message);
    session.openaiReady = false;

    if (
      session.clientWs &&
      session.clientWs.readyState === WebSocket.OPEN &&
      !session.cleanedUp
    ) {
      sendToClient(session, {
        type: "error",
        message: "Voice service error. Please try again.",
      });
      cleanup(session);
    }
  });
}

// ---------------------------------------------------------------------------
// Client -> OpenAI message handling
// ---------------------------------------------------------------------------

function handleClientMessage(session, msg) {
  switch (msg.type) {
    case "audio":
      if (!session.openaiReady) {
        log(session.id, "Dropping audio — OpenAI not ready");
        return;
      }
      // Forward audio to OpenAI
      sendToOpenAI(session, {
        type: "input_audio_buffer.append",
        audio: msg.audio,
      });
      break;

    case "control":
      handleControlMessage(session, msg.action);
      break;

    default:
      log(session.id, `Unknown client message type: ${msg.type}`);
  }
}

function handleControlMessage(session, action) {
  switch (action) {
    case "interrupt":
      log(session.id, "Client interrupt");
      sendToOpenAI(session, { type: "response.cancel" });
      sendToClient(session, { type: "status", state: "listening" });
      break;

    case "end_turn":
      log(session.id, "Client end_turn");
      sendToOpenAI(session, { type: "input_audio_buffer.commit" });
      sendToClient(session, { type: "status", state: "thinking" });
      break;

    case "disconnect":
      log(session.id, "Client requested disconnect");
      cleanup(session);
      break;

    default:
      log(session.id, `Unknown control action: ${action}`);
  }
}

// ---------------------------------------------------------------------------
// OpenAI -> Client message handling
// ---------------------------------------------------------------------------

function handleOpenAIMessage(session, msg) {
  switch (msg.type) {
    // Audio chunks from assistant
    case "response.audio.delta":
      sendToClient(session, {
        type: "audio",
        audio: msg.delta,
        is_final: false,
      });
      break;

    case "response.audio.done":
      sendToClient(session, {
        type: "audio",
        audio: "",
        is_final: true,
      });
      break;

    // Assistant transcript
    case "response.audio_transcript.delta":
      sendToClient(session, {
        type: "transcript",
        text: msg.delta,
        role: "assistant",
      });
      break;

    case "response.audio_transcript.done":
      sendToClient(session, {
        type: "transcript",
        text: msg.transcript,
        role: "assistant",
      });
      break;

    // User speech transcript (from input_audio_transcription)
    case "conversation.item.input_audio_transcription.completed":
      sendToClient(session, {
        type: "transcript",
        text: msg.transcript,
        role: "user",
      });
      break;

    // Status transitions
    case "input_audio_buffer.speech_started":
      sendToClient(session, { type: "status", state: "listening" });
      break;

    case "input_audio_buffer.speech_stopped":
      sendToClient(session, { type: "status", state: "thinking" });
      break;

    case "response.created":
      sendToClient(session, { type: "status", state: "thinking" });
      break;

    case "response.output_item.added":
      if (msg.item && msg.item.type === "message") {
        sendToClient(session, { type: "status", state: "speaking" });
      }
      break;

    case "response.done":
      sendToClient(session, { type: "status", state: "listening" });
      break;

    // Errors from OpenAI
    case "error":
      logError(session.id, "OpenAI error:", JSON.stringify(msg.error));
      sendToClient(session, {
        type: "error",
        message: msg.error?.message || "Voice service error",
      });
      break;

    // Session events (logged but not forwarded)
    case "session.created":
      log(session.id, "OpenAI session created");
      break;

    case "session.updated":
      log(session.id, "OpenAI session updated");
      break;

    // Rate limit info
    case "rate_limits.updated":
      // Silently ignore
      break;

    default:
      // Log unhandled event types at debug level
      if (process.env.DEBUG) {
        log(session.id, `Unhandled OpenAI event: ${msg.type}`);
      }
  }
}

// ---------------------------------------------------------------------------
// Send helpers
// ---------------------------------------------------------------------------

function sendToClient(session, msg) {
  if (session.clientWs && session.clientWs.readyState === WebSocket.OPEN) {
    try {
      session.clientWs.send(JSON.stringify(msg));
    } catch (err) {
      logError(session.id, "Error sending to client:", err.message);
    }
  }
}

function sendToOpenAI(session, msg) {
  if (session.openaiWs && session.openaiWs.readyState === WebSocket.OPEN) {
    try {
      session.openaiWs.send(JSON.stringify(msg));
    } catch (err) {
      logError(session.id, "Error sending to OpenAI:", err.message);
    }
  }
}

// ---------------------------------------------------------------------------
// Idle timer
// ---------------------------------------------------------------------------

function resetIdleTimer(session) {
  if (session.idleTimer) {
    clearTimeout(session.idleTimer);
  }
  session.idleTimer = setTimeout(() => {
    log(session.id, "Idle timeout (10 min)");
    sendToClient(session, {
      type: "error",
      message: "Session closed due to inactivity.",
    });
    cleanup(session);
  }, IDLE_TIMEOUT_MS);
}

// ---------------------------------------------------------------------------
// Cleanup
// ---------------------------------------------------------------------------

function cleanup(session) {
  if (session.cleanedUp) return;
  session.cleanedUp = true;

  log(session.id, "Cleaning up session");

  // Clear timers
  if (session.sessionTimer) clearTimeout(session.sessionTimer);
  if (session.idleTimer) clearTimeout(session.idleTimer);
  if (session.pingInterval) clearInterval(session.pingInterval);

  // Close OpenAI connection
  if (session.openaiWs) {
    try {
      if (session.openaiWs.readyState === WebSocket.OPEN) {
        session.openaiWs.close(1000, "Session ended");
      }
    } catch (err) {
      logError(session.id, "Error closing OpenAI WS:", err.message);
    }
    session.openaiWs = null;
  }

  // Close client connection
  if (session.clientWs) {
    try {
      if (session.clientWs.readyState === WebSocket.OPEN) {
        session.clientWs.close(1000, "Session ended");
      }
    } catch (err) {
      logError(session.id, "Error closing client WS:", err.message);
    }
    session.clientWs = null;
  }

  // Remove from tracking
  untrackConnection(session.userId, session.id);
  sessions.delete(session.id);

  log(session.id, "Session cleaned up");
}

// ---------------------------------------------------------------------------
// Graceful Shutdown
// ---------------------------------------------------------------------------

function gracefulShutdown(signal) {
  log(null, `${signal} received, shutting down gracefully...`);

  // Stop accepting new connections
  wss.close();

  // Close all active sessions
  for (const session of sessions.values()) {
    sendToClient(session, {
      type: "error",
      message: "Server is restarting. Please reconnect.",
    });
    cleanup(session);
  }

  httpServer.close(() => {
    log(null, "HTTP server closed");
    process.exit(0);
  });

  // Force exit after 10 seconds
  setTimeout(() => {
    logError(null, "Forced shutdown after timeout");
    process.exit(1);
  }, 10000);
}

process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));
process.on("SIGINT", () => gracefulShutdown("SIGINT"));

// ---------------------------------------------------------------------------
// Start
// ---------------------------------------------------------------------------

httpServer.listen(PORT, () => {
  log(null, `Voice relay server listening on port ${PORT}`);
  log(null, `Health check: http://localhost:${PORT}/health`);
  log(null, `WebSocket relay: ws://localhost:${PORT}/relay`);
});
