const { withMiddleware } = require('../../lib/middleware');
const { getDoc } = require('../../lib/firestore');

const LIMITS = {
  free: {
    conversationsPerDay: 10,
    storiesPerDay: 20,
    voiceMinutesPerDay: 3,
  },
  premium: {
    conversationsPerDay: -1, // unlimited
    storiesPerDay: -1,
    voiceMinutesPerDay: -1,
  },
};

module.exports = withMiddleware(async (req, res, log) => {
  const uid = req.uid;
  const user = await getDoc('users', uid);

  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  const today = new Date().toDateString();
  const lastReset = user.lastUsageReset?.toDate?.()?.toDateString?.() || '';
  const isNewDay = lastReset !== today;

  const tier = user.isPremium ? 'premium' : 'free';
  const limits = LIMITS[tier];

  const conversationsToday = isNewDay ? 0 : (user.conversationsToday || 0);
  const storiesPlayedToday = isNewDay ? 0 : (user.storiesPlayedToday || 0);

  res.status(200).json({
    tier,
    isPremium: user.isPremium,
    usage: {
      conversationsToday,
      storiesPlayedToday,
    },
    limits,
    remaining: {
      conversations: limits.conversationsPerDay === -1
        ? -1
        : Math.max(0, limits.conversationsPerDay - conversationsToday),
      stories: limits.storiesPerDay === -1
        ? -1
        : Math.max(0, limits.storiesPerDay - storiesPlayedToday),
    },
  });
}, { auth: true, methods: ['GET'], cacheControl: 'PRIVATE' });
