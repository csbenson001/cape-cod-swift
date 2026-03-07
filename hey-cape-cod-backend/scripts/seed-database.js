#!/usr/bin/env node

/**
 * Seed Firestore with Cape Cod POI data and story variants.
 *
 * Usage: node scripts/seed-database.js
 *
 * Idempotent: checks if each document exists before writing.
 * Set FORCE_SEED=true to overwrite existing documents.
 */

// Load env vars if running locally
try { require('dotenv').config(); } catch {}

const { db, admin } = require('../lib/firebase-admin');

const FieldValue = admin.firestore.FieldValue;

// ─────────────────────────────────────────────
// POI DATA — 15 Cape Cod Points of Interest
// ─────────────────────────────────────────────

const POIS = [
  {
    id: 'sagamore-bridge',
    name: 'Sagamore Bridge',
    description: 'The northern gateway to Cape Cod, carrying US Route 6 over the Cape Cod Canal. One of only two road connections to the Cape.',
    latitude: 41.7718,
    longitude: -70.5392,
    radius: 500,
    category: 'landmark',
    town: 'Bourne',
    address: 'Sagamore Bridge, US-6, Sagamore, MA 02561',
    imageUrl: '',
    storyIds: ['sagamore-bridge-history', 'sagamore-bridge-kids'],
    facts: [
      'Opened in 1935 and carries US Route 6 over the Cape Cod Canal',
      'Approximately 30,000 vehicles cross daily in summer',
      'The bridge is 616 feet long with a 135-foot clearance above the canal',
      'A replacement bridge is planned for completion by 2032'
    ],
    tips: [
      'Friday afternoons 3-8 PM are the worst — leave earlier or later',
      'The Bourne Bridge is often 10-15 minutes faster during peak congestion',
      'Check the Hey Cape Cod traffic tab before crossing'
    ],
    relatedPoiIds: ['bourne-bridge', 'cape-cod-canal'],
    seasonalRelevance: { spring: true, summer: true, fall: true, winter: true },
    priority: 9,
    isActive: true,
  },
  {
    id: 'bourne-bridge',
    name: 'Bourne Bridge',
    description: 'The southern gateway to Cape Cod, carrying Route 28 over the Cape Cod Canal. Often the faster alternative to Sagamore.',
    latitude: 41.7445,
    longitude: -70.5597,
    radius: 500,
    category: 'landmark',
    town: 'Bourne',
    address: 'Bourne Bridge, MA-28, Bourne, MA 02532',
    imageUrl: '',
    storyIds: ['bourne-bridge-history', 'bourne-bridge-kids'],
    facts: [
      'Opened in 1935, the same year as the Sagamore Bridge',
      'Both bridges were designed by the same engineers',
      'The Bourne Bridge carries Route 28 to the Upper Cape',
      'A new replacement bridge is planned alongside the Sagamore replacement'
    ],
    tips: [
      'Usually faster than Sagamore on Friday evenings',
      'Best route if heading to Falmouth, Woods Hole, or the Upper Cape',
      'The Canal bike path runs right underneath — great views!'
    ],
    relatedPoiIds: ['sagamore-bridge', 'cape-cod-canal'],
    seasonalRelevance: { spring: true, summer: true, fall: true, winter: true },
    priority: 8,
    isActive: true,
  },
  {
    id: 'cape-cod-canal',
    name: 'Cape Cod Canal',
    description: 'A 6.5-mile waterway connecting Buzzards Bay to Cape Cod Bay, with paved bike paths on both sides and excellent fishing.',
    latitude: 41.7650,
    longitude: -70.5200,
    radius: 400,
    category: 'nature',
    town: 'Bourne',
    address: 'Cape Cod Canal, Bourne, MA',
    imageUrl: '',
    storyIds: ['cape-cod-canal-history', 'cape-cod-canal-kids'],
    facts: [
      'Completed in 1914, making Cape Cod technically an island',
      'The canal is 480 feet wide and 32 feet deep',
      'Tidal currents can reach 5 knots — among the strongest on the East Coast',
      'The Army Corps of Engineers has managed it since 1928'
    ],
    tips: [
      'The paved bike paths run the full 6.5 miles on both sides',
      'Striped bass fishing is excellent from the banks in spring and fall',
      'Watch for massive ships transiting — they pass through daily'
    ],
    relatedPoiIds: ['sagamore-bridge', 'bourne-bridge'],
    seasonalRelevance: { spring: true, summer: true, fall: true, winter: true },
    priority: 7,
    isActive: true,
  },
  {
    id: 'sandwich-town',
    name: 'Sandwich Village',
    description: 'The oldest town on Cape Cod, founded in 1637. Home to the famous Sandwich Glass Museum, the iconic boardwalk, and charming colonial architecture.',
    latitude: 41.7589,
    longitude: -70.4938,
    radius: 300,
    category: 'historic',
    town: 'Sandwich',
    address: 'Main Street, Sandwich, MA 02563',
    imageUrl: '',
    storyIds: ['sandwich-history', 'sandwich-kids'],
    facts: [
      'Founded in 1637 — the oldest town on Cape Cod',
      'The Sandwich Glass Museum showcases glass made here from 1825-1888',
      'The famous boardwalk stretches 1,350 feet across a salt marsh',
      'Dexter Grist Mill on Shawme Pond has been grinding corn since 1654'
    ],
    tips: [
      'The boardwalk is best at sunset — the marsh glows golden',
      'Read the inscriptions on the boardwalk planks — some are deeply touching',
      'The Dan\'l Webster Inn has excellent dining in a historic setting'
    ],
    relatedPoiIds: ['cape-cod-canal'],
    seasonalRelevance: { spring: true, summer: true, fall: true, winter: true },
    priority: 7,
    isActive: true,
  },
  {
    id: 'chatham-lighthouse',
    name: 'Chatham Lighthouse',
    description: 'An iconic lighthouse overlooking the dramatic Chatham Break, with a thriving seal colony offshore and one of the best views on Cape Cod.',
    latitude: 41.6714,
    longitude: -69.9500,
    radius: 250,
    category: 'lighthouse',
    town: 'Chatham',
    address: '37 Main St, Chatham, MA 02633',
    imageUrl: '',
    storyIds: ['chatham-lighthouse-history', 'chatham-lighthouse-kids'],
    facts: [
      'First lit in 1808 — one of the oldest lighthouses on Cape Cod',
      'The Chatham Break occurred in 1987, dramatically reshaping the coastline',
      'Over 15,000 grey and harbor seals now inhabit the outer bars',
      'Great white sharks patrol these waters from June through October'
    ],
    tips: [
      'Free tours are offered on Wednesdays in summer — check the schedule',
      'Bring binoculars to spot seals from the overlook',
      'The Fish Pier nearby is perfect for watching the fleet unload around 2-3 PM'
    ],
    relatedPoiIds: ['nauset-beach'],
    seasonalRelevance: { spring: true, summer: true, fall: true, winter: true },
    priority: 9,
    isActive: true,
  },
  {
    id: 'orleans-inn',
    name: 'Orleans Inn',
    description: 'A historic waterfront inn dating to 1875, famous for its harbor views, excellent seafood, and friendly resident ghosts.',
    latitude: 41.7897,
    longitude: -69.9897,
    radius: 150,
    category: 'historic',
    town: 'Orleans',
    address: '3 Old County Rd, Orleans, MA 02653',
    imageUrl: '',
    storyIds: ['orleans-inn-ghosts', 'orleans-inn-kids'],
    facts: [
      'Built in 1875 by Aaron Snow II, a sea captain',
      'At least three ghosts have been reported: Hannah, Fred, and an unnamed spinster',
      'The inn overlooks Town Cove, one of the prettiest harbors on Cape Cod',
      'Orleans was the only town in the US shelled by a German submarine in WWI'
    ],
    tips: [
      'Ask for a table on the deck at sunset — stunning harbor views',
      'Ask the staff about the ghost stories — they have great tales',
      'The lobster bisque is legendary'
    ],
    relatedPoiIds: ['nauset-beach', 'cape-cod-national-seashore'],
    seasonalRelevance: { spring: true, summer: true, fall: true, winter: true },
    priority: 6,
    isActive: true,
  },
  {
    id: 'whydah-pirate-museum',
    name: 'Whydah Pirate Museum',
    description: 'Home to the only authenticated pirate shipwreck ever discovered. Over 200,000 artifacts from the 1717 wreck of the Whydah Gally.',
    latitude: 41.7585,
    longitude: -70.0637,
    radius: 200,
    category: 'museum',
    town: 'Yarmouth',
    address: '674 MA-28, West Yarmouth, MA 02673',
    imageUrl: '',
    storyIds: ['whydah-pirates-history', 'whydah-pirates-kids'],
    facts: [
      'The Whydah is the only authenticated pirate shipwreck ever discovered',
      'Over 200,000 artifacts have been recovered since 1984',
      'Captain Sam Bellamy captured 53 ships in just over one year',
      'The ship\'s bell, inscribed "THE WHYDAH GALLY 1716", confirmed the wreck\'s identity'
    ],
    tips: [
      'Visit on a weekday morning to avoid crowds',
      'The gift shop has great pirate costumes for kids',
      'Ask about the seasonal "Real Pirates" exhibit for extra artifacts'
    ],
    relatedPoiIds: [],
    seasonalRelevance: { spring: true, summer: true, fall: true, winter: true },
    priority: 8,
    isActive: true,
  },
  {
    id: 'pilgrim-monument',
    name: 'Pilgrim Monument & Provincetown',
    description: 'The tallest all-granite structure in the US, marking where the Mayflower Pilgrims first landed in the New World. Provincetown is also the heart of Cape Cod\'s art scene.',
    latitude: 42.0529,
    longitude: -70.1861,
    radius: 300,
    category: 'historic',
    town: 'Provincetown',
    address: '1 High Pole Hill Rd, Provincetown, MA 02657',
    imageUrl: '',
    storyIds: ['pilgrim-monument-history', 'pilgrim-monument-kids'],
    facts: [
      'At 252 feet, it\'s the tallest all-granite structure in the United States',
      'The Mayflower spent 5 weeks in Provincetown before sailing to Plymouth',
      'President Theodore Roosevelt laid the cornerstone in 1907',
      'You can see Boston from the top on clear days'
    ],
    tips: [
      'Climb the 116 steps for a panoramic view — go at sunset for magic',
      'Provincetown\'s Commercial Street is the best people-watching on the Cape',
      'Whale watching tours depart from MacMillan Wharf — book in advance'
    ],
    relatedPoiIds: ['race-point-beach'],
    seasonalRelevance: { spring: true, summer: true, fall: true, winter: false },
    priority: 9,
    isActive: true,
  },
  {
    id: 'nauset-beach',
    name: 'Nauset Beach',
    description: 'A dramatic barrier beach stretching 10 miles along the Atlantic. Famous for great white sharks, excellent surfing, and powerful ocean waves.',
    latitude: 41.8050,
    longitude: -69.9417,
    radius: 350,
    category: 'beach',
    town: 'Orleans',
    address: 'Beach Rd, Orleans, MA 02653',
    imageUrl: '',
    storyIds: ['nauset-beach-history', 'nauset-beach-kids'],
    facts: [
      'The beach stretches 10 miles from Orleans to Chatham',
      'Great white sharks are regularly spotted here from June through October',
      'The beach loses about 3 feet of coastline to erosion each year',
      'One of the best surfing spots on the East Coast'
    ],
    tips: [
      'Arrive before 9 AM in summer — the parking lot fills by 10',
      'Always check shark activity reports before swimming (Sharktivity app)',
      'The south end toward Chatham is less crowded',
      'Bring a windbreaker — the ocean breeze is strong'
    ],
    relatedPoiIds: ['chatham-lighthouse', 'cape-cod-national-seashore'],
    seasonalRelevance: { spring: false, summer: true, fall: true, winter: false },
    priority: 8,
    isActive: true,
  },
  {
    id: 'cape-cod-national-seashore',
    name: 'Cape Cod National Seashore',
    description: '40 miles of pristine ocean beach, dunes, marshes, and uplands established by President Kennedy in 1961. A crown jewel of the National Park system.',
    latitude: 41.8400,
    longitude: -69.9700,
    radius: 500,
    category: 'nature',
    town: 'Eastham',
    address: 'Salt Pond Visitor Center, 50 Nauset Rd, Eastham, MA 02642',
    imageUrl: '',
    storyIds: ['national-seashore-history', 'national-seashore-kids'],
    facts: [
      'Established by President Kennedy on August 7, 1961',
      'Protects 43,604 acres across 6 towns',
      'Over 4 million people visit annually',
      'Home to over 450 species of plants and 350 species of birds'
    ],
    tips: [
      'Start at Salt Pond Visitor Center for maps and ranger programs',
      'The Nauset Marsh Trail is an easy 1.3-mile loop with stunning views',
      'National Park Pass ($30/year) covers all parking fees',
      'Ranger-led programs are free and excellent — check the schedule'
    ],
    relatedPoiIds: ['nauset-beach', 'marconi-beach'],
    seasonalRelevance: { spring: true, summer: true, fall: true, winter: true },
    priority: 10,
    isActive: true,
  },
  {
    id: 'wellfleet-town',
    name: 'Wellfleet',
    description: 'A charming Outer Cape town famous for its world-class oysters, thriving art gallery scene, and the last drive-in movie theater in New England.',
    latitude: 41.9306,
    longitude: -70.0342,
    radius: 300,
    category: 'historic',
    town: 'Wellfleet',
    address: 'Main Street, Wellfleet, MA 02667',
    imageUrl: '',
    storyIds: ['wellfleet-history', 'wellfleet-kids'],
    facts: [
      'Wellfleet oysters are considered among the best in the world',
      'The Wellfleet Drive-In Theatre has been operating since 1957',
      'The town has the highest concentration of art galleries per capita on the Cape',
      'Marconi sent the first US transatlantic wireless message from Wellfleet in 1903'
    ],
    tips: [
      'Hit the Wellfleet Flea Market on weekends — over 200 vendors',
      'Mac\'s Shack and Bookstore & Restaurant are local favorites for oysters',
      'Gallery night is Thursday evenings in summer — free wine and art!',
      'The drive-in shows double features nightly in summer'
    ],
    relatedPoiIds: ['marconi-beach', 'cape-cod-national-seashore'],
    seasonalRelevance: { spring: true, summer: true, fall: true, winter: false },
    priority: 7,
    isActive: true,
  },
  {
    id: 'jfk-hyannis-museum',
    name: 'JFK Hyannis Museum',
    description: 'Celebrates President Kennedy\'s deep connection to Cape Cod through photographs, memorabilia, and oral histories from his summers in Hyannis Port.',
    latitude: 41.6525,
    longitude: -70.2895,
    radius: 200,
    category: 'museum',
    town: 'Barnstable',
    address: '397 Main St, Hyannis, MA 02601',
    imageUrl: '',
    storyIds: ['jfk-museum-history', 'jfk-museum-kids'],
    facts: [
      'The Kennedy family has been in Hyannis Port since 1926',
      'JFK used the compound as his 1960 presidential campaign headquarters',
      'Kennedy signed the Cape Cod National Seashore Act in 1961',
      'The museum contains over 80,000 photographs'
    ],
    tips: [
      'The museum is on Main Street — easy walking to shops and dining',
      'The Kennedy Compound is visible from the harbor but not open to the public',
      'Combine with a ferry to Nantucket or Martha\'s Vineyard from the nearby dock'
    ],
    relatedPoiIds: ['cape-cod-national-seashore'],
    seasonalRelevance: { spring: true, summer: true, fall: true, winter: true },
    priority: 7,
    isActive: true,
  },
  {
    id: 'race-point-beach',
    name: 'Race Point Beach',
    description: 'Wild, windswept beach at the very tip of Cape Cod. Famous for whale watching, stunning sunsets over the ocean, and untamed Atlantic surf.',
    latitude: 42.0794,
    longitude: -70.2087,
    radius: 350,
    category: 'beach',
    town: 'Provincetown',
    address: 'Race Point Rd, Provincetown, MA 02657',
    imageUrl: '',
    storyIds: ['race-point-history', 'race-point-kids'],
    facts: [
      'You can watch the sun set INTO the ocean — rare for the East Coast',
      'Over 3,000 shipwrecks have occurred in nearby waters',
      'Humpback whales feed just offshore from April through October',
      'Part of the Cape Cod National Seashore since 1961'
    ],
    tips: [
      'Best sunset on the East Coast — arrive 30 minutes early for a good spot',
      'Bring a windbreaker — it\'s always breezy at the tip of the Cape',
      'Best whale-watching from shore in late July and August',
      'The Old Harbor Life-Saving Station has free summer demonstrations'
    ],
    relatedPoiIds: ['pilgrim-monument', 'cape-cod-national-seashore'],
    seasonalRelevance: { spring: false, summer: true, fall: true, winter: false },
    priority: 9,
    isActive: true,
  },
  {
    id: 'marconi-beach',
    name: 'Marconi Beach & Station Site',
    description: 'Site of the first transatlantic wireless communication from the US in 1903. Dramatic 60-foot clay cliffs overlook the open Atlantic.',
    latitude: 41.8881,
    longitude: -69.9611,
    radius: 250,
    category: 'historic',
    town: 'Wellfleet',
    address: 'Marconi Beach Rd, Wellfleet, MA 02667',
    imageUrl: '',
    storyIds: ['marconi-beach-history', 'marconi-beach-kids'],
    facts: [
      'First transatlantic wireless message from the US was sent here on January 18, 1903',
      'Marconi\'s four towers were each 210 feet tall',
      'The original station site has eroded into the ocean',
      'The beach has some of the most dramatic cliffs on Cape Cod'
    ],
    tips: [
      'Visit the interpretive shelter at the old station site before hitting the beach',
      'The beach requires a steep staircase — not ideal for mobility issues',
      'Great for body surfing when the waves cooperate'
    ],
    relatedPoiIds: ['wellfleet-town', 'cape-cod-national-seashore'],
    seasonalRelevance: { spring: true, summer: true, fall: true, winter: true },
    priority: 7,
    isActive: true,
  },
  {
    id: 'skaket-beach',
    name: 'Skaket Beach',
    description: 'A family-friendly Cape Cod Bay beach famous for its extraordinary low tides that expose acres of sand flats and tide pools.',
    latitude: 41.7786,
    longitude: -70.0186,
    radius: 250,
    category: 'beach',
    town: 'Orleans',
    address: 'Skaket Beach Rd, Orleans, MA 02653',
    imageUrl: '',
    storyIds: ['skaket-beach-history', 'skaket-beach-kids'],
    facts: [
      'At low tide, you can walk nearly a mile out onto the sand flats',
      'The tide pools are teeming with hermit crabs, snails, and small fish',
      'Sunset over Cape Cod Bay is spectacular from this beach',
      'The bay-side water is significantly warmer than the ocean side'
    ],
    tips: [
      'Check the tide chart — visit at low tide for the best tide pool experience',
      'Bring water shoes for walking the flats',
      'The snack bar has surprisingly good fried clams',
      'Perfect beach for toddlers and small children — calm, warm water'
    ],
    relatedPoiIds: ['nauset-beach', 'cape-cod-national-seashore'],
    seasonalRelevance: { spring: false, summer: true, fall: true, winter: false },
    priority: 7,
    isActive: true,
  },
];

// ─────────────────────────────────────────────
// STORY DATA — 2 variants per POI (adult + kids)
// ─────────────────────────────────────────────

const STORIES = [
  // Sagamore Bridge
  {
    id: 'sagamore-bridge-history',
    poiId: 'sagamore-bridge',
    title: 'Gateway to the Cape',
    mode: 'adult',
    category: 'historic',
    script: `You're crossing the Sagamore Bridge — one of only two road connections to Cape Cod. Built in 1935 by the Army Corps of Engineers, this bridge replaced a drawbridge that created nightmarish traffic jams even in the 1930s. The 616-foot steel structure carries US Route 6 over the Cape Cod Canal at a height of 135 feet, high enough for the largest ships to pass beneath. On a busy summer Friday, over 30,000 vehicles cross this bridge, creating the legendary "Cape Cod traffic" that's been a rite of passage for generations of vacationers. Here's an insider tip: the Bourne Bridge, three miles south, often has shorter delays. And if you're stuck in traffic, take comfort — you're following a tradition that goes back to the 1930s. The bridges themselves are engineering marvels, but they're also reaching the end of their design life. A massive replacement project is underway, with new bridges expected by 2032. You're crossing a piece of history that won't be here much longer.`,
    durationSeconds: 90,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['traffic', 'history', 'bridges', 'driving'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'sagamore-bridge-kids',
    poiId: 'sagamore-bridge',
    title: 'The Big Bridge to Cape Cod!',
    mode: 'kids',
    category: 'historic',
    script: `Ahoy, young explorers! Captain Cod here! See this GIANT bridge we're crossing? It's called the Sagamore Bridge, and it's one of only TWO bridges that can take you to Cape Cod! Imagine if there were no bridges — you'd have to take a BOAT every time you wanted to visit the beach! This bridge is super tall — as tall as a 13-story building! That's so big ships can sail right underneath us. And guess what? Over 30,000 cars cross this bridge every single day in summer! That's like a parade of cars stretching from here all the way to Boston! Now look down if you can — see that water? That's the Cape Cod Canal. It was dug by people to make a shortcut for ships. Pretty cool, right? Welcome to Cape Cod, matey!`,
    durationSeconds: 60,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['traffic', 'history', 'bridges', 'kids'],
    sortOrder: 2,
    isActive: true,
  },
  // Bourne Bridge
  {
    id: 'bourne-bridge-history',
    poiId: 'bourne-bridge',
    title: 'The Other Gateway',
    mode: 'adult',
    category: 'historic',
    script: `The Bourne Bridge is the Sagamore's twin — built in the same year, 1935, by the same engineers. But while the Sagamore gets all the attention, savvy Cape Codders know that the Bourne Bridge is often the smarter choice. It carries Route 28 directly to the Upper Cape towns of Bourne, Falmouth, and Mashpee, and during peak Friday evening traffic, it can save you 15-20 minutes over the Sagamore. The bridge offers something the Sagamore doesn't: a stunning view of the Cape Cod Canal bike path running directly beneath it. On any summer day, you can see hundreds of cyclists and walkers enjoying the 6.5-mile paved path. The canal itself is an engineering marvel — completed in 1914 by financier August Belmont Jr., it transformed Cape Cod from a peninsula into an island. Both bridges are scheduled for replacement, and the new spans will be wider and more modern. But for now, enjoy crossing this 89-year-old piece of American infrastructure.`,
    durationSeconds: 85,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['traffic', 'history', 'bridges'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'bourne-bridge-kids',
    poiId: 'bourne-bridge',
    title: 'Bridge Number Two!',
    mode: 'kids',
    category: 'historic',
    script: `Hey there, Captain Cod again! Did you know there are only TWO bridges to Cape Cod? This one is called the Bourne Bridge, and it's the Sagamore Bridge's twin — they were both built at the same time! Look down — can you see people riding bikes and walking? That's the Canal bike path! It goes for six and a half miles along the water. And see those big boats in the canal? Some of them are longer than a football field! The coolest thing about this bridge? It's a secret shortcut! When there's lots of traffic on the other bridge, this one is sometimes faster. Smart travelers know to check both!`,
    durationSeconds: 50,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['traffic', 'bridges', 'kids'],
    sortOrder: 2,
    isActive: true,
  },
  // Cape Cod Canal
  {
    id: 'cape-cod-canal-history',
    poiId: 'cape-cod-canal',
    title: 'The Ditch That Made an Island',
    mode: 'adult',
    category: 'historic',
    script: `The Cape Cod Canal is one of the great engineering achievements of the 20th century. Before it existed, ships had to sail all the way around Cape Cod — a treacherous journey through waters that claimed over 3,000 vessels. The idea for a canal dates back to Miles Standish in 1623, and George Washington himself commissioned a survey in 1776. But it took a New York financier named August Belmont Jr. to finally make it happen, spending his entire personal fortune on the project. The original canal, completed in 1914, was narrow and dangerous. The Army Corps of Engineers took it over in 1928 and widened it to 480 feet, eliminating the deadly currents. Today, the canal handles commercial shipping, recreational boating, and thousands of fishermen casting from the banks. The tidal currents here reach 5 knots — among the strongest on the East Coast. If you're biking the path, keep your eyes peeled for massive cargo ships passing silently through.`,
    durationSeconds: 95,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['history', 'nature', 'biking'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'cape-cod-canal-kids',
    poiId: 'cape-cod-canal',
    title: 'The Giant Shortcut!',
    mode: 'kids',
    category: 'historic',
    script: `Ahoy! See this big channel of water? People DUG this! It's called the Cape Cod Canal, and it's like a giant shortcut for boats. Before this canal was here, ships had to sail ALL the way around Cape Cod, which was super dangerous. Thousands of ships crashed! So some really determined people spent YEARS digging this channel. The water rushes through here so fast that it's like a river! And here's the coolest part — Cape Cod used to be attached to the rest of Massachusetts, like a long arm reaching into the ocean. But when they dug this canal, Cape Cod became an ISLAND! Well, almost — those two bridges still connect it. Can you feel the wind from the water? That's the tide rushing through!`,
    durationSeconds: 55,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['history', 'nature', 'kids'],
    sortOrder: 2,
    isActive: true,
  },
  // Sandwich
  {
    id: 'sandwich-history',
    poiId: 'sandwich-town',
    title: 'The Oldest Town on Cape Cod',
    mode: 'adult',
    category: 'historic',
    script: `Welcome to Sandwich, founded in 1637 — the oldest town on Cape Cod and one of the oldest in America. Walking through the village center feels like stepping into a New England postcard. The Dexter Grist Mill on Shawme Pond has been grinding corn since 1654, and the Hoxie House nearby is one of the oldest surviving homes on Cape Cod. But Sandwich's most famous chapter came in the 19th century, when the Boston & Sandwich Glass Company turned this quiet village into a glassmaking powerhouse. From 1825 to 1888, the factory produced some of the most beautiful pressed glass in American history. The Sandwich Glass Museum displays thousands of pieces, each one catching the light in ways that seem almost magical. Don't miss the boardwalk across the marsh — after a nor'easter destroyed the original, the town rebuilt it by selling individual planks to donors who inscribed them with personal messages. Walk slowly and read them. You'll find love letters, memorials, and inside jokes spanning decades.`,
    durationSeconds: 100,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['history', 'glass', 'boardwalk'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'sandwich-kids',
    poiId: 'sandwich-town',
    title: 'The Town Named After a Sandwich!',
    mode: 'kids',
    category: 'historic',
    script: `Captain Cod here with a fun fact — this town is called SANDWICH! But it wasn't named after the food. It was named after a place in England. Still, how cool is it to live in a town called Sandwich? This is the OLDEST town on all of Cape Cod — people have lived here for almost 400 years! See that old building by the pond? That's a grist mill, and it grinds corn into flour using a big stone wheel powered by water. People have been using it since 1654! And there's a really cool boardwalk here — every single wooden plank has a special message carved into it by a real person. Can you find the funniest one?`,
    durationSeconds: 50,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['history', 'kids', 'boardwalk'],
    sortOrder: 2,
    isActive: true,
  },
  // Chatham Lighthouse
  {
    id: 'chatham-lighthouse-history',
    poiId: 'chatham-lighthouse',
    title: 'Chatham: Where the Ocean Remade the Land',
    mode: 'adult',
    category: 'maritime',
    script: `Chatham Lighthouse has stood guard over one of the most dynamic coastlines in the world since 1808. But the real story here isn't the lighthouse — it's what happened to the land around it. In January 1987, a powerful nor'easter broke through the barrier beach south of here, creating what locals call "the Chatham Break." Overnight, the geography of Chatham changed forever. The break created new islands, redirected currents, and fundamentally altered the harbor. Then came the seals. Protected by the Marine Mammal Protection Act of 1972, grey and harbor seals slowly returned to Cape Cod. Their population exploded, and today over 15,000 seals inhabit the outer bars you can see from this overlook. The seals, in turn, attracted an apex predator that hadn't been seen in these waters for decades: the great white shark. Since 2012, researchers have tagged over 400 individual great whites off Chatham. The ecosystem is being remade before our eyes — the most dramatic ecological shift on the East Coast.`,
    durationSeconds: 100,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['lighthouse', 'sharks', 'seals', 'nature'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'chatham-lighthouse-kids',
    poiId: 'chatham-lighthouse',
    title: 'Seals, Sharks, and a Big Lighthouse!',
    mode: 'kids',
    category: 'maritime',
    script: `Ahoy, matey! See that lighthouse flashing? That's the Chatham Lighthouse, and it's been helping ships find their way for over 200 years! Now look out at the water — see those dark shapes on the sand bars? Those are SEALS! Hundreds and hundreds of them! They love to sunbathe and play in the waves. And here's something WILD — because all those seals are here, guess who else showed up? GREAT WHITE SHARKS! Real ones! Don't worry though — the sharks are out there eating fish and seals, not hanging out at the beach. Scientists put special tags on the sharks to track where they swim. There are over 400 tagged sharks out there right now! How cool is that?`,
    durationSeconds: 55,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['lighthouse', 'sharks', 'seals', 'kids'],
    sortOrder: 2,
    isActive: true,
  },
  // Orleans Inn
  {
    id: 'orleans-inn-ghosts',
    poiId: 'orleans-inn',
    title: 'The Ghosts of the Orleans Inn',
    mode: 'adult',
    category: 'legend',
    script: `The Orleans Inn has been welcoming guests since 1875, but not all of its visitors have checked out. Staff and guests have reported encounters with at least three spirits over the years. The most famous is Hannah, believed to be a former owner who still tends to her beloved inn. Guests in Room 7 have reported the scent of lavender and the feeling of being gently tucked into bed at night. Then there's Fred, a more mischievous presence who enjoys moving objects behind the bar — bottles shift positions overnight, and glasses have been found neatly rearranged by morning. And perhaps most unsettling is the unnamed spinster, seen as a shadowy figure on the third-floor staircase, always ascending but never reaching the top. The building was constructed by Captain Aaron Snow II, a man who sailed the world but chose this spot on Town Cove for his home. Whether you believe in ghosts or not, there's an undeniable energy to this place — a sense that the walls remember every story told within them over 150 years.`,
    durationSeconds: 95,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['ghosts', 'history', 'legends'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'orleans-inn-kids',
    poiId: 'orleans-inn',
    title: 'The Friendly Ghosts of Orleans!',
    mode: 'kids',
    category: 'legend',
    script: `Ahoy, mateys! Captain Cod here with a spooky tale! See that big old building? That's the Orleans Inn, and guess what — it's HAUNTED! Well, the friendly kind of haunted. There's a nice ghost named Hannah who tucks people into bed at night and makes the room smell like flowers. Then there's a silly ghost named Fred who likes to play tricks — he moves bottles behind the bar and rearranges glasses when nobody's looking! And there's one more ghost — a mysterious lady on the stairs who's always walking UP but never gets to the top! If your french fries go missing at dinner, maybe Fred took them! Don't worry though — these ghosts are the friendly, silly kind. No scary stuff here, just Cape Cod magic!`,
    durationSeconds: 50,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['ghosts', 'legends', 'kids'],
    sortOrder: 2,
    isActive: true,
  },
  // Whydah Pirate Museum
  {
    id: 'whydah-pirates-history',
    poiId: 'whydah-pirate-museum',
    title: 'Black Sam Bellamy and the Whydah',
    mode: 'adult',
    category: 'maritime',
    script: `In 1717, the pirate ship Whydah went down in a fierce nor'easter off Wellfleet. Its captain, "Black Sam" Bellamy, was just 28 years old and already the wealthiest pirate in recorded history. Bellamy was no ordinary buccaneer. Born in Devon, England, he came to Cape Cod seeking fortune and fell in love with a local girl named Maria Hallett from Eastham. When her family rejected the penniless sailor, Bellamy turned to piracy, vowing to return rich enough to claim her hand. In just over a year, he captured more than 53 ships. The Whydah itself was a slave ship he seized off the coast of Cuba, converting it into his flagship. On April 26, 1717, Bellamy was sailing north to reunite with Maria when a violent storm drove the Whydah onto a sandbar off Wellfleet. Of the 146 men aboard, only two survived. The wreck lay undiscovered for over 260 years until explorer Barry Clifford found it in 1984. Since then, over 200,000 artifacts have been recovered, including gold coins, weapons, and the ship's bell that confirmed the wreck's identity.`,
    durationSeconds: 100,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['pirates', 'shipwreck', 'history', 'maritime'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'whydah-pirates-kids',
    poiId: 'whydah-pirate-museum',
    title: 'The Pirate\'s Treasure!',
    mode: 'kids',
    category: 'maritime',
    script: `Arrr! Gather round, me hearties! Captain Cod has a pirate tale for ye! Long ago, a pirate named Sam sailed these very waters with a ship FULL of treasure. His ship was called the Whydah, and it was the fastest ship on the seven seas! Captain Sam was different from other pirates though — he was kind to his crew and shared his treasure fairly. But one stormy night, the waves got so big they were taller than a HOUSE! The Whydah crashed right here near Cape Cod. For hundreds of years, people searched for the treasure. Then one day, a brave diver named Barry went underwater and found GOLD COINS, a real cannon, and even a pirate bell! You can see the real pirate treasure right here in this museum! Look for the gold dust and the pistol that belonged to Captain Sam himself!`,
    durationSeconds: 55,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['pirates', 'treasure', 'kids'],
    sortOrder: 2,
    isActive: true,
  },
  // Pilgrim Monument
  {
    id: 'pilgrim-monument-history',
    poiId: 'pilgrim-monument',
    title: 'The Pilgrims\' Forgotten First Landing',
    mode: 'adult',
    category: 'historic',
    script: `Most Americans believe the Pilgrims landed at Plymouth Rock. But history tells a different story. On November 11, 1620, the Mayflower first dropped anchor right here in Provincetown Harbor after 66 days at sea. The Pilgrims spent five weeks exploring Cape Cod before deciding to move on to Plymouth. During those five weeks, they signed the Mayflower Compact — the first governing document of Plymouth Colony and a cornerstone of American democracy. This monument, standing 252 feet tall, was built between 1907 and 1910 to set the record straight. President Theodore Roosevelt himself laid the cornerstone. The tower's Italian Renaissance design was modeled after the Torre del Mangia in Siena, Italy. Climb the 116 steps and 60 ramps to the top for a panoramic view spanning from the tip of Cape Cod to Boston on a clear day. Below you, Provincetown thrives as one of the most vibrant art colonies and LGBTQ-friendly communities in the world — a fitting legacy for a place founded on the idea of freedom.`,
    durationSeconds: 95,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['pilgrims', 'history', 'monument'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'pilgrim-monument-kids',
    poiId: 'pilgrim-monument',
    title: 'The Tallest Tower!',
    mode: 'kids',
    category: 'historic',
    script: `Look up! Way, way, WAY up! See that giant tower? It's the tallest stone tower in the whole United States! A long time ago, a big ship called the Mayflower sailed across the entire ocean with families looking for a new home. And guess where they stopped FIRST? Right here! Before Plymouth, before any of that — they came to THIS very spot! The tower has 116 steps inside. If you climb all the way to the top, you can see SO far you might spot Boston! Are you brave enough to count every single step? Let's see — ready, set, CLIMB!`,
    durationSeconds: 45,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['pilgrims', 'monument', 'kids'],
    sortOrder: 2,
    isActive: true,
  },
  // Nauset Beach
  {
    id: 'nauset-beach-history',
    poiId: 'nauset-beach',
    title: 'The Wild Atlantic Shore',
    mode: 'adult',
    category: 'nature',
    script: `You're standing on one of the most powerful beaches on the East Coast. Nauset Beach stretches 10 unbroken miles from Orleans to Chatham, a barrier beach that takes the full force of the North Atlantic. The waves here are generated by storms thousands of miles away, crossing the open ocean to crash on this shore with a force that erodes 3 feet of coastline every year. This is also shark territory. Since 2012, great white sharks have returned to these waters in numbers not seen in over a century, drawn by the booming seal population on the outer bars. If you swim here, stay in waist-deep water, swim in groups, and always check the Sharktivity app for recent sightings. Despite the sharks, Nauset remains one of the most beloved beaches on Cape Cod. Surfers come for the consistent breaks, beachgoers come for the raw beauty, and everyone comes for the feeling of standing at the edge of a continent.`,
    durationSeconds: 85,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['beach', 'sharks', 'surfing', 'nature'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'nauset-beach-kids',
    poiId: 'nauset-beach',
    title: 'Waves, Sharks, and Sand Castles!',
    mode: 'kids',
    category: 'nature',
    script: `WOW, listen to those waves! This is Nauset Beach, and the ocean here is WILD! These waves traveled all the way across the Atlantic Ocean — that's thousands of miles — just to crash right here on this sand! This beach is TEN MILES long. That's so long you can't even see the end! And guess what lives in the water out there? Great white sharks! Real ones! Scientists have counted over 400 of them. But don't worry — they're way out deep looking for seals, not near the shore. As long as you stay where you can touch the bottom, you're totally safe. Now, who wants to build the biggest sand castle ever?!`,
    durationSeconds: 50,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['beach', 'sharks', 'kids'],
    sortOrder: 2,
    isActive: true,
  },
  // Cape Cod National Seashore
  {
    id: 'national-seashore-history',
    poiId: 'cape-cod-national-seashore',
    title: 'Kennedy\'s Gift to the Nation',
    mode: 'adult',
    category: 'nature',
    script: `On August 7, 1961, President John F. Kennedy signed legislation creating the Cape Cod National Seashore, preserving 40 miles of pristine coastline from Chatham to Provincetown. It was personal for Kennedy — he'd spent every summer of his life in Hyannis Port and understood that without federal protection, this extraordinary landscape would be consumed by development. The National Seashore protects 43,604 acres of beaches, dunes, marshes, ponds, and uplands. More than 450 plant species and 350 bird species thrive within its boundaries. The Salt Pond Visitor Center, where the park begins, sits beside one of the finest salt marsh ecosystems on the East Coast. Henry David Thoreau walked these beaches in 1849 and wrote, "The sea-shore is a sort of neutral ground." Today, over 4 million people visit annually, finding exactly the wild beauty that Thoreau described and Kennedy fought to preserve.`,
    durationSeconds: 90,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['nature', 'kennedy', 'history', 'national-park'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'national-seashore-kids',
    poiId: 'cape-cod-national-seashore',
    title: 'A President\'s Beach Park!',
    mode: 'kids',
    category: 'nature',
    script: `Did you know a PRESIDENT saved these beaches? President Kennedy loved Cape Cod SO much that he made a special law to protect 40 MILES of beach forever! That means nobody can ever build houses or stores on these beaches — they'll always be wild and beautiful for kids like you to explore! The National Seashore has beaches, ponds, marshes, and trails through the forest. Over 350 different kinds of birds live here! Keep your eyes open for osprey — they're big birds that dive into the water to catch fish. And the ranger programs are FREE — you can learn about whales, tide pools, and even how to be a Junior Ranger!`,
    durationSeconds: 50,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['nature', 'kennedy', 'kids', 'national-park'],
    sortOrder: 2,
    isActive: true,
  },
  // Wellfleet
  {
    id: 'wellfleet-history',
    poiId: 'wellfleet-town',
    title: 'Oysters, Art, and Drive-In Movies',
    mode: 'adult',
    category: 'culture',
    script: `Wellfleet is the kind of town that makes people fall in love with Cape Cod. This small Outer Cape community has three claims to fame, each one utterly distinctive. First, the oysters. Wellfleet oysters are prized by chefs worldwide for their clean, briny flavor, shaped by the unique blend of freshwater and saltwater in Wellfleet Harbor. The annual Wellfleet OysterFest draws thousands every October. Second, the art. Wellfleet has the highest concentration of art galleries per capita on Cape Cod. Thursday evening gallery strolls in summer are a beloved tradition — free wine, local art, and the energy of a creative community in full bloom. And third, the Wellfleet Drive-In Theatre. Operating since 1957, it's one of fewer than 300 drive-ins left in America. On summer nights, families park their cars, tune their radios to the theater's FM frequency, and watch movies under the stars. On weekend mornings, the same lot transforms into the legendary Wellfleet Flea Market.`,
    durationSeconds: 95,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['oysters', 'art', 'drive-in', 'culture'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'wellfleet-kids',
    poiId: 'wellfleet-town',
    title: 'Movies Under the Stars!',
    mode: 'kids',
    category: 'culture',
    script: `Captain Cod has THREE amazing things to tell you about Wellfleet! Number ONE: oysters! This town is famous for growing the yummiest oysters in the world. They grow right in the harbor! Number TWO: an outdoor movie theater! Imagine watching a movie from INSIDE YOUR CAR, with the stars twinkling above you! The Wellfleet Drive-In has been showing movies since 1957! You tune the car radio to hear the sound! And number THREE: on weekend mornings, the movie theater parking lot turns into a GIANT treasure hunt called a flea market, where over 200 sellers have all sorts of cool stuff. I once found a real ship in a bottle there!`,
    durationSeconds: 50,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['oysters', 'drive-in', 'kids'],
    sortOrder: 2,
    isActive: true,
  },
  // JFK Museum
  {
    id: 'jfk-museum-history',
    poiId: 'jfk-hyannis-museum',
    title: 'The Kennedys and Cape Cod',
    mode: 'adult',
    category: 'historic',
    script: `For the Kennedy family, Cape Cod wasn't just a vacation spot — it was home. Joseph Kennedy Sr. first rented a cottage in Hyannis Port in 1926, and by 1928 he'd purchased the large white clapboard house on Marchant Avenue that would become the Kennedy Compound. It was here that John F. Kennedy spent every summer of his life. He learned to sail in these waters, played touch football on the lawn, and in 1960, used the compound as his presidential campaign headquarters. On election night, JFK watched the returns from the Hyannis Armory. Throughout his presidency, Kennedy returned to Hyannis Port whenever he could — it was his place of restoration. And it was his love for these shores that drove him to establish the Cape Cod National Seashore in 1961, preserving 40 miles of pristine coastline for future generations. The museum on Main Street in Hyannis celebrates this relationship through over 80,000 photographs and deeply personal memorabilia.`,
    durationSeconds: 90,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['kennedy', 'history', 'presidents'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'jfk-museum-kids',
    poiId: 'jfk-hyannis-museum',
    title: 'The President Who Loved the Beach!',
    mode: 'kids',
    category: 'historic',
    script: `Did you know that a President of the United States used to play on Cape Cod beaches JUST LIKE YOU? President Kennedy LOVED Cape Cod! He came here every single summer since he was a kid. He sailed boats, played football on his lawn, and swam in the ocean. When he grew up and became President, he STILL came back every chance he got! And because he loved Cape Cod so much, he made a special law to protect the beaches forever. That means you can always come here and play, thanks to President Kennedy! Pretty cool that a president was a beach kid too, right?`,
    durationSeconds: 45,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['kennedy', 'presidents', 'kids'],
    sortOrder: 2,
    isActive: true,
  },
  // Race Point Beach
  {
    id: 'race-point-history',
    poiId: 'race-point-beach',
    title: 'Where Two Oceans Meet',
    mode: 'adult',
    category: 'nature',
    script: `You're standing at one of the most geologically remarkable places on the Atlantic coast. Race Point is where the cold Labrador Current collides with the warm Gulf Stream, creating one of the richest marine ecosystems on Earth. This convergence is why humpback whales migrate here every summer — the churning waters create a feast of sand lance and herring. The "Race" in Race Point refers to the racing tidal currents that have wrecked more than 3,000 ships over the centuries. The Peaked Hill Bars, just offshore, were so deadly that the US Life-Saving Service built one of its first stations here in 1872. But what makes Race Point truly magical is the sunset. Because Cape Cod curls back on itself here at the very tip, you can watch the sun set directly into the ocean — something almost impossible on the East Coast. On a clear evening, the sky turns from gold to pink to deep purple as the sun drops below the horizon. It's the best sunset on the entire Eastern Seaboard.`,
    durationSeconds: 95,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['beach', 'sunset', 'whales', 'nature'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'race-point-kids',
    poiId: 'race-point-beach',
    title: 'Sunset and Whales!',
    mode: 'kids',
    category: 'nature',
    script: `Welcome to the TIP of Cape Cod! This is Race Point Beach, and it's super special. WHALES come here to eat dinner! Big humpback whales swim all the way from the Caribbean just to munch on tiny fish. Sometimes you can see them jumping right out of the water from this beach! And here's the coolest thing — you can watch the sun SET into the OCEAN at this beach, even though we're on the East Coast! That's because Cape Cod curves around like a giant fishhook. The sunsets here are the most beautiful anywhere! The sky turns orange, then pink, then purple. Ready to find the perfect spot to watch?`,
    durationSeconds: 45,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['beach', 'sunset', 'whales', 'kids'],
    sortOrder: 2,
    isActive: true,
  },
  // Marconi Beach
  {
    id: 'marconi-beach-history',
    poiId: 'marconi-beach',
    title: 'The Message That Changed the World',
    mode: 'adult',
    category: 'historic',
    script: `On January 18, 1903, President Theodore Roosevelt stood in the White House and sent a wireless message to King Edward VII of England. The signal traveled from right here, bounced into the ionosphere, and was received in Cornwall, England. It was the first transatlantic wireless communication between heads of state. Guglielmo Marconi chose this spot carefully — the high clay cliffs gave his antenna towers the elevation they needed. His four wooden towers, each 210 feet tall, stood in a diamond pattern. Within years, wireless telegraphy transformed maritime safety, and within decades, Marconi's work evolved into radio, television, and every wireless technology we use today. Every text message, every phone call, every streaming song — they all trace their lineage back to this windy bluff in Wellfleet. The irony is that the very cliffs Marconi chose for their height have been slowly consumed by the Atlantic. The original station site has long since fallen into the sea.`,
    durationSeconds: 90,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['history', 'technology', 'marconi'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'marconi-beach-kids',
    poiId: 'marconi-beach',
    title: 'The World\'s First Text Message!',
    mode: 'kids',
    category: 'historic',
    script: `You know how you can send messages to people far away with a phone? Well, someone had to INVENT that! And it started RIGHT HERE! A super smart inventor named Marconi built HUGE towers on this cliff — taller than a 20-story building! He used them to send the very first wireless message across the whole Atlantic Ocean, all the way to ENGLAND! The President of the United States sent a message to the King of England, and it WORKED! That was over 120 years ago. So next time you use a phone, tablet, or watch a video — remember it all started on this beach in Cape Cod! Now, let's go check out those amazing cliffs!`,
    durationSeconds: 45,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['history', 'technology', 'kids'],
    sortOrder: 2,
    isActive: true,
  },
  // Skaket Beach
  {
    id: 'skaket-beach-history',
    poiId: 'skaket-beach',
    title: 'The Beach That Disappears',
    mode: 'adult',
    category: 'nature',
    script: `Skaket Beach is Cape Cod's great reveal. At high tide, it looks like a modest bay-side beach — warm water, gentle waves, families spread across a strip of sand. But wait for low tide and something extraordinary happens. The water retreats nearly a mile, exposing a vast landscape of sand flats, tidal pools, and channels. It's like watching the ocean pull back a curtain on a hidden world. The tide pools are teeming with life: hermit crabs shuffle between shells, tiny fish dart through shallow pools, and ribbed mussels cluster around rocks. Children can spend hours exploring, and marine biologists consider these flats among the most productive intertidal zones on Cape Cod Bay. The bay side of Cape Cod is an entirely different world from the wild Atlantic beaches on the outer shore. The water here is 10-15 degrees warmer, the waves are gentle, and the sunsets over Cape Cod Bay are legendary. This is where local families come to swim, where grandparents bring grandchildren, and where the pace of Cape Cod slows to its most relaxed.`,
    durationSeconds: 95,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['beach', 'tide-pools', 'family', 'nature'],
    sortOrder: 1,
    isActive: true,
  },
  {
    id: 'skaket-beach-kids',
    poiId: 'skaket-beach',
    title: 'The Magical Disappearing Ocean!',
    mode: 'kids',
    category: 'nature',
    script: `Captain Cod here with a MYSTERY! Sometimes this beach has water, and sometimes... the ocean DISAPPEARS! Where does it go?! It's called LOW TIDE, and when it happens here at Skaket Beach, you can walk for almost a MILE where the ocean used to be! And the coolest part? The ocean leaves behind little pools of water full of CREATURES! Hermit crabs walking around with their shell houses, teeny tiny fish, snails, and sometimes even a starfish! It's like a treasure hunt every time! Remember to bring water shoes because the sand can be squishy. Now let's go find some hermit crabs — I bet we can find a hundred!`,
    durationSeconds: 50,
    isPremium: false,
    narratorVoice: 'alloy',
    audioUrl: '',
    tags: ['beach', 'tide-pools', 'kids'],
    sortOrder: 2,
    isActive: true,
  },
];

// ─────────────────────────────────────────────
// SEED FUNCTION
// ─────────────────────────────────────────────

async function seed() {
  const forceSeed = process.env.FORCE_SEED === 'true';
  let poiCount = 0;
  let storyCount = 0;
  let skippedCount = 0;

  console.log('🏖️  Seeding Hey Cape Cod database...\n');

  // Seed POIs
  console.log(`📍 Seeding ${POIS.length} POIs...`);
  for (const poi of POIS) {
    const ref = db.collection('pois').doc(poi.id);
    const existing = await ref.get();

    if (existing.exists && !forceSeed) {
      console.log(`  ⏭️  Skipping existing POI: ${poi.name}`);
      skippedCount++;
      continue;
    }

    await ref.set({
      ...poi,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    console.log(`  ✅ ${poi.name}`);
    poiCount++;
  }

  // Seed Stories
  console.log(`\n📖 Seeding ${STORIES.length} stories...`);
  for (const story of STORIES) {
    const ref = db.collection('stories').doc(story.id);
    const existing = await ref.get();

    if (existing.exists && !forceSeed) {
      console.log(`  ⏭️  Skipping existing story: ${story.title}`);
      skippedCount++;
      continue;
    }

    await ref.set({
      ...story,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    console.log(`  ✅ ${story.title} (${story.mode})`);
    storyCount++;
  }

  console.log(`\n🎉 Seeding complete!`);
  console.log(`   POIs seeded: ${poiCount}`);
  console.log(`   Stories seeded: ${storyCount}`);
  console.log(`   Skipped (existing): ${skippedCount}`);
  console.log(`\n   Total documents: ${poiCount + storyCount}`);
}

seed()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('❌ Seed failed:', err);
    process.exit(1);
  });
