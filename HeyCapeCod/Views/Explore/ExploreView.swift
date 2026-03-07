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
                .padding(.bottom, CodSpacing.xxl)
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
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm))
        .padding(.horizontal, CodSpacing.screenEdge)
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
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.input))
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
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
    }

    private var loadingSkeleton: some View {
        LazyVStack(spacing: CodSpacing.md) {
            ForEach(0..<4, id: \.self) { _ in
                VStack(alignment: .leading, spacing: CodSpacing.sm) {
                    RoundedRectangle(cornerRadius: CodRadius.card)
                        .fill(Color.capeCod.driftwood.opacity(0.1))
                        .frame(height: 160)

                    VStack(alignment: .leading, spacing: CodSpacing.xs) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.capeCod.driftwood.opacity(0.15))
                            .frame(width: 180, height: 16)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.capeCod.driftwood.opacity(0.1))
                            .frame(width: 120, height: 12)
                    }
                    .padding(.horizontal, CodSpacing.sm)
                    .padding(.bottom, CodSpacing.sm)
                }
                .background(Color.capeCod.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
                .codShadow(.card)
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .redacted(reason: .placeholder)
    }

    private var locationsList: some View {
        LazyVStack(spacing: CodSpacing.md) {
            ForEach(viewModel.filteredLocations) { location in
                NavigationLink(value: location) {
                    LocationCard(
                        location: location,
                        distance: viewModel.distance(to: location)
                    )
                }
                .buttonStyle(.plain)
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
                .codTextStyle(.subtitle)

            Text("Try adjusting your search or filters")
                .codTextStyle(.caption)
        }
        .padding(.top, CodSpacing.xxl)
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
                    .codTextStyle(.label)
            }
            .padding(.horizontal, CodSpacing.md)
            .padding(.vertical, CodSpacing.sm)
            .background(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.cardBackground)
            .foregroundStyle(isSelected ? .white : Color.capeCod.primaryText)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Location Card

private struct LocationCard: View {
    let location: CodLocation
    let distance: String?

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            // Image placeholder
            RoundedRectangle(cornerRadius: CodRadius.card)
                .fill(Color.capeCod.oceanBlue.opacity(0.1))
                .frame(height: 160)
                .overlay {
                    Image(systemName: location.category.icon)
                        .font(.system(size: 32))
                        .foregroundStyle(Color.capeCod.oceanBlue.opacity(0.3))
                }

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
            .padding(.horizontal, CodSpacing.sm)
            .padding(.bottom, CodSpacing.sm)
        }
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .codShadow(.card)
    }
}

#Preview {
    ExploreView()
}
