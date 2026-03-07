/**
 * Cache layer with Vercel KV (Redis) support and in-memory fallback.
 *
 * Automatically uses Vercel KV when KV_REST_API_URL is set,
 * otherwise falls back to in-memory Map with TTL.
 */
let kv;

try {
  if (process.env.KV_REST_API_URL) {
    kv = require('@vercel/kv');
  }
} catch {
  // Vercel KV not available, use in-memory fallback
}

// In-memory fallback store
const memStore = new Map();

/**
 * Get a cached value. Returns null if expired or missing.
 */
async function get(key) {
  if (kv) {
    try {
      return await kv.get(key);
    } catch {
      return memGet(key);
    }
  }
  return memGet(key);
}

/**
 * Set a cached value with TTL in seconds.
 */
async function set(key, value, ttlSeconds) {
  if (kv) {
    try {
      await kv.set(key, value, { ex: ttlSeconds });
      return;
    } catch {
      // Fall through to in-memory
    }
  }
  memSet(key, value, ttlSeconds);
}

/**
 * Delete a cached value.
 */
async function del(key) {
  if (kv) {
    try {
      await kv.del(key);
    } catch {
      // ignore
    }
  }
  memStore.delete(key);
}

/**
 * Clear all cached values (in-memory only; KV requires explicit key deletion).
 */
function clear() {
  memStore.clear();
}

// In-memory helpers
function memGet(key) {
  const entry = memStore.get(key);
  if (!entry) return null;
  if (Date.now() > entry.expiresAt) {
    memStore.delete(key);
    return null;
  }
  return entry.value;
}

function memSet(key, value, ttlSeconds) {
  memStore.set(key, {
    value,
    expiresAt: Date.now() + ttlSeconds * 1000,
  });
}

// TTL presets (seconds)
const TTL = {
  TRAFFIC: 5 * 60,        // 5 minutes
  WEATHER: 15 * 60,       // 15 minutes
  TIDES: 24 * 60 * 60,    // 24 hours
  POI_LIST: 60 * 60,      // 1 hour
  POI_DETAIL: 60 * 60,    // 1 hour
};

// Cache-Control header values
const CACHE_CONTROL = {
  TRAFFIC: 'public, max-age=300, stale-while-revalidate=60',
  WEATHER: 'public, max-age=900, stale-while-revalidate=120',
  TIDES: 'public, max-age=86400, stale-while-revalidate=3600',
  POI_LIST: 'public, max-age=3600, stale-while-revalidate=600',
  POI_DETAIL: 'public, max-age=3600, stale-while-revalidate=600',
  PRIVATE: 'private, no-cache',
  NONE: 'no-store',
};

module.exports = { get, set, del, clear, TTL, CACHE_CONTROL };
