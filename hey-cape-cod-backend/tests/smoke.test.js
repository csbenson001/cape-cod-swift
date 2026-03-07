/**
 * Smoke tests for staging deployment.
 * Run against a deployed environment to verify basic functionality.
 *
 * Usage: STAGING_URL=https://staging-xxx.vercel.app node tests/smoke.test.js
 */

const BASE_URL = process.env.STAGING_URL || 'http://localhost:3000';

async function runSmokeTests() {
  const results = [];
  let passed = 0;
  let failed = 0;

  async function test(name, fn) {
    try {
      await fn();
      results.push({ name, status: 'PASS' });
      passed++;
      console.log(`  PASS  ${name}`);
    } catch (err) {
      results.push({ name, status: 'FAIL', error: err.message });
      failed++;
      console.error(`  FAIL  ${name}: ${err.message}`);
    }
  }

  console.log(`\nSmoke tests against: ${BASE_URL}\n`);

  // --- Health Check ---
  await test('GET /api/health returns 200', async () => {
    const res = await fetch(`${BASE_URL}/api/health`);
    assert(res.ok, `Expected 200, got ${res.status}`);
    const data = await res.json();
    assert(data.status === 'ok' || data.status === 'degraded', `Unexpected status: ${data.status}`);
    assert(data.version, 'Missing version');
    assert(data.timestamp, 'Missing timestamp');
  });

  // --- POIs ---
  await test('GET /api/pois returns POI list', async () => {
    const res = await fetch(`${BASE_URL}/api/pois`);
    assert(res.ok, `Expected 200, got ${res.status}`);
    const data = await res.json();
    assert(Array.isArray(data.pois), 'Expected pois array');
    assert(data.count >= 0, 'Expected count');
  });

  await test('GET /api/pois?category=beach filters correctly', async () => {
    const res = await fetch(`${BASE_URL}/api/pois?category=beach`);
    assert(res.ok, `Expected 200, got ${res.status}`);
    const data = await res.json();
    for (const poi of data.pois) {
      assert(poi.category === 'beach', `Expected beach, got ${poi.category}`);
    }
  });

  await test('GET /api/pois/nearby requires lat/lng', async () => {
    const res = await fetch(`${BASE_URL}/api/pois/nearby`);
    assert(res.status === 400, `Expected 400, got ${res.status}`);
  });

  await test('GET /api/pois/nearby returns nearby POIs', async () => {
    const res = await fetch(`${BASE_URL}/api/pois/nearby?lat=41.7003&lng=-70.3002&radius=20000`);
    assert(res.ok, `Expected 200, got ${res.status}`);
    const data = await res.json();
    assert(Array.isArray(data.pois), 'Expected pois array');
  });

  // --- Stories ---
  await test('GET /api/stories returns story list', async () => {
    const res = await fetch(`${BASE_URL}/api/stories`);
    assert(res.ok, `Expected 200, got ${res.status}`);
    const data = await res.json();
    assert(Array.isArray(data.stories), 'Expected stories array');
  });

  // --- Weather ---
  await test('GET /api/weather returns weather data', async () => {
    const res = await fetch(`${BASE_URL}/api/weather`);
    assert(res.ok, `Expected 200, got ${res.status}`);
    const data = await res.json();
    assert(data.current || data.fetchedAt, 'Expected weather data');
  });

  // --- Tides ---
  await test('GET /api/weather/tides returns tide data', async () => {
    const res = await fetch(`${BASE_URL}/api/weather/tides`);
    assert(res.ok, `Expected 200, got ${res.status}`);
    const data = await res.json();
    assert(data.predictions || data.stationId, 'Expected tide data');
  });

  // --- Traffic ---
  await test('GET /api/traffic returns traffic data', async () => {
    const res = await fetch(`${BASE_URL}/api/traffic`);
    assert(res.ok, `Expected 200, got ${res.status}`);
    const data = await res.json();
    assert(data.bridges || data.routes, 'Expected traffic data');
  });

  // --- Auth Required Endpoints ---
  await test('POST /api/chat returns 401 without auth', async () => {
    const res = await fetch(`${BASE_URL}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: 'test' }),
    });
    assert(res.status === 401, `Expected 401, got ${res.status}`);
  });

  await test('GET /api/user/profile returns 401 without auth', async () => {
    const res = await fetch(`${BASE_URL}/api/user/profile`);
    assert(res.status === 401, `Expected 401, got ${res.status}`);
  });

  await test('GET /api/user/usage returns 401 without auth', async () => {
    const res = await fetch(`${BASE_URL}/api/user/usage`);
    assert(res.status === 401, `Expected 401, got ${res.status}`);
  });

  // --- Security Headers ---
  await test('Response includes security headers', async () => {
    const res = await fetch(`${BASE_URL}/api/health`);
    assert(res.headers.get('x-content-type-options') === 'nosniff', 'Missing X-Content-Type-Options');
    assert(res.headers.get('x-frame-options') === 'DENY', 'Missing X-Frame-Options');
    assert(res.headers.get('x-request-id'), 'Missing X-Request-Id');
  });

  // --- Rate Limit Headers ---
  await test('Response includes rate limit headers', async () => {
    const res = await fetch(`${BASE_URL}/api/health`);
    assert(res.headers.get('x-ratelimit-limit'), 'Missing X-RateLimit-Limit');
    assert(res.headers.get('x-ratelimit-remaining'), 'Missing X-RateLimit-Remaining');
  });

  // --- Cache-Control Headers ---
  await test('Weather has Cache-Control header', async () => {
    const res = await fetch(`${BASE_URL}/api/weather`);
    const cc = res.headers.get('cache-control');
    assert(cc && cc.includes('max-age'), `Expected Cache-Control, got: ${cc}`);
  });

  // --- Summary ---
  console.log(`\n${'='.repeat(50)}`);
  console.log(`Results: ${passed} passed, ${failed} failed, ${results.length} total`);
  console.log('='.repeat(50));

  if (failed > 0) {
    console.error('\nFailed tests:');
    for (const r of results.filter((r) => r.status === 'FAIL')) {
      console.error(`  - ${r.name}: ${r.error}`);
    }
    process.exit(1);
  }

  console.log('\nAll smoke tests passed!');
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

runSmokeTests().catch((err) => {
  console.error('Smoke test runner failed:', err);
  process.exit(1);
});
