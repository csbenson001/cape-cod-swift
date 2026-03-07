const { fetchTraffic } = require('../../lib/traffic-client');
const { setDoc, getDoc } = require('../../lib/firestore');
const cache = require('../../lib/cache');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    // Check in-memory cache first
    const cached = cache.get('traffic:current');
    if (cached) {
      return res.status(200).json(cached);
    }

    // Fetch fresh data from traffic APIs
    const traffic = await fetchTraffic();

    // Cache in memory
    cache.set('traffic:current', traffic, cache.TTL.TRAFFIC);

    // Persist to Firestore for history / cron updates
    try {
      await setDoc('traffic_cache', 'current', traffic);
    } catch (dbErr) {
      console.warn('[api/traffic] Firestore write failed:', dbErr.message);
    }

    res.status(200).json(traffic);
  } catch (err) {
    console.error('[api/traffic] Error:', err);

    // Try Firestore fallback
    try {
      const fallback = await getDoc('traffic_cache', 'current');
      if (fallback) {
        return res.status(200).json({ ...fallback, isStale: true });
      }
    } catch {
      // ignore
    }

    res.status(500).json({ error: 'Failed to fetch traffic data' });
  }
};
