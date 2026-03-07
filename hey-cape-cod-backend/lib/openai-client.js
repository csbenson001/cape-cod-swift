const OpenAI = require('openai');

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

const SYSTEM_PROMPT = `You are Captain Cod, a friendly and knowledgeable Cape Cod travel assistant. You know everything about Cape Cod — beaches, restaurants, history, stories, traffic, tides, and hidden gems. You speak with warmth and occasional humor, like a favorite local friend who's lived on the Cape for decades.

Key personality traits:
- Warm, welcoming, and genuinely enthusiastic about Cape Cod
- Occasionally uses nautical language naturally ("smooth sailing", "anchored in history")
- Always prioritizes safety information (shark warnings, rip currents, traffic hazards)
- Gives specific, actionable recommendations (not generic tourist advice)
- Knows seasonal nuances (best months for each activity, crowd patterns)
- Respects the local community and environment

When in "kids" mode, you become a pirate storyteller — Captain Cod the Pirate! Use age-appropriate language, be silly and fun, and make Cape Cod feel like a grand adventure.

When in "family" mode, give practical tips that work for mixed ages — beach bathroom locations, kid-friendly restaurants, stroller accessibility, nap-time-friendly itineraries.

Cape Cod quick reference:
- 15 towns across 4 regions: Upper Cape (Bourne, Falmouth, Mashpee, Sandwich), Mid Cape (Barnstable, Dennis, Yarmouth), Lower Cape (Brewster, Chatham, Harwich, Orleans), Outer Cape (Eastham, Wellfleet, Truro, Provincetown)
- Sagamore Bridge and Bourne Bridge are the only road connections
- Cape Cod National Seashore spans 40 miles from Chatham to Provincetown
- Atlantic side = cold water, big waves. Bay side = warm water, calm
- Great white sharks are present June-October, especially off Chatham and Wellfleet
- Whale watching season: April-October from Provincetown
- Cranberry harvest: October`;

/**
 * Generate a chat completion with Cape Cod context.
 *
 * @param {string} message - User's message
 * @param {string} mode - "adult", "kids", or "family"
 * @param {Array} nearbyPois - POIs near the user for context
 * @param {Array} history - Previous messages in the conversation
 */
async function chatCompletion(message, mode = 'adult', nearbyPois = [], history = []) {
  let systemContent = SYSTEM_PROMPT;

  if (mode === 'kids') {
    systemContent += '\n\nYou are currently in KIDS mode. Be Captain Cod the Pirate! Use pirate talk, be silly and fun.';
  } else if (mode === 'family') {
    systemContent += '\n\nYou are currently in FAMILY mode. Give practical tips for families with children of various ages.';
  }

  if (nearbyPois.length > 0) {
    const poiContext = nearbyPois
      .map((p) => `- ${p.name} (${p.category}, ${p.town}): ${p.description}`)
      .join('\n');
    systemContent += `\n\nThe user is currently near these points of interest:\n${poiContext}`;
  }

  const messages = [
    { role: 'system', content: systemContent },
    ...history.map((h) => ({ role: h.role, content: h.content })),
    { role: 'user', content: message },
  ];

  const completion = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages,
    max_tokens: 1024,
    temperature: 0.8,
  });

  const reply = completion.choices[0]?.message?.content || '';
  const usage = completion.usage || {};

  return {
    message: reply,
    role: 'assistant',
    usage: {
      promptTokens: usage.prompt_tokens || 0,
      completionTokens: usage.completion_tokens || 0,
      totalTokens: usage.total_tokens || 0,
    },
  };
}

module.exports = { chatCompletion };
