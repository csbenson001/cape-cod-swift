const { withMiddleware } = require('../../lib/middleware');
const { queryDocs } = require('../../lib/firestore');
const cache = require('../../lib/cache');

module.exports = withMiddleware(async (req, res, log) => {
  const { category, town, limit = '50', offset = '0' } = req.query;

  const parsedLimit = Math.min(parseInt(limit, 10) || 50, 100);
  const parsedOffset = parseInt(offset, 10) || 0;

  const cacheKey = `pois:${category || 'all'}:${town || 'all'}:${parsedLimit}:${parsedOffset}`;

  const cached = await cache.get(cacheKey);
  if (cached) {
    return res.status(200).json(cached);
  }

  const filters = [];
  if (category) filters.push({ field: 'category', op: '==', value: category });
  if (town) filters.push({ field: 'town', op: '==', value: town });
  filters.push({ field: 'isActive', op: '==', value: true });

  const pois = await queryDocs('pois', filters, {
    limit: parsedLimit,
    offset: parsedOffset,
    orderBy: 'priority',
    orderDir: 'desc',
  });

  const summary = pois.map(({ id, name, description, latitude, longitude, radius, category, town, address, imageUrl, storyIds, facts, tips, priority }) => ({
    id, name, description, latitude, longitude, radius, category, town, address, imageUrl,
    storyCount: (storyIds || []).length,
    facts, tips, priority,
  }));

  const response = { pois: summary, count: summary.length };
  await cache.set(cacheKey, response, cache.TTL.POI_LIST);

  res.status(200).json(response);
}, { methods: ['GET'], cacheControl: 'POI_LIST' });
