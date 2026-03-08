import SwiftUI
import MapKit

/// Restaurant detail view with menu recommendations, community ratings,
/// and the ability to rate individual dishes — powering the feedback loop.
struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @State private var showReviewSheet = false
    @State private var selectedMenuCategory: MenuCategory?

    private var filteredMenu: [MenuItem] {
        guard let category = selectedMenuCategory else {
            return topRecommendedItems
        }
        return restaurant.menuHighlights.filter { $0.category == category }
    }

    private var topRecommendedItems: [MenuItem] {
        ReviewService.shared.recommendedItems(
            for: restaurant.id,
            from: restaurant.menuHighlights,
            userInterests: UserProfileManager.shared.currentProfile?.interests ?? []
        )
    }

    private var signatureDishes: [MenuItem] {
        restaurant.menuHighlights.filter { $0.isSignatureDish }
    }

    private var menuCategories: [MenuCategory] {
        let categories = Set(restaurant.menuHighlights.map(\.category))
        return MenuCategory.allCases.filter { categories.contains($0) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero header
                heroHeader

                VStack(alignment: .leading, spacing: CodSpacing.sectionSpacing) {
                    // Restaurant info
                    infoSection

                    // Rating summary
                    ratingSummary

                    Divider()

                    // Signature dishes
                    if !signatureDishes.isEmpty {
                        signatureDishesSection
                    }

                    // Menu category filter
                    menuCategoryFilter

                    // Menu items
                    menuSection

                    // Review button
                    CodButton("Write a Review", variant: .secondary, icon: "square.and.pencil", isFullWidth: true) {
                        CodHaptic.tap()
                        showReviewSheet = true
                    }

                    // Map & directions
                    mapSection
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.top, CodSpacing.lg)
                .padding(.bottom, CodSpacing.xxl)
            }
        }
        .background(Color.capeCod.background)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReviewSheet) {
            WriteReviewView(
                targetId: restaurant.id,
                targetName: restaurant.name,
                targetType: .restaurant,
                menuItems: restaurant.menuHighlights
            )
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color.capeCod.deepNavy, Color.capeCod.oceanBlue],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .frame(height: 200)
            .overlay(alignment: .topTrailing) {
                Image(systemName: restaurant.cuisine.id == "seafood" ? "fish.fill" : "fork.knife")
                    .font(.system(size: 80))
                    .foregroundStyle(.white.opacity(0.08))
                    .offset(x: -20, y: 30)
            }

            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                HStack(spacing: CodSpacing.sm) {
                    Text(restaurant.cuisine.displayName)
                        .codTextStyle(.label)
                    Text("·")
                    Text(restaurant.priceRange.displaySymbol)
                        .codTextStyle(.label)
                }
                .foregroundStyle(.white.opacity(0.7))

                Text(restaurant.name)
                    .codTextStyle(.heroTitle)
                    .foregroundStyle(.white)

                HStack(spacing: CodSpacing.sm) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text(String(format: "%.1f", restaurant.averageRating))
                    }
                    .foregroundStyle(Color.capeCod.sandbarYellow)

                    Text("(\(restaurant.totalReviews) reviews)")
                        .foregroundStyle(.white.opacity(0.6))
                }
                .codTextStyle(.label)
            }
            .padding(CodSpacing.cardPadding + 4)
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text(restaurant.description)
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)

            VStack(spacing: CodSpacing.sm) {
                if let hours = restaurant.hours {
                    infoRow(icon: "clock", text: hours)
                }
                infoRow(icon: "mappin", text: restaurant.address)
                if let phone = restaurant.phoneNumber {
                    infoRow(icon: "phone", text: phone)
                }
            }

            // Tags
            if !restaurant.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: CodSpacing.xs) {
                        ForEach(restaurant.tags, id: \.self) { tag in
                            Text(tag)
                                .codTextStyle(.label)
                                .padding(.horizontal, CodSpacing.sm)
                                .padding(.vertical, CodSpacing.xs)
                                .background(Color.capeCod.oceanBlue.opacity(0.08))
                                .foregroundStyle(Color.capeCod.oceanBlue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.capeCod.oceanBlue)
                .frame(width: 20)
            Text(text)
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
    }

    // MARK: - Rating Summary

    private var ratingSummary: some View {
        HStack(spacing: CodSpacing.lg) {
            // Big rating number
            VStack(spacing: CodSpacing.xs) {
                Text(String(format: "%.1f", restaurant.averageRating))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.capeCod.textPrimary)

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= Int(restaurant.averageRating.rounded()) ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.capeCod.sandbarYellow)
                    }
                }

                Text("\(restaurant.totalReviews) reviews")
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.textSecondary)
            }

            Spacer()

            // Top recommended badge
            VStack(spacing: CodSpacing.sm) {
                Image(systemName: "hand.thumbsup.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.capeCod.duneGrass)

                Text("Community\nRecommended")
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Signature Dishes

    private var signatureDishesSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "star.circle.fill")
                    .foregroundStyle(Color.capeCod.sandbarYellow)
                Text("Must-Try Dishes")
                    .codTextStyle(.sectionTitle)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.md) {
                    ForEach(signatureDishes) { item in
                        SignatureDishCard(item: item)
                    }
                }
            }
        }
    }

    // MARK: - Menu Category Filter

    private var menuCategoryFilter: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Full Menu Highlights")
                .codTextStyle(.sectionTitle)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.sm) {
                    menuFilterChip(label: "Top Picks", icon: "hand.thumbsup.fill", category: nil)
                    ForEach(menuCategories) { category in
                        menuFilterChip(label: category.displayName, icon: category.icon, category: category)
                    }
                }
            }
        }
    }

    private func menuFilterChip(label: String, icon: String, category: MenuCategory?) -> some View {
        Button {
            withAnimation(CodAnimation.quick) { selectedMenuCategory = category }
            CodHaptic.selection()
        } label: {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .codTextStyle(.label)
            }
            .padding(.horizontal, CodSpacing.md)
            .padding(.vertical, CodSpacing.sm)
            .background(selectedMenuCategory == category ? Color.capeCod.oceanBlue : Color.capeCod.surfaceElevated)
            .foregroundStyle(selectedMenuCategory == category ? .white : Color.capeCod.textPrimary)
            .clipShape(Capsule())
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
    }

    // MARK: - Menu Section

    private var menuSection: some View {
        LazyVStack(spacing: CodSpacing.sm) {
            ForEach(filteredMenu) { item in
                MenuItemCard(item: item)
            }
        }
    }

    // MARK: - Map

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Location")
                .codTextStyle(.sectionTitle)

            Map(initialPosition: .region(MKCoordinateRegion(
                center: restaurant.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))) {
                Marker(restaurant.name, coordinate: restaurant.coordinate)
                    .tint(Color.capeCod.oceanBlue)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .allowsHitTesting(false)

            CodButton("Get Directions", variant: .secondary, icon: "arrow.triangle.turn.up.right.diamond.fill", isFullWidth: true) {
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: restaurant.coordinate))
                mapItem.name = restaurant.name
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            }
        }
    }
}

// MARK: - Signature Dish Card

private struct SignatureDishCard: View {
    let item: MenuItem

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.capeCod.sandbarYellow)
                Text("SIGNATURE")
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.sandbarYellow)
            }

            Text(item.name)
                .codTextStyle(.cardTitle)
                .lineLimit(2)

            Text(item.description)
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.textSecondary)
                .lineLimit(2)

            HStack {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text(String(format: "%.1f", item.communityRating))
                }
                .foregroundStyle(Color.capeCod.sandbarYellow)
                .codTextStyle(.label)

                Spacer()

                if let price = item.formattedPrice {
                    Text(price)
                        .codTextStyle(.label)
                        .foregroundStyle(Color.capeCod.duneGrass)
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .frame(width: 200)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }
}

// MARK: - Menu Item Card

private struct MenuItemCard: View {
    let item: MenuItem

    var body: some View {
        HStack(alignment: .top, spacing: CodSpacing.md) {
            // Category icon
            ZStack {
                Circle()
                    .fill(Color.capeCod.oceanBlue.opacity(0.1))
                    .frame(width: 40, height: 40)

                Image(systemName: item.category.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }

            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                HStack {
                    Text(item.name)
                        .codTextStyle(.cardTitle)

                    if item.isSignatureDish {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.capeCod.sandbarYellow)
                    }
                }

                Text(item.description)
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.textSecondary)
                    .lineLimit(2)

                HStack(spacing: CodSpacing.md) {
                    // Rating
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text(String(format: "%.1f", item.communityRating))
                        Text("(\(item.ratingCount))")
                            .foregroundStyle(Color.capeCod.textSecondary)
                    }
                    .foregroundStyle(Color.capeCod.sandbarYellow)
                    .codTextStyle(.label)

                    // Dietary tags
                    ForEach(item.dietaryTags) { tag in
                        Image(systemName: tag.icon)
                            .font(.system(size: 10))
                            .foregroundStyle(Color.capeCod.duneGrass)
                    }

                    Spacer()

                    // Price
                    if let price = item.formattedPrice {
                        Text(price)
                            .codTextStyle(.body)
                            .foregroundStyle(Color.capeCod.textPrimary)
                    }
                }
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
        RestaurantDetailView(restaurant: BundledRestaurants.all.first!)
    }
}
