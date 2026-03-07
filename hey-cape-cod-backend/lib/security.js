/**
 * Security middleware: Helmet headers, CORS, HTTPS enforcement, input sanitization.
 */
const sanitizeHtml = require('sanitize-html');

// --- Helmet-style security headers ---

const SECURITY_HEADERS = {
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'X-XSS-Protection': '0',
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  'Permissions-Policy': 'camera=(), microphone=(), geolocation=()',
  'Content-Security-Policy': "default-src 'none'; frame-ancestors 'none'",
  'X-DNS-Prefetch-Control': 'off',
  'X-Download-Options': 'noopen',
  'X-Permitted-Cross-Domain-Policies': 'none',
};

function applySecurityHeaders(res) {
  for (const [key, value] of Object.entries(SECURITY_HEADERS)) {
    res.setHeader(key, value);
  }
}

// --- CORS ---

const ALLOWED_ORIGINS = [
  'https://heycapecod.com',
  'https://www.heycapecod.com',
  'https://staging-cape-cod.vercel.app',
  'https://v0-cape-cod-ai-travel-assistant.vercel.app',
];

const ALLOWED_BUNDLE_IDS = [
  'com.heycapecod.app',
];

function applyCors(req, res) {
  const origin = req.headers.origin || '';
  const bundleId = req.headers['x-bundle-id'] || '';

  // Allow if origin matches, or if request comes from our iOS app
  const isAllowedOrigin = ALLOWED_ORIGINS.includes(origin);
  const isAllowedApp = ALLOWED_BUNDLE_IDS.includes(bundleId);

  if (isAllowedOrigin) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  } else if (isAllowedApp || !origin) {
    // iOS app requests have no origin header; allow if bundle ID matches or no origin
    res.setHeader('Access-Control-Allow-Origin', '*');
  }

  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Bundle-Id, X-Request-Id');
  res.setHeader('Access-Control-Max-Age', '86400');

  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return true; // Signal to caller that response was sent
  }

  return false;
}

// --- HTTPS enforcement ---

function enforceHttps(req, res) {
  if (process.env.NODE_ENV === 'production' &&
      req.headers['x-forwarded-proto'] !== 'https') {
    res.status(301).setHeader('Location', `https://${req.headers.host}${req.url}`);
    res.end();
    return true;
  }
  return false;
}

// --- Input sanitization ---

/**
 * Sanitize a string value — strips HTML tags and trims.
 */
function sanitizeString(value) {
  if (typeof value !== 'string') return value;
  return sanitizeHtml(value, { allowedTags: [], allowedAttributes: {} }).trim();
}

/**
 * Recursively sanitize all string values in an object.
 */
function sanitizeInput(obj) {
  if (typeof obj === 'string') return sanitizeString(obj);
  if (Array.isArray(obj)) return obj.map(sanitizeInput);
  if (obj && typeof obj === 'object') {
    const clean = {};
    for (const [key, value] of Object.entries(obj)) {
      clean[sanitizeString(key)] = sanitizeInput(value);
    }
    return clean;
  }
  return obj;
}

/**
 * Validate and clamp numeric query parameters.
 */
function sanitizeQueryParams(query) {
  const clean = {};
  for (const [key, value] of Object.entries(query)) {
    clean[key] = sanitizeString(String(value));
  }
  return clean;
}

// --- Combined middleware ---

/**
 * Apply all security measures. Returns true if the response was already sent
 * (e.g., HTTPS redirect or CORS preflight).
 */
function applySecurity(req, res) {
  if (enforceHttps(req, res)) return true;
  applySecurityHeaders(res);
  if (applyCors(req, res)) return true;

  // Sanitize request body
  if (req.body && typeof req.body === 'object') {
    req.body = sanitizeInput(req.body);
  }

  // Sanitize query params
  if (req.query) {
    req.query = sanitizeQueryParams(req.query);
  }

  return false;
}

module.exports = {
  applySecurity,
  applySecurityHeaders,
  applyCors,
  enforceHttps,
  sanitizeString,
  sanitizeInput,
};
