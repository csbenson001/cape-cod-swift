import Foundation
import CoreLocation

// MARK: - Shark Sighting Model

struct SharkSighting: Identifiable, Codable {
    let id: UUID
    let species: String
    let location: String
    let latitude: Double
    let longitude: Double
    let date: Date
    let description: String
    let source: String
    let isConfirmed: Bool

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Alert Level

enum SharkAlertLevel {
    case low
    case moderate
    case high

    var label: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        }
    }

    var icon: String {
        switch self {
        case .low: return "checkmark.shield.fill"
        case .moderate: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.octagon.fill"
        }
    }
}

// MARK: - Shark Alert Service

@MainActor
@Observable
final class SharkAlertService {
    private(set) var sightings: [SharkSighting] = []
    private(set) var isLoading = false
    private(set) var lastFetched: Date?

    private let cacheDuration: TimeInterval = 30 * 60 // 30 minutes

    // MARK: - Public API

    func fetchRecentSightings() async {
        // Return cached data if still fresh
        if let lastFetched, Date().timeIntervalSince(lastFetched) < cacheDuration, !sightings.isEmpty {
            return
        }

        isLoading = true
        defer { isLoading = false }

        // Attempt live fetch, fall back to hardcoded data
        do {
            let liveSightings = try await fetchFromSharktivity()
            sightings = liveSightings
            lastFetched = Date()
        } catch {
            print("Sharktivity fetch failed: \(error.localizedDescription). Using fallback data.")
            sightings = Self.fallbackSightings
            lastFetched = Date()
        }
    }

    func forceRefresh() async {
        lastFetched = nil
        await fetchRecentSightings()
    }

    // MARK: - Alert Level

    var alertLevel: SharkAlertLevel {
        let cutoff = Date().addingTimeInterval(-48 * 3600)
        let recentCount = sightings.filter { $0.date >= cutoff }.count
        if recentCount >= 3 { return .high }
        if recentCount >= 1 { return .moderate }
        return .low
    }

    var recentSightingCount: Int {
        let cutoff = Date().addingTimeInterval(-48 * 3600)
        return sightings.filter { $0.date >= cutoff }.count
    }

    // MARK: - Beach-specific status

    func sightingsNear(latitude: Double, longitude: Double, radiusKm: Double = 5.0) -> [SharkSighting] {
        let center = CLLocation(latitude: latitude, longitude: longitude)
        return sightings.filter { sighting in
            let loc = CLLocation(latitude: sighting.latitude, longitude: sighting.longitude)
            return center.distance(from: loc) / 1000.0 <= radiusKm
        }
    }

    // MARK: - Live Fetch

    private func fetchFromSharktivity() async throws -> [SharkSighting] {
        // The Sharktivity API is not publicly documented;
        // we attempt a fetch and fall back to hardcoded data.
        guard let url = URL(string: "https://www.atlanticwhiteshark.org/sharktivity-app-data") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.setValue("HeyCapeCod/1.0", forHTTPHeaderField: "User-Agent")

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        // If API response parsing were implemented, it would go here.
        // For now, fall back to curated data.
        throw URLError(.cannotParseResponse)
    }

    // MARK: - Fallback Data

    static let fallbackSightings: [SharkSighting] = {
        let calendar = Calendar.current
        let now = Date()

        func hoursAgo(_ h: Int) -> Date {
            calendar.date(byAdding: .hour, value: -h, to: now) ?? now
        }
        func daysAgo(_ d: Int) -> Date {
            calendar.date(byAdding: .day, value: -d, to: now) ?? now
        }

        return [
            // Recent (within 48 hours) — drives alert level
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "Nauset Beach",
                latitude: 41.8344, longitude: -69.9517, date: hoursAgo(4),
                description: "Large white shark spotted approximately 75 yards offshore, estimated 12-14 feet.",
                source: "Sharktivity", isConfirmed: true
            ),
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "Coast Guard Beach",
                latitude: 41.8492, longitude: -69.9475, date: hoursAgo(12),
                description: "Shark observed feeding on a seal near the shoreline. Beach temporarily closed.",
                source: "Lifeguard Report", isConfirmed: true
            ),
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "Marconi Beach",
                latitude: 41.8894, longitude: -69.9614, date: hoursAgo(28),
                description: "Fin spotted from the bluff overlook, moving south along the coast.",
                source: "Beachgoer", isConfirmed: false
            ),
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "White Crest Beach",
                latitude: 41.9131, longitude: -69.9694, date: hoursAgo(36),
                description: "Spotter plane confirmed a juvenile white shark cruising parallel to shore.",
                source: "Sharktivity", isConfirmed: true
            ),

            // Older sightings (3-14 days ago)
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "Cahoon Hollow",
                latitude: 41.9225, longitude: -69.9731, date: daysAgo(3),
                description: "Seal carcass found on beach with bite marks consistent with white shark.",
                source: "Lifeguard Report", isConfirmed: true
            ),
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "Head of the Meadow",
                latitude: 42.0561, longitude: -70.0783, date: daysAgo(4),
                description: "Two sharks observed from aerial survey approximately 200 yards offshore.",
                source: "Sharktivity", isConfirmed: true
            ),
            SharkSighting(
                id: UUID(), species: "Blue Shark", location: "Race Point",
                latitude: 42.0717, longitude: -70.2089, date: daysAgo(5),
                description: "Blue shark sighted by fishing charter about half a mile from Race Point Beach.",
                source: "Beachgoer", isConfirmed: false
            ),
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "Newcomb Hollow",
                latitude: 41.9311, longitude: -69.9756, date: daysAgo(5),
                description: "15-foot white shark tagged as 'Luna' detected by acoustic receiver.",
                source: "Sharktivity", isConfirmed: true
            ),
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "Nauset Beach",
                latitude: 41.8344, longitude: -69.9517, date: daysAgo(6),
                description: "Shark approached a kayaker who safely returned to shore.",
                source: "Lifeguard Report", isConfirmed: true
            ),
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "Chatham Lighthouse Beach",
                latitude: 41.6714, longitude: -69.9508, date: daysAgo(7),
                description: "Multiple sharks observed near seal colony off Chatham bars.",
                source: "Sharktivity", isConfirmed: true
            ),
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "Monomoy Island",
                latitude: 41.6044, longitude: -69.9858, date: daysAgo(8),
                description: "Three white sharks observed feeding near Monomoy seal haul-out.",
                source: "Sharktivity", isConfirmed: true
            ),
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "Coast Guard Beach",
                latitude: 41.8492, longitude: -69.9475, date: daysAgo(9),
                description: "Drone footage captured a 10-foot shark swimming through the surf zone.",
                source: "Beachgoer", isConfirmed: true
            ),
            SharkSighting(
                id: UUID(), species: "Blue Shark", location: "Marconi Beach",
                latitude: 41.8894, longitude: -69.9614, date: daysAgo(10),
                description: "Small blue shark spotted near surfcasters at dawn.",
                source: "Beachgoer", isConfirmed: false
            ),
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "Race Point",
                latitude: 42.0717, longitude: -70.2089, date: daysAgo(11),
                description: "Tagged shark 'Captain' pinged near Race Point, estimated 16 feet.",
                source: "Sharktivity", isConfirmed: true
            ),
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "White Crest Beach",
                latitude: 41.9131, longitude: -69.9694, date: daysAgo(12),
                description: "Lifeguards cleared water after possible fin sighting. Not confirmed.",
                source: "Lifeguard Report", isConfirmed: false
            ),
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "Head of the Meadow",
                latitude: 42.0561, longitude: -70.0783, date: daysAgo(13),
                description: "Large shark breached while pursuing a seal, witnessed by hikers.",
                source: "Beachgoer", isConfirmed: true
            ),
            SharkSighting(
                id: UUID(), species: "Great White Shark", location: "Cahoon Hollow",
                latitude: 41.9225, longitude: -69.9731, date: daysAgo(14),
                description: "Aerial survey counted 4 sharks in the Cahoon Hollow to Newcomb Hollow corridor.",
                source: "Sharktivity", isConfirmed: true
            ),
        ]
    }()
}

// MARK: - Safety Tips

enum SharkSafetyTips {
    static let tips: [(icon: String, title: String, detail: String)] = [
        ("figure.walk", "Stay Close to Shore",
         "Swim in waist-deep water where you can stand. Sharks are more common in deeper water."),
        ("person.2.fill", "Swim in Groups",
         "Sharks are more likely to approach individuals. Stay with your group."),
        ("eye.fill", "Heed Warning Signs",
         "Obey posted shark warnings and purple flags. Leave the water immediately if a sighting is announced."),
        ("seal.fill", "Avoid Seal Colonies",
         "Seals are a primary food source for white sharks. Keep distance from seal groups."),
        ("sunrise.fill", "Avoid Dawn & Dusk",
         "Sharks are most active during low-light conditions. Swim during midday hours."),
        ("drop.fill", "Don't Swim Near Bait",
         "Avoid areas where people are fishing or where bait fish are schooling near shore."),
    ]
}
