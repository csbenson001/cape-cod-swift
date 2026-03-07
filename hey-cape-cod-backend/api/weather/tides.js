const { fetchTides } = require('../../lib/tide-client');
const cache = require('../../lib/cache');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Default to Woods Hole station
  const station = req.query.station || '8447930';
  const cacheKey = `tides:${station}`;

  try {
    const cached = cache.get(cacheKey);
    if (cached) {
      return res.status(200).json(cached);
    }

    const tides = await fetchTides(station);
    cache.set(cacheKey, tides, cache.TTL.TIDES);

    res.status(200).json(tides);
  } catch (err) {
    console.error('[api/weather/tides] Error:', err);
    res.status(500).json({ error: 'Failed to fetch tide data' });
  }
};
