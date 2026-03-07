/**
 * Unified middleware wrapper for all API endpoints.
 *
 * Applies security, rate limiting, logging, and metrics
 * in a single composable wrapper.
 *
 * Usage:
 *   module.exports = withMiddleware(async (req, res) => { ... });
 *   module.exports = withMiddleware(handler, { auth: true, cacheControl: 'WEATHER' });
 */
const { applySecurity } = require('./security');
const { checkRateLimit } = require('./rate-limiter');
const { createRequestLogger, logRequest } = require('./logger');
const { trackActiveUser } = require('./metrics');
const { verifyAuth, optionalAuth } = require('./auth-middleware');

/**
 * @param {Function} handler - The route handler function
 * @param {Object} options
 * @param {boolean} options.auth - Require authentication (default: false)
 * @param {boolean} options.optionalAuth - Try auth but don't require it (default: false)
 * @param {string} options.cacheControl - Cache-Control preset key (from cache.CACHE_CONTROL)
 * @param {string[]} options.methods - Allowed HTTP methods (default: ['GET'])
 */
function withMiddleware(handler, options = {}) {
  const {
    auth = false,
    optionalAuth: tryAuth = false,
    cacheControl = null,
    methods = null,
  } = options;

  return async function wrappedHandler(req, res) {
    const startTime = Date.now();

    // 1. Security (HTTPS, headers, CORS, sanitization)
    if (applySecurity(req, res)) return;

    // 2. Method check
    if (methods && !methods.includes(req.method)) {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    // 3. Rate limiting
    if (checkRateLimit(req, res)) return;

    // 4. Request logger
    const log = createRequestLogger(req);

    // 5. Auth
    if (auth) {
      const uid = await verifyAuth(req, res);
      if (!uid) return;
    } else if (tryAuth) {
      await optionalAuth(req);
    }

    // 6. Track active user
    if (req.uid) {
      trackActiveUser(req.uid).catch(() => {});
    }

    // 7. Cache-Control header
    if (cacheControl) {
      const { CACHE_CONTROL } = require('./cache');
      const headerValue = CACHE_CONTROL[cacheControl] || CACHE_CONTROL.NONE;
      res.setHeader('Cache-Control', headerValue);
    }

    // 8. Correlation ID header
    res.setHeader('X-Request-Id', req.correlationId);

    // 9. Execute handler
    try {
      await handler(req, res, log);
    } catch (err) {
      log.error('Unhandled error', {
        error: err.message,
        stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
      });

      if (!res.headersSent) {
        res.status(500).json({ error: 'Internal server error' });
      }
    } finally {
      logRequest(req, res, startTime);
    }
  };
}

module.exports = { withMiddleware };
