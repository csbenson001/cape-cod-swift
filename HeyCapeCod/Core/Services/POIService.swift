import Foundation

/// Fetches POI and story data from the backend API.
/// Falls back to BundledContent when offline.
///
/// Data loading strategy (three-tier):
/// 1. SwiftData cache (fastest — loaded on launch)
/// 2. API fetch (freshest — replaces cache on success)
/// 3. BundledContent (always available — never deleted)
@MainActor
@Observable
final class POIService {
    nonisolated(unsafe) static let shared = POIService()

    private(set) var allPOIs: [POI] = []
    private(set) var nearbyPOIs: [POI] = []
    private(set) var isLoading = false
    var error: String?

    private let api = APIClient.shared
    private let cache = POICacheManager.shared

    private init() {
        // Tier 1: Try SwiftData cache first
        let cached = cache.loadCachedPOIs()
        if !cached.isEmpty {
            allPOIs = cached
            print("💾 Loaded \(cached.count) POIs from cache")
        } else {
            // Tier 3: Fall back to bundled content
            allPOIs = BundledContent.allPOIs.map { $0.toPOI() }
            print("📦 Using bundled content (\(allPOIs.count) POIs)")
        }
    }

    // MARK: - Fetch All POIs

    func fetchAllPOIs() async {
        isLoading = true
        defer { isLoading = false }

        // Tier 2: Fetch from API
        do {
            let response: POIListResponse = try await api.get("/pois")
            allPOIs = response.pois
            error = nil
            // Update SwiftData cache
            cache.savePOIs(response.pois)
            print("✅ Loaded \(response.count) POIs from API")
        } catch {
            print("❌ API error fetching POIs: \(error.localizedDescription)")
            self.error = error.localizedDescription
            if allPOIs.isEmpty {
                allPOIs = BundledContent.allPOIs.map { $0.toPOI() }
                print("📦 Using bundled content (offline)")
            }
        }
    }

    // MARK: - Fetch Nearby POIs

    func fetchNearbyPOIs(lat: Double, lng: Double, radius: Int = 10000) async {
        do {
            let response: POIListResponse = try await api.get("/pois/nearby", queryItems: [
                URLQueryItem(name: "lat", value: String(lat)),
                URLQueryItem(name: "lng", value: String(lng)),
                URLQueryItem(name: "radius", value: String(radius)),
            ])
            nearbyPOIs = response.pois
            print("✅ Loaded \(response.count) nearby POIs")
        } catch {
            print("❌ Error fetching nearby POIs: \(error.localizedDescription)")
            nearbyPOIs = []
        }
    }

    /// Returns nearby POIs for GeofenceManager — returns array directly
    func fetchNearbyPOIsList(lat: Double, lng: Double, radius: Int = 15000) async -> [POI] {
        do {
            let response: POIListResponse = try await api.get("/pois/nearby", queryItems: [
                URLQueryItem(name: "lat", value: String(lat)),
                URLQueryItem(name: "lng", value: String(lng)),
                URLQueryItem(name: "radius", value: String(radius)),
            ])
            print("✅ Loaded \(response.count) nearby POIs for geofencing")
            return response.pois
        } catch {
            print("❌ Error fetching nearby POIs: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Fetch POI Detail

    func fetchPOIDetail(id: String) async -> POIDetailResponse? {
        do {
            let detail: POIDetailResponse = try await api.get("/pois/\(id)")
            print("✅ Loaded detail for \(detail.name)")
            return detail
        } catch {
            print("❌ Error fetching POI detail: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Fetch Stories

    func fetchStories(mode: ExperienceMode? = nil, category: String? = nil) async -> [APIStoryResponse] {
        var items: [URLQueryItem] = []
        if let mode { items.append(URLQueryItem(name: "mode", value: mode.rawValue)) }
        if let category { items.append(URLQueryItem(name: "category", value: category)) }

        do {
            let response: StoryListResponse = try await api.get("/stories", queryItems: items.isEmpty ? nil : items)
            return response.stories
        } catch {
            print("❌ Error fetching stories: \(error.localizedDescription)")
            return []
        }
    }

    func fetchStoryDetail(id: String) async -> APIStoryResponse? {
        do {
            return try await api.get("/stories/\(id)")
        } catch {
            print("❌ Error fetching story detail: \(error.localizedDescription)")
            return nil
        }
    }
}
