import Foundation
import CoreLocation

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

    private let locationService: LocationService

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
        }

        isLoading = true
        defer { isLoading = false }

        // Fetch live data from API
        await POIService.shared.fetchAllPOIs()
        let apiPOIs = POIService.shared.allPOIs

        if !apiPOIs.isEmpty {
            locations = apiPOIs.map { $0.toCodLocation() }
            hasLoadedFromAPI = true
            print("[ExploreViewModel] Loaded \(apiPOIs.count) POIs from API")
        } else {
            print("[ExploreViewModel] API unavailable, showing bundled content")
        }

        error = POIService.shared.lastError
        applyFilters()
    }
}

// MARK: - APIPOI → CodLocation Conversion

extension APIPOI {
    func toCodLocation() -> CodLocation {
        CodLocation(
            name: name,
            latitude: latitude,
            longitude: longitude,
            category: LocationCategory(rawValue: category) ?? .nature,
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
