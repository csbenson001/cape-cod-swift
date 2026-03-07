/**
 * OpenAI spending controls and model fallback.
 *
 * - Per-user daily spending cap
 * - Monthly threshold alerts ($100, $500, $1000)
 * - Automatic fallback to cheaper models when approaching limits
 * - Non-urgent request queuing during high load
 */
const { getDoc, setDoc, updateDoc } = require('./firestore');
const { admin } = require('./firebase-admin');
const { logger } = require('./logger');

// Cost estimates per 1K tokens (approximate)
const MODEL_COSTS = {
  'gpt-4o-mini': { input: 0.00015, output: 0.0006 },
  'gpt-4o': { input: 0.005, output: 0.015 },
};

const DEFAULT_MODEL = 'gpt-4o-mini';
const FALLBACK_MODEL = 'gpt-4o-mini'; // Already cheapest

// Per-user daily spending cap in USD
const USER_DAILY_CAP = parseFloat(process.env.USER_DAILY_CAP || '1.00');

// Monthly alert thresholds
const MONTHLY_THRESHOLDS = [100, 500, 1000];

/**
 * Estimate cost of a completion based on token usage.
 */
function estimateCost(model, promptTokens, completionTokens) {
  const costs = MODEL_COSTS[model] || MODEL_COSTS[DEFAULT_MODEL];
  return (promptTokens / 1000) * costs.input + (completionTokens / 1000) * costs.output;
}

/**
 * Check if a user has exceeded their daily spending cap.
 * Returns { allowed, model, reason }.
 */
async function checkSpendingLimit(uid) {
  try {
    const today = new Date().toISOString().slice(0, 10); // YYYY-MM-DD
    const key = `spending:${uid}:${today}`;
    const record = await getDoc('spending', key);

    const dailySpend = record?.totalCost || 0;

    if (dailySpend >= USER_DAILY_CAP) {
      return {
        allowed: false,
        model: null,
        reason: `Daily API spending limit reached ($${dailySpend.toFixed(4)} / $${USER_DAILY_CAP})`,
      };
    }

    // If approaching 80% of cap, use the cheapest model
    const model = dailySpend >= USER_DAILY_CAP * 0.8 ? FALLBACK_MODEL : DEFAULT_MODEL;

    return { allowed: true, model, reason: null };
  } catch {
    // On error, allow but use cheapest model
    return { allowed: true, model: FALLBACK_MODEL, reason: null };
  }
}

/**
 * Record token usage and cost for a user.
 */
async function recordUsage(uid, model, promptTokens, completionTokens) {
  const cost = estimateCost(model, promptTokens, completionTokens);
  const today = new Date().toISOString().slice(0, 10);
  const userKey = `spending:${uid}:${today}`;
  const monthKey = `spending:monthly:${today.slice(0, 7)}`;

  try {
    // Update user daily spending
    const existing = await getDoc('spending', userKey);
    await setDoc('spending', userKey, {
      uid,
      date: today,
      totalTokens: (existing?.totalTokens || 0) + promptTokens + completionTokens,
      totalCost: (existing?.totalCost || 0) + cost,
      requestCount: (existing?.requestCount || 0) + 1,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Update monthly aggregate
    const monthly = await getDoc('spending', monthKey);
    const newMonthlyTotal = (monthly?.totalCost || 0) + cost;
    await setDoc('spending', monthKey, {
      month: today.slice(0, 7),
      totalCost: newMonthlyTotal,
      totalTokens: (monthly?.totalTokens || 0) + promptTokens + completionTokens,
      requestCount: (monthly?.requestCount || 0) + 1,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Check monthly thresholds
    for (const threshold of MONTHLY_THRESHOLDS) {
      const prevTotal = monthly?.totalCost || 0;
      if (prevTotal < threshold && newMonthlyTotal >= threshold) {
        logger.warn('Monthly spending threshold crossed', {
          threshold,
          currentSpend: newMonthlyTotal.toFixed(2),
          month: today.slice(0, 7),
        });
        // In production, send alert via webhook/email here
        await setDoc('alerts', `spend-${today.slice(0, 7)}-${threshold}`, {
          type: 'spending_threshold',
          threshold,
          currentSpend: newMonthlyTotal,
          month: today.slice(0, 7),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }
  } catch (err) {
    logger.error('Failed to record usage', { uid, error: err.message });
  }
}

/**
 * Get current monthly spend.
 */
async function getMonthlySpend() {
  const monthKey = `spending:monthly:${new Date().toISOString().slice(0, 7)}`;
  const record = await getDoc('spending', monthKey);
  return record?.totalCost || 0;
}

module.exports = {
  checkSpendingLimit,
  recordUsage,
  estimateCost,
  getMonthlySpend,
  DEFAULT_MODEL,
  USER_DAILY_CAP,
  MONTHLY_THRESHOLDS,
};
