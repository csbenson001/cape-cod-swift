/**
 * Voice WebSocket relay endpoint.
 *
 * NOTE: Vercel serverless functions have timeout limits (10s hobby, 60s pro).
 * For production, the voice relay should run on a persistent server
 * (Railway, Render, Fly.io) that supports long-lived WebSocket connections.
 *
 * This endpoint serves as a placeholder that:
 * 1. Validates the auth token
 * 2. Returns connection instructions for the voice relay server
 *
 * TODO (Prompt 14 — Backend Hardening):
 * - Deploy voice relay to Railway/Render with persistent WebSocket support
 * - Implement OpenAI Realtime API relay
 * - Add connection pooling and session management
 */
const { verifyAuth } = require('../../lib/auth-middleware');

module.exports = async function handler(req, res) {
  // WebSocket upgrade requests come as GET
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const uid = await verifyAuth(req, res);
  if (!uid) return;

  // For now, return the voice relay server URL
  // The iOS app's WebSocketManager should connect directly to this URL
  res.status(200).json({
    message: 'Voice relay endpoint',
    uid,
    // TODO: Replace with actual voice relay server URL once deployed
    relayUrl: process.env.VOICE_RELAY_URL || 'wss://voice.heycapecod.com/relay',
    note: 'WebSocket connections require a persistent server. See TODO in source.',
  });
};
