import Foundation
import CoreLocation

@MainActor
@Observable
final class ExploreViewModel {
    var locations: [CodLocation] = []
    var filteredLocations: [CodLocation] = []
    var selectedCategory: LocationCategory?
    var selectedTown: CapeCodTown?
    var selectedRegion: CapeRegion?
    var searchText = ""
    var isLoading = false
    var error: Error?
    var hasLoadedFromAPI = false
    var isOffline = false

    private let locationService: LocationService
    private let poiService = POIService.shared

    init(locationService: LocationService = LocationService()) {
        self.locationService = locationService
    }

    var categories: [LocationCategory] { LocationCategory.allCases }
    var towns: [CapeCodTown] { CapeCodTown.allCases }
    var regions: [CapeRegion] { CapeRegion.allCases }

    func applyFilters() {
        filteredLocations = locations.filter { location in
            var matches = true

            if let category = selectedCategory {
                matches = matches && location.category == category
            }
            if let town = selectedTown {
                matches = matches && location.town == town
            }
            if let region = selectedRegion {
                matches = matches && location.town.region == region
            }
            if !searchText.isEmpty {
                let query = searchText.lowercased()
                matches = matches && (
                    location.name.lowercased().contains(query) ||
                    location.description.lowercased().contains(query) ||
                    location.town.displayName.lowercased().contains(query)
                )
            }

            return matches
        }

        // Sort by distance if location available
        if let userLocation = locationService.currentLocation {
            filteredLocations.sort { a, b in
                let distA = userLocation.distance(from: a.clLocation)
                let distB = userLocation.distance(from: b.clLocation)
                return distA < distB
            }
        }
    }

    func selectCategory(_ category: LocationCategory?) {
        selectedCategory = (selectedCategory == category) ? nil : category
        applyFilters()
    }

    func selectTown(_ town: CapeCodTown?) {
        selectedTown = (selectedTown == town) ? nil : town
        applyFilters()
    }

    func toggleFavorite(_ location: CodLocation) {
        guard let index = locations.firstIndex(where: { $0.id == location.id }) else { return }
        locations[index].isFavorite.toggle()
        applyFilters()
    }

    var favorites: [CodLocation] {
        locations.filter(\.isFavorite)
    }

    func distance(to location: CodLocation) -> String? {
        locationService.formattedDistance(to: location)
    }

    // MARK: - Data Loading

    func loadLocations() async {
        // Show bundled content immediately on first load
        if locations.isEmpty {
            locations = BundledContent.allPOIs.map { $0.toCodLocation() }
            applyFilters()
            print("📦 ExploreView showing bundled content")
        }

        isLoading = true
        defer { isLoading = false }

        // Fetch live data from API
        await poiService.fetchAllPOIs()
        let apiPOIs = poiService.allPOIs

        if !apiPOIs.isEmpty {
            locations = apiPOIs.map { $0.toCodLocation() }
            hasLoadedFromAPI = true
            isOffline = false
            print("✅ ExploreView loaded \(apiPOIs.count) POIs from API")
        } else {
            isOffline = true
            print("📦 ExploreView showing bundled content (offline)")
        }

        error = poiService.error.map { NSError(domain: "POI", code: 0, userInfo: [NSLocalizedDescriptionKey: $0]) }
        applyFilters()
    }

    func loadNearby(location: CLLocationCoordinate2D) async {
        await poiService.fetchNearbyPOIs(lat: location.latitude, lng: location.longitude)
        let nearby = poiService.nearbyPOIs
        if !nearby.isEmpty {
            locations = nearby.map { $0.toCodLocation() }
            applyFilters()
        }
    }
}

// MARK: - POI → CodLocation Conversion

extension POI {
    func toCodLocation() -> CodLocation {
        CodLocation(
            name: name,
            latitude: latitude,
            longitude: longitude,
            category: category.toLocationCategory ?? .nature,
            description: description,
            town: CapeCodTown(rawValue: town) ?? .barnstable
        )
    }
}

// MARK: - PointOfInterest → CodLocation Conversion

extension PointOfInterest {
    func toCodLocation() -> CodLocation {
        CodLocation(
            name: name,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            category: category,
            description: description,
            town: town
        )
    }
}
