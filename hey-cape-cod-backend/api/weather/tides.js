const { withMiddleware } = require('../../lib/middleware');
const { fetchTides } = require('../../lib/tide-client');
const cache = require('../../lib/cache');

module.exports = withMiddleware(async (req, res, log) => {
  const station = req.query.station || '8447930';

  // Validate station ID is numeric
  if (!/^\d{7}$/.test(station)) {
    return res.status(400).json({ error: 'Invalid station ID' });
  }

  const cacheKey = `tides:${station}`;

  const cached = await cache.get(cacheKey);
  if (cached) {
    return res.status(200).json(cached);
  }

  const tides = await fetchTides(station);
  await cache.set(cacheKey, tides, cache.TTL.TIDES);

  res.status(200).json(tides);
}, { methods: ['GET'], cacheControl: 'TIDES' });
