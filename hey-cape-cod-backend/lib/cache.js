/**
 * Simple in-memory cache with TTL support.
 * Falls back to this when Vercel KV is unavailable.
 */
const store = new Map();

/**
 * Get a cached value. Returns null if expired or missing.
 */
function get(key) {
  const entry = store.get(key);
  if (!entry) return null;
  if (Date.now() > entry.expiresAt) {
    store.delete(key);
    return null;
  }
  return entry.value;
}

/**
 * Set a cached value with TTL in seconds.
 */
function set(key, value, ttlSeconds) {
  store.set(key, {
    value,
    expiresAt: Date.now() + ttlSeconds * 1000,
  });
}

/**
 * Delete a cached value.
 */
function del(key) {
  store.delete(key);
}

/**
 * Clear all cached values.
 */
function clear() {
  store.clear();
}

// TTL presets (seconds)
const TTL = {
  TRAFFIC: 5 * 60,        // 5 minutes
  WEATHER: 15 * 60,       // 15 minutes
  TIDES: 24 * 60 * 60,    // 24 hours
  POI_LIST: 60 * 60,      // 1 hour
  POI_DETAIL: 60 * 60,    // 1 hour
};

module.exports = { get, set, del, clear, TTL };
