const { queryDocs } = require('../../lib/firestore');
const cache = require('../../lib/cache');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { category, town, limit = '50', offset = '0' } = req.query;
    const cacheKey = `pois:${category || 'all'}:${town || 'all'}:${limit}:${offset}`;

    const cached = cache.get(cacheKey);
    if (cached) {
      return res.status(200).json(cached);
    }

    const filters = [];
    if (category) filters.push({ field: 'category', op: '==', value: category });
    if (town) filters.push({ field: 'town', op: '==', value: town });
    filters.push({ field: 'isActive', op: '==', value: true });

    const pois = await queryDocs('pois', filters, {
      limit: parseInt(limit, 10),
      offset: parseInt(offset, 10),
      orderBy: 'priority',
      orderDir: 'desc',
    });

    // Strip full story scripts from list responses — just return metadata
    const summary = pois.map(({ id, name, description, latitude, longitude, radius, category, town, address, imageUrl, storyIds, facts, tips, priority }) => ({
      id, name, description, latitude, longitude, radius, category, town, address, imageUrl,
      storyCount: (storyIds || []).length,
      facts, tips, priority,
    }));

    const response = { pois: summary, count: summary.length };
    cache.set(cacheKey, response, cache.TTL.POI_LIST);

    res.status(200).json(response);
  } catch (err) {
    console.error('[api/pois] Error:', err);
    res.status(500).json({ error: 'Failed to fetch POIs' });
  }
};
