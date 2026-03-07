import Foundation

/// Fetches POI and story data from the backend API.
/// Replaces hardcoded BundledContent with live data,
/// falling back to bundled content when offline.
@Observable
final class POIService {
    static let shared = POIService()

    private(set) var allPOIs: [APIPOI] = []
    private(set) var isLoading = false
    private(set) var lastError: Error?

    private let api = APIClient.shared

    private init() {}

    // MARK: - Fetch All POIs

    func fetchAllPOIs(category: String? = nil, town: String? = nil) async {
        isLoading = true
        defer { isLoading = false }

        var query: [String: String] = [:]
        if let category { query["category"] = category }
        if let town { query["town"] = town }

        do {
            let response: APIPOIListResponse = try await api.get("/api/pois", query: query)
            allPOIs = response.pois
            lastError = nil
            print("[POIService] Loaded \(response.count) POIs")
        } catch {
            print("[POIService] Error fetching POIs: \(error)")
            lastError = error
            // Keep existing data if we had some
        }
    }

    // MARK: - Fetch Nearby POIs (for GeofenceManager)

    func fetchNearbyPOIs(lat: Double, lng: Double, radius: Double = 10000) async -> [APIPOI] {
        do {
            let response: APIPOIListResponse = try await api.get("/api/pois/nearby", query: [
                "lat": String(lat),
                "lng": String(lng),
                "radius": String(Int(radius)),
            ])
            print("[POIService] Loaded \(response.count) nearby POIs")
            return response.pois
        } catch {
            print("[POIService] Error fetching nearby POIs: \(error)")
            return []
        }
    }

    // MARK: - Fetch POI Detail (with stories)

    func fetchPOIDetail(id: String) async -> APIPOIDetail? {
        do {
            let detail: APIPOIDetail = try await api.get("/api/pois/\(id)")
            print("[POIService] Loaded detail for \(detail.name)")
            return detail
        } catch {
            print("[POIService] Error fetching POI detail: \(error)")
            return nil
        }
    }

    // MARK: - Fetch Stories

    func fetchStories(mode: String? = nil, category: String? = nil) async -> [APIStory] {
        var query: [String: String] = [:]
        if let mode { query["mode"] = mode }
        if let category { query["category"] = category }

        do {
            let response: APIStoryListResponse = try await api.get("/api/stories", query: query)
            return response.stories
        } catch {
            print("[POIService] Error fetching stories: \(error)")
            return []
        }
    }

    func fetchStoryDetail(id: String) async -> APIStory? {
        do {
            return try await api.get("/api/stories/\(id)")
        } catch {
            print("[POIService] Error fetching story detail: \(error)")
            return nil
        }
    }
}

// MARK: - API Response Models

struct APIPOIListResponse: Codable {
    let pois: [APIPOI]
    let count: Int
}

struct APIPOI: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    let radius: Double?
    let category: String
    let town: String
    let storyCount: Int?
    let facts: [String]?
    let tips: [String]?
    let priority: Int?
    let distance: Int? // present in nearby responses

    static func == (lhs: APIPOI, rhs: APIPOI) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct APIPOIDetail: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    let radius: Double?
    let category: String
    let town: String
    let address: String?
    let imageUrl: String?
    let facts: [String]?
    let tips: [String]?
    let stories: [APIStory]?
    let relatedPoiIds: [String]?
    let priority: Int?
}

struct APIStoryListResponse: Codable {
    let stories: [APIStory]
    let count: Int
}

struct APIStory: Codable, Identifiable {
    let id: String
    let poiId: String?
    let title: String
    let mode: String?
    let category: String?
    let script: String?
    let durationSeconds: Int?
    let isPremium: Bool?
    let narratorVoice: String?
    let tags: [String]?
    let sortOrder: Int?
}
