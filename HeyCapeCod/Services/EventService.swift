import Foundation

// MARK: - Cape Cod Event Model

struct CapeCodEvent: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let date: String
    let endDate: String?
    let time: String
    let location: String
    let town: String
    let category: String
    let venue: String
    let imageUrl: String?
    let website: String?
    let isFree: Bool
    let price: String?
    let isRecurring: Bool

    var parsedDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date) ?? .now
    }

    var parsedEndDate: Date? {
        guard let endDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: endDate)
    }

    var categoryIcon: String {
        switch category.lowercased() {
        case "festivals": return "party.popper.fill"
        case "concerts": return "music.note"
        case "markets": return "basket.fill"
        case "parades": return "flag.fill"
        case "theater": return "theatermasks.fill"
        case "sports": return "figure.run"
        case "family": return "person.2.fill"
        case "food": return "fork.knife"
        default: return "calendar"
        }
    }

    var categoryColor: CodEventCategoryColor {
        switch category.lowercased() {
        case "festivals": return .festivals
        case "concerts": return .concerts
        case "markets": return .markets
        case "parades": return .parades
        case "theater": return .theater
        case "sports": return .sports
        case "family": return .family
        case "food": return .food
        default: return .festivals
        }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: parsedDate)
    }

    var formattedDateRange: String {
        guard let end = parsedEndDate else { return formattedDate }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: parsedDate)) - \(formatter.string(from: end))"
    }
}

enum CodEventCategoryColor {
    case festivals, concerts, markets, parades, theater, sports, family, food
}

// MARK: - Events API Response

struct EventsResponse: Codable {
    let events: [CapeCodEvent]
    let count: Int
    let total: Int
    let dateRange: EventDateRange
}

struct EventDateRange: Codable {
    let start: String
    let end: String
}

// MARK: - Event Category

enum EventCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case festivals = "Festivals"
    case concerts = "Concerts"
    case markets = "Markets"
    case parades = "Parades"
    case theater = "Theater"
    case sports = "Sports"
    case family = "Family"
    case food = "Food"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "sparkles"
        case .festivals: return "party.popper.fill"
        case .concerts: return "music.note"
        case .markets: return "basket.fill"
        case .parades: return "flag.fill"
        case .theater: return "theatermasks.fill"
        case .sports: return "figure.run"
        case .family: return "person.2.fill"
        case .food: return "fork.knife"
        }
    }

    var queryValue: String? {
        self == .all ? nil : rawValue.lowercased()
    }
}

// MARK: - Event Town Filter

enum EventTownFilter: String, CaseIterable, Identifiable {
    case all = "All Towns"
    case barnstable = "Barnstable"
    case bourne = "Bourne"
    case brewster = "Brewster"
    case chatham = "Chatham"
    case dennis = "Dennis"
    case eastham = "Eastham"
    case falmouth = "Falmouth"
    case harwich = "Harwich"
    case mashpee = "Mashpee"
    case orleans = "Orleans"
    case provincetown = "Provincetown"
    case sandwich = "Sandwich"
    case truro = "Truro"
    case wellfleet = "Wellfleet"
    case yarmouth = "Yarmouth"

    var id: String { rawValue }

    var queryValue: String? {
        self == .all ? nil : rawValue
    }
}

// MARK: - Event Service

@preconcurrency @MainActor
@Observable
final class EventService {
    private(set) var events: [CapeCodEvent] = []
    private(set) var isLoading = false
    private(set) var error: Error?
    private(set) var lastFetched: Date?

    private static let cacheLifetime: TimeInterval = 3600 // 1 hour

    private var cachedEvents: [String: CachedEvents] = [:]

    private struct CachedEvents {
        let events: [CapeCodEvent]
        let fetchedAt: Date
        var isExpired: Bool {
            Date().timeIntervalSince(fetchedAt) > EventService.cacheLifetime
        }
    }

    // MARK: - Public API

    func fetchEvents(
        startDate: Date? = nil,
        endDate: Date? = nil,
        category: EventCategory = .all,
        town: EventTownFilter = .all
    ) async -> [CapeCodEvent] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let start = startDate ?? Date()
        let end = endDate ?? Calendar.current.date(byAdding: .day, value: 30, to: start) ?? start

        let cacheKey = "\(formatter.string(from: start)):\(formatter.string(from: end)):\(category.rawValue):\(town.rawValue)"

        // Return cached if fresh
        if let cached = cachedEvents[cacheKey], !cached.isExpired {
            events = cached.events
            return cached.events
        }

        isLoading = true
        error = nil

        do {
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: "startDate", value: formatter.string(from: start)),
                URLQueryItem(name: "endDate", value: formatter.string(from: end)),
            ]
            if let cat = category.queryValue {
                queryItems.append(URLQueryItem(name: "category", value: cat))
            }
            if let t = town.queryValue {
                queryItems.append(URLQueryItem(name: "town", value: t))
            }

            let response: EventsResponse = try await APIClient.shared.get("/events", queryItems: queryItems)
            events = response.events
            cachedEvents[cacheKey] = CachedEvents(events: response.events, fetchedAt: .now)
            lastFetched = .now
            isLoading = false
            return response.events
        } catch {
            print("Event fetch failed, using fallback: \(error.localizedDescription)")
            self.error = error
            isLoading = false
            let fallback = Self.fallbackEvents(category: category, town: town)
            events = fallback
            return fallback
        }
    }

    func fetchUpcomingEvents(days: Int = 7) async -> [CapeCodEvent] {
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: days, to: start)
        return await fetchEvents(startDate: start, endDate: end)
    }

    func fetchThisWeekend() async -> [CapeCodEvent] {
        let cal = Calendar.current
        let today = Date()
        let weekday = cal.component(.weekday, from: today)
        // Saturday = 7, Sunday = 1
        let daysUntilSaturday = (7 - weekday) % 7
        let saturday = cal.date(byAdding: .day, value: max(daysUntilSaturday, 0), to: today) ?? today
        let sunday = cal.date(byAdding: .day, value: 1, to: saturday) ?? saturday
        return await fetchEvents(startDate: saturday, endDate: sunday)
    }

    func clearCache() {
        cachedEvents.removeAll()
    }

    // MARK: - Fallback Events

    static func fallbackEvents(category: EventCategory = .all, town: EventTownFilter = .all) -> [CapeCodEvent] {
        var events = hardcodedFallbackEvents
        if let cat = category.queryValue {
            events = events.filter { $0.category.lowercased() == cat }
        }
        if let t = town.queryValue {
            events = events.filter { $0.town == t }
        }
        return events
    }

    private static let hardcodedFallbackEvents: [CapeCodEvent] = [
        CapeCodEvent(id: "fallback-oysterfest", name: "Wellfleet OysterFest", description: "Annual celebration of Wellfleet's famous oyster industry featuring shucking contests, live music, local food vendors, and family activities.", date: "2025-10-18", endDate: "2025-10-19", time: "10:00 AM - 5:00 PM", location: "Main Street, Wellfleet", town: "Wellfleet", category: "festivals", venue: "Wellfleet Town Center", imageUrl: nil, website: "https://www.wellfleetoysterfest.org", isFree: false, price: "$5 suggested donation", isRecurring: false),
        CapeCodEvent(id: "fallback-ptown-carnival", name: "Provincetown Carnival", description: "Week-long celebration with themed parades, costumes, live entertainment, and parties throughout Provincetown.", date: "2025-08-11", endDate: "2025-08-17", time: "12:00 PM - 11:00 PM", location: "Commercial Street, Provincetown", town: "Provincetown", category: "festivals", venue: "Commercial Street", imageUrl: nil, website: "https://pfranciscarn.org", isFree: true, price: nil, isRecurring: false),
        CapeCodEvent(id: "fallback-chatham-band", name: "Chatham Band Concert", description: "Free Friday evening concerts at Kate Gould Park. A Cape Cod summer tradition since 1931.", date: "2025-07-04", endDate: nil, time: "8:00 PM - 10:00 PM", location: "Kate Gould Park, Chatham", town: "Chatham", category: "concerts", venue: "Kate Gould Park", imageUrl: nil, website: "https://chathamband.com", isFree: true, price: nil, isRecurring: true),
        CapeCodEvent(id: "fallback-barnstable-fair", name: "Barnstable County Fair", description: "The Cape's biggest fair with carnival rides, livestock shows, demolition derby, live music, and fried dough.", date: "2025-07-20", endDate: "2025-07-26", time: "12:00 PM - 10:00 PM", location: "Route 151, East Falmouth", town: "Falmouth", category: "festivals", venue: "Barnstable County Fairgrounds", imageUrl: nil, website: "https://www.barnstablecountyfair.org", isFree: false, price: "$15 adults, $5 children", isRecurring: false),
        CapeCodEvent(id: "fallback-falmouth-race", name: "Falmouth Road Race", description: "One of the most prestigious road races in the world. A 7-mile course from Woods Hole to Falmouth Heights.", date: "2025-08-17", endDate: nil, time: "10:00 AM", location: "Woods Hole to Falmouth Heights", town: "Falmouth", category: "sports", venue: "Falmouth Heights Beach", imageUrl: nil, website: "https://falmouthroadrace.com", isFree: false, price: "$100 registration", isRecurring: false),
        CapeCodEvent(id: "fallback-orleans-fireworks", name: "Orleans Fireworks", description: "Spectacular Fourth of July fireworks display over Rock Harbor in Orleans.", date: "2025-07-04", endDate: nil, time: "9:00 PM", location: "Rock Harbor, Orleans", town: "Orleans", category: "family", venue: "Rock Harbor", imageUrl: nil, website: nil, isFree: true, price: nil, isRecurring: false),
        CapeCodEvent(id: "fallback-farmers-market", name: "Orleans Farmers' Market", description: "Fresh local produce, baked goods, artisan cheeses, and crafts every Saturday morning.", date: "2025-07-05", endDate: nil, time: "8:00 AM - 12:00 PM", location: "21 Old Colony Way, Orleans", town: "Orleans", category: "markets", venue: "Old Colony Way", imageUrl: nil, website: nil, isFree: true, price: nil, isRecurring: true),
        CapeCodEvent(id: "fallback-melody-tent", name: "Cape Cod Melody Tent", description: "The iconic in-the-round Melody Tent hosts national touring acts all summer.", date: "2025-07-15", endDate: nil, time: "8:00 PM", location: "21 West Main Street, Hyannis", town: "Barnstable", category: "concerts", venue: "Cape Cod Melody Tent", imageUrl: nil, website: "https://www.melodytent.org", isFree: false, price: "$35-$85", isRecurring: false),
    ]
}
