import SwiftUI

// MARK: - Models

struct HiddenGemSpot: Identifiable {
    let id: String
    let name: String
    let town: String
    let category: HiddenGemCategory
    let insiderTip: String
    let difficulty: GemDifficulty
    let discoveryCount: Int
}

enum HiddenGemCategory: String, CaseIterable {
    case secretBeaches
    case hiddenTrails
    case localOnly
    case historicSecrets
    case bestKeptRestaurants
    case offTheBeatenPath

    var displayName: String {
        switch self {
        case .secretBeaches: "Secret Beaches"
        case .hiddenTrails: "Hidden Trails"
        case .localOnly: "Local-Only Spots"
        case .historicSecrets: "Historic Secrets"
        case .bestKeptRestaurants: "Best Kept Restaurants"
        case .offTheBeatenPath: "Off-the-Beaten-Path"
        }
    }

    var icon: String {
        switch self {
        case .secretBeaches: "water.waves"
        case .hiddenTrails: "figure.hiking"
        case .localOnly: "mappin.and.ellipse"
        case .historicSecrets: "scroll.fill"
        case .bestKeptRestaurants: "fork.knife"
        case .offTheBeatenPath: "map.fill"
        }
    }

    var chipColor: CodChipColor {
        switch self {
        case .secretBeaches: .blue
        case .hiddenTrails: .green
        case .localOnly: .orange
        case .historicSecrets: .brown
        case .bestKeptRestaurants: .orange
        case .offTheBeatenPath: .green
        }
    }
}

enum GemDifficulty: String, CaseIterable {
    case easy = "Easy"
    case moderate = "Moderate"
    case tricky = "Tricky"

    var color: Color {
        switch self {
        case .easy: Color.capeCod.duneGrass
        case .moderate: Color.capeCod.sunsetOrange
        case .tricky: Color.capeCod.cranberry
        }
    }

    var icon: String {
        switch self {
        case .easy: "figure.walk"
        case .moderate: "figure.hiking"
        case .tricky: "mountain.2.fill"
        }
    }
}

// MARK: - Gem Database

private let allHiddenGemSpots: [HiddenGemSpot] = [

    // MARK: Secret Beaches

    HiddenGemSpot(
        id: "gem-long-point",
        name: "Long Point Beach Walk",
        town: "Provincetown",
        category: .secretBeaches,
        insiderTip: "Walk the breakwater at low tide to reach this remote spit of sand. Bring water and sunscreen - there's zero shade and no facilities. The walk back at high tide means wet feet, so time it right.",
        difficulty: .moderate,
        discoveryCount: 47
    ),
    HiddenGemSpot(
        id: "gem-thumpertown",
        name: "Thumpertown Beach",
        town: "Eastham",
        category: .secretBeaches,
        insiderTip: "Most people head to Coast Guard Beach, but Thumpertown has the same gorgeous bay water without the crowds. The sunset here is spectacular and parking is free after 4 PM.",
        difficulty: .easy,
        discoveryCount: 62
    ),
    HiddenGemSpot(
        id: "gem-bound-brook",
        name: "Bound Brook Island",
        town: "Wellfleet",
        category: .secretBeaches,
        insiderTip: "Drive past the oyster grants on a bumpy dirt road to find a crescent of sand where the harbor meets the marsh. The birding here is unmatched - bring binoculars.",
        difficulty: .tricky,
        discoveryCount: 23
    ),
    HiddenGemSpot(
        id: "gem-cold-storage",
        name: "Cold Storage Beach",
        town: "Dennis",
        category: .secretBeaches,
        insiderTip: "The tiny parking lot naturally limits crowds. Walk left along the shore for near-total solitude. Calm bay water makes it perfect for small kids.",
        difficulty: .easy,
        discoveryCount: 38
    ),
    HiddenGemSpot(
        id: "gem-paines-creek",
        name: "Paines Creek at Low Tide",
        town: "Brewster",
        category: .secretBeaches,
        insiderTip: "At low tide you can walk out half a mile on the flats. The sunset here rivals Skaket with a fraction of the people. Bring water shoes for the walk.",
        difficulty: .easy,
        discoveryCount: 55
    ),

    // MARK: Hidden Trails

    HiddenGemSpot(
        id: "gem-great-island",
        name: "Great Island Trail",
        town: "Wellfleet",
        category: .hiddenTrails,
        insiderTip: "This 8-mile loop through pitch pine forest ends at a deserted beach on the bay. Most people turn back after a mile - push on and you'll have a private beach. Bring plenty of water.",
        difficulty: .tricky,
        discoveryCount: 31
    ),
    HiddenGemSpot(
        id: "gem-pamet-bog",
        name: "Pamet Cranberry Bog Trail",
        town: "Truro",
        category: .hiddenTrails,
        insiderTip: "A flat, easy walk through an old cranberry bog to the Pamet River. In fall, the bogs turn crimson red. Go early morning for the best light and bird activity.",
        difficulty: .easy,
        discoveryCount: 29
    ),
    HiddenGemSpot(
        id: "gem-cedar-swamp",
        name: "Atlantic White Cedar Swamp",
        town: "Wellfleet",
        category: .hiddenTrails,
        insiderTip: "A boardwalk through a primeval swamp that feels like another century. The ancient cedars and total silence make it magical. Wear grippy shoes - the boardwalk gets slippery.",
        difficulty: .moderate,
        discoveryCount: 42
    ),
    HiddenGemSpot(
        id: "gem-red-maple-swamp",
        name: "Red Maple Swamp Trail",
        town: "Eastham",
        category: .hiddenTrails,
        insiderTip: "Behind the Fort Hill parking lot, almost nobody takes this trail. A boardwalk loop through a red maple swamp that's ablaze with color in autumn. Quick and stunning.",
        difficulty: .easy,
        discoveryCount: 19
    ),
    HiddenGemSpot(
        id: "gem-beech-forest",
        name: "Beech Forest Trail",
        town: "Provincetown",
        category: .hiddenTrails,
        insiderTip: "Ancient beech trees draped in lichen create a canopy so thick it feels like twilight at noon. In spring, lady slippers bloom along the boardwalk. Best bird-watching on the Outer Cape.",
        difficulty: .easy,
        discoveryCount: 51
    ),

    // MARK: Local-Only Spots

    HiddenGemSpot(
        id: "gem-earth-house",
        name: "Earth House",
        town: "Orleans",
        category: .localOnly,
        insiderTip: "A treasure trove of vinyl records, crystals, and eclectic gifts. The back room has the best selection of used records on the Cape. Locals treat this like a second living room.",
        difficulty: .easy,
        discoveryCount: 67
    ),
    HiddenGemSpot(
        id: "gem-chatham-pier-morning",
        name: "Chatham Fish Pier at Dawn",
        town: "Chatham",
        category: .localOnly,
        insiderTip: "Show up at 6 AM to watch the fishing fleet come in. The fishermen will sometimes sell you lobsters right off the boat. Seals follow the boats into the harbor - a show tourists miss entirely.",
        difficulty: .easy,
        discoveryCount: 34
    ),
    HiddenGemSpot(
        id: "gem-rock-harbor-sunset",
        name: "Rock Harbor at Golden Hour",
        town: "Orleans",
        category: .localOnly,
        insiderTip: "Skaket gets all the press but locals know Rock Harbor sunsets are the real deal. Walk out on the jetty for the best angle. Arrive 30 minutes before sunset.",
        difficulty: .easy,
        discoveryCount: 73
    ),

    // MARK: Historic Secrets

    HiddenGemSpot(
        id: "gem-atlantic-cable",
        name: "French Atlantic Cable Station",
        town: "Orleans",
        category: .historicSecrets,
        insiderTip: "The first transatlantic cable from France landed here in 1898. A tiny museum in the original cable hut tells the story of how Orleans became America's link to Europe. Most visitors walk right past it.",
        difficulty: .easy,
        discoveryCount: 15
    ),
    HiddenGemSpot(
        id: "gem-marconi-station",
        name: "Marconi Wireless Station Site",
        town: "Wellfleet",
        category: .historicSecrets,
        insiderTip: "In 1903, the first transatlantic wireless message was sent from this very spot. Only the concrete foundations remain, but the cliffside view is breathtaking and the interpretive signs tell a fascinating story.",
        difficulty: .easy,
        discoveryCount: 28
    ),
    HiddenGemSpot(
        id: "gem-penniman-house",
        name: "Captain Penniman House",
        town: "Eastham",
        category: .historicSecrets,
        insiderTip: "A whaling captain's mansion with a jawbone gate from a right whale. Free to explore the grounds. The house itself opens for tours occasionally - call ahead. Fort Hill's best-kept secret.",
        difficulty: .easy,
        discoveryCount: 22
    ),
    HiddenGemSpot(
        id: "gem-shipwreck-sites",
        name: "Nauset Beach Shipwreck Remains",
        town: "Orleans",
        category: .historicSecrets,
        insiderTip: "After big storms, the ribs of old shipwrecks emerge from the sand at the south end of Nauset Beach. You need to walk about a mile from the parking lot. Timing and luck required.",
        difficulty: .tricky,
        discoveryCount: 11
    ),

    // MARK: Best Kept Restaurants

    HiddenGemSpot(
        id: "gem-the-knack",
        name: "The Knack",
        town: "Orleans",
        category: .bestKeptRestaurants,
        insiderTip: "Chef-driven street food in a tiny space behind the post office. The lobster corn dog and duck fat fries are legendary. Get there early - they sell out regularly. Cash or card.",
        difficulty: .moderate,
        discoveryCount: 45
    ),
    HiddenGemSpot(
        id: "gem-pb-boulangerie",
        name: "PB Boulangerie Back Patio",
        town: "Wellfleet",
        category: .bestKeptRestaurants,
        insiderTip: "Everyone knows the bakery, but the hidden back patio serves full French bistro dinners. Reservations are tough - call exactly two weeks ahead. The cassoulet is worth the planning.",
        difficulty: .moderate,
        discoveryCount: 37
    ),
    HiddenGemSpot(
        id: "gem-capt-cass",
        name: "Cap't Cass Rock Harbor Seafood",
        town: "Orleans",
        category: .bestKeptRestaurants,
        insiderTip: "A shack so small you'll drive past it. Cash only. The fish tacos are legendary among locals and the fried clams sell out by 2 PM on busy days. Just look for the boats.",
        difficulty: .easy,
        discoveryCount: 58
    ),

    // MARK: Off the Beaten Path

    HiddenGemSpot(
        id: "gem-crows-pasture",
        name: "Crow's Pasture",
        town: "Dennis",
        category: .offTheBeatenPath,
        insiderTip: "An old farmstead turned conservation land with trails through meadows down to tidal flats. At low tide, walk out to sandbars. The osprey nest near the trailhead has been active for 20 years.",
        difficulty: .moderate,
        discoveryCount: 26
    ),
    HiddenGemSpot(
        id: "gem-scargo-tower",
        name: "Scargo Tower at Sunset",
        town: "Dennis",
        category: .offTheBeatenPath,
        insiderTip: "Climb the stone tower on Scargo Hill for 360-degree views from Provincetown to Plymouth. Go at golden hour, bring a blanket, and sit on the hillside after. The Cape's best-kept overlook.",
        difficulty: .easy,
        discoveryCount: 41
    ),
]

// MARK: - HiddenGemsExploreView

struct HiddenGemsExploreView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var selectedCategory: HiddenGemCategory?
    @State private var expandedGemID: String?
    @State private var discoveredIDs: Set<String> = []
    @State private var headerAppeared = false

    // MARK: - Computed

    private var totalGems: Int { allHiddenGemSpots.count }
    private var discoveredCount: Int { discoveredIDs.count }

    private var filteredGems: [HiddenGemSpot] {
        guard let selectedCategory else { return allHiddenGemSpots }
        return allHiddenGemSpots.filter { $0.category == selectedCategory }
    }

    private var progressFraction: CGFloat {
        guard totalGems > 0 else { return 0 }
        return CGFloat(discoveredCount) / CGFloat(totalGems)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    discoveryHeader
                        .staggered(index: 0)

                    progressTracker
                        .staggered(index: 1)

                    categoryFilters
                        .staggered(index: 2)

                    gemList
                        .staggered(index: 3)
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Hidden Cape Cod")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        CodHaptic.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.capeCod.textSecondary)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if selectedCategory != nil {
                        Button {
                            CodHaptic.selection()
                            withAnimation(CodAnimation.spring) {
                                selectedCategory = nil
                            }
                        } label: {
                            Text("Clear")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.capeCod.oceanBlue)
                        }
                    }
                }
            }
            .onAppear {
                loadDiscovered()
                withAnimation(CodAnimation.gentle) {
                    headerAppeared = true
                }
            }
        }
    }

    // MARK: - Discovery Header

    private var discoveryHeader: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(Color.capeCod.sunsetOrange)
                .symbolEffect(.pulse, options: .repeating)
                .codAccessibleHidden()

            Text("Discover Hidden Cape Cod")
                .codTextStyle(.heroTitle)
                .multilineTextAlignment(.center)
                .codAccessibleHeader("Discover Hidden Cape Cod")

            Text("Secret spots that repeat visitors swear by")
                .codTextStyle(.subtitle)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, CodSpacing.lg)
    }

    // MARK: - Progress Tracker

    private var progressTracker: some View {
        VStack(spacing: CodSpacing.md) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.capeCod.sunsetOrange)
                    .codAccessibleHidden()

                Text("Discovery Progress")
                    .codTextStyle(.cardTitle)

                Spacer()

                Text("\(discoveredCount) of \(totalGems) discovered")
                    .codTextStyle(.caption)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.capeCod.surface)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.capeCod.oceanGradient)
                        .frame(
                            width: geometry.size.width * progressFraction,
                            height: 8
                        )
                        .animation(CodAnimation.spring, value: discoveredCount)
                }
            }
            .frame(height: 8)

            progressMilestones
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .codAccessibleGroup(label: "\(discoveredCount) of \(totalGems) hidden gems discovered.")
    }

    private var progressMilestones: some View {
        HStack(spacing: CodSpacing.xs) {
            milestoneBadge(count: 5, label: "Scout", icon: "binoculars.fill")
            Spacer(minLength: 0)
            milestoneBadge(count: 10, label: "Explorer", icon: "map.fill")
            Spacer(minLength: 0)
            milestoneBadge(count: 15, label: "Adventurer", icon: "mountain.2.fill")
            Spacer(minLength: 0)
            milestoneBadge(count: 20, label: "Legend", icon: "crown.fill")
        }
    }

    private func milestoneBadge(count: Int, label: String, icon: String) -> some View {
        let achieved = discoveredCount >= count
        return HStack(spacing: CodSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(label)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundStyle(achieved ? Color.capeCod.oceanBlue : Color.capeCod.driftwood.opacity(0.5))
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(achieved ? Color.capeCod.oceanBlue.opacity(0.12) : Color.capeCod.surface)
        .clipShape(Capsule())
    }

    // MARK: - Category Filters

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                ForEach(HiddenGemCategory.allCases, id: \.self) { category in
                    CodChip(
                        category.displayName,
                        style: .category(category.chipColor),
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(CodAnimation.spring) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                    .codAccessibleButton(
                        category.displayName,
                        hint: selectedCategory == category ? "Remove filter" : "Filter by \(category.displayName)"
                    )
                }
            }
        }
    }

    // MARK: - Gem List

    private var gemList: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack {
                Text(selectedCategory?.displayName ?? "All Hidden Gems")
                    .codTextStyle(.sectionTitle)
                    .codAccessibleHeader(selectedCategory?.displayName ?? "All Hidden Gems")

                Spacer()

                Text("\(filteredGems.count) gems")
                    .codTextStyle(.caption)
            }

            LazyVStack(spacing: CodSpacing.md) {
                ForEach(Array(filteredGems.enumerated()), id: \.element.id) { index, gem in
                    gemCard(gem: gem)
                        .staggered(index: index)
                }
            }
        }
    }

    // MARK: - Gem Card

    private func gemCard(gem: HiddenGemSpot) -> some View {
        let isExpanded = expandedGemID == gem.id
        let isDiscovered = discoveredIDs.contains(gem.id)

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                CodHaptic.light()
                withAnimation(CodAnimation.spring) {
                    expandedGemID = isExpanded ? nil : gem.id
                }
            } label: {
                gemCardHeader(gem: gem, isExpanded: isExpanded, isDiscovered: isDiscovered)
            }
            .buttonStyle(CodButtonPressStyle(variant: .ghost))
            .codAccessibleCard(
                label: "\(gem.name), \(gem.town), \(gem.difficulty.rawValue) to find\(isDiscovered ? ", discovered" : "")",
                hint: isExpanded ? "Tap to collapse" : "Tap to expand details"
            )

            if isExpanded {
                gemCardExpanded(gem: gem, isDiscovered: isDiscovered)
            }
        }
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private func gemCardHeader(gem: HiddenGemSpot, isExpanded: Bool, isDiscovered: Bool) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(alignment: .top, spacing: CodSpacing.sm) {
                Image(systemName: gem.category.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .frame(width: 36, height: 36)
                    .codAccessibleHidden()

                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    HStack {
                        Text(gem.name)
                            .codTextStyle(.cardTitle)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        if isDiscovered {
                            CodCardBadge(text: "Discovered", color: Color.capeCod.duneGrass)
                        }

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.capeCod.driftwood)
                            .codAccessibleHidden()
                    }

                    HStack(spacing: CodSpacing.sm) {
                        Label(gem.town, systemImage: "mappin")
                            .codTextStyle(.caption)

                        difficultyBadge(gem.difficulty)

                        Spacer()

                        Label("\(gem.discoveryCount) explorers", systemImage: "person.2.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.capeCod.driftwood)
                    }
                }
            }

            if !isExpanded {
                Text(gem.insiderTip)
                    .codTextStyle(.body)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(CodSpacing.cardPadding)
    }

    private func gemCardExpanded(gem: HiddenGemSpot, isDiscovered: Bool) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Divider()
                .padding(.horizontal, CodSpacing.cardPadding)

            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                // Insider tip callout
                HStack(alignment: .top, spacing: CodSpacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.capeCod.sunsetOrange)
                        .codAccessibleHidden()

                    VStack(alignment: .leading, spacing: CodSpacing.xs) {
                        Text("Insider Tip")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.capeCod.sunsetOrange)

                        Text(gem.insiderTip)
                            .font(.system(size: 14, weight: .regular, design: .serif))
                            .italic()
                            .foregroundStyle(Color.capeCod.sunsetOrange)
                    }
                }
                .padding(CodSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.capeCod.sunsetOrange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))

                // Discovery toggle
                HStack(spacing: CodSpacing.sm) {
                    if !isDiscovered {
                        CodButton("Mark Discovered", variant: .primary, icon: "checkmark.circle") {
                            CodHaptic.success()
                            markDiscovered(gem.id)
                        }
                    } else {
                        CodButton("Unmark", variant: .ghost, icon: "xmark.circle") {
                            CodHaptic.selection()
                            unmarkDiscovered(gem.id)
                        }
                    }

                    Spacer()

                    CodButton("Share", variant: .ghost, icon: "square.and.arrow.up") {
                        shareGem(gem)
                    }
                }
            }
            .padding(.horizontal, CodSpacing.cardPadding)
            .padding(.bottom, CodSpacing.cardPadding)
        }
        .transition(.codSlideUp)
    }

    // MARK: - Difficulty Badge

    private func difficultyBadge(_ difficulty: GemDifficulty) -> some View {
        HStack(spacing: 3) {
            Image(systemName: difficulty.icon)
                .font(.system(size: 9))
            Text(difficulty.rawValue)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(difficulty.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(difficulty.color.opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: - Persistence

    private static let discoveredKey = "hiddenGemsExplore.discoveredIDs"

    private func loadDiscovered() {
        let saved = UserDefaults.standard.stringArray(forKey: Self.discoveredKey) ?? []
        discoveredIDs = Set(saved)
    }

    private func markDiscovered(_ id: String) {
        withAnimation(CodAnimation.spring) {
            discoveredIDs.insert(id)
        }
        UserDefaults.standard.set(Array(discoveredIDs), forKey: Self.discoveredKey)
    }

    private func unmarkDiscovered(_ id: String) {
        withAnimation(CodAnimation.spring) {
            discoveredIDs.remove(id)
        }
        UserDefaults.standard.set(Array(discoveredIDs), forKey: Self.discoveredKey)
    }

    // MARK: - Share

    private func shareGem(_ gem: HiddenGemSpot) {
        CodHaptic.tap()
        let text = "I discovered a hidden gem on Cape Cod! \(gem.name) in \(gem.town) - \(gem.difficulty.rawValue) to find. via @HeyCapeCode"

        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else { return }

        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        topVC.present(activityVC, animated: true)
    }
}

// MARK: - Preview

#Preview("Hidden Cape Cod") {
    HiddenGemsExploreView()
}

#Preview("Hidden Cape Cod - Sheet") {
    Text("Home")
        .sheet(isPresented: .constant(true)) {
            HiddenGemsExploreView()
        }
}
