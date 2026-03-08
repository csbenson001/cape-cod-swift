import Foundation

/// Service for submitting, fetching, and aggregating reviews.
/// Powers the rating feedback loop that improves restaurant and POI recommendations.
@preconcurrency @MainActor
@Observable
final class ReviewService {
    static let shared = ReviewService()

    private(set) var reviews: [String: [Review]] = [:]  // targetId -> reviews
    private(set) var aggregations: [String: RatingAggregation] = [:] // targetId -> aggregation
    private(set) var isLoading = false

    private init() {}

    // MARK: - Fetch Reviews

    func fetchReviews(for targetId: String, type: ReviewTarget) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response: ReviewListResponse = try await APIClient.shared.get(
                "reviews",
                query: ["targetId": targetId, "targetType": type.rawValue]
            )
            reviews[targetId] = response.reviews
            aggregations[targetId] = response.aggregation
        } catch {
            // Use locally cached reviews if available
            print("⚠️ Failed to fetch reviews: \(error.localizedDescription)")
        }
    }

    // MARK: - Submit Review

    func submitReview(_ review: Review) async throws {
        let _: ReviewSubmitResponse = try await APIClient.shared.post("reviews", body: review)

        // Update local cache
        var existing = reviews[review.targetId] ?? []
        existing.insert(review, at: 0)
        reviews[review.targetId] = existing

        // Update aggregation
        updateLocalAggregation(for: review.targetId, newRating: review.rating)
    }

    // MARK: - Submit Menu Item Ratings

    func submitMenuItemRatings(_ ratings: [MenuItemRating], restaurantId: String) async throws {
        let payload = MenuRatingPayload(restaurantId: restaurantId, ratings: ratings)
        let _: ReviewSubmitResponse = try await APIClient.shared.post("reviews/menu-ratings", body: payload)
    }

    // MARK: - Mark Review Helpful

    func markHelpful(reviewId: String, targetId: String) async {
        do {
            let _: ReviewSubmitResponse = try await APIClient.shared.post(
                "reviews/\(reviewId)/helpful",
                body: EmptyBody()
            )

            // Update local
            if var targetReviews = reviews[targetId],
               let index = targetReviews.firstIndex(where: { $0.id == reviewId }) {
                targetReviews[index].helpfulCount += 1
                reviews[targetId] = targetReviews
            }
        } catch {
            print("⚠️ Failed to mark helpful: \(error.localizedDescription)")
        }
    }

    // MARK: - Get Top-Rated Items

    func topRatedMenuItems(for restaurantId: String, from items: [MenuItem]) -> [MenuItem] {
        items
            .filter { $0.ratingCount > 0 }
            .sorted { $0.communityRating > $1.communityRating }
    }

    func recommendedItems(for restaurantId: String, from items: [MenuItem], userInterests: [String]) -> [MenuItem] {
        var scored = items.map { item -> (MenuItem, Double) in
            var score = item.communityRating * Double(min(item.ratingCount, 50)) / 50.0

            if item.isSignatureDish { score += 2.0 }

            // Boost items matching user dietary preferences
            if userInterests.contains("seafood") && item.category == .seafood { score += 1.5 }
            if userInterests.contains("vegetarian") && item.dietaryTags.contains(.vegetarian) { score += 1.5 }
            if item.dietaryTags.contains(.localCatch) { score += 1.0 }

            return (item, score)
        }

        scored.sort { $0.1 > $1.1 }
        return scored.map(\.0)
    }

    // MARK: - Aggregation

    func aggregation(for targetId: String) -> RatingAggregation? {
        aggregations[targetId]
    }

    private func updateLocalAggregation(for targetId: String, newRating: Int) {
        if var agg = aggregations[targetId] {
            let newTotal = agg.totalReviews + 1
            let newAvg = (agg.averageRating * Double(agg.totalReviews) + Double(newRating)) / Double(newTotal)
            var dist = agg.distribution
            dist[newRating, default: 0] += 1

            aggregations[targetId] = RatingAggregation(
                targetId: targetId,
                averageRating: newAvg,
                totalReviews: newTotal,
                distribution: dist,
                topTags: agg.topTags,
                trend: newAvg > agg.averageRating ? .rising : .stable
            )
        } else {
            aggregations[targetId] = RatingAggregation(
                targetId: targetId,
                averageRating: Double(newRating),
                totalReviews: 1,
                distribution: [newRating: 1],
                topTags: [],
                trend: .stable
            )
        }
    }
}

// MARK: - API Payloads

private struct ReviewListResponse: Codable {
    let reviews: [Review]
    let aggregation: RatingAggregation?
}

private struct ReviewSubmitResponse: Codable {
    let success: Bool
    let id: String?
}

private struct MenuRatingPayload: Encodable {
    let restaurantId: String
    let ratings: [MenuItemRating]
}

private struct EmptyBody: Encodable {}
