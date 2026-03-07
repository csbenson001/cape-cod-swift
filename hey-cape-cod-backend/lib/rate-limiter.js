/**
 * In-memory rate limiter with per-user tracking.
 *
 * Limits:
 * - REST: 100 requests/minute per user (by uid or IP)
 * - WebSocket: 5 concurrent connections per user
 *
 * In production, back this with Vercel KV for cross-instance consistency.
 */

const WINDOW_MS = 60 * 1000; // 1 minute
const MAX_REQUESTS_PER_WINDOW = 100;
const MAX_WS_CONNECTIONS = 5;

// Track REST request counts per key
const requestCounts = new Map();

// Track active WebSocket connections per user
const wsConnections = new Map();

/**
 * Clean up expired entries periodically.
 */
setInterval(() => {
  const now = Date.now();
  for (const [key, entry] of requestCounts) {
    if (now - entry.windowStart > WINDOW_MS) {
      requestCounts.delete(key);
    }
  }
}, 30_000);

/**
 * Get a rate limit key from the request (prefer uid, fall back to IP).
 */
function getKey(req) {
  return req.uid || req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.socket?.remoteAddress || 'unknown';
}

/**
 * Check and enforce REST rate limit.
 * Returns true if rate limited (response already sent).
 */
function checkRateLimit(req, res) {
  const key = getKey(req);
  const now = Date.now();

  let entry = requestCounts.get(key);
  if (!entry || now - entry.windowStart > WINDOW_MS) {
    entry = { count: 0, windowStart: now };
    requestCounts.set(key, entry);
  }

  entry.count++;

  // Set rate limit headers
  const remaining = Math.max(0, MAX_REQUESTS_PER_WINDOW - entry.count);
  const resetAt = entry.windowStart + WINDOW_MS;
  res.setHeader('X-RateLimit-Limit', MAX_REQUESTS_PER_WINDOW);
  res.setHeader('X-RateLimit-Remaining', remaining);
  res.setHeader('X-RateLimit-Reset', Math.ceil(resetAt / 1000));

  if (entry.count > MAX_REQUESTS_PER_WINDOW) {
    const retryAfter = Math.ceil((resetAt - now) / 1000);
    res.setHeader('Retry-After', retryAfter);
    res.status(429).json({
      error: 'Rate limit exceeded',
      retryAfter,
    });
    return true;
  }

  return false;
}

/**
 * Track a new WebSocket connection for a user.
 * Returns false if the user has too many connections.
 */
function trackWsConnection(uid) {
  const count = wsConnections.get(uid) || 0;
  if (count >= MAX_WS_CONNECTIONS) return false;
  wsConnections.set(uid, count + 1);
  return true;
}

/**
 * Release a WebSocket connection slot.
 */
function releaseWsConnection(uid) {
  const count = wsConnections.get(uid) || 0;
  if (count <= 1) {
    wsConnections.delete(uid);
  } else {
    wsConnections.set(uid, count - 1);
  }
}

/**
 * Get current WebSocket connection count for a user.
 */
function getWsConnectionCount(uid) {
  return wsConnections.get(uid) || 0;
}

module.exports = {
  checkRateLimit,
  trackWsConnection,
  releaseWsConnection,
  getWsConnectionCount,
  MAX_REQUESTS_PER_WINDOW,
  MAX_WS_CONNECTIONS,
};
