import Foundation
import CoreLocation

struct CodLocation: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var category: LocationCategory
    var description: String
    var imageURL: URL?
    var town: CapeCodTown
    var storyIDs: [UUID]
    var isFavorite: Bool
    var rating: Double?
    var reviewCount: Int

    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        category: LocationCategory,
        description: String = "",
        imageURL: URL? = nil,
        town: CapeCodTown = .barnstable,
        storyIDs: [UUID] = [],
        isFavorite: Bool = false,
        rating: Double? = nil,
        reviewCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.description = description
        self.imageURL = imageURL
        self.town = town
        self.storyIDs = storyIDs
        self.isFavorite = isFavorite
        self.rating = rating
        self.reviewCount = reviewCount
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Location Category

enum LocationCategory: String, Codable, CaseIterable, Identifiable {
    case beach
    case restaurant
    case lighthouse
    case museum
    case nature
    case shopping
    case marina
    case historic
    case entertainment
    case lodging

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beach: "Beaches"
        case .restaurant: "Dining"
        case .lighthouse: "Lighthouses"
        case .museum: "Museums"
        case .nature: "Nature"
        case .shopping: "Shopping"
        case .marina: "Marinas"
        case .historic: "Historic Sites"
        case .entertainment: "Entertainment"
        case .lodging: "Lodging"
        }
    }

    var icon: String {
        switch self {
        case .beach: "beach.umbrella.fill"
        case .restaurant: "fork.knife"
        case .lighthouse: "light.beacon.max.fill"
        case .museum: "building.columns.fill"
        case .nature: "leaf.fill"
        case .shopping: "bag.fill"
        case .marina: "sailboat.fill"
        case .historic: "clock.fill"
        case .entertainment: "theatermasks.fill"
        case .lodging: "bed.double.fill"
        }
    }
}

// MARK: - Cape Cod Towns

enum CapeCodTown: String, Codable, CaseIterable, Identifiable {
    case barnstable, bourne, brewster, chatham, dennis
    case eastham, falmouth, harwich, mashpee, orleans
    case provincetown, sandwich, truro, wellfleet, yarmouth

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var region: CapeRegion {
        switch self {
        case .bourne, .falmouth, .mashpee, .sandwich:
            return .upperCape
        case .barnstable, .dennis, .yarmouth:
            return .midCape
        case .brewster, .chatham, .harwich, .orleans:
            return .lowerCape
        case .eastham, .wellfleet, .truro, .provincetown:
            return .outerCape
        }
    }
}

enum CapeRegion: String, Codable, CaseIterable, Identifiable {
    case upperCape = "Upper Cape"
    case midCape = "Mid Cape"
    case lowerCape = "Lower Cape"
    case outerCape = "Outer Cape"

    var id: String { rawValue }
}
