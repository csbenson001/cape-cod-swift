import SwiftUI

/// Browse restaurants with cuisine filters, sorting by rating, and featured recommendations.
struct RestaurantListView: View {
    @State private var searchText = ""
    @State private var selectedCuisine: CuisineType?
    @State private var sortByRating = true

    private var filteredRestaurants: [Restaurant] {
        var restaurants = BundledRestaurants.all

        if let cuisine = selectedCuisine {
            restaurants = restaurants.filter { $0.cuisine == cuisine }
        }

        if !searchText.isEmpty {
            restaurants = restaurants.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.cuisine.displayName.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        if sortByRating {
            restaurants.sort { $0.averageRating > $1.averageRating }
        }

        return restaurants
    }

    private var availableCuisines: [CuisineType] {
        let cuisines = Set(BundledRestaurants.all.map(\.cuisine))
        return CuisineType.allCases.filter { cuisines.contains($0) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    searchBar
                    cuisineFilters
                    sortToggle

                    if filteredRestaurants.isEmpty {
                        emptyState
                    } else {
                        restaurantList
                    }
                }
                .padding(.bottom, CodSpacing.xxl)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Dining")
            .navigationDestination(for: Restaurant.self) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
            }
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.capeCod.driftwood)
            TextField("Search restaurants...", text: $searchText)
                .codTextStyle(.body)
        }
        .padding(.horizontal, CodSpacing.md)
        .padding(.vertical, CodSpacing.sm + 2)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
        .adaptiveCardStyle(cornerRadius: CodRadius.input, shadow: .button)
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Cuisine Filters

    private var cuisineFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                cuisineChip(label: "All", cuisine: nil)
                ForEach(availableCuisines) { cuisine in
                    cuisineChip(label: cuisine.displayName, cuisine: cuisine)
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
    }

    private func cuisineChip(label: String, cuisine: CuisineType?) -> some View {
        Button {
            withAnimation(CodAnimation.quick) {
                selectedCuisine = selectedCuisine == cuisine ? nil : cuisine
            }
            CodHaptic.selection()
        } label: {
            Text(label)
                .codTextStyle(.label)
                .padding(.horizontal, CodSpacing.md)
                .padding(.vertical, CodSpacing.sm)
                .background(selectedCuisine == cuisine ? Color.capeCod.oceanBlue : Color.capeCod.surfaceElevated)
                .foregroundStyle(selectedCuisine == cuisine ? .white : Color.capeCod.textPrimary)
                .clipShape(Capsule())
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
    }

    // MARK: - Sort Toggle

    private var sortToggle: some View {
        HStack {
            Spacer()
            Button {
                withAnimation(CodAnimation.quick) { sortByRating.toggle() }
                CodHaptic.selection()
            } label: {
                HStack(spacing: CodSpacing.xs) {
                    Image(systemName: sortByRating ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    Text(sortByRating ? "Top Rated" : "All")
                }
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.oceanBlue)
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Restaurant List

    private var restaurantList: some View {
        LazyVStack(spacing: CodSpacing.md) {
            ForEach(Array(filteredRestaurants.enumerated()), id: \.element.id) { index, restaurant in
                NavigationLink(value: restaurant) {
                    RestaurantCard(restaurant: restaurant)
                }
                .buttonStyle(.plain)
                .staggered(index: index)
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: CodSpacing.lg) {
            Image(systemName: "fork.knife")
                .font(.system(size: 48))
                .foregroundStyle(Color.capeCod.oceanBlue.opacity(0.3))
            Text("No restaurants found")
                .codTextStyle(.sectionTitle)
            Text("Try a different cuisine or search term")
                .codTextStyle(.caption)
        }
        .padding(.top, CodSpacing.xxl)
    }
}

// MARK: - Restaurant Card

private struct RestaurantCard: View {
    let restaurant: Restaurant

    var topDish: MenuItem? {
        restaurant.menuHighlights
            .filter { $0.isSignatureDish }
            .max { $0.communityRating < $1.communityRating }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top section
            HStack(spacing: CodSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.capeCod.oceanBlue.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: "fork.knife")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.capeCod.oceanBlue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(restaurant.name)
                        .codTextStyle(.cardTitle)
                    HStack(spacing: CodSpacing.xs) {
                        Text(restaurant.cuisine.displayName)
                        Text("·")
                        Text(restaurant.priceRange.displaySymbol)
                        Text("·")
                        Text(restaurant.town.capitalized)
                    }
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.textSecondary)
                }

                Spacer()

                // Rating badge
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text(String(format: "%.1f", restaurant.averageRating))
                    }
                    .foregroundStyle(Color.capeCod.sandbarYellow)
                    .codTextStyle(.label)

                    Text("\(restaurant.totalReviews)")
                        .codTextStyle(.label)
                        .foregroundStyle(Color.capeCod.textSecondary)
                }
            }
            .padding(CodSpacing.cardPadding)

            // Top dish recommendation
            if let dish = topDish {
                Divider()
                    .padding(.horizontal, CodSpacing.cardPadding)

                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.capeCod.duneGrass)

                    Text("Try the \(dish.name)")
                        .codTextStyle(.label)
                        .foregroundStyle(Color.capeCod.textSecondary)

                    Spacer()

                    if let price = dish.formattedPrice {
                        Text(price)
                            .codTextStyle(.label)
                            .foregroundStyle(Color.capeCod.duneGrass)
                    }
                }
                .padding(CodSpacing.cardPadding)
            }
        }
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .codAccessibleCard(
            label: "\(restaurant.name), \(restaurant.cuisine.displayName), \(restaurant.priceRange.displaySymbol), rated \(String(format: "%.1f", restaurant.averageRating))",
            hint: "Double tap for menu and details"
        )
    }
}

#Preview {
    RestaurantListView()
}
