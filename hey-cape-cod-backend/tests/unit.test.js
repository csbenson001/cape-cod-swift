const { describe, it } = require('node:test');
const assert = require('node:assert');

// --- Security Tests ---

describe('Security', () => {
  const { sanitizeString, sanitizeInput } = require('../lib/security');

  it('strips HTML tags from strings', () => {
    assert.strictEqual(sanitizeString('<script>alert("xss")</script>hello'), 'hello');
    assert.strictEqual(sanitizeString('<b>bold</b>'), 'bold');
    assert.strictEqual(sanitizeString('normal text'), 'normal text');
  });

  it('trims whitespace', () => {
    assert.strictEqual(sanitizeString('  hello  '), 'hello');
  });

  it('handles non-string values', () => {
    assert.strictEqual(sanitizeString(42), 42);
    assert.strictEqual(sanitizeString(null), null);
    assert.strictEqual(sanitizeString(undefined), undefined);
  });

  it('recursively sanitizes objects', () => {
    const input = {
      name: '<script>bad</script>John',
      nested: { value: '<b>bold</b>' },
      array: ['<i>item</i>', 'clean'],
    };
    const result = sanitizeInput(input);
    assert.strictEqual(result.name, 'John');
    assert.strictEqual(result.nested.value, 'bold');
    assert.deepStrictEqual(result.array, ['item', 'clean']);
  });
});

// --- Rate Limiter Tests ---

describe('Rate Limiter', () => {
  const { trackWsConnection, releaseWsConnection, getWsConnectionCount, MAX_WS_CONNECTIONS } = require('../lib/rate-limiter');

  it('tracks WebSocket connections', () => {
    const uid = 'test-ws-user';
    assert.strictEqual(getWsConnectionCount(uid), 0);
    assert.strictEqual(trackWsConnection(uid), true);
    assert.strictEqual(getWsConnectionCount(uid), 1);
    releaseWsConnection(uid);
    assert.strictEqual(getWsConnectionCount(uid), 0);
  });

  it('enforces max WebSocket connections', () => {
    const uid = 'test-ws-limit';
    for (let i = 0; i < MAX_WS_CONNECTIONS; i++) {
      assert.strictEqual(trackWsConnection(uid), true);
    }
    assert.strictEqual(trackWsConnection(uid), false);

    // Cleanup
    for (let i = 0; i < MAX_WS_CONNECTIONS; i++) {
      releaseWsConnection(uid);
    }
  });

  it('has correct limits', () => {
    assert.strictEqual(MAX_WS_CONNECTIONS, 5);
  });
});

// --- Logger Tests ---

describe('Logger', () => {
  const { createRequestLogger, getCorrelationId } = require('../lib/logger');

  it('generates correlation ID when none provided', () => {
    const req = { headers: {} };
    const id = getCorrelationId(req);
    assert.ok(id);
    assert.ok(typeof id === 'string');
    assert.ok(id.length > 0);
  });

  it('uses existing correlation ID from header', () => {
    const req = { headers: { 'x-request-id': 'test-123' } };
    assert.strictEqual(getCorrelationId(req), 'test-123');
  });

  it('creates request-scoped logger', () => {
    const req = { headers: {}, url: '/test' };
    const log = createRequestLogger(req);
    assert.ok(log.info);
    assert.ok(log.warn);
    assert.ok(log.error);
    assert.ok(log.debug);
    assert.ok(req.correlationId);
  });
});

// --- Cost Controls Tests ---

describe('Cost Controls', () => {
  const { estimateCost, DEFAULT_MODEL, USER_DAILY_CAP, MONTHLY_THRESHOLDS } = require('../lib/cost-controls');

  it('estimates cost for gpt-4o-mini', () => {
    const cost = estimateCost('gpt-4o-mini', 1000, 500);
    assert.ok(cost > 0);
    // 1000 * 0.00015 + 500 * 0.0006 = 0.15 + 0.30 = 0.45
    assert.strictEqual(cost, 0.00015 * 1 + 0.0006 * 0.5);
  });

  it('has sane defaults', () => {
    assert.strictEqual(DEFAULT_MODEL, 'gpt-4o-mini');
    assert.ok(USER_DAILY_CAP > 0);
    assert.deepStrictEqual(MONTHLY_THRESHOLDS, [100, 500, 1000]);
  });
});

// --- Cache Tests ---

describe('Cache', () => {
  const cache = require('../lib/cache');

  it('has correct TTL presets', () => {
    assert.strictEqual(cache.TTL.TRAFFIC, 300);
    assert.strictEqual(cache.TTL.WEATHER, 900);
    assert.strictEqual(cache.TTL.TIDES, 86400);
    assert.strictEqual(cache.TTL.POI_LIST, 3600);
    assert.strictEqual(cache.TTL.POI_DETAIL, 3600);
  });

  it('has Cache-Control presets', () => {
    assert.ok(cache.CACHE_CONTROL.TRAFFIC.includes('max-age=300'));
    assert.ok(cache.CACHE_CONTROL.WEATHER.includes('max-age=900'));
    assert.ok(cache.CACHE_CONTROL.TIDES.includes('max-age=86400'));
    assert.ok(cache.CACHE_CONTROL.PRIVATE.includes('private'));
    assert.ok(cache.CACHE_CONTROL.NONE.includes('no-store'));
  });

  it('stores and retrieves values in memory', async () => {
    await cache.set('test-key', { hello: 'world' }, 60);
    const val = await cache.get('test-key');
    assert.deepStrictEqual(val, { hello: 'world' });
    await cache.del('test-key');
    const deleted = await cache.get('test-key');
    assert.strictEqual(deleted, null);
  });
});

// --- Voice Relay Tests ---

describe('Voice Relay', () => {
  const { IDLE_TIMEOUT_MS, MAX_SESSION_MS, getActiveSessionCount } = require('../lib/voice-relay');

  it('has correct timeout values', () => {
    assert.strictEqual(IDLE_TIMEOUT_MS, 10 * 60 * 1000);
    assert.strictEqual(MAX_SESSION_MS, 15 * 60 * 1000);
  });

  it('reports zero active sessions initially', () => {
    assert.strictEqual(getActiveSessionCount(), 0);
  });
});
