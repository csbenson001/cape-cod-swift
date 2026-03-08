import SwiftUI

struct TourListView: View {
    @State private var selectedCategory: TourCategory?
    @State private var searchText = ""

    private var filteredTours: [GuidedTour] {
        var tours = CuratedTours.all
        if let category = selectedCategory {
            tours = tours.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            tours = tours.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.subtitle.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        return tours
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    // Search
                    tourSearchBar

                    // Category filters
                    tourCategoryFilters

                    // Hero tour card
                    if selectedCategory == nil && searchText.isEmpty {
                        featuredTourCard
                    }

                    // Tour list
                    if filteredTours.isEmpty {
                        emptyState
                    } else {
                        toursList
                    }
                }
                .padding(.bottom, CodSpacing.xxl)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Tours")
            .navigationDestination(for: GuidedTour.self) { tour in
                TourDetailView(tour: tour)
            }
        }
    }

    // MARK: - Search Bar

    private var tourSearchBar: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.capeCod.driftwood)

            TextField("Search tours...", text: $searchText)
                .codTextStyle(.body)
        }
        .padding(.horizontal, CodSpacing.md)
        .padding(.vertical, CodSpacing.sm + 2)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
        .adaptiveCardStyle(cornerRadius: CodRadius.input, shadow: .button)
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Category Filters

    private var tourCategoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                TourFilterChip(label: "All", icon: "map.fill", isSelected: selectedCategory == nil) {
                    withAnimation(CodAnimation.quick) { selectedCategory = nil }
                    CodHaptic.selection()
                }

                ForEach(TourCategory.allCases) { category in
                    TourFilterChip(
                        label: category.displayName,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(CodAnimation.quick) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                        CodHaptic.selection()
                    }
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
    }

    // MARK: - Featured Tour Card

    private var featuredTourCard: some View {
        NavigationLink(value: CuratedTours.lighthouseTrail) {
            ZStack(alignment: .bottomLeading) {
                // Background gradient
                LinearGradient(
                    colors: [Color.capeCod.deepNavy, Color.capeCod.oceanBlue],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .frame(height: 200)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "light.beacon.max.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white.opacity(0.1))
                        .offset(x: -20, y: 20)
                }

                VStack(alignment: .leading, spacing: CodSpacing.sm) {
                    HStack(spacing: CodSpacing.xs) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text("FEATURED TOUR")
                            .codTextStyle(.label)
                    }
                    .foregroundStyle(Color.capeCod.sandbarYellow)

                    Text("Lighthouse Trail")
                        .codTextStyle(.heroTitle)
                        .foregroundStyle(.white)

                    Text("Visit 3 iconic lighthouses across the Cape")
                        .codTextStyle(.body)
                        .foregroundStyle(.white.opacity(0.7))

                    HStack(spacing: CodSpacing.md) {
                        Label("3-4 hrs", systemImage: "clock")
                        Label("65 mi", systemImage: "car")
                        Label("3 stops", systemImage: "mappin.circle")
                    }
                    .codTextStyle(.label)
                    .foregroundStyle(.white.opacity(0.6))
                }
                .padding(CodSpacing.cardPadding + 4)
            }
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .buttonStyle(.plain)
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Tours List

    private var toursList: some View {
        LazyVStack(spacing: CodSpacing.md) {
            ForEach(Array(filteredTours.enumerated()), id: \.element.id) { index, tour in
                // Skip the featured tour if showing unfiltered
                if selectedCategory != nil || searchText.isEmpty == false || tour.id != "tour-lighthouses" {
                    NavigationLink(value: tour) {
                        TourCard(tour: tour)
                    }
                    .buttonStyle(.plain)
                    .staggered(index: index)
                }
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: CodSpacing.lg) {
            Image(systemName: "map")
                .font(.system(size: 48))
                .foregroundStyle(Color.capeCod.oceanBlue.opacity(0.3))

            Text("No tours found")
                .codTextStyle(.sectionTitle)

            Text("Try a different category or search term")
                .codTextStyle(.caption)
        }
        .padding(.top, CodSpacing.xxl)
    }
}

// MARK: - Tour Card

private struct TourCard: View {
    let tour: GuidedTour

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top: icon strip
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.capeCod.oceanBlue.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: tour.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.capeCod.oceanBlue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(tour.name)
                        .codTextStyle(.cardTitle)

                    Text(tour.subtitle)
                        .codTextStyle(.caption)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.capeCod.driftwood.opacity(0.4))
            }
            .padding(CodSpacing.cardPadding)

            Divider()
                .padding(.horizontal, CodSpacing.cardPadding)

            // Bottom: metadata
            HStack(spacing: CodSpacing.md) {
                Label(tour.estimatedDuration, systemImage: "clock")
                Label(tour.distance, systemImage: "car")
                Label("\(tour.stopIDs.count) stops", systemImage: "mappin.circle")

                Spacer()

                Text(tour.difficulty.displayName)
                    .codTextStyle(.label)
                    .padding(.horizontal, CodSpacing.sm)
                    .padding(.vertical, CodSpacing.xs)
                    .background(difficultyColor.opacity(0.12))
                    .foregroundStyle(difficultyColor)
                    .clipShape(Capsule())
            }
            .codTextStyle(.label)
            .foregroundStyle(Color.capeCod.textSecondary)
            .padding(CodSpacing.cardPadding)
        }
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .codAccessibleCard(
            label: "\(tour.name), \(tour.subtitle), \(tour.stopIDs.count) stops, \(tour.estimatedDuration)",
            hint: "Double tap to view tour details"
        )
    }

    private var difficultyColor: Color {
        switch tour.difficulty {
        case .easy: Color.capeCod.duneGrass
        case .moderate: Color.capeCod.sandbarYellow
        case .challenging: Color.capeCod.sunsetOrange
        }
    }
}

// MARK: - Filter Chip

private struct TourFilterChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .codTextStyle(.label)
            }
            .padding(.horizontal, CodSpacing.md)
            .padding(.vertical, CodSpacing.sm)
            .background(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.surfaceElevated)
            .foregroundStyle(isSelected ? .white : Color.capeCod.textPrimary)
            .clipShape(Capsule())
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleButton(
            "\(label) filter",
            hint: isSelected ? "Currently selected" : "Double tap to filter"
        )
    }
}

#Preview {
    TourListView()
}
