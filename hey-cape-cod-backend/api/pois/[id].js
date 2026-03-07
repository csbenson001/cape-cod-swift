const { getDoc, queryDocs } = require('../../lib/firestore');
const cache = require('../../lib/cache');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { id } = req.query;
    const cacheKey = `poi:${id}`;

    const cached = cache.get(cacheKey);
    if (cached) {
      return res.status(200).json(cached);
    }

    const poi = await getDoc('pois', id);
    if (!poi) {
      return res.status(404).json({ error: 'POI not found' });
    }

    // Fetch embedded stories
    const stories = poi.storyIds && poi.storyIds.length > 0
      ? await queryDocs('stories', [
          { field: 'poiId', op: '==', value: id },
          { field: 'isActive', op: '==', value: true },
        ], { orderBy: 'sortOrder' })
      : [];

    const response = { ...poi, stories };
    cache.set(cacheKey, response, cache.TTL.POI_DETAIL);

    res.status(200).json(response);
  } catch (err) {
    console.error('[api/pois/[id]] Error:', err);
    res.status(500).json({ error: 'Failed to fetch POI' });
  }
};
