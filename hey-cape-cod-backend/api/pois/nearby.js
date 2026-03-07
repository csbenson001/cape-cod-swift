const { queryDocs } = require('../../lib/firestore');
const cache = require('../../lib/cache');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { lat, lng, radius = '10000' } = req.query;

  if (!lat || !lng) {
    return res.status(400).json({ error: 'lat and lng query parameters are required' });
  }

  const userLat = parseFloat(lat);
  const userLng = parseFloat(lng);
  const radiusMeters = parseFloat(radius);

  if (isNaN(userLat) || isNaN(userLng) || isNaN(radiusMeters)) {
    return res.status(400).json({ error: 'Invalid coordinate or radius values' });
  }

  try {
    // Firestore doesn't support native geo queries, so we fetch all active POIs
    // and filter by distance in memory. For Cape Cod (~60 POIs max), this is fine.
    const cacheKey = 'pois:all-active';
    let allPois = cache.get(cacheKey);

    if (!allPois) {
      allPois = await queryDocs('pois', [
        { field: 'isActive', op: '==', value: true },
      ]);
      cache.set(cacheKey, allPois, cache.TTL.POI_LIST);
    }

    // Calculate distance and filter
    const nearby = allPois
      .map((poi) => ({
        ...poi,
        distance: haversineDistance(userLat, userLng, poi.latitude, poi.longitude),
      }))
      .filter((poi) => poi.distance <= radiusMeters)
      .sort((a, b) => a.distance - b.distance);

    // Return summary (no full scripts) with distance
    const summary = nearby.map(({ id, name, description, latitude, longitude, radius: r, category, town, storyIds, facts, tips, priority, distance }) => ({
      id, name, description, latitude, longitude, radius: r, category, town,
      storyCount: (storyIds || []).length,
      facts, tips, priority,
      distance: Math.round(distance),
    }));

    res.status(200).json({ pois: summary, count: summary.length });
  } catch (err) {
    console.error('[api/pois/nearby] Error:', err);
    res.status(500).json({ error: 'Failed to fetch nearby POIs' });
  }
};

/**
 * Haversine formula: distance between two lat/lng points in meters.
 */
function haversineDistance(lat1, lng1, lat2, lng2) {
  const R = 6371000; // Earth radius in meters
  const toRad = (deg) => (deg * Math.PI) / 180;

  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLng / 2) * Math.sin(dLng / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}
