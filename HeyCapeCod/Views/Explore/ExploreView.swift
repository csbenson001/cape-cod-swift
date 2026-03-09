import SwiftUI

struct ExploreView: View {
    @State private var viewModel = ExploreViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    // Offline indicator
                    if viewModel.isOffline {
                        offlineBanner
                            .transition(.codSlideUp)
                    }

                    // Search
                    searchBar

                    // Category Filters
                    categoryFilters

                    // Results
                    if viewModel.isLoading && viewModel.filteredLocations.isEmpty {
                        loadingSkeleton
                    } else if viewModel.filteredLocations.isEmpty {
                        emptyState
                    } else {
                        locationsList
                    }
                }
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Explore")
            .task {
                await viewModel.loadLocations()
            }
        }
    }

    private var offlineBanner: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "wifi.slash")
                .font(.caption)
            Text("Showing offline data")
                .codTextStyle(.label)
        }
        .padding(.horizontal, CodSpacing.md)
        .padding(.vertical, CodSpacing.xs)
        .frame(maxWidth: .infinity)
        .background(Color.capeCod.driftwood.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
        .padding(.horizontal, CodSpacing.screenEdge)
        .codAccessible(label: "Offline mode active, showing cached data")
    }

    private var searchBar: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.capeCod.driftwood)

            TextField("Search beaches, restaurants, lighthouses...", text: $viewModel.searchText)
                .codTextStyle(.body)
                .onChange(of: viewModel.searchText) {
                    viewModel.applyFilters()
                }
        }
        .padding(.horizontal, CodSpacing.md)
        .padding(.vertical, CodSpacing.sm + 2)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
        .adaptiveCardStyle(cornerRadius: CodRadius.input, shadow: .button)
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                ForEach(viewModel.categories) { category in
                    CategoryChip(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        withAnimation(CodAnimation.quick) {
                            viewModel.selectCategory(category)
                        }
                        CodHaptic.selection()
                    }
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
    }

    private var loadingSkeleton: some View {
        VStack(spacing: CodSpacing.md) {
            ForEach(0..<4, id: \.self) { index in
                LoadingSkeleton(variant: .card)
                    .staggered(index: index)
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    private var locationsList: some View {
        LazyVStack(spacing: CodSpacing.md) {
            ForEach(Array(viewModel.filteredLocations.enumerated()), id: \.element.id) { index, location in
                NavigationLink(value: location) {
                    LocationCard(
                        location: location,
                        distance: viewModel.distance(to: location)
                    )
                }
                .buttonStyle(.plain)
                .staggered(index: index)
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .navigationDestination(for: CodLocation.self) { location in
            LocationDetailView(location: location)
        }
    }

    private var emptyState: some View {
        VStack(spacing: CodSpacing.lg) {
            Image(systemName: "safari")
                .font(.system(size: 48))
                .foregroundStyle(Color.capeCod.oceanBlue.opacity(0.3))

            Text("No locations found")
                .codTextStyle(.sectionTitle)

            Text("Try adjusting your search or filters")
                .codTextStyle(.caption)
        }
        .padding(.top, CodSpacing.xxl)
        .codAccessible(label: "No locations found. Try adjusting your search or filters.")
    }
}

// MARK: - Category Chip

private struct CategoryChip: View {
    let category: LocationCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.displayName)
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
        .codAccessibleButton(
            "\(category.displayName) filter",
            hint: isSelected ? "Currently selected" : "Double tap to filter"
        )
    }
}

// MARK: - Location Card

private struct LocationCard: View {
    let location: CodLocation
    let distance: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder with gradient overlay
            ImagePlaceholder(categoryColor: categoryColor)
                .frame(height: 160)
                .overlay(alignment: .center) {
                    Image(systemName: location.category.icon)
                        .font(.system(size: 32))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .overlay(alignment: .bottom) {
                    Color.capeCod.imageOverlayGradient()
                        .frame(height: 60)
                }
                .clipped()

            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                HStack {
                    Text(location.name)
                        .codTextStyle(.cardTitle)
                    Spacer()
                    if let distance {
                        Text(distance)
                            .codTextStyle(.label)
                    }
                }

                HStack(spacing: CodSpacing.xs) {
                    Text(location.town.displayName)
                        .codTextStyle(.caption)

                    if let rating = location.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(Color.capeCod.sandbarYellow)
                            Text(String(format: "%.1f", rating))
                                .codTextStyle(.label)
                        }
                    }
                }

                if !location.description.isEmpty {
                    Text(location.description)
                        .codTextStyle(.caption)
                        .lineLimit(2)
                }
            }
            .padding(CodSpacing.cardPadding)
        }
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .codAccessibleCard(
            label: "\(location.name), \(location.town.displayName)\(distance.map { ", \($0) away" } ?? "")",
            hint: "Double tap for details"
        )
    }

    private var categoryColor: Color {
        switch location.category {
        case .beach: Color.capeCod.oceanBlue
        case .restaurant: Color.capeCod.sunsetOrange
        case .nature: Color.capeCod.duneGrass
        default: Color.capeCod.driftwood
        }
    }
}

#Preview {
    ExploreView()
}
