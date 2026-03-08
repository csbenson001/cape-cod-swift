import Foundation
import CoreLocation

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
    case appetizer
    case entree
    case seafood
    case sandwich
    case salad
    case soup
    case dessert
    case drink
    case kids

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
    case seafood
    case american
    case italian
    case portuguese
    case newEngland
    case farmToTable
    case casual
    case fineDining
    case cafe
    case iceCream

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
    case budget     // $
    case moderate   // $$
    case upscale    // $$$
    case fineDining // $$$$

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
    case vegetarian
    case vegan
    case glutenFree
    case dairyFree
    case nutFree
    case localCatch

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
