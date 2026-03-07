/**
 * Usage metrics tracking.
 *
 * Tracks:
 * - Daily active users (DAU)
 * - Conversations started
 * - Stories played
 * - Premium conversions
 * - Voice session minutes
 *
 * Stored in Firestore `metrics` collection, keyed by date.
 */
const { getDoc, setDoc } = require('./firestore');
const { admin } = require('./firebase-admin');
const { logger } = require('./logger');

function todayKey() {
  return new Date().toISOString().slice(0, 10);
}

/**
 * Increment a metric counter for today.
 */
async function incrementMetric(name, amount = 1) {
  const key = `daily:${todayKey()}`;
  try {
    await setDoc('metrics', key, {
      date: todayKey(),
      [name]: admin.firestore.FieldValue.increment(amount),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (err) {
    logger.error('Failed to increment metric', { metric: name, error: err.message });
  }
}

/**
 * Track a unique daily active user.
 */
async function trackActiveUser(uid) {
  if (!uid) return;
  const key = `dau:${todayKey()}`;
  try {
    await setDoc('metrics', key, {
      date: todayKey(),
      users: admin.firestore.FieldValue.arrayUnion(uid),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (err) {
    logger.error('Failed to track DAU', { uid, error: err.message });
  }
}

/**
 * Record a voice session duration in seconds.
 */
async function recordVoiceSession(uid, durationSeconds) {
  await incrementMetric('voiceSessionsStarted');
  await incrementMetric('voiceMinutesTotal', Math.round(durationSeconds / 60));

  // Per-user tracking
  try {
    const userKey = `voice:${uid}:${todayKey()}`;
    await setDoc('metrics', userKey, {
      uid,
      date: todayKey(),
      totalSeconds: admin.firestore.FieldValue.increment(durationSeconds),
      sessionCount: admin.firestore.FieldValue.increment(1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (err) {
    logger.error('Failed to record voice session', { uid, error: err.message });
  }
}

/**
 * Get today's metrics summary.
 */
async function getTodayMetrics() {
  const key = `daily:${todayKey()}`;
  const dauKey = `dau:${todayKey()}`;

  const [metrics, dau] = await Promise.all([
    getDoc('metrics', key),
    getDoc('metrics', dauKey),
  ]);

  return {
    date: todayKey(),
    dailyActiveUsers: dau?.users?.length || 0,
    conversationsStarted: metrics?.conversationsStarted || 0,
    storiesPlayed: metrics?.storiesPlayed || 0,
    premiumConversions: metrics?.premiumConversions || 0,
    voiceSessionsStarted: metrics?.voiceSessionsStarted || 0,
    voiceMinutesTotal: metrics?.voiceMinutesTotal || 0,
  };
}

module.exports = {
  incrementMetric,
  trackActiveUser,
  recordVoiceSession,
  getTodayMetrics,
};
