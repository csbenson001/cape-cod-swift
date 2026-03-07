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

    func loadLocations() async {
        isLoading = true
        defer { isLoading = false }
        // TODO: Load from API or local database
        applyFilters()
    }
}
