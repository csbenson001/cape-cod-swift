const { withMiddleware } = require('../../lib/middleware');
const { queryDocs } = require('../../lib/firestore');
const { checkSpendingLimit, recordUsage } = require('../../lib/cost-controls');
const { incrementMetric } = require('../../lib/metrics');
const OpenAI = require('openai');

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

const VALID_THEMES = [
  'historic', 'art', 'maritime', 'pirate', 'haunted', 'romantic',
  'photography', 'seafood', 'family', 'rail-trail', 'scenic', 'hidden-gems',
];

const VALID_DURATIONS = ['quick', 'half-day', 'full-day', 'weekend'];

const DURATION_HOURS = {
  'quick': 1,
  'half-day': 3,
  'full-day': 6,
  'weekend': 16,
};

const MAX_PREFERENCES = 20;

module.exports = withMiddleware(async (req, res, log) => {
  const uid = req.uid;

  const { theme, duration, startLocation, preferences = [], mode = 'adult' } = req.body;

  // Validate theme
  if (!theme || !VALID_THEMES.includes(theme)) {
    return res.status(400).json({ error: `theme must be one of: ${VALID_THEMES.join(', ')}` });
  }

  // Validate duration
  if (!duration || !VALID_DURATIONS.includes(duration)) {
    return res.status(400).json({ error: `duration must be one of: ${VALID_DURATIONS.join(', ')}` });
  }

  // Validate startLocation
  if (!startLocation || typeof startLocation !== 'object') {
    return res.status(400).json({ error: 'startLocation is required with lat and lng' });
  }

  const lat = parseFloat(startLocation.lat);
  const lng = parseFloat(startLocation.lng);
  if (isNaN(lat) || isNaN(lng) || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
    return res.status(400).json({ error: 'startLocation must have valid lat (-90 to 90) and lng (-180 to 180)' });
  }

  // Validate preferences
  if (!Array.isArray(preferences) || preferences.length > MAX_PREFERENCES) {
    return res.status(400).json({ error: `preferences must be an array of up to ${MAX_PREFERENCES} strings` });
  }
  if (!preferences.every((p) => typeof p === 'string')) {
    return res.status(400).json({ error: 'Each preference must be a string' });
  }

  // Check spending limits
  const spending = await checkSpendingLimit(uid);
  if (!spending.allowed) {
    log.warn('Spending limit reached for tour generation', { uid, reason: spending.reason });
    return res.status(429).json({ error: spending.reason });
  }

  // Fetch active POIs for context
  const allPois = await queryDocs('pois', [
    { field: 'isActive', op: '==', value: true },
  ]);

  if (allPois.length === 0) {
    return res.status(503).json({ error: 'No points of interest available. Please try again later.' });
  }

  // Build POI list for the prompt
  const poiList = allPois.map((p) => ({
    id: p.id,
    name: p.name,
    category: p.category,
    town: p.town,
    description: p.description,
    latitude: p.latitude,
    longitude: p.longitude,
  }));

  const durationHours = DURATION_HOURS[duration];

  const systemPrompt = `You are a Cape Cod tour planning expert. Given a list of points of interest, create a curated tour itinerary.

You must respond with ONLY valid JSON (no markdown, no code fences). The JSON must match this exact schema:
{
  "name": "string - creative tour name",
  "description": "string - 2-3 sentence overview",
  "stops": [
    {
      "poiId": "string - ID from the POI list",
      "name": "string - POI name",
      "description": "string - why this stop matters for the tour theme, 1-2 sentences",
      "estimatedMinutes": number,
      "highlights": ["string - specific thing to see/do at this stop"]
    }
  ],
  "estimatedDuration": "string - e.g. '3 hours' or '2 days'",
  "theme": "string - the tour theme"
}

Rules:
- Only use POIs from the provided list
- Order stops geographically to minimize travel time
- Start from the location closest to the user's starting point
- Each stop should have 1-3 highlights
- Total estimated time for all stops should fit within the ${durationHours}-hour window
- Include travel time estimates between stops (roughly 5-15 min per Cape Cod drive)
- For "${theme}" theme, prioritize POIs that match this theme
- Select between 3-12 stops depending on duration`;

  const userMessage = `Create a ${duration} (${durationHours} hours) "${theme}" tour of Cape Cod.

Starting location: lat ${lat}, lng ${lng}
User preferences: ${preferences.length > 0 ? preferences.join(', ') : 'none specified'}
Mode: ${mode}

Available POIs:
${JSON.stringify(poiList, null, 0)}`;

  const model = spending.model;

  const completion = await openai.chat.completions.create({
    model,
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userMessage },
    ],
    max_tokens: 2048,
    temperature: 0.7,
  });

  const rawContent = completion.choices[0]?.message?.content || '';
  const usage = completion.usage || {};

  // Parse the JSON response
  let tour;
  try {
    // Strip markdown code fences if present
    const cleaned = rawContent.replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/i, '').trim();
    tour = JSON.parse(cleaned);
  } catch (parseError) {
    log.error('Failed to parse tour generation response', {
      error: parseError.message,
      rawContent: rawContent.substring(0, 500),
    });
    return res.status(502).json({ error: 'Failed to generate tour. Please try again.' });
  }

  // Validate the parsed tour structure
  if (!tour.name || !tour.stops || !Array.isArray(tour.stops) || tour.stops.length === 0) {
    log.error('Invalid tour structure from AI', { tour: JSON.stringify(tour).substring(0, 500) });
    return res.status(502).json({ error: 'Generated tour was invalid. Please try again.' });
  }

  // Ensure theme is set
  tour.theme = theme;

  // Record usage (non-blocking)
  recordUsage(uid, model, usage.prompt_tokens || 0, usage.completion_tokens || 0).catch(() => {});
  incrementMetric('toursGenerated').catch(() => {});

  log.info('Tour generated', {
    theme,
    duration,
    stops: tour.stops.length,
    model,
    tokens: usage.total_tokens || 0,
  });

  res.status(200).json({ tour });
}, { auth: true, methods: ['POST'], cacheControl: 'NONE' });
