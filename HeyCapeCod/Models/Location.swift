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

// MARK: - Restaurant Model

/// A restaurant with menu items and recommendation rankings.
struct Restaurant: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    let town: String
    let address: String
    let cuisine: CuisineType
    let priceRange: PriceRange
    let imageUrl: String?
    let phoneNumber: String?
    let websiteUrl: String?
    let hours: String?
    let menuHighlights: [MenuItem]
    let averageRating: Double
    let totalReviews: Int
    let tags: [String]

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool { lhs.id == rhs.id }
}

/// A menu item with community-driven ranking.
struct MenuItem: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double?
    let category: MenuCategory
    var communityRating: Double
    var ratingCount: Int
    let isSignatureDish: Bool
    let dietaryTags: [DietaryTag]

    var formattedPrice: String? {
        guard let price else { return nil }
        return String(format: "$%.2f", price)
    }
}

enum MenuCategory: String, Codable, CaseIterable, Identifiable {
    case appetizer, entree, seafood, sandwich, salad, soup, dessert, drink, kids

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .appetizer: "Appetizers"
        case .entree: "Entrees"
        case .seafood: "Seafood"
        case .sandwich: "Sandwiches"
        case .salad: "Salads"
        case .soup: "Soups"
        case .dessert: "Desserts"
        case .drink: "Drinks"
        case .kids: "Kids Menu"
        }
    }

    var icon: String {
        switch self {
        case .appetizer: "sparkles"
        case .entree: "fork.knife"
        case .seafood: "fish.fill"
        case .sandwich: "takeoutbag.and.cup.and.straw.fill"
        case .salad: "leaf.fill"
        case .soup: "mug.fill"
        case .dessert: "birthday.cake.fill"
        case .drink: "wineglass.fill"
        case .kids: "figure.child"
        }
    }
}

enum CuisineType: String, Codable, CaseIterable, Identifiable {
    case seafood, american, italian, portuguese, newEngland, farmToTable, casual, fineDining, cafe, iceCream

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .seafood: "Seafood"
        case .american: "American"
        case .italian: "Italian"
        case .portuguese: "Portuguese"
        case .newEngland: "New England"
        case .farmToTable: "Farm to Table"
        case .casual: "Casual"
        case .fineDining: "Fine Dining"
        case .cafe: "Cafe"
        case .iceCream: "Ice Cream"
        }
    }
}

enum PriceRange: String, Codable, CaseIterable, Identifiable {
    case budget, moderate, upscale, fineDining

    var id: String { rawValue }

    var displaySymbol: String {
        switch self {
        case .budget: "$"
        case .moderate: "$$"
        case .upscale: "$$$"
        case .fineDining: "$$$$"
        }
    }
}

enum DietaryTag: String, Codable, CaseIterable, Identifiable {
    case vegetarian, vegan, glutenFree, dairyFree, nutFree, localCatch

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vegetarian: "Vegetarian"
        case .vegan: "Vegan"
        case .glutenFree: "Gluten Free"
        case .dairyFree: "Dairy Free"
        case .nutFree: "Nut Free"
        case .localCatch: "Local Catch"
        }
    }

    var icon: String {
        switch self {
        case .vegetarian: "leaf.circle.fill"
        case .vegan: "leaf.fill"
        case .glutenFree: "g.circle.fill"
        case .dairyFree: "drop.circle.fill"
        case .nutFree: "exclamationmark.triangle.fill"
        case .localCatch: "fish.fill"
        }
    }
}

// MARK: - Review Model

/// A user review for a POI or restaurant, powering the feedback loop.
struct Review: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    let userName: String
    let targetId: String
    let targetType: ReviewTarget
    let rating: Int
    let title: String
    let body: String
    let visitDate: Date?
    let createdAt: Date
    let menuItemRatings: [MenuItemRating]
    let tags: [ReviewTag]
    var helpfulCount: Int
    var reportCount: Int

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Review, rhs: Review) -> Bool { lhs.id == rhs.id }
}

struct MenuItemRating: Codable, Hashable {
    let menuItemId: String
    let menuItemName: String
    let rating: Int
    let comment: String?
}

enum ReviewTarget: String, Codable {
    case poi, restaurant, tour
}

enum ReviewTag: String, Codable, CaseIterable, Identifiable {
    case greatFood, niceView, familyFriendly, goodService, goodValue
    case livelyAtmosphere, romantic, quickService, petFriendly
    case localFavorite, touristSpot, hiddenGem

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .greatFood: "Great Food"
        case .niceView: "Nice View"
        case .familyFriendly: "Family Friendly"
        case .goodService: "Good Service"
        case .goodValue: "Good Value"
        case .livelyAtmosphere: "Lively"
        case .romantic: "Romantic"
        case .quickService: "Quick Service"
        case .petFriendly: "Pet Friendly"
        case .localFavorite: "Local Favorite"
        case .touristSpot: "Tourist Spot"
        case .hiddenGem: "Hidden Gem"
        }
    }

    var icon: String {
        switch self {
        case .greatFood: "fork.knife"
        case .niceView: "eye.fill"
        case .familyFriendly: "figure.2.and.child.holdinghands"
        case .goodService: "hand.thumbsup.fill"
        case .goodValue: "dollarsign.circle.fill"
        case .livelyAtmosphere: "music.note"
        case .romantic: "heart.fill"
        case .quickService: "bolt.fill"
        case .petFriendly: "pawprint.fill"
        case .localFavorite: "star.fill"
        case .touristSpot: "camera.fill"
        case .hiddenGem: "sparkle"
        }
    }
}

struct RatingAggregation: Codable {
    let targetId: String
    let averageRating: Double
    let totalReviews: Int
    let distribution: [Int: Int]
    let topTags: [ReviewTag]
    let trend: RatingTrend

    var formattedRating: String {
        String(format: "%.1f", averageRating)
    }
}

enum RatingTrend: String, Codable {
    case rising, stable, declining
}
