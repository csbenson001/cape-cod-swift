const { withMiddleware } = require('../../lib/middleware');
const { queryDocs } = require('../../lib/firestore');
const cache = require('../../lib/cache');

module.exports = withMiddleware(async (req, res, log) => {
  const lat = parseFloat(req.query.lat);
  const lng = parseFloat(req.query.lng);
  const radius = parseFloat(req.query.radius) || 10000;

  if (isNaN(lat) || isNaN(lng)) {
    return res.status(400).json({ error: 'lat and lng query parameters are required' });
  }

  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
    return res.status(400).json({ error: 'Invalid coordinates' });
  }

  const clampedRadius = Math.min(Math.max(radius, 100), 50000);
  const cacheKey = `pois:nearby:${lat.toFixed(3)}:${lng.toFixed(3)}:${clampedRadius}`;

  const cached = await cache.get(cacheKey);
  if (cached) {
    return res.status(200).json(cached);
  }

  // Fetch all active POIs (cached separately to avoid repeated Firestore reads)
  let allPois = await cache.get('pois:all:active');
  if (!allPois) {
    allPois = await queryDocs('pois', [
      { field: 'isActive', op: '==', value: true },
    ]);
    await cache.set('pois:all:active', allPois, cache.TTL.POI_LIST);
  }

  // Filter by distance
  const nearby = allPois
    .map((p) => {
      const dist = haversineDistance(lat, lng, p.latitude, p.longitude);
      return { ...p, distance: Math.round(dist) };
    })
    .filter((p) => p.distance <= clampedRadius)
    .sort((a, b) => a.distance - b.distance);

  // Return summary
  const summary = nearby.map(({ id, name, description, latitude, longitude, radius, category, town, address, imageUrl, storyIds, facts, tips, priority, distance }) => ({
    id, name, description, latitude, longitude, radius, category, town, address, imageUrl,
    storyCount: (storyIds || []).length,
    facts, tips, priority, distance,
  }));

  const response = { pois: summary, count: summary.length };
  await cache.set(cacheKey, response, 300); // 5 min for location-specific queries

  res.status(200).json(response);
}, { methods: ['GET'], cacheControl: 'POI_LIST' });

function haversineDistance(lat1, lng1, lat2, lng2) {
  const R = 6371000;
  const toRad = (deg) => (deg * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a = Math.sin(dLat / 2) ** 2 + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
