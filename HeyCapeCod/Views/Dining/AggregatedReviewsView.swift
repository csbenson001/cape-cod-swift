import SwiftUI

/// Displays aggregated reviews for a restaurant from multiple sources
/// with AI-powered recommendations and popular dish analysis.
struct AggregatedReviewsView: View {
    let restaurant: AggregatedRestaurant
    @State private var selectedSource: ReviewSource?
    @State private var sortMode: ReviewSortMode = .date

    private var filteredReviews: [AggregatedReview] {
        var reviews = restaurant.reviews
        if let source = selectedSource {
            reviews = reviews.filter { $0.source == source }
        }
        switch sortMode {
        case .date: reviews.sort { $0.date > $1.date }
        case .rating: reviews.sort { $0.rating > $1.rating }
        case .helpful: reviews.sort { $0.helpful > $1.helpful }
        }
        return reviews
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CodSpacing.sectionSpacing) {
                headerSection
                ratingBreakdownSection
                aiRecommendationCard
                popularDishesSection
                sourceFilterChips
                sortPicker
                reviewsList
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.top, CodSpacing.lg)
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background)
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text(restaurant.name).codTextStyle(.heroTitle).foregroundStyle(Color.capeCod.textPrimary)
            HStack(spacing: CodSpacing.sm) {
                Text(restaurant.town); Text("·"); Text(restaurant.cuisine); Text("·")
                Text(String(repeating: "$", count: restaurant.priceLevel))
            }
            .codTextStyle(.caption).foregroundStyle(Color.capeCod.textSecondary)
        }
    }

    private var ratingBreakdownSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(Color.capeCod.oceanBlue)
                Text("Rating Breakdown")
                    .codTextStyle(.sectionTitle)
            }

            HStack(spacing: CodSpacing.lg) {
                overallRatingBadge
                VStack(spacing: CodSpacing.sm) {
                    ForEach(ReviewSource.allCases, id: \.rawValue) { source in
                        SourceRatingRow(
                            source: source,
                            rating: RestaurantReviewAggregator.shared.averageRating(for: restaurant, source: source),
                            count: RestaurantReviewAggregator.shared.reviewCount(for: restaurant, source: source)
                        )
                    }
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private var overallRatingBadge: some View {
        VStack(spacing: CodSpacing.xs) {
            Text(String(format: "%.1f", restaurant.overallRating))
                .font(.system(size: 36, weight: .bold)).foregroundStyle(Color.capeCod.textPrimary)
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= Int(restaurant.overallRating.rounded()) ? "star.fill" : "star")
                        .font(.system(size: 10)).foregroundStyle(Color.capeCod.sandbarYellow)
                }
            }
            Text("\(restaurant.reviews.count) reviews").codTextStyle(.label).foregroundStyle(Color.capeCod.textSecondary)
        }
        .frame(minWidth: 80)
    }

    private var aiRecommendationCard: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.capeCod.sunsetOrange)
                Text("AI Recommendation")
                    .codTextStyle(.sectionTitle)
            }

            Text("Our AI analyzed \(restaurant.reviews.count) reviews across \(restaurant.sources.count) platforms...")
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.textSecondary)

            Text(restaurant.aiSummary)
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textPrimary)

            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.capeCod.oceanBlue)
                Text("Best time: \(restaurant.bestTimeToVisit)")
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(
            LinearGradient(
                colors: [Color.capeCod.sunsetOrange.opacity(0.08), Color.capeCod.seafoam.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .stroke(Color.capeCod.sunsetOrange.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Popular Dishes

    private var popularDishesSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "fork.knife.circle.fill")
                    .foregroundStyle(Color.capeCod.duneGrass)
                Text("Popular Dishes")
                    .codTextStyle(.sectionTitle)
            }

            ForEach(Array(restaurant.popularDishes.enumerated()), id: \.element.id) { index, dish in
                PopularDishCard(dish: dish)
                    .staggered(index: index)
            }
        }
    }

    // MARK: - Source Filter

    private var sourceFilterChips: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Filter Reviews")
                .codTextStyle(.sectionTitle)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.sm) {
                    sourceChip(label: "All Sources", source: nil)
                    ForEach(ReviewSource.allCases, id: \.rawValue) { source in
                        sourceChip(label: source.rawValue, source: source)
                    }
                }
            }
        }
    }

    private func sourceChip(label: String, source: ReviewSource?) -> some View {
        Button {
            withAnimation(CodAnimation.quick) {
                selectedSource = selectedSource == source ? nil : source
            }
            CodHaptic.selection()
        } label: {
            let isSelected = selectedSource == source
            HStack(spacing: CodSpacing.xs) {
                if let source {
                    Image(systemName: source.icon)
                        .font(.caption)
                }
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.5)
                    .textCase(.uppercase)
            }
            .foregroundStyle(isSelected ? .white : Color.capeCod.textPrimary)
            .padding(.horizontal, CodSpacing.md)
            .padding(.vertical, CodSpacing.sm)
            .background(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.surfaceElevated)
            .clipShape(Capsule())
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
    }

    // MARK: - Sort

    private var sortPicker: some View {
        HStack {
            Spacer()
            Menu {
                ForEach(ReviewSortMode.allCases, id: \.self) { mode in
                    Button {
                        sortMode = mode
                        CodHaptic.selection()
                    } label: {
                        Label(mode.label, systemImage: mode.icon)
                    }
                }
            } label: {
                HStack(spacing: CodSpacing.xs) {
                    Image(systemName: sortMode.icon)
                    Text("Sort: \(sortMode.label)")
                }
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.oceanBlue)
            }
        }
    }

    // MARK: - Reviews List

    private var reviewsList: some View {
        LazyVStack(spacing: CodSpacing.md) {
            ForEach(Array(filteredReviews.enumerated()), id: \.element.id) { index, review in
                ReviewCard(review: review)
                    .staggered(index: index)
            }
        }
    }
}

private enum ReviewSortMode: CaseIterable {
    case date, rating, helpful
    var label: String {
        switch self { case .date: "Most Recent"; case .rating: "Highest Rated"; case .helpful: "Most Helpful" }
    }
    var icon: String {
        switch self { case .date: "calendar"; case .rating: "star.fill"; case .helpful: "hand.thumbsup.fill" }
    }
}

private struct SourceRatingRow: View {
    let source: ReviewSource
    let rating: Double?
    let count: Int

    var body: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: source.icon).font(.system(size: 12))
                .foregroundStyle(Color.capeCod.oceanBlue).frame(width: 16)
            Text(source.rawValue).codTextStyle(.label).frame(width: 80, alignment: .leading)
            if let rating {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill").font(.system(size: 9)).foregroundStyle(Color.capeCod.sandbarYellow)
                    Text(String(format: "%.1f", rating)).codTextStyle(.label)
                }
            } else {
                Text("--").codTextStyle(.label).foregroundStyle(Color.capeCod.textSecondary)
            }
            Spacer()
            Text("\(count)").codTextStyle(.label).foregroundStyle(Color.capeCod.textSecondary)
        }
    }
}

// MARK: - Popular Dish Card

private struct PopularDishCard: View {
    let dish: PopularDish

    var body: some View {
        HStack(spacing: CodSpacing.md) {
            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                Text(dish.name)
                    .codTextStyle(.cardTitle)
                HStack(spacing: CodSpacing.sm) {
                    Text("\(dish.mentions) mentions")
                        .codTextStyle(.label)
                        .foregroundStyle(Color.capeCod.textSecondary)
                    if let price = dish.avgPrice {
                        Text(price)
                            .codTextStyle(.label)
                            .foregroundStyle(Color.capeCod.duneGrass)
                    }
                }
            }

            Spacer()

            // Sentiment bar
            VStack(alignment: .trailing, spacing: CodSpacing.xs) {
                Text("\(Int(dish.sentiment * 100))%")
                    .codTextStyle(.label)
                    .foregroundStyle(sentimentColor)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.capeCod.driftwood.opacity(0.2))
                        Capsule()
                            .fill(sentimentColor)
                            .frame(width: geo.size.width * dish.sentiment)
                    }
                }
                .frame(width: 60, height: 6)
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private var sentimentColor: Color {
        if dish.sentiment >= 0.9 { return Color.capeCod.duneGrass }
        if dish.sentiment >= 0.8 { return Color.capeCod.oceanBlue }
        return Color.capeCod.sunsetOrange
    }
}

// MARK: - Review Card

private struct ReviewCard: View {
    let review: AggregatedReview

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack {
                HStack(spacing: CodSpacing.xs) {
                    Image(systemName: review.source.icon)
                        .font(.system(size: 12))
                    Text(review.source.rawValue)
                        .codTextStyle(.label)
                }
                .foregroundStyle(Color.capeCod.oceanBlue)

                Spacer()

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= Int(review.rating.rounded()) ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.capeCod.sandbarYellow)
                    }
                }
            }

            Text(review.text)
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textPrimary)

            HStack {
                Text(review.author)
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.textSecondary)

                Spacer()

                HStack(spacing: CodSpacing.xs) {
                    Image(systemName: "hand.thumbsup")
                        .font(.system(size: 10))
                    Text("\(review.helpful)")
                }
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.textSecondary)

                Text(review.date, style: .date)
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.textSecondary)
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }
}

#Preview {
    NavigationStack {
        AggregatedReviewsView(
            restaurant: RestaurantAggregatorData.lobsterPot
        )
    }
}
