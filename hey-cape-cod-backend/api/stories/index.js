const { withMiddleware } = require('../../lib/middleware');
const { queryDocs } = require('../../lib/firestore');
const cache = require('../../lib/cache');
const { incrementMetric } = require('../../lib/metrics');

module.exports = withMiddleware(async (req, res, log) => {
  const { mode, category, limit = '20', offset = '0' } = req.query;

  const parsedLimit = Math.min(parseInt(limit, 10) || 20, 50);
  const parsedOffset = parseInt(offset, 10) || 0;

  const cacheKey = `stories:${mode || 'all'}:${category || 'all'}:${parsedLimit}:${parsedOffset}`;

  const cached = await cache.get(cacheKey);
  if (cached) {
    return res.status(200).json(cached);
  }

  const filters = [{ field: 'isActive', op: '==', value: true }];
  if (mode) filters.push({ field: 'mode', op: '==', value: mode });
  if (category) filters.push({ field: 'category', op: '==', value: category });

  const stories = await queryDocs('stories', filters, {
    limit: parsedLimit,
    offset: parsedOffset,
    orderBy: 'sortOrder',
    orderDir: 'asc',
  });

  // Strip scripts from list responses
  const summary = stories.map(({ id, poiId, title, mode, category, durationSeconds, isPremium, narratorVoice, tags, sortOrder }) => ({
    id, poiId, title, mode, category, durationSeconds, isPremium, narratorVoice, tags, sortOrder,
  }));

  const response = { stories: summary, count: summary.length };
  await cache.set(cacheKey, response, cache.TTL.POI_LIST);

  res.status(200).json(response);
}, { methods: ['GET'], cacheControl: 'POI_LIST' });
