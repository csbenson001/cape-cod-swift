const { withMiddleware } = require('../../lib/middleware');
const cache = require('../../lib/cache');

// ---------------------------------------------------------------------------
// Cape Cod Events Aggregation Endpoint
//
// GET /api/events
//   ?startDate=YYYY-MM-DD  (optional, defaults to today)
//   ?endDate=YYYY-MM-DD    (optional, defaults to startDate + 30 days)
//   ?category=festivals     (optional, comma-separated)
//   ?town=Wellfleet          (optional, comma-separated)
//
// Returns: { events: [...], count: N, dateRange: { start, end } }
// ---------------------------------------------------------------------------

// --- Future scraping stubs ------------------------------------------------
// TODO: Replace hardcoded events with scraped data using cheerio or puppeteer.
//
// Sources to integrate:
//   1. Cape Cod Chamber of Commerce events calendar
//      - URL: https://www.capecodchamber.org/events/
//      - Method: cheerio HTML parse or their iCal feed
//
//   2. Eventbrite Cape Cod
//      - URL: https://www.eventbrite.com/d/ma--cape-cod/events/
//      - Method: Eventbrite API (requires API key)
//
//   3. CapeCodOnline.com / Cape Cod Times events
//      - URL: https://www.capecodtimes.com/entertainment/events/
//      - Method: cheerio scrape
//
//   4. Town recreation department calendars
//      - Barnstable, Chatham, Falmouth, Orleans, Provincetown, etc.
//      - Method: Individual scraping per town website
//
//   5. Cape Cod Museum Trail
//      - URL: https://www.capecodmuseumtrail.com/
//      - Method: cheerio scrape for special exhibitions
//
// Architecture:
//   async function scrapeEvents() {
//     const [chamber, eventbrite, capecodOnline, townEvents] = await Promise.allSettled([
//       scrapeChamberEvents(),
//       scrapeEventbriteEvents(),
//       scrapeCapeCodeOnlineEvents(),
//       scrapeTownEvents(),
//     ]);
//     return deduplicateAndMerge([...results]);
//   }
// --------------------------------------------------------------------------

module.exports = withMiddleware(async (req, res, log) => {
  const {
    startDate,
    endDate,
    category,
    town,
    limit = '50',
    offset = '0',
  } = req.query;

  const parsedLimit = Math.min(parseInt(limit, 10) || 50, 100);
  const parsedOffset = parseInt(offset, 10) || 0;

  // Determine date range
  const now = new Date();
  const start = startDate ? new Date(startDate) : now;
  const end = endDate
    ? new Date(endDate)
    : new Date(start.getTime() + 30 * 24 * 60 * 60 * 1000);

  const cacheKey = `events:${start.toISOString().slice(0, 10)}:${end.toISOString().slice(0, 10)}:${category || 'all'}:${town || 'all'}:${parsedLimit}:${parsedOffset}`;

  const cached = await cache.get(cacheKey);
  if (cached) {
    return res.status(200).json(cached);
  }

  // Filter the hardcoded events
  let events = getHardcodedEvents();

  // Resolve recurring events into concrete dates within the window
  events = expandRecurringEvents(events, start, end);

  // Filter by date range
  events = events.filter((e) => {
    const eventDate = new Date(e.date);
    return eventDate >= start && eventDate <= end;
  });

  // Filter by category (comma-separated)
  if (category) {
    const cats = category.split(',').map((c) => c.trim().toLowerCase());
    events = events.filter((e) => cats.includes(e.category.toLowerCase()));
  }

  // Filter by town (comma-separated)
  if (town) {
    const towns = town.split(',').map((t) => t.trim().toLowerCase());
    events = events.filter((e) => towns.includes(e.town.toLowerCase()));
  }

  // Sort by date
  events.sort((a, b) => new Date(a.date) - new Date(b.date));

  // Paginate
  const total = events.length;
  events = events.slice(parsedOffset, parsedOffset + parsedLimit);

  const response = {
    events,
    count: events.length,
    total,
    dateRange: {
      start: start.toISOString().slice(0, 10),
      end: end.toISOString().slice(0, 10),
    },
  };

  await cache.set(cacheKey, response, 3600); // Cache 1 hour

  res.status(200).json(response);
}, { methods: ['GET'], cacheControl: 'NONE' });

// ---------------------------------------------------------------------------
// Recurring Event Expansion
// ---------------------------------------------------------------------------

function expandRecurringEvents(events, rangeStart, rangeEnd) {
  const expanded = [];

  for (const event of events) {
    if (!event.isRecurring || !event.recurrenceRule) {
      expanded.push(event);
      continue;
    }

    const rule = event.recurrenceRule;
    const current = new Date(Math.max(rangeStart.getTime(), new Date(event.date).getTime()));
    const limit = new Date(Math.min(rangeEnd.getTime(), new Date(event.recurringEndDate || rangeEnd).getTime()));

    if (rule === 'weekly') {
      // Find the first matching day of week
      const targetDay = new Date(event.date).getDay();
      const d = new Date(current);
      while (d.getDay() !== targetDay) d.setDate(d.getDate() + 1);

      while (d <= limit) {
        expanded.push({
          ...event,
          id: `${event.id}-${d.toISOString().slice(0, 10)}`,
          date: d.toISOString().slice(0, 10),
        });
        d.setDate(d.getDate() + 7);
      }
    } else {
      expanded.push(event);
    }
  }

  return expanded;
}

// ---------------------------------------------------------------------------
// Hardcoded Cape Cod Events (MVP — 35 events)
// ---------------------------------------------------------------------------

function getHardcodedEvents() {
  return [
    {
      id: 'wellfleet-oysterfest-2025',
      name: 'Wellfleet OysterFest',
      description: 'Annual celebration of Wellfleet\'s famous oyster industry featuring shucking contests, live music, local food vendors, art shows, and family activities. One of Cape Cod\'s most beloved fall festivals.',
      date: '2025-10-18',
      endDate: '2025-10-19',
      time: '10:00 AM - 5:00 PM',
      location: 'Main Street, Wellfleet',
      town: 'Wellfleet',
      category: 'festivals',
      venue: 'Wellfleet Town Center',
      imageUrl: null,
      website: 'https://www.wellfleetoysterfest.org',
      isFree: false,
      price: '$5 suggested donation',
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'ptown-carnival-2025',
      name: 'Provincetown Carnival',
      description: 'A week-long celebration with themed parades, costumes, live entertainment, street performances, and parties throughout Provincetown. The grand parade on Commercial Street is the highlight.',
      date: '2025-08-11',
      endDate: '2025-08-17',
      time: '12:00 PM - 11:00 PM',
      location: 'Commercial Street, Provincetown',
      town: 'Provincetown',
      category: 'festivals',
      venue: 'Commercial Street',
      imageUrl: null,
      website: 'https://pfranciscarn.org',
      isFree: true,
      price: null,
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'chatham-band-concert',
      name: 'Chatham Band Concert',
      description: 'The Chatham Band performs a free concert every Friday evening at Kate Gould Park. Bring a blanket and enjoy classic American band music under the stars. A Cape Cod summer tradition since 1931.',
      date: '2025-06-27',
      endDate: null,
      time: '8:00 PM - 10:00 PM',
      location: 'Kate Gould Park, Chatham',
      town: 'Chatham',
      category: 'concerts',
      venue: 'Kate Gould Park',
      imageUrl: null,
      website: 'https://chathamband.com',
      isFree: true,
      price: null,
      isRecurring: true,
      recurrenceRule: 'weekly',
      recurringEndDate: '2025-09-05',
    },
    {
      id: 'barnstable-county-fair-2025',
      name: 'Barnstable County Fair',
      description: 'The Cape\'s biggest fair with carnival rides, livestock shows, demolition derby, live music, craft exhibits, and fried dough. A week-long celebration of Cape Cod agriculture and community.',
      date: '2025-07-20',
      endDate: '2025-07-26',
      time: '12:00 PM - 10:00 PM',
      location: 'Route 151, East Falmouth',
      town: 'Falmouth',
      category: 'festivals',
      venue: 'Barnstable County Fairgrounds',
      imageUrl: null,
      website: 'https://www.barnstablecountyfair.org',
      isFree: false,
      price: '$15 adults, $5 children',
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'cape-cod-canal-day-2025',
      name: 'Cape Cod Canal Day',
      description: 'Celebrate the Cape Cod Canal with guided walks, bike rides, fishing demonstrations, live music, food trucks, and historical exhibits about the canal\'s fascinating history.',
      date: '2025-07-26',
      endDate: null,
      time: '10:00 AM - 4:00 PM',
      location: 'Cape Cod Canal Visitor Center, Sandwich',
      town: 'Sandwich',
      category: 'festivals',
      venue: 'Cape Cod Canal Visitor Center',
      imageUrl: null,
      website: 'https://www.capecodcanal.us',
      isFree: true,
      price: null,
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'hyannis-harborfest-2025',
      name: 'Hyannis HarborFest',
      description: 'Downtown Hyannis comes alive with live music, local food vendors, art displays, boat rides, and family activities along the scenic harbor.',
      date: '2025-06-07',
      endDate: '2025-06-08',
      time: '11:00 AM - 8:00 PM',
      location: 'Bismore Park, Hyannis',
      town: 'Barnstable',
      category: 'festivals',
      venue: 'Hyannis Harbor',
      imageUrl: null,
      website: 'https://www.hyannismainstreet.com',
      isFree: true,
      price: null,
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'orleans-fireworks-2025',
      name: 'Orleans Fireworks',
      description: 'Spectacular Fourth of July fireworks display over Rock Harbor in Orleans. Arrive early for live music and food. One of the best fireworks shows on the Cape.',
      date: '2025-07-04',
      endDate: null,
      time: '9:00 PM',
      location: 'Rock Harbor, Orleans',
      town: 'Orleans',
      category: 'family',
      venue: 'Rock Harbor',
      imageUrl: null,
      website: 'https://www.orleanscapecod.org',
      isFree: true,
      price: null,
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'brewster-in-bloom-2025',
      name: 'Brewster in Bloom',
      description: 'A spring festival featuring a garden tour, plant sale, craft fair, parade, live music, and children\'s activities. Celebrates the beauty of Brewster in bloom.',
      date: '2025-04-26',
      endDate: '2025-04-27',
      time: '10:00 AM - 4:00 PM',
      location: 'Route 6A, Brewster',
      town: 'Brewster',
      category: 'festivals',
      venue: 'Brewster Town Center',
      imageUrl: null,
      website: 'https://www.brewsterinbloom.org',
      isFree: true,
      price: null,
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'falmouth-road-race-2025',
      name: 'Falmouth Road Race',
      description: 'One of the most prestigious road races in the world — a 7-mile course from Woods Hole to Falmouth Heights along the coast. Elite and amateur runners compete. Registration opens in spring.',
      date: '2025-08-17',
      endDate: null,
      time: '10:00 AM',
      location: 'Woods Hole to Falmouth Heights',
      town: 'Falmouth',
      category: 'sports',
      venue: 'Falmouth Heights Beach (Finish)',
      imageUrl: null,
      website: 'https://falmouthroadrace.com',
      isFree: false,
      price: '$100 registration',
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'cc-symphony-summer-2025',
      name: 'Cape Cod Symphony Orchestra Summer Concert',
      description: 'The Cape Cod Symphony performs its summer pops concert featuring beloved classical and popular music. An outdoor musical experience under the Cape Cod sky.',
      date: '2025-08-02',
      endDate: null,
      time: '7:30 PM',
      location: 'Eldredge Park, Orleans',
      town: 'Orleans',
      category: 'concerts',
      venue: 'Eldredge Park',
      imageUrl: null,
      website: 'https://www.capesymphony.org',
      isFree: false,
      price: '$30-$60',
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'harwich-cranberry-festival-2025',
      name: 'Harwich Cranberry Arts & Music Festival',
      description: 'Celebrate Cape Cod\'s cranberry heritage with arts, crafts, live music, food vendors, fireworks, and a parade. Held at Brooks Park in Harwich.',
      date: '2025-09-13',
      endDate: '2025-09-14',
      time: '10:00 AM - 5:00 PM',
      location: 'Brooks Park, Harwich',
      town: 'Harwich',
      category: 'festivals',
      venue: 'Brooks Park',
      imageUrl: null,
      website: 'https://harwichcranberryfestival.org',
      isFree: true,
      price: null,
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'farmers-market-orleans',
      name: 'Orleans Farmers\' Market',
      description: 'Fresh local produce, baked goods, artisan cheeses, flowers, and crafts from Cape Cod farmers and makers. Rain or shine every Saturday morning.',
      date: '2025-06-07',
      endDate: null,
      time: '8:00 AM - 12:00 PM',
      location: '21 Old Colony Way, Orleans',
      town: 'Orleans',
      category: 'markets',
      venue: 'Old Colony Way',
      imageUrl: null,
      website: 'https://www.orleansfarmersmarket.com',
      isFree: true,
      price: null,
      isRecurring: true,
      recurrenceRule: 'weekly',
      recurringEndDate: '2025-10-25',
    },
    {
      id: 'farmers-market-chatham',
      name: 'Chatham Farmers\' Market',
      description: 'Weekly farmers\' market at the elementary school featuring local produce, seafood, baked goods, and handmade crafts.',
      date: '2025-06-10',
      endDate: null,
      time: '3:00 PM - 6:00 PM',
      location: 'Chatham Elementary School',
      town: 'Chatham',
      category: 'markets',
      venue: 'Chatham Elementary School',
      imageUrl: null,
      website: 'https://www.chathamfarmersmarket.com',
      isFree: true,
      price: null,
      isRecurring: true,
      recurrenceRule: 'weekly',
      recurringEndDate: '2025-09-30',
    },
    {
      id: 'farmers-market-falmouth',
      name: 'Falmouth Farmers Market',
      description: 'One of the largest farmers\' markets on the Cape with 40+ vendors offering produce, seafood, baked goods, flowers, and live music.',
      date: '2025-06-12',
      endDate: null,
      time: '12:00 PM - 5:00 PM',
      location: 'Marine Park, Falmouth',
      town: 'Falmouth',
      category: 'markets',
      venue: 'Marine Park',
      imageUrl: null,
      website: null,
      isFree: true,
      price: null,
      isRecurring: true,
      recurrenceRule: 'weekly',
      recurringEndDate: '2025-10-09',
    },
    {
      id: 'wellfleet-drivein-2025',
      name: 'Wellfleet Drive-In Theatre',
      description: 'New England\'s only remaining drive-in theater shows double features all summer long. Also hosts a flea market on weekends. A beloved Cape Cod institution since 1957.',
      date: '2025-05-24',
      endDate: null,
      time: '8:30 PM (dusk)',
      location: '51 Route 6, Wellfleet',
      town: 'Wellfleet',
      category: 'theater',
      venue: 'Wellfleet Drive-In Theatre',
      imageUrl: null,
      website: 'https://www.wellfleetcinemas.com',
      isFree: false,
      price: '$14 adults, $10 children',
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'ptown-film-fest-2025',
      name: 'Provincetown International Film Festival',
      description: 'Annual film festival showcasing independent films, documentaries, and shorts with filmmaker Q&As, panels, and parties. Draws filmmakers and cinephiles from around the world.',
      date: '2025-06-18',
      endDate: '2025-06-22',
      time: 'Varies',
      location: 'Various venues, Provincetown',
      town: 'Provincetown',
      category: 'theater',
      venue: 'Various',
      imageUrl: null,
      website: 'https://www.provincetownfilm.org',
      isFree: false,
      price: '$15-$20 per screening',
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'nauset-surf-comp-2025',
      name: 'Nauset Beach Surf Competition',
      description: 'Annual amateur and pro surf competition at Nauset Beach. Watch Cape Cod\'s best surfers compete in the Atlantic swells. Food trucks and beach vibes all day.',
      date: '2025-08-09',
      endDate: '2025-08-10',
      time: '7:00 AM - 4:00 PM',
      location: 'Nauset Beach, Orleans',
      town: 'Orleans',
      category: 'sports',
      venue: 'Nauset Beach',
      imageUrl: null,
      website: null,
      isFree: true,
      price: null,
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'chatham-shark-center-2025',
      name: 'Chatham Shark Center Open House',
      description: 'Interactive exhibits about white sharks in Cape Cod waters, shark research updates, and educational programs for all ages. Meet the scientists tracking sharks off our coast.',
      date: '2025-06-14',
      endDate: '2025-09-01',
      time: '10:00 AM - 4:00 PM',
      location: '235 Orleans Road, Chatham',
      town: 'Chatham',
      category: 'family',
      venue: 'Atlantic White Shark Conservancy',
      imageUrl: null,
      website: 'https://www.atlanticwhiteshark.org',
      isFree: false,
      price: '$6 adults, $4 children',
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'ccmnh-whale-talk-2025',
      name: 'Cape Cod Museum of Natural History: Whale Watch Talk',
      description: 'Expert naturalists discuss humpback and right whale sightings in Cape Cod Bay. Learn about whale behavior, migration patterns, and conservation efforts.',
      date: '2025-07-12',
      endDate: null,
      time: '2:00 PM - 3:30 PM',
      location: '869 Route 6A, Brewster',
      town: 'Brewster',
      category: 'family',
      venue: 'Cape Cod Museum of Natural History',
      imageUrl: null,
      website: 'https://www.ccmnh.org',
      isFree: false,
      price: '$18 adults, $8 children',
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'cotuit-arts-show-2025',
      name: 'Cotuit Center for the Arts: Summer Musical',
      description: 'The Cotuit Center for the Arts presents its summer musical production featuring local talent. Intimate theater experience in a historic Cape Cod venue.',
      date: '2025-07-10',
      endDate: '2025-08-02',
      time: '7:30 PM',
      location: '4404 Falmouth Road, Cotuit',
      town: 'Barnstable',
      category: 'theater',
      venue: 'Cotuit Center for the Arts',
      imageUrl: null,
      website: 'https://www.cotuitcenterforthearts.org',
      isFree: false,
      price: '$30-$35',
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'sandwich-band-concert',
      name: 'Sandwich Town Band Concert',
      description: 'Free weekly summer concerts by the Sandwich Town Band on the Village Green. Bring lawn chairs and enjoy Americana music in a quintessential New England setting.',
      date: '2025-07-03',
      endDate: null,
      time: '7:00 PM - 8:30 PM',
      location: 'Village Green, Sandwich',
      town: 'Sandwich',
      category: 'concerts',
      venue: 'Sandwich Village Green',
      imageUrl: null,
      website: null,
      isFree: true,
      price: null,
      isRecurring: true,
      recurrenceRule: 'weekly',
      recurringEndDate: '2025-08-28',
    },
    {
      id: 'dennis-band-concert',
      name: 'Dennis Village Band Concert',
      description: 'Free Thursday evening band concerts at the Dennis Village Green bandstand. A wonderful Cape Cod summer tradition.',
      date: '2025-07-03',
      endDate: null,
      time: '7:00 PM - 8:30 PM',
      location: 'Dennis Village Green',
      town: 'Dennis',
      category: 'concerts',
      venue: 'Dennis Village Green Bandstand',
      imageUrl: null,
      website: null,
      isFree: true,
      price: null,
      isRecurring: true,
      recurrenceRule: 'weekly',
      recurringEndDate: '2025-08-28',
    },
    {
      id: 'yarmouth-seafood-fest-2025',
      name: 'Yarmouth Seaside Festival',
      description: 'Waterfront festival featuring fresh seafood, live music, craft beer, carnival rides, and a spectacular fireworks finale over the harbor.',
      date: '2025-07-12',
      endDate: '2025-07-13',
      time: '11:00 AM - 9:00 PM',
      location: 'Bass River Sports World, Yarmouth',
      town: 'Yarmouth',
      category: 'food',
      venue: 'Bass River Sports World',
      imageUrl: null,
      website: 'https://www.yarmouthseasidefestival.com',
      isFree: false,
      price: '$5 adults',
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'ptown-art-walk-2025',
      name: 'Provincetown Gallery Stroll',
      description: 'Free Friday evening gallery walk through Provincetown\'s world-renowned art galleries on Commercial Street. Meet artists, enjoy wine receptions, and explore new exhibitions.',
      date: '2025-07-04',
      endDate: null,
      time: '7:00 PM - 9:00 PM',
      location: 'Commercial Street, Provincetown',
      town: 'Provincetown',
      category: 'festivals',
      venue: 'Provincetown Art Association & Galleries',
      imageUrl: null,
      website: 'https://www.paam.org',
      isFree: true,
      price: null,
      isRecurring: true,
      recurrenceRule: 'weekly',
      recurringEndDate: '2025-09-26',
    },
    {
      id: 'wellfleet-art-gallery-walk',
      name: 'Wellfleet Art Gallery Walk',
      description: 'Saturday evening gallery crawl through Wellfleet\'s charming art galleries. Browse local and visiting artists\' work, enjoy refreshments, and soak in the creative energy.',
      date: '2025-07-05',
      endDate: null,
      time: '7:00 PM - 9:00 PM',
      location: 'Main Street & Commercial Street, Wellfleet',
      town: 'Wellfleet',
      category: 'festivals',
      venue: 'Wellfleet Art Galleries',
      imageUrl: null,
      website: null,
      isFree: true,
      price: null,
      isRecurring: true,
      recurrenceRule: 'weekly',
      recurringEndDate: '2025-09-27',
    },
    {
      id: 'nauset-lighthouse-tour-2025',
      name: 'Nauset Light Open House',
      description: 'Climb the iconic red and white Nauset Lighthouse for panoramic views of Nauset Beach and the Atlantic. Rangers share the lighthouse\'s history and maritime heritage.',
      date: '2025-05-25',
      endDate: null,
      time: '4:30 PM - 7:30 PM',
      location: 'Nauset Light Beach, Eastham',
      town: 'Eastham',
      category: 'family',
      venue: 'Nauset Lighthouse',
      imageUrl: null,
      website: 'https://www.nausetlight.org',
      isFree: true,
      price: null,
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'highland-lighthouse-tour-2025',
      name: 'Highland Lighthouse Tour',
      description: 'Tour Cape Cod\'s oldest and tallest lighthouse in Truro. Spectacular views from the top of the bluffs overlooking the Atlantic. Museum and gift shop on site.',
      date: '2025-06-01',
      endDate: '2025-10-15',
      time: '10:00 AM - 5:30 PM',
      location: '27 Highland Light Road, Truro',
      town: 'Truro',
      category: 'family',
      venue: 'Highland Lighthouse',
      imageUrl: null,
      website: 'https://www.highlandlighthouse.org',
      isFree: false,
      price: '$8 adults, $4 children',
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'sandwich-glass-museum-demo-2025',
      name: 'Sandwich Glass Museum: Glassblowing Demo',
      description: 'Watch live glassblowing demonstrations at the famous Sandwich Glass Museum. Master glassblowers create beautiful pieces using techniques from the 1800s.',
      date: '2025-07-05',
      endDate: null,
      time: '11:00 AM, 1:00 PM, 3:00 PM',
      location: '129 Main Street, Sandwich',
      town: 'Sandwich',
      category: 'family',
      venue: 'Sandwich Glass Museum',
      imageUrl: null,
      website: 'https://www.sandwichglassmuseum.org',
      isFree: false,
      price: '$10 adults, $3 children (museum admission)',
      isRecurring: true,
      recurrenceRule: 'weekly',
      recurringEndDate: '2025-09-06',
    },
    {
      id: 'cape-cod-baseball-league-2025',
      name: 'Cape Cod Baseball League Game',
      description: 'Watch future MLB stars play on Cape Cod! The Cape Cod Baseball League is the premier amateur baseball league. Games are free and held at fields across the Cape all summer.',
      date: '2025-06-14',
      endDate: null,
      time: '5:00 PM',
      location: 'Various fields across Cape Cod',
      town: 'Barnstable',
      category: 'sports',
      venue: 'Various Cape League Fields',
      imageUrl: null,
      website: 'https://www.capecodbaseball.org',
      isFree: true,
      price: null,
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'cape-cod-melody-tent-2025',
      name: 'Cape Cod Melody Tent Concert Season',
      description: 'The iconic in-the-round Melody Tent hosts national touring acts all summer — from classic rock to comedy. No seat is more than 50 feet from the stage.',
      date: '2025-06-15',
      endDate: '2025-09-06',
      time: 'Varies',
      location: '21 West Main Street, Hyannis',
      town: 'Barnstable',
      category: 'concerts',
      venue: 'Cape Cod Melody Tent',
      imageUrl: null,
      website: 'https://www.melodytent.org',
      isFree: false,
      price: '$35-$85',
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'truro-vineyards-music-2025',
      name: 'Truro Vineyards Live Music',
      description: 'Enjoy live music on the lawn at Truro Vineyards every Sunday afternoon. Sip local wines, sample from the South Hollow Spirits distillery, and relax in the vineyard.',
      date: '2025-06-29',
      endDate: null,
      time: '1:00 PM - 4:00 PM',
      location: '11 Shore Road, Truro',
      town: 'Truro',
      category: 'concerts',
      venue: 'Truro Vineyards',
      imageUrl: null,
      website: 'https://www.trurovineyardsofcapecod.com',
      isFree: true,
      price: null,
      isRecurring: true,
      recurrenceRule: 'weekly',
      recurringEndDate: '2025-09-28',
    },
    {
      id: 'mashpee-wampanoag-powwow-2025',
      name: 'Mashpee Wampanoag Powwow',
      description: 'The oldest powwow in the country celebrating the Mashpee Wampanoag tribe\'s heritage with traditional dancing, drumming, storytelling, and native food. A powerful cultural experience.',
      date: '2025-07-04',
      endDate: '2025-07-06',
      time: '10:00 AM - 6:00 PM',
      location: 'Route 130, Mashpee',
      town: 'Mashpee',
      category: 'festivals',
      venue: 'Mashpee Wampanoag Tribal Grounds',
      imageUrl: null,
      website: 'https://www.mashpeewampanoagtribe-nsn.gov',
      isFree: false,
      price: '$10 adults, $5 children',
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'cape-cod-st-patricks-parade-2025',
      name: 'Cape Cod St. Patrick\'s Day Parade',
      description: 'Annual St. Patrick\'s Day parade through Yarmouth featuring marching bands, floats, Irish dancers, bagpipers, and community groups. One of Cape Cod\'s biggest parades.',
      date: '2025-03-08',
      endDate: null,
      time: '11:00 AM',
      location: 'Route 28, Yarmouth',
      town: 'Yarmouth',
      category: 'parades',
      venue: 'Route 28',
      imageUrl: null,
      website: null,
      isFree: true,
      price: null,
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'hyannis-july4-parade-2025',
      name: 'Hyannis Fourth of July Parade',
      description: 'Patriotic parade through Main Street Hyannis featuring bands, veterans, floats, antique cars, and community organizations. A classic Independence Day celebration.',
      date: '2025-07-04',
      endDate: null,
      time: '10:00 AM',
      location: 'Main Street, Hyannis',
      town: 'Barnstable',
      category: 'parades',
      venue: 'Main Street, Hyannis',
      imageUrl: null,
      website: 'https://www.hyannismainstreet.com',
      isFree: true,
      price: null,
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'cape-cod-clam-bake-2025',
      name: 'Cape Cod Clambake at Wychmere Harbor',
      description: 'Traditional New England clambake on the beach with lobster, steamers, corn on the cob, and all the fixings. Live music and sunset views over Wychmere Harbor.',
      date: '2025-07-19',
      endDate: null,
      time: '5:00 PM - 9:00 PM',
      location: 'Wychmere Harbor, Harwich Port',
      town: 'Harwich',
      category: 'food',
      venue: 'Wychmere Harbor Beach Club',
      imageUrl: null,
      website: null,
      isFree: false,
      price: '$85 per person',
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
    {
      id: 'eastham-windmill-weekend-2025',
      name: 'Eastham Windmill Weekend',
      description: 'Annual festival at the oldest working windmill on Cape Cod. Arts and crafts fair, live entertainment, road race, square dancing, and windmill tours.',
      date: '2025-09-06',
      endDate: '2025-09-07',
      time: '10:00 AM - 5:00 PM',
      location: 'Windmill Green, Eastham',
      town: 'Eastham',
      category: 'festivals',
      venue: 'Eastham Windmill Green',
      imageUrl: null,
      website: 'https://www.easthamwindmillweekend.com',
      isFree: true,
      price: null,
      isRecurring: false,
      recurrenceRule: null,
      recurringEndDate: null,
    },
  ];
}
