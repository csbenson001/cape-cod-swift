import SwiftUI

/// "Find the Best..." dish search across all restaurants
/// with AI-powered recommendations and quick-search chips.
struct DishFinderView: View {
    @State private var searchText = ""
    @State private var results: [AggregatedRestaurant] = []
    @State private var activeDish = ""

    private let popularSearches = [
        "Lobster Roll", "Fried Clams", "Chowder",
        "Oysters", "Fish & Chips", "Ice Cream",
        "Lobster Bisque", "Scallops", "Croissants"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CodSpacing.sectionSpacing) {
                headerSection
                searchSection
                chipSection

                if !results.isEmpty {
                    resultsSection
                } else if !activeDish.isEmpty {
                    emptyState
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.top, CodSpacing.lg)
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background)
        .navigationTitle("Dish Finder")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Find the Best...")
                .codTextStyle(.heroTitle)
                .foregroundStyle(Color.capeCod.textPrimary)
            Text("Search for a dish and we'll show you where to find the best version on Cape Cod.")
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
    }

    // MARK: - Search

    private var searchSection: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.capeCod.driftwood)
            TextField("Search a dish...", text: $searchText)
                .codTextStyle(.body)
                .onSubmit { performSearch(searchText) }
        }
        .padding(.horizontal, CodSpacing.md)
        .padding(.vertical, CodSpacing.sm + 2)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
        .adaptiveCardStyle(cornerRadius: CodRadius.input, shadow: .button)
    }

    // MARK: - Chips

    private var chipSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Popular Searches")
                .codTextStyle(.sectionTitle)

            FlowLayout(spacing: CodSpacing.sm) {
                ForEach(popularSearches, id: \.self) { dish in
                    Button {
                        searchText = dish
                        performSearch(dish)
                        CodHaptic.tap()
                    } label: {
                        Text(dish)
                            .font(.system(size: 11, weight: .medium))
                            .tracking(1.5)
                            .textCase(.uppercase)
                            .foregroundStyle(activeDish == dish ? .white : Color.capeCod.textPrimary)
                            .padding(.horizontal, CodSpacing.md)
                            .padding(.vertical, CodSpacing.sm)
                            .background(activeDish == dish ? Color.capeCod.oceanBlue : Color.capeCod.surfaceElevated)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(CodButtonPressStyle(variant: .ghost))
                }
            }
        }
    }

    // MARK: - Results

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack {
                Text("Best \"\(activeDish)\" on Cape Cod")
                    .codTextStyle(.sectionTitle)
                Spacer()
                Text("\(results.count) spots")
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.textSecondary)
            }

            ForEach(Array(results.enumerated()), id: \.element.id) { index, restaurant in
                NavigationLink {
                    AggregatedReviewsView(restaurant: restaurant)
                } label: {
                    DishResultCard(
                        restaurant: restaurant,
                        dishQuery: activeDish,
                        isTopPick: index == 0
                    )
                }
                .buttonStyle(.plain)
                .staggered(index: index)
            }
        }
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: CodSpacing.lg) {
            Image(systemName: "fork.knife")
                .font(.system(size: 48))
                .foregroundStyle(Color.capeCod.oceanBlue.opacity(0.3))
            Text("No restaurants found for \"\(activeDish)\"")
                .codTextStyle(.sectionTitle)
                .multilineTextAlignment(.center)
            Text("Try a different dish name")
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, CodSpacing.xxl)
    }

    // MARK: - Helpers

    private func performSearch(_ query: String) {
        guard !query.isEmpty else { return }
        withAnimation(CodAnimation.gentle) {
            activeDish = query
            results = RestaurantReviewAggregator.shared.searchByDish(query)
        }
        CodHaptic.success()
    }
}

// MARK: - Dish Result Card

private struct DishResultCard: View {
    let restaurant: AggregatedRestaurant
    let dishQuery: String
    let isTopPick: Bool

    private var matchedDish: PopularDish? {
        restaurant.popularDishes.first {
            $0.name.localizedCaseInsensitiveContains(dishQuery)
        }
    }

    private var relevantSnippet: String? {
        restaurant.reviews.first { review in
            review.text.localizedCaseInsensitiveContains(dishQuery)
        }?.text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            // Top row
            HStack {
                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    HStack(spacing: CodSpacing.sm) {
                        Text(restaurant.name)
                            .codTextStyle(.cardTitle)
                        if isTopPick {
                            aiPickBadge
                        }
                    }
                    HStack(spacing: CodSpacing.xs) {
                        Text(restaurant.town)
                        Text("·")
                        Text(String(repeating: "$", count: restaurant.priceLevel))
                    }
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.textSecondary)
                }

                Spacer()

                if let dish = matchedDish {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(Int(dish.sentiment * 100))%")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.capeCod.duneGrass)
                        Text("positive")
                            .codTextStyle(.label)
                            .foregroundStyle(Color.capeCod.textSecondary)
                    }
                }
            }

            // Dish details
            if let dish = matchedDish {
                HStack(spacing: CodSpacing.md) {
                    HStack(spacing: CodSpacing.xs) {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 11))
                        Text("\(dish.mentions) mentions")
                    }
                    if let price = dish.avgPrice {
                        HStack(spacing: CodSpacing.xs) {
                            Image(systemName: "dollarsign.circle")
                                .font(.system(size: 11))
                            Text(price)
                        }
                    }
                }
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.textSecondary)
            }

            // Review snippet
            if let snippet = relevantSnippet {
                Text("\"\(snippet)\"")
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.textSecondary)
                    .lineLimit(2)
                    .italic()
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private var aiPickBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "sparkles")
                .font(.system(size: 9))
            Text("AI PICK")
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, CodSpacing.sm)
        .padding(.vertical, 3)
        .background(Color.capeCod.sunsetOrange)
        .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        DishFinderView()
    }
}
