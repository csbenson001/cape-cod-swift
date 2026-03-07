const { withMiddleware } = require('../lib/middleware');
const { getActiveSessionCount } = require('../lib/voice-relay');
const { getMonthlySpend } = require('../lib/cost-controls');
const { getTodayMetrics } = require('../lib/metrics');
const cache = require('../lib/cache');

module.exports = withMiddleware(async (req, res, log) => {
  const checks = {
    api: 'ok',
    firebase: 'unknown',
    cache: 'unknown',
  };

  // Check Firebase
  try {
    const { db } = require('../lib/firebase-admin');
    await db.collection('health').doc('ping').set({ timestamp: new Date() });
    checks.firebase = 'ok';
  } catch (err) {
    checks.firebase = 'error';
    log.warn('Firebase health check failed', { error: err.message });
  }

  // Check cache
  try {
    await cache.set('health:ping', 'ok', 10);
    const val = await cache.get('health:ping');
    checks.cache = val === 'ok' ? 'ok' : 'degraded';
  } catch {
    checks.cache = 'error';
  }

  const allOk = Object.values(checks).every((v) => v === 'ok');

  // Metrics (non-blocking)
  let metrics = {};
  let monthlySpend = 0;
  try {
    [metrics, monthlySpend] = await Promise.all([
      getTodayMetrics(),
      getMonthlySpend(),
    ]);
  } catch { /* ignore */ }

  res.status(allOk ? 200 : 503).json({
    status: allOk ? 'ok' : 'degraded',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    checks,
    voiceSessions: getActiveSessionCount(),
    metrics,
    monthlySpend: `$${monthlySpend.toFixed(2)}`,
    uptime: process.uptime(),
  });
}, { methods: ['GET'], cacheControl: 'NONE' });
