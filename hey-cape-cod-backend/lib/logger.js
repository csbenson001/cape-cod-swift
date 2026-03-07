/**
 * Structured JSON logger with correlation IDs.
 *
 * All log entries include:
 * - timestamp (ISO 8601)
 * - level (info, warn, error, debug)
 * - message
 * - correlationId (from request header or auto-generated)
 * - Additional context fields
 */
const { v4: uuidv4 } = require('uuid');

const LOG_LEVELS = { debug: 0, info: 1, warn: 2, error: 3 };
const MIN_LEVEL = LOG_LEVELS[process.env.LOG_LEVEL || 'info'];

function formatEntry(level, message, context = {}) {
  return JSON.stringify({
    timestamp: new Date().toISOString(),
    level,
    message,
    service: 'hey-cape-cod-api',
    ...context,
  });
}

function shouldLog(level) {
  return (LOG_LEVELS[level] ?? 1) >= MIN_LEVEL;
}

const logger = {
  debug(message, context) {
    if (shouldLog('debug')) console.log(formatEntry('debug', message, context));
  },
  info(message, context) {
    if (shouldLog('info')) console.log(formatEntry('info', message, context));
  },
  warn(message, context) {
    if (shouldLog('warn')) console.warn(formatEntry('warn', message, context));
  },
  error(message, context) {
    if (shouldLog('error')) console.error(formatEntry('error', message, context));
  },
};

/**
 * Extract or generate a correlation ID for request tracing.
 */
function getCorrelationId(req) {
  return req.headers['x-request-id'] || req.headers['x-correlation-id'] || uuidv4();
}

/**
 * Create a request-scoped logger with correlation ID attached.
 */
function createRequestLogger(req) {
  const correlationId = getCorrelationId(req);
  req.correlationId = correlationId;

  return {
    debug(message, ctx = {}) {
      logger.debug(message, { correlationId, uid: req.uid, path: req.url, ...ctx });
    },
    info(message, ctx = {}) {
      logger.info(message, { correlationId, uid: req.uid, path: req.url, ...ctx });
    },
    warn(message, ctx = {}) {
      logger.warn(message, { correlationId, uid: req.uid, path: req.url, ...ctx });
    },
    error(message, ctx = {}) {
      logger.error(message, { correlationId, uid: req.uid, path: req.url, ...ctx });
    },
  };
}

/**
 * Log request/response for observability.
 */
function logRequest(req, res, startTime) {
  const duration = Date.now() - startTime;
  logger.info('request', {
    method: req.method,
    path: req.url,
    status: res.statusCode,
    duration_ms: duration,
    uid: req.uid || null,
    correlationId: req.correlationId,
    userAgent: req.headers['user-agent'],
    ip: req.headers['x-forwarded-for']?.split(',')[0]?.trim(),
  });
}

module.exports = { logger, createRequestLogger, logRequest, getCorrelationId };
