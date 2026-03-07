const { auth } = require('./firebase-admin');

/**
 * Verify Firebase Auth ID token from Authorization header.
 * Sets req.uid on success. Returns 401 on failure.
 *
 * @param {import('http').IncomingMessage} req
 * @returns {Promise<string|null>} uid or null if unauthorized
 */
async function verifyAuth(req, res) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    res.status(401).json({ error: 'Missing or invalid Authorization header' });
    return null;
  }

  const token = header.split('Bearer ')[1];
  try {
    const decoded = await auth.verifyIdToken(token);
    req.uid = decoded.uid;
    return decoded.uid;
  } catch (err) {
    res.status(401).json({ error: 'Invalid or expired auth token' });
    return null;
  }
}

/**
 * Optional auth — sets req.uid if token is present but doesn't reject.
 */
async function optionalAuth(req) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) return;

  const token = header.split('Bearer ')[1];
  try {
    const decoded = await auth.verifyIdToken(token);
    req.uid = decoded.uid;
  } catch {
    // Silently ignore invalid tokens for optional auth
  }
}

module.exports = { verifyAuth, optionalAuth };
