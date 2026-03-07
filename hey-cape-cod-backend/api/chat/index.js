const { verifyAuth } = require('../../lib/auth-middleware');
const { chatCompletion } = require('../../lib/openai-client');
const { getDoc, updateDoc, queryDocs } = require('../../lib/firestore');
const { admin } = require('../../lib/firebase-admin');

const FREE_TIER_CONVERSATIONS_PER_DAY = 10;

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const uid = await verifyAuth(req, res);
  if (!uid) return; // 401 already sent

  try {
    const { message, mode = 'adult', location, history = [] } = req.body;

    if (!message || typeof message !== 'string') {
      return res.status(400).json({ error: 'message is required' });
    }

    // Check usage limits for free tier
    const user = await getDoc('users', uid);
    if (user && !user.isPremium) {
      const today = new Date().toDateString();
      const lastReset = user.lastUsageReset?.toDate?.()?.toDateString?.() || '';

      let conversationsToday = user.conversationsToday || 0;
      if (lastReset !== today) {
        conversationsToday = 0;
      }

      if (conversationsToday >= FREE_TIER_CONVERSATIONS_PER_DAY) {
        return res.status(429).json({
          error: 'Daily conversation limit reached',
          limit: FREE_TIER_CONVERSATIONS_PER_DAY,
          upgradeUrl: 'heycapecod://upgrade',
        });
      }
    }

    // Fetch nearby POIs for context if location provided
    let nearbyPois = [];
    if (location?.lat && location?.lng) {
      const allPois = await queryDocs('pois', [
        { field: 'isActive', op: '==', value: true },
      ]);
      nearbyPois = allPois
        .map((p) => ({
          ...p,
          dist: haversineDistance(location.lat, location.lng, p.latitude, p.longitude),
        }))
        .filter((p) => p.dist < 5000)
        .sort((a, b) => a.dist - b.dist)
        .slice(0, 5);
    }

    // Generate response
    const result = await chatCompletion(message, mode, nearbyPois, history);

    // Track usage
    const today = new Date().toDateString();
    const lastReset = user?.lastUsageReset?.toDate?.()?.toDateString?.() || '';
    const currentCount = lastReset === today ? (user?.conversationsToday || 0) : 0;

    await updateDoc('users', uid, {
      conversationsToday: currentCount + 1,
      lastUsageReset: admin.firestore.FieldValue.serverTimestamp(),
    }).catch(() => {}); // Non-blocking

    res.status(200).json(result);
  } catch (err) {
    console.error('[api/chat] Error:', err);
    res.status(500).json({ error: 'Failed to generate response' });
  }
};

function haversineDistance(lat1, lng1, lat2, lng2) {
  const R = 6371000;
  const toRad = (deg) => (deg * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a = Math.sin(dLat / 2) ** 2 + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
