/**
 * Voice relay connection info endpoint.
 *
 * Returns the WebSocket URL for the persistent voice relay server.
 * The actual voice relay runs on Railway/Fly.io (see /voice-relay-server/)
 * because Vercel doesn't support persistent WebSocket connections.
 */
const { withMiddleware } = require('../../lib/middleware');
const { getWsConnectionCount, MAX_WS_CONNECTIONS } = require('../../lib/rate-limiter');

module.exports = withMiddleware(async (req, res, log) => {
  const uid = req.uid;
  const currentConnections = getWsConnectionCount(uid);

  if (currentConnections >= MAX_WS_CONNECTIONS) {
    return res.status(429).json({
      error: `Too many concurrent voice connections (max ${MAX_WS_CONNECTIONS})`,
      currentConnections,
    });
  }

  log.info('Voice relay info requested', { uid, currentConnections });

  res.status(200).json({
    uid,
    relayUrl: process.env.VOICE_RELAY_URL || 'wss://voice.heycapecod.com/relay',
    maxConnections: MAX_WS_CONNECTIONS,
    currentConnections,
    config: {
      idleTimeoutMinutes: 10,
      maxSessionMinutes: 15,
      audioFormat: 'pcm16',
      sampleRate: 24000,
      channels: 1,
    },
  });
}, { auth: true, methods: ['GET'], cacheControl: 'NONE' });
