import Foundation

// MARK: - Models

struct AggregatedRestaurant: Identifiable, Codable {
    let id: String
    let name: String
    let town: String
    let cuisine: String
    let priceLevel: Int
    let reviews: [AggregatedReview]
    let overallRating: Double
    let popularDishes: [PopularDish]
    let bestTimeToVisit: String
    let aiSummary: String
    let sources: [ReviewSource]
}

struct AggregatedReview: Identifiable, Codable {
    let id: String
    let source: ReviewSource
    let rating: Double
    let text: String
    let author: String
    let date: Date
    let helpful: Int
}

enum ReviewSource: String, Codable, CaseIterable {
    case google = "Google"
    case yelp = "Yelp"
    case tripadvisor = "TripAdvisor"
    case heycapecod = "Hey Cape Cod"

    var icon: String {
        switch self {
        case .google: "globe"
        case .yelp: "star.bubble"
        case .tripadvisor: "airplane"
        case .heycapecod: "wave.3.right"
        }
    }
}

struct PopularDish: Identifiable, Codable {
    let id: String
    let name: String
    let mentions: Int
    let sentiment: Double
    let avgPrice: String?
}

// MARK: - Aggregator Service

@Observable
final class RestaurantReviewAggregator {
    static let shared = RestaurantReviewAggregator()

    private(set) var restaurants: [AggregatedRestaurant] = []

    private init() {
        restaurants = RestaurantAggregatorData.allRestaurants
    }

    func getAggregatedData(for restaurantName: String) -> AggregatedRestaurant? {
        restaurants.first {
            $0.name.localizedCaseInsensitiveContains(restaurantName)
        }
    }

    func getTopDishes(for restaurantName: String) -> [PopularDish] {
        guard let restaurant = getAggregatedData(for: restaurantName) else {
            return []
        }
        return restaurant.popularDishes.sorted { $0.mentions > $1.mentions }
    }

    func searchByDish(_ dish: String) -> [AggregatedRestaurant] {
        restaurants.filter { restaurant in
            restaurant.popularDishes.contains {
                $0.name.localizedCaseInsensitiveContains(dish)
            }
        }.sorted { a, b in
            let aDish = a.popularDishes.first { $0.name.localizedCaseInsensitiveContains(dish) }
            let bDish = b.popularDishes.first { $0.name.localizedCaseInsensitiveContains(dish) }
            return (aDish?.sentiment ?? 0) > (bDish?.sentiment ?? 0)
        }
    }

    func averageRating(for restaurant: AggregatedRestaurant, source: ReviewSource) -> Double? {
        let sourceReviews = restaurant.reviews.filter { $0.source == source }
        guard !sourceReviews.isEmpty else { return nil }
        return sourceReviews.map(\.rating).reduce(0, +) / Double(sourceReviews.count)
    }

    func reviewCount(for restaurant: AggregatedRestaurant, source: ReviewSource) -> Int {
        restaurant.reviews.filter { $0.source == source }.count
    }
}
