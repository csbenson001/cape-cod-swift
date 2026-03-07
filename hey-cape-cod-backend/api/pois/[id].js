const { withMiddleware } = require('../../lib/middleware');
const { getDoc, queryDocs } = require('../../lib/firestore');
const cache = require('../../lib/cache');

module.exports = withMiddleware(async (req, res, log) => {
  const { id } = req.query;

  if (!id || typeof id !== 'string') {
    return res.status(400).json({ error: 'POI ID is required' });
  }

  const cacheKey = `poi:${id}`;
  const cached = await cache.get(cacheKey);
  if (cached) {
    return res.status(200).json(cached);
  }

  const poi = await getDoc('pois', id);
  if (!poi) {
    return res.status(404).json({ error: 'POI not found' });
  }

  // Embed related stories
  const stories = await queryDocs('stories', [
    { field: 'poiId', op: '==', value: id },
    { field: 'isActive', op: '==', value: true },
  ], { orderBy: 'sortOrder', orderDir: 'asc' });

  const response = { ...poi, stories };
  await cache.set(cacheKey, response, cache.TTL.POI_DETAIL);

  res.status(200).json(response);
}, { methods: ['GET'], cacheControl: 'POI_DETAIL' });
