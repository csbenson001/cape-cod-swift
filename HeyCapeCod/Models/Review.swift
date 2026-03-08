import Foundation

/// A user review for a POI or restaurant, powering the feedback loop.
struct Review: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    let userName: String
    let targetId: String
    let targetType: ReviewTarget
    let rating: Int // 1-5 stars
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

/// Individual menu item rating within a restaurant review.
struct MenuItemRating: Codable, Hashable {
    let menuItemId: String
    let menuItemName: String
    let rating: Int // 1-5
    let comment: String?
}

enum ReviewTarget: String, Codable {
    case poi
    case restaurant
    case tour
}

enum ReviewTag: String, Codable, CaseIterable, Identifiable {
    case greatFood
    case niceView
    case familyFriendly
    case goodService
    case goodValue
    case livelyAtmosphere
    case romantic
    case quickService
    case petFriendly
    case localFavorite
    case touristSpot
    case hiddenGem

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

/// Aggregated rating data for display and ranking.
struct RatingAggregation: Codable {
    let targetId: String
    let averageRating: Double
    let totalReviews: Int
    let distribution: [Int: Int] // star count -> number of reviews
    let topTags: [ReviewTag]
    let trend: RatingTrend

    var formattedRating: String {
        String(format: "%.1f", averageRating)
    }
}

enum RatingTrend: String, Codable {
    case rising
    case stable
    case declining
}
