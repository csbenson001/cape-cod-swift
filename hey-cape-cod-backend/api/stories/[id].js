const { withMiddleware } = require('../../lib/middleware');
const { getDoc } = require('../../lib/firestore');
const cache = require('../../lib/cache');
const { incrementMetric } = require('../../lib/metrics');

module.exports = withMiddleware(async (req, res, log) => {
  const { id } = req.query;

  if (!id || typeof id !== 'string') {
    return res.status(400).json({ error: 'Story ID is required' });
  }

  const cacheKey = `story:${id}`;
  const cached = await cache.get(cacheKey);
  if (cached) {
    incrementMetric('storiesPlayed').catch(() => {});
    return res.status(200).json(cached);
  }

  const story = await getDoc('stories', id);
  if (!story) {
    return res.status(404).json({ error: 'Story not found' });
  }

  await cache.set(cacheKey, story, cache.TTL.POI_DETAIL);
  incrementMetric('storiesPlayed').catch(() => {});

  res.status(200).json(story);
}, { methods: ['GET'], cacheControl: 'POI_DETAIL' });
