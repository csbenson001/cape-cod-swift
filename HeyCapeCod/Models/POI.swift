import Foundation
import CoreLocation

/// A Point of Interest from the backend API.
struct POI: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    let radius: Int
    let category: POICategory
    let town: String
    let address: String?
    let imageUrl: String?
    let storyIds: [String]
    let facts: [String]
    let tips: [String]
    let relatedPoiIds: [String]
    let priority: Int
    let isActive: Bool

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        description = try c.decodeIfPresent(String.self, forKey: .description) ?? ""
        latitude = try c.decode(Double.self, forKey: .latitude)
        longitude = try c.decode(Double.self, forKey: .longitude)
        radius = try c.decodeIfPresent(Int.self, forKey: .radius) ?? 200
        category = try c.decodeIfPresent(POICategory.self, forKey: .category) ?? .nature
        town = try c.decodeIfPresent(String.self, forKey: .town) ?? ""
        address = try c.decodeIfPresent(String.self, forKey: .address)
        imageUrl = try c.decodeIfPresent(String.self, forKey: .imageUrl)
        storyIds = try c.decodeIfPresent([String].self, forKey: .storyIds) ?? []
        facts = try c.decodeIfPresent([String].self, forKey: .facts) ?? []
        tips = try c.decodeIfPresent([String].self, forKey: .tips) ?? []
        relatedPoiIds = try c.decodeIfPresent([String].self, forKey: .relatedPoiIds) ?? []
        priority = try c.decodeIfPresent(Int.self, forKey: .priority) ?? 0
        isActive = try c.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
    }

    init(
        id: String,
        name: String,
        description: String = "",
        latitude: Double,
        longitude: Double,
        radius: Int = 200,
        category: POICategory = .nature,
        town: String = "",
        address: String? = nil,
        imageUrl: String? = nil,
        storyIds: [String] = [],
        facts: [String] = [],
        tips: [String] = [],
        relatedPoiIds: [String] = [],
        priority: Int = 0,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.category = category
        self.town = town
        self.address = address
        self.imageUrl = imageUrl
        self.storyIds = storyIds
        self.facts = facts
        self.tips = tips
        self.relatedPoiIds = relatedPoiIds
        self.priority = priority
        self.isActive = isActive
    }

    static func == (lhs: POI, rhs: POI) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum POICategory: String, Codable, CaseIterable, Identifiable {
    case beach
    case restaurant
    case historic
    case nature
    case town
    case landmark
    case lighthouse
    case museum
    case marina
    case entertainment
    case shopping
    case lodging

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beach: "Beaches"
        case .restaurant: "Dining"
        case .historic: "Historic Sites"
        case .nature: "Nature"
        case .town: "Towns"
        case .landmark: "Landmarks"
        case .lighthouse: "Lighthouses"
        case .museum: "Museums"
        case .marina: "Marinas"
        case .entertainment: "Entertainment"
        case .shopping: "Shopping"
        case .lodging: "Lodging"
        }
    }

    var icon: String {
        switch self {
        case .beach: "beach.umbrella.fill"
        case .restaurant: "fork.knife"
        case .historic: "clock.fill"
        case .nature: "leaf.fill"
        case .town: "building.2.fill"
        case .landmark: "mappin.and.ellipse"
        case .lighthouse: "light.beacon.max.fill"
        case .museum: "building.columns.fill"
        case .marina: "sailboat.fill"
        case .entertainment: "theatermasks.fill"
        case .shopping: "bag.fill"
        case .lodging: "bed.double.fill"
        }
    }

    /// Map from old LocationCategory raw values for compatibility
    var toLocationCategory: LocationCategory? {
        LocationCategory(rawValue: rawValue)
    }
}

// MARK: - API Response Wrappers

struct POIListResponse: Codable {
    let pois: [POI]
    let count: Int
}

struct POIDetailResponse: Codable {
    let id: String
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    let radius: Int?
    let category: String
    let town: String
    let address: String?
    let imageUrl: String?
    let facts: [String]?
    let tips: [String]?
    let stories: [APIStoryResponse]?
    let relatedPoiIds: [String]?
    let priority: Int?
}
