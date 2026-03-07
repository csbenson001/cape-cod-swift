const { fetchWeather } = require('../../lib/weather-client');
const cache = require('../../lib/cache');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Default to Cape Cod center (Barnstable)
  const lat = parseFloat(req.query.lat) || 41.7003;
  const lng = parseFloat(req.query.lng) || -70.3002;

  const cacheKey = `weather:${lat.toFixed(2)}:${lng.toFixed(2)}`;

  try {
    const cached = cache.get(cacheKey);
    if (cached) {
      return res.status(200).json(cached);
    }

    const weather = await fetchWeather(lat, lng);
    cache.set(cacheKey, weather, cache.TTL.WEATHER);

    res.status(200).json(weather);
  } catch (err) {
    console.error('[api/weather] Error:', err);
    res.status(500).json({ error: 'Failed to fetch weather data' });
  }
};
