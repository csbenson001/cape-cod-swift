/**
 * GET /api/sharks
 *
 * Returns aggregated shark sighting data for Cape Cod from multiple sources:
 * - Atlantic White Shark Conservancy (Sharktivity)
 * - National Park Service Cape Cod National Seashore alerts
 * - MA Division of Marine Fisheries / state beach alerts
 * - Curated fallback data based on historical patterns
 *
 * Query params:
 *   ?days=7       — how many days back to include (default: 30, max: 90)
 *   ?beach=nauset — filter by beach name (partial match)
 *
 * Response:
 * {
 *   sightings: [...],
 *   alertLevel: "low" | "moderate" | "high",
 *   recentCount: 3,          // sightings in last 48 hours
 *   totalCount: 12,
 *   sources: { sharktivity: 5, nps: 2, maAlerts: 1 },
 *   isLiveData: true,
 *   fetchedAt: "2026-07-15T...",
 *   safetyTips: [...]
 * }
 */

const { withMiddleware } = require('../../lib/middleware');
const { fetchSharkSightings } = require('../../lib/shark-scraper');
const cache = require('../../lib/cache');

// Cache shark data for 30 minutes
const SHARK_CACHE_TTL = 30 * 60; // seconds

const SAFETY_TIPS = [
  {
    title: 'Stay in groups',
    description: 'Sharks are more likely to approach solitary individuals. Swim, paddle, and surf in groups.',
  },
  {
    title: 'Avoid seal colonies',
    description: 'Great white sharks feed on seals. If you see seals, maintain a safe distance — sharks are likely nearby.',
  },
  {
    title: 'Stay close to shore',
    description: 'Keep within waist-deep water on Outer Cape beaches. Most shark activity occurs further offshore.',
  },
  {
    title: 'Avoid dawn and dusk',
    description: 'Sharks are most active during low-light periods. Swim during midday when visibility is best.',
  },
  {
    title: 'Heed beach closures',
    description: 'When lifeguards close a beach for a shark sighting, stay out of the water for the full closure period (typically 1-2 hours).',
  },
  {
    title: 'Know the signs',
    description: 'Watch for unusual bird activity, schools of fish jumping, or seals rapidly leaving the water — these can indicate a nearby predator.',
  },
  {
    title: 'Use the buddy system',
    description: 'Never swim alone on Outer Cape beaches. Always have someone on shore who can call for help.',
  },
  {
    title: 'Learn Stop the Bleed',
    description: 'Cape Cod beaches have Stop the Bleed kits. Familiarize yourself with tourniquet use — it saves lives in the rare event of a shark encounter.',
  },
];

module.exports = withMiddleware(async (req, res, log) => {
  const { days = '30', beach } = req.query;
  const daysBack = Math.min(Math.max(parseInt(days) || 30, 1), 90);

  // Build cache key based on params
  const cacheKey = `sharks:${daysBack}:${beach || 'all'}`;

  // Check cache first
  const cached = await cache.get(cacheKey);
  if (cached) {
    log.info('Shark data served from cache', { daysBack, beach });
    return res.status(200).json(cached);
  }

  log.info('Fetching fresh shark sighting data', { daysBack, beach });

  // Fetch from all sources
  const result = await fetchSharkSightings();

  // Filter by date range
  const cutoffDate = new Date(Date.now() - daysBack * 24 * 3600000);
  let sightings = result.sightings.filter(
    (s) => new Date(s.date) >= cutoffDate
  );

  // Filter by beach name if specified
  if (beach) {
    const beachLower = beach.toLowerCase();
    sightings = sightings.filter(
      (s) => s.location.toLowerCase().includes(beachLower) ||
             s.town.toLowerCase().includes(beachLower)
    );
  }

  // Calculate alert level based on last 48 hours
  const fortyEightHoursAgo = new Date(Date.now() - 48 * 3600000);
  const recentCount = sightings.filter(
    (s) => new Date(s.date) >= fortyEightHoursAgo
  ).length;

  let alertLevel = 'low';
  if (recentCount >= 3) alertLevel = 'high';
  else if (recentCount >= 1) alertLevel = 'moderate';

  const response = {
    sightings,
    alertLevel,
    recentCount,
    totalCount: sightings.length,
    sources: result.sources,
    isLiveData: result.isLiveData,
    fetchedAt: result.fetchedAt,
    safetyTips: SAFETY_TIPS,
  };

  // Cache the response
  await cache.set(cacheKey, response, SHARK_CACHE_TTL);

  res.status(200).json(response);
}, { methods: ['GET'], cacheControl: 'WEATHER' }); // Same cache-control as weather (15 min browser cache)
