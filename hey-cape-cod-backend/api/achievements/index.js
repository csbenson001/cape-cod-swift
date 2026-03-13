const { withMiddleware } = require('../../lib/middleware');
const { getDoc, setDoc } = require('../../lib/firestore');
const { admin } = require('../../lib/firebase-admin');

const DEFAULT_ACHIEVEMENTS = {
  unlocked: [],
  metrics: {
    totalPOIsVisited: 0,
    totalStoriesPlayed: 0,
    totalToursCompleted: 0,
    regionsVisited: [],
    beachesVisited: 0,
    lighthousesVisited: 0,
    totalShares: 0,
  },
};

const MAX_UNLOCKED = 500;
const MAX_REGIONS = 50;

module.exports = withMiddleware(async (req, res, log) => {
  const uid = req.uid;

  if (req.method === 'GET') {
    return handleGet(req, res, log, uid);
  }

  if (req.method === 'PUT') {
    return handlePut(req, res, log, uid);
  }
}, { auth: true, methods: ['GET', 'PUT'], cacheControl: 'NONE' });

async function handleGet(req, res, log, uid) {
  const doc = await getDoc('achievements', uid);

  if (!doc) {
    log.info('Returning default achievements', { uid });
    return res.status(200).json({ achievements: DEFAULT_ACHIEVEMENTS });
  }

  res.status(200).json({
    achievements: {
      unlocked: doc.unlocked || [],
      metrics: doc.metrics || DEFAULT_ACHIEVEMENTS.metrics,
    },
  });
}

async function handlePut(req, res, log, uid) {
  const { unlocked, metrics } = req.body;

  // Validate unlocked
  if (unlocked !== undefined && unlocked !== null) {
    if (!Array.isArray(unlocked)) {
      return res.status(400).json({ error: 'unlocked must be an array of strings' });
    }
    if (unlocked.length > MAX_UNLOCKED) {
      return res.status(400).json({ error: `unlocked array exceeds maximum of ${MAX_UNLOCKED} entries` });
    }
    if (!unlocked.every((a) => typeof a === 'string')) {
      return res.status(400).json({ error: 'Each unlocked item must be a string' });
    }
  }

  // Validate metrics
  if (metrics !== undefined && metrics !== null) {
    if (typeof metrics !== 'object' || Array.isArray(metrics)) {
      return res.status(400).json({ error: 'metrics must be an object' });
    }

    // Validate numeric fields
    const numericFields = [
      'totalPOIsVisited', 'totalStoriesPlayed', 'totalToursCompleted',
      'beachesVisited', 'lighthousesVisited', 'totalShares',
    ];

    for (const field of numericFields) {
      if (metrics[field] !== undefined) {
        const val = metrics[field];
        if (typeof val !== 'number' || !Number.isFinite(val) || val < 0) {
          return res.status(400).json({ error: `metrics.${field} must be a non-negative number` });
        }
      }
    }

    // Validate regionsVisited
    if (metrics.regionsVisited !== undefined) {
      if (!Array.isArray(metrics.regionsVisited)) {
        return res.status(400).json({ error: 'metrics.regionsVisited must be an array of strings' });
      }
      if (metrics.regionsVisited.length > MAX_REGIONS) {
        return res.status(400).json({ error: `metrics.regionsVisited exceeds maximum of ${MAX_REGIONS} entries` });
      }
      if (!metrics.regionsVisited.every((r) => typeof r === 'string')) {
        return res.status(400).json({ error: 'Each region in metrics.regionsVisited must be a string' });
      }
    }
  }

  // Build the document to upsert
  const data = {};

  if (unlocked !== undefined && unlocked !== null) {
    data.unlocked = unlocked;
  }

  if (metrics !== undefined && metrics !== null) {
    data.metrics = metrics;
  }

  if (Object.keys(data).length === 0) {
    return res.status(400).json({ error: 'At least one of unlocked or metrics must be provided' });
  }

  data.uid = uid;
  data.updatedAt = admin.firestore.FieldValue.serverTimestamp();

  await setDoc('achievements', uid, data, true);

  log.info('Achievements updated', {
    uid,
    unlockedCount: data.unlocked?.length,
    hasMetrics: !!data.metrics,
  });

  res.status(200).json({ success: true });
}
