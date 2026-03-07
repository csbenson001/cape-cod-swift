const { withMiddleware } = require('../../lib/middleware');
const { fetchTraffic } = require('../../lib/traffic-client');
const { setDoc, getDoc } = require('../../lib/firestore');
const cache = require('../../lib/cache');

module.exports = withMiddleware(async (req, res, log) => {
  // Check in-memory/KV cache first
  const cached = await cache.get('traffic:current');
  if (cached) {
    return res.status(200).json(cached);
  }

  // Fetch fresh data from traffic APIs
  const traffic = await fetchTraffic();

  // Cache in memory/KV
  await cache.set('traffic:current', traffic, cache.TTL.TRAFFIC);

  // Persist to Firestore for history / cron updates (non-blocking)
  setDoc('traffic_cache', 'current', traffic).catch((err) => {
    log.warn('Firestore traffic write failed', { error: err.message });
  });

  res.status(200).json(traffic);
}, { methods: ['GET'], cacheControl: 'TRAFFIC' });
