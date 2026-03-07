const { withMiddleware } = require('../../lib/middleware');
const { fetchWeather } = require('../../lib/weather-client');
const cache = require('../../lib/cache');

module.exports = withMiddleware(async (req, res, log) => {
  const lat = parseFloat(req.query.lat) || 41.7003;
  const lng = parseFloat(req.query.lng) || -70.3002;

  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
    return res.status(400).json({ error: 'Invalid coordinates' });
  }

  const cacheKey = `weather:${lat.toFixed(2)}:${lng.toFixed(2)}`;

  const cached = await cache.get(cacheKey);
  if (cached) {
    return res.status(200).json(cached);
  }

  const weather = await fetchWeather(lat, lng);
  await cache.set(cacheKey, weather, cache.TTL.WEATHER);

  res.status(200).json(weather);
}, { methods: ['GET'], cacheControl: 'WEATHER' });
