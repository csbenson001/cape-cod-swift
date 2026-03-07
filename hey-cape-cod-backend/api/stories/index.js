const { queryDocs } = require('../../lib/firestore');
const cache = require('../../lib/cache');

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { mode, category, limit = '50', offset = '0' } = req.query;
    const cacheKey = `stories:${mode || 'all'}:${category || 'all'}:${limit}:${offset}`;

    const cached = cache.get(cacheKey);
    if (cached) {
      return res.status(200).json(cached);
    }

    const filters = [{ field: 'isActive', op: '==', value: true }];
    if (mode) filters.push({ field: 'mode', op: '==', value: mode });
    if (category) filters.push({ field: 'category', op: '==', value: category });

    const stories = await queryDocs('stories', filters, {
      limit: parseInt(limit, 10),
      offset: parseInt(offset, 10),
      orderBy: 'sortOrder',
    });

    // Return metadata without full scripts for listing
    const summary = stories.map(({ id, poiId, title, mode: m, category: c, durationSeconds, isPremium, narratorVoice, tags, sortOrder }) => ({
      id, poiId, title, mode: m, category: c, durationSeconds, isPremium, narratorVoice, tags, sortOrder,
    }));

    const response = { stories: summary, count: summary.length };
    cache.set(cacheKey, response, cache.TTL.POI_LIST);

    res.status(200).json(response);
  } catch (err) {
    console.error('[api/stories] Error:', err);
    res.status(500).json({ error: 'Failed to fetch stories' });
  }
};
