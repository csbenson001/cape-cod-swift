const { getDoc } = require('../../lib/firestore');
const cache = require('../../lib/cache');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { id } = req.query;
    const cacheKey = `story:${id}`;

    const cached = cache.get(cacheKey);
    if (cached) {
      return res.status(200).json(cached);
    }

    const story = await getDoc('stories', id);
    if (!story) {
      return res.status(404).json({ error: 'Story not found' });
    }

    cache.set(cacheKey, story, cache.TTL.POI_DETAIL);
    res.status(200).json(story);
  } catch (err) {
    console.error('[api/stories/[id]] Error:', err);
    res.status(500).json({ error: 'Failed to fetch story' });
  }
};
