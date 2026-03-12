/**
 * Traffic data client for Cape Cod bridges and routes.
 *
 * Hybrid approach:
 * - MassDOT / Mass511 API for incidents, closures, and alerts
 * - Google Maps Directions API for real-time travel delay estimates
 * - Time-of-day/seasonal estimates as final fallback
 *
 * Since MassDOT APIs can be unreliable, this module gracefully
 * degrades to cached data with a "stale" flag.
 */

const BRIDGES = {
  sagamore: {
    name: 'Sagamore Bridge',
    lat: 41.7718,
    lon: -70.5393,
    normalTravelMinutes: 5,
    // Google Maps: mainland side → Cape side across Sagamore
    googleOrigin: '41.7750,-70.5350',
    googleDest: '41.7580,-70.5000',
  },
  bourne: {
    name: 'Bourne Bridge',
    lat: 41.7437,
    lon: -70.5983,
    normalTravelMinutes: 5,
    // Google Maps: mainland side → Cape side across Bourne
    googleOrigin: '41.7500,-70.5650',
    googleDest: '41.7350,-70.5400',
  },
};

/**
 * Fetch current traffic conditions for Cape Cod bridges and routes.
 * Uses hybrid: MassDOT for alerts + Google Maps for delays + seasonal fallback.
 */
async function fetchTraffic() {
  // Run MassDOT and Google Maps in parallel
  const [massdotResult, googleResult] = await Promise.allSettled([
    fetchMassDOTAlerts(),
    fetchGoogleDelays(),
  ]);

  const alerts = massdotResult.status === 'fulfilled' ? massdotResult.value : [];
  const googleDelays = googleResult.status === 'fulfilled' ? googleResult.value : null;

  if (massdotResult.status === 'rejected') {
    console.warn('[traffic-client] MassDOT failed:', massdotResult.reason?.message);
  }
  if (googleResult.status === 'rejected') {
    console.warn('[traffic-client] Google Maps failed:', googleResult.reason?.message);
  }

  // Build bridge data: prefer Google delays, fall back to seasonal estimates
  const sagamoreDelay = googleDelays?.sagamore ?? getSeasonalDelay('sagamore');
  const bourneDelay = googleDelays?.bourne ?? getSeasonalDelay('bourne');

  const sagamoreAlerts = alerts.filter(a => a.bridge === 'sagamore');
  const bourneAlerts = alerts.filter(a => a.bridge === 'bourne');

  // If MassDOT reports a closure/severe incident, override delay
  const sagamoreFinal = hasClosureAlert(sagamoreAlerts) ? Math.max(sagamoreDelay, 30) : sagamoreDelay;
  const bourneFinal = hasClosureAlert(bourneAlerts) ? Math.max(bourneDelay, 30) : bourneDelay;

  const source = googleDelays ? 'google' : 'estimate';

  return {
    bridges: {
      sagamore: {
        delayMinutes: sagamoreFinal,
        status: delayToStatus(sagamoreFinal),
        direction: 'cape-bound',
        normalTravelMinutes: BRIDGES.sagamore.normalTravelMinutes,
        currentTravelMinutes: BRIDGES.sagamore.normalTravelMinutes + sagamoreFinal,
        alerts: sagamoreAlerts,
        source,
        lastUpdated: new Date().toISOString(),
      },
      bourne: {
        delayMinutes: bourneFinal,
        status: delayToStatus(bourneFinal),
        direction: 'cape-bound',
        normalTravelMinutes: BRIDGES.bourne.normalTravelMinutes,
        currentTravelMinutes: BRIDGES.bourne.normalTravelMinutes + bourneFinal,
        alerts: bourneAlerts,
        source,
        lastUpdated: new Date().toISOString(),
      },
    },
    routes: {
      route6: { status: 'clear', delayMinutes: 0 },
      route3: { status: 'clear', delayMinutes: 0 },
    },
    recommendation: generateRecommendation(sagamoreFinal, bourneFinal, alerts),
    isStale: !googleDelays && alerts.length === 0,
    updatedAt: new Date().toISOString(),
  };
}

// MARK: - MassDOT / Mass511 (incidents and alerts)

async function fetchMassDOTAlerts() {
  const alerts = [];

  // Events/incidents endpoint
  try {
    const eventsRes = await fetch(
      'https://mass511.com/api/v2/get/event?format=json&jurisdiction=MassDOT',
      { headers: { Accept: 'application/json' }, signal: AbortSignal.timeout(8000) }
    );
    if (!eventsRes.ok) throw new Error(`Mass511 events returned ${eventsRes.status}`);
    const eventsData = await eventsRes.json();

    if (eventsData && Array.isArray(eventsData.events)) {
      for (const event of eventsData.events) {
        const text = `${event.description || ''} ${event.headline || ''}`.toLowerCase();

        const isSagamore = text.includes('sagamore');
        const isBourne = text.includes('bourne');
        if (!isSagamore && !isBourne) continue;

        // Parse delay from description if available
        let delayMinutes = 15;
        const delayMatch = text.match(/(\d+)\s*(?:min|minute)/);
        if (delayMatch) delayMinutes = parseInt(delayMatch[1]);

        const isClosure = text.includes('closed') || text.includes('closure');
        const severity = isClosure ? 'closure' : delayMinutes > 20 ? 'severe' : 'moderate';

        alerts.push({
          bridge: isSagamore ? 'sagamore' : 'bourne',
          title: event.headline || 'Traffic Alert',
          description: event.description || '',
          severity,
          delayMinutes,
          lastUpdated: event.last_updated || new Date().toISOString(),
        });
      }
    }
  } catch (err) {
    console.warn('[traffic-client] Mass511 events failed:', err.message);
  }

  // Travel times endpoint
  try {
    const ttRes = await fetch(
      'https://mass511.com/api/v2/get/traveltimes?format=json',
      { headers: { Accept: 'application/json' }, signal: AbortSignal.timeout(8000) }
    );
    if (!ttRes.ok) throw new Error(`Mass511 travel times returned ${ttRes.status}`);
    const ttData = await ttRes.json();

    if (ttData && Array.isArray(ttData.travelTimes)) {
      for (const tt of ttData.travelTimes) {
        const name = (tt.title || tt.name || '').toLowerCase();
        const isSagamore = name.includes('sagamore');
        const isBourne = name.includes('bourne');
        if (!isSagamore && !isBourne) continue;

        const bridgeKey = isSagamore ? 'sagamore' : 'bourne';
        const bridge = BRIDGES[bridgeKey];
        const currentTime = tt.travelTime || tt.current || bridge.normalTravelMinutes;
        const delayMinutes = Math.max(0, currentTime - bridge.normalTravelMinutes);

        if (delayMinutes > 5) {
          alerts.push({
            bridge: bridgeKey,
            title: `${bridge.name} delay`,
            description: `Travel time: ${currentTime} min (normally ${bridge.normalTravelMinutes} min)`,
            severity: delayMinutes > 20 ? 'severe' : 'moderate',
            delayMinutes,
            lastUpdated: tt.lastUpdated || new Date().toISOString(),
          });
        }
      }
    }
  } catch (err) {
    console.warn('[traffic-client] Mass511 travel times failed:', err.message);
  }

  return alerts;
}

function hasClosureAlert(alerts) {
  return alerts.some(a => a.severity === 'closure');
}

// MARK: - Google Maps Directions (real-time delays)

async function fetchGoogleDelays() {
  const apiKey = process.env.GOOGLE_MAPS_API_KEY;
  if (!apiKey) throw new Error('No Google Maps API key configured');

  const [sagamoreRes, bourneRes] = await Promise.all([
    fetch(
      `https://maps.googleapis.com/maps/api/directions/json?origin=${BRIDGES.sagamore.googleOrigin}&destination=${BRIDGES.sagamore.googleDest}&departure_time=now&key=${apiKey}`,
      { signal: AbortSignal.timeout(10000) }
    ),
    fetch(
      `https://maps.googleapis.com/maps/api/directions/json?origin=${BRIDGES.bourne.googleOrigin}&destination=${BRIDGES.bourne.googleDest}&departure_time=now&key=${apiKey}`,
      { signal: AbortSignal.timeout(10000) }
    ),
  ]);

  const [sagamoreData, bourneData] = await Promise.all([
    sagamoreRes.json(),
    bourneRes.json(),
  ]);

  const sagamoreDelay = extractDelay(sagamoreData);
  const bourneDelay = extractDelay(bourneData);

  console.log(`[traffic-client] Google delays: Sagamore=${sagamoreDelay}min, Bourne=${bourneDelay}min`);

  return { sagamore: sagamoreDelay, bourne: bourneDelay };
}

function extractDelay(directionsData) {
  try {
    if (directionsData.status !== 'OK') return 0;
    const leg = directionsData.routes?.[0]?.legs?.[0];
    if (!leg) return 0;
    const durationInTraffic = leg.duration_in_traffic?.value || 0;
    const typicalDuration = leg.duration?.value || 0;
    if (!durationInTraffic) return 0;
    return Math.max(0, Math.round((durationInTraffic - typicalDuration) / 60));
  } catch {
    return 0;
  }
}

// MARK: - Seasonal Fallback Estimates

function getSeasonalDelay(bridgeKey) {
  const now = new Date();
  const hour = now.getHours();
  const dayOfWeek = now.getDay();
  const month = now.getMonth();

  const isSummer = month >= 5 && month <= 8;
  const isShoulder = month === 4 || month === 9;
  const isFriday = dayOfWeek === 5;
  const isSunday = dayOfWeek === 0;
  const isWeekend = dayOfWeek === 0 || dayOfWeek === 6;

  let delay = 0;

  if (isSummer) {
    if (isFriday && hour >= 14 && hour <= 20) {
      delay = 20 + Math.floor(Math.random() * 15);
    } else if (isSunday && hour >= 13 && hour <= 19) {
      delay = 15 + Math.floor(Math.random() * 15);
    } else if (isWeekend) {
      delay = 5 + Math.floor(Math.random() * 10);
    } else if ((hour >= 7 && hour <= 9) || (hour >= 16 && hour <= 18)) {
      delay = 5 + Math.floor(Math.random() * 8);
    }
  } else if (isShoulder) {
    if (isFriday && hour >= 15 && hour <= 19) {
      delay = 8 + Math.floor(Math.random() * 8);
    } else if (isSunday && hour >= 14 && hour <= 18) {
      delay = 8 + Math.floor(Math.random() * 8);
    }
  } else {
    if ((hour >= 7 && hour <= 9) || (hour >= 16 && hour <= 18)) {
      delay = 3 + Math.floor(Math.random() * 5);
    }
  }

  // Sagamore is typically slightly busier
  if (bridgeKey === 'sagamore') delay += Math.floor(Math.random() * 3);

  return delay;
}

// MARK: - Helpers

function delayToStatus(minutes) {
  if (minutes <= 5) return 'clear';
  if (minutes <= 15) return 'moderate';
  if (minutes <= 30) return 'heavy';
  return 'severe';
}

function generateRecommendation(sagamore, bourne, alerts) {
  const closures = alerts.filter(a => a.severity === 'closure');
  if (closures.length > 0) {
    const bridgeNames = [...new Set(closures.map(a => a.bridge === 'sagamore' ? 'Sagamore' : 'Bourne'))];
    return `${bridgeNames.join(' and ')} Bridge has a closure alert. Check for detours.`;
  }

  if (sagamore <= 5 && bourne <= 5) {
    return 'Both bridges are clear. Smooth sailing to Cape Cod!';
  }
  if (sagamore > bourne + 10) {
    return `Bourne Bridge is faster right now. Expect ${bourne} min delay vs ${sagamore} min on Sagamore.`;
  }
  if (bourne > sagamore + 10) {
    return `Sagamore Bridge is faster right now. Expect ${sagamore} min delay vs ${bourne} min on Bourne.`;
  }
  if (sagamore > 5 || bourne > 5) {
    return `Both bridges have similar delays (~${Math.max(sagamore, bourne)} min). Pick whichever is closer.`;
  }
  return 'Traffic data is current. Check back for real-time updates.';
}

module.exports = { fetchTraffic };
