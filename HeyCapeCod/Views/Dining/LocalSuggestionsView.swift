import SwiftUI

// MARK: - Town Data

enum CapeCodArea: String, CaseIterable, Identifiable {
    case orleans = "Orleans"
    case chatham = "Chatham"
    case hyannis = "Hyannis"
    case provincetown = "Provincetown"
    case wellfleet = "Wellfleet"
    case brewster = "Brewster"
    case falmouth = "Falmouth"
    case sandwich = "Sandwich"
    case dennisYarmouth = "Dennis/Yarmouth"
    case truro = "Truro"
    case eastham = "Eastham"
    case harwich = "Harwich"

    var id: String { rawValue }

    var tagline: String {
        switch self {
        case .orleans: "Gateway to the Outer Cape"
        case .chatham: "Classic New England charm"
        case .hyannis: "The Cape's main hub"
        case .provincetown: "Art, culture & seafood"
        case .wellfleet: "Oysters & ocean vibes"
        case .brewster: "Nature trails & bayside dining"
        case .falmouth: "Island ferries & beaches"
        case .sandwich: "Historic village & glass museum"
        case .dennisYarmouth: "Family fun & mini golf"
        case .truro: "Quiet beaches & lighthouses"
        case .eastham: "National Seashore gateway"
        case .harwich: "Cranberry bogs & harbors"
        }
    }

    var icon: String {
        switch self {
        case .orleans: "mappin.circle.fill"
        case .chatham: "building.columns.fill"
        case .hyannis: "ferry.fill"
        case .provincetown: "paintpalette.fill"
        case .wellfleet: "drop.fill"
        case .brewster: "leaf.fill"
        case .falmouth: "sailboat.fill"
        case .sandwich: "clock.fill"
        case .dennisYarmouth: "figure.play"
        case .truro: "sun.max.fill"
        case .eastham: "binoculars.fill"
        case .harwich: "tree.fill"
        }
    }
}

// MARK: - Local Suggestion Model

struct LocalSuggestion: Identifiable {
    let id: String
    let name: String
    let type: SuggestionType
    let town: CapeCodArea
    let rating: Double
    let reviewCount: Int
    let priceLevel: Int
    let description: String
    let topItems: [String]
    let bestFor: String
    let icon: String

    enum SuggestionType: String, CaseIterable {
        case restaurant = "Restaurants"
        case attraction = "Attractions"

        var icon: String {
            switch self {
            case .restaurant: "fork.knife"
            case .attraction: "star.fill"
            }
        }
    }
}

// MARK: - View

struct LocalSuggestionsView: View {
    @State private var selectedArea: CapeCodArea = .orleans
    @State private var selectedType: LocalSuggestion.SuggestionType = .restaurant
    @State private var searchText = ""

    private var filteredSuggestions: [LocalSuggestion] {
        var items = LocalSuggestionsData.suggestions.filter {
            $0.town == selectedArea && $0.type == selectedType
        }
        if !searchText.isEmpty {
            items = items.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.topItems.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        return items.sorted { $0.rating > $1.rating }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                areaSelector
                typeToggle
                searchBar

                if filteredSuggestions.isEmpty {
                    emptyState
                } else {
                    suggestionCards
                }
            }
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background)
        .navigationTitle("Local Picks")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Area Selector

    private var areaSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                ForEach(CapeCodArea.allCases) { area in
                    areaChip(area)
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
    }

    private func areaChip(_ area: CapeCodArea) -> some View {
        Button {
            withAnimation(CodAnimation.quick) { selectedArea = area }
            CodHaptic.selection()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: area.icon)
                    .font(.system(size: 12))
                Text(area.rawValue)
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(selectedArea == area ? Color.white : Color.capeCod.textPrimary)
            .padding(.horizontal, CodSpacing.md)
            .padding(.vertical, CodSpacing.sm)
            .background(selectedArea == area ? Color.capeCod.oceanBlue : Color.capeCod.surfaceElevated)
            .clipShape(Capsule())
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
    }

    // MARK: - Type Toggle

    private var typeToggle: some View {
        HStack(spacing: 0) {
            ForEach(LocalSuggestion.SuggestionType.allCases, id: \.rawValue) { type in
                Button {
                    withAnimation(CodAnimation.quick) { selectedType = type }
                    CodHaptic.selection()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: type.icon)
                            .font(.system(size: 12))
                        Text(type.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(selectedType == type ? Color.white : Color.capeCod.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, CodSpacing.sm + 2)
                    .background(selectedType == type ? Color.capeCod.oceanBlue : Color.clear)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(3)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(Capsule())
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.capeCod.driftwood)
            TextField("Search \(selectedArea.rawValue)...", text: $searchText)
                .codTextStyle(.body)
        }
        .padding(.horizontal, CodSpacing.md)
        .padding(.vertical, CodSpacing.sm + 2)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Cards

    private var suggestionCards: some View {
        VStack(spacing: 0) {
            // Area header
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedArea.rawValue)
                    .codTextStyle(.sectionTitle)
                Text(selectedArea.tagline)
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.md)

            LazyVStack(spacing: CodSpacing.md) {
                ForEach(Array(filteredSuggestions.enumerated()), id: \.element.id) { index, suggestion in
                    SuggestionCard(suggestion: suggestion, rank: index + 1)
                        .staggered(index: index)
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: CodSpacing.lg) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 48))
                .foregroundStyle(Color.capeCod.oceanBlue.opacity(0.3))
            Text("No suggestions found")
                .codTextStyle(.sectionTitle)
            Text("Try a different area or search term")
                .codTextStyle(.caption)
        }
        .padding(.top, CodSpacing.xxl)
    }
}

// MARK: - Suggestion Card

private struct SuggestionCard: View {
    let suggestion: LocalSuggestion
    let rank: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: CodSpacing.sm) {
                // Rank badge
                ZStack {
                    Circle()
                        .fill(rank <= 3 ? Color.capeCod.oceanBlue : Color.capeCod.driftwood.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(rank <= 3 ? Color.white : Color.capeCod.textPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.name)
                        .codTextStyle(.cardTitle)
                    HStack(spacing: CodSpacing.xs) {
                        if suggestion.type == .restaurant {
                            Text(String(repeating: "$", count: suggestion.priceLevel))
                                .foregroundStyle(Color.capeCod.duneGrass)
                        }
                        Text(suggestion.bestFor)
                    }
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.textSecondary)
                }

                Spacer()

                // Rating
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text(String(format: "%.1f", suggestion.rating))
                    }
                    .foregroundStyle(Color.capeCod.sandbarYellow)
                    .codTextStyle(.label)

                    Text("\(suggestion.reviewCount) reviews")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.capeCod.textSecondary)
                }
            }
            .padding(CodSpacing.cardPadding)

            // Description
            Text(suggestion.description)
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
                .lineLimit(2)
                .padding(.horizontal, CodSpacing.cardPadding)

            // Top items
            if !suggestion.topItems.isEmpty {
                Divider()
                    .padding(.horizontal, CodSpacing.cardPadding)
                    .padding(.top, CodSpacing.sm)

                topItemsSection
            }
        }
        .padding(.bottom, CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private var topItemsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.xs) {
            Text(suggestion.type == .restaurant ? "Popular Items" : "Highlights")
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.oceanBlue)

            FlowLayout(spacing: 6) {
                ForEach(suggestion.topItems, id: \.self) { item in
                    Text(item)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.capeCod.textPrimary)
                        .padding(.horizontal, CodSpacing.sm)
                        .padding(.vertical, 4)
                        .background(Color.capeCod.oceanBlue.opacity(0.08))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, CodSpacing.cardPadding)
        .padding(.top, CodSpacing.sm)
    }
}

#Preview {
    NavigationStack {
        LocalSuggestionsView()
    }
}
