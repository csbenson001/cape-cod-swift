const { withMiddleware } = require('../../lib/middleware');
const { chatCompletion } = require('../../lib/openai-client');
const { getDoc, updateDoc, queryDocs } = require('../../lib/firestore');
const { admin } = require('../../lib/firebase-admin');
const { checkSpendingLimit, recordUsage } = require('../../lib/cost-controls');
const { incrementMetric } = require('../../lib/metrics');

const FREE_TIER_CONVERSATIONS_PER_DAY = 10;

module.exports = withMiddleware(async (req, res, log) => {
  const uid = req.uid;

  const { message, mode = 'adult', location, history = [] } = req.body;

  if (!message || typeof message !== 'string') {
    return res.status(400).json({ error: 'message is required' });
  }

  if (message.length > 2000) {
    return res.status(400).json({ error: 'Message too long (max 2000 characters)' });
  }

  // Check spending limits
  const spending = await checkSpendingLimit(uid);
  if (!spending.allowed) {
    log.warn('Spending limit reached', { uid, reason: spending.reason });
    return res.status(429).json({ error: spending.reason });
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
    const lat = parseFloat(location.lat);
    const lng = parseFloat(location.lng);
    if (!isNaN(lat) && !isNaN(lng)) {
      const allPois = await queryDocs('pois', [
        { field: 'isActive', op: '==', value: true },
      ]);
      nearbyPois = allPois
        .map((p) => ({
          ...p,
          dist: haversineDistance(lat, lng, p.latitude, p.longitude),
        }))
        .filter((p) => p.dist < 5000)
        .sort((a, b) => a.dist - b.dist)
        .slice(0, 5);
    }
  }

  // Generate response (use model from cost controls)
  const result = await chatCompletion(message, mode, nearbyPois, history, spending.model);

  // Track usage (non-blocking)
  const today = new Date().toDateString();
  const lastReset = user?.lastUsageReset?.toDate?.()?.toDateString?.() || '';
  const currentCount = lastReset === today ? (user?.conversationsToday || 0) : 0;

  updateDoc('users', uid, {
    conversationsToday: currentCount + 1,
    lastUsageReset: admin.firestore.FieldValue.serverTimestamp(),
  }).catch(() => {});

  recordUsage(uid, spending.model, result.usage.promptTokens, result.usage.completionTokens).catch(() => {});
  incrementMetric('conversationsStarted').catch(() => {});

  log.info('Chat completed', {
    mode,
    model: spending.model,
    tokens: result.usage.totalTokens,
  });

  res.status(200).json(result);
}, { auth: true, methods: ['POST'], cacheControl: 'NONE' });

function haversineDistance(lat1, lng1, lat2, lng2) {
  const R = 6371000;
  const toRad = (deg) => (deg * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a = Math.sin(dLat / 2) ** 2 + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}
