import SwiftUI

// MARK: - Models

struct HiddenGem: Identifiable {
    let id: String
    let name: String
    let emoji: String
    let category: GemCategory
    let town: String
    let description: String
    let localTip: String
    let unlockTier: GemTier
}

enum GemCategory: String, CaseIterable {
    case secretBeaches, localEats, bestViews, swimmingHoles, hiddenWalks, localShops

    var displayName: String {
        switch self {
        case .secretBeaches: "Secret Beaches"
        case .localEats: "Local Eats"
        case .bestViews: "Best Views"
        case .swimmingHoles: "Swimming Holes"
        case .hiddenWalks: "Hidden Walks"
        case .localShops: "Local Shops"
        }
    }

    var emoji: String {
        switch self {
        case .secretBeaches: "\u{1F3D6}"
        case .localEats: "\u{1F37D}"
        case .bestViews: "\u{1F305}"
        case .swimmingHoles: "\u{1F3CA}"
        case .hiddenWalks: "\u{1F6B6}"
        case .localShops: "\u{1F6CD}"
        }
    }

    var icon: String {
        switch self {
        case .secretBeaches: "water.waves"
        case .localEats: "fork.knife"
        case .bestViews: "sun.horizon.fill"
        case .swimmingHoles: "figure.pool.swim"
        case .hiddenWalks: "figure.walk"
        case .localShops: "bag.fill"
        }
    }

    var chipColor: CodChipColor {
        switch self {
        case .secretBeaches: .blue
        case .localEats: .orange
        case .bestViews: .orange
        case .swimmingHoles: .blue
        case .hiddenWalks: .green
        case .localShops: .brown
        }
    }
}

enum GemTier: Int, CaseIterable, Comparable {
    case freebie = 0
    case explorer = 5
    case adventurer = 10
    case legendary = 20

    var displayName: String {
        switch self {
        case .freebie: "Freebie"
        case .explorer: "Explorer"
        case .adventurer: "Adventurer"
        case .legendary: "Legendary"
        }
    }

    var locationsRequired: Int { rawValue }

    var color: Color {
        switch self {
        case .freebie: Color.capeCod.duneGrass
        case .explorer: Color.capeCod.oceanBlue
        case .adventurer: Color.capeCod.sunsetOrange
        case .legendary: Color(hex: 0xB48AE0)
        }
    }

    var icon: String {
        switch self {
        case .freebie: "gift.fill"
        case .explorer: "binoculars.fill"
        case .adventurer: "map.fill"
        case .legendary: "crown.fill"
        }
    }

    static func < (lhs: GemTier, rhs: GemTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Gem Database

private let allHiddenGems: [HiddenGem] = [

    // MARK: Secret Beaches (4)

    HiddenGem(
        id: "beach-paines-creek",
        name: "Paines Creek Beach",
        emoji: "\u{1F3D6}",
        category: .secretBeaches,
        town: "Brewster",
        description: "Arrive at low tide and walk out half a mile on the flats. Most tourists don't know this beach exists because it's tucked behind a residential area. The sunset here is arguably better than Skaket, and you'll share it with maybe 10 other people.",
        localTip: "Go at low tide for the best tidal flat walk. Bring water shoes.",
        unlockTier: .freebie
    ),
    HiddenGem(
        id: "beach-great-island",
        name: "Great Island Trail Beach",
        emoji: "\u{1F3D6}",
        category: .secretBeaches,
        town: "Wellfleet",
        description: "Hike two miles through pitch pine forest and suddenly the bay opens up. This beach at the end of the Great Island Trail is deserted most days. It feels like discovering your own private island.",
        localTip: "Bring plenty of water and snacks. There's no shade on the beach itself.",
        unlockTier: .explorer
    ),
    HiddenGem(
        id: "beach-cold-storage",
        name: "Cold Storage Beach",
        emoji: "\u{1F3D6}",
        category: .secretBeaches,
        town: "Dennis",
        description: "A tiny Bayside gem that the Dennis locals guard jealously. The water is calm, the sand is soft, and the parking lot is so small that it naturally limits crowds. Walk left at the shore for total solitude.",
        localTip: "Park on the side street if the lot is full. Get there before 10 AM in summer.",
        unlockTier: .freebie
    ),
    HiddenGem(
        id: "beach-bound-brook",
        name: "Bound Brook Island Beach",
        emoji: "\u{1F3D6}",
        category: .secretBeaches,
        town: "Wellfleet",
        description: "Even most Wellfleet regulars miss this one. Down a bumpy dirt road, past the oyster grants, there's a crescent of sand where the harbor meets the marsh. Bring binoculars\u{2014}the birding is spectacular.",
        localTip: "The road is rough. Go slow and park where the pavement ends.",
        unlockTier: .adventurer
    ),

    // MARK: Local Eats (4)

    HiddenGem(
        id: "eats-capt-cass",
        name: "Cap't Cass Rock Harbor Seafood",
        emoji: "\u{1F37D}",
        category: .localEats,
        town: "Orleans",
        description: "A shack so small you might drive past it. The fish tacos are legendary among locals. The lobster roll is no-frills perfection\u{2014}just lobster, butter, and a toasted bun. Don't bother with GPS, just look for the boats.",
        localTip: "Cash only. The fried clams sell out by 2 PM on busy days.",
        unlockTier: .freebie
    ),
    HiddenGem(
        id: "eats-hole-in-one",
        name: "Hole In One Donut Shop",
        emoji: "\u{1F37D}",
        category: .localEats,
        town: "Orleans",
        description: "Locals have been lining up here since dawn for decades. The apple fritters are the size of your head and the coffee is strong. This is where the fishermen eat breakfast, which tells you everything.",
        localTip: "Arrive before 7 AM or the best donuts are gone. The bismarks go first.",
        unlockTier: .freebie
    ),
    HiddenGem(
        id: "eats-pjs",
        name: "PJ's Family Restaurant",
        emoji: "\u{1F37D}",
        category: .localEats,
        town: "Wellfleet",
        description: "A no-frills breakfast joint where the portions are enormous and the regulars all know each other by name. The blueberry pancakes use wild Cape blueberries. Don't let the plain exterior fool you.",
        localTip: "Order the special, whatever it is. The waitresses know what's good.",
        unlockTier: .explorer
    ),
    HiddenGem(
        id: "eats-arnolds",
        name: "Arnold's Lobster & Clam Bar",
        emoji: "\u{1F37D}",
        category: .localEats,
        town: "Eastham",
        description: "Tourists think it's just another clam shack, but the raw bar in the back is one of the best on the Cape. The onion rings are hand-battered. Get the lazy lobster if you hate working for your food.",
        localTip: "Skip the front line and head straight to the raw bar. Half-price oysters before 4 PM on Wednesdays.",
        unlockTier: .adventurer
    ),

    // MARK: Best Views (4)

    HiddenGem(
        id: "view-rock-harbor",
        name: "Rock Harbor at Sunset",
        emoji: "\u{1F305}",
        category: .bestViews,
        town: "Orleans",
        description: "The fishing boats come in, the sky turns pink and gold, and you realize this is why people fall in love with the Cape. Skaket gets all the press but locals know Rock Harbor sunsets are the real deal.",
        localTip: "Arrive 30 minutes before sunset. Walk out on the jetty for the best angle.",
        unlockTier: .freebie
    ),
    HiddenGem(
        id: "view-scargo-tower",
        name: "Scargo Tower",
        emoji: "\u{1F305}",
        category: .bestViews,
        town: "Dennis",
        description: "Climb the stone tower on Scargo Hill and you can see all the way to Provincetown on a clear day. The 360-degree panorama covers the bay, the ocean, and cranberry bogs. It's the Cape's best-kept overlook.",
        localTip: "Go at golden hour. Bring a blanket and sit on the hillside after you climb down.",
        unlockTier: .freebie
    ),
    HiddenGem(
        id: "view-fort-hill",
        name: "Fort Hill Overlook",
        emoji: "\u{1F305}",
        category: .bestViews,
        town: "Eastham",
        description: "The view from Fort Hill sweeps across Nauset Marsh all the way to the ocean. In fall, the marsh grass turns gold and the light is otherworldly. Edward Penniman's whalebone gate makes it feel like stepping into a painting.",
        localTip: "Walk the Red Maple Swamp trail behind the parking lot. Almost nobody does.",
        unlockTier: .explorer
    ),
    HiddenGem(
        id: "view-pilgrim-monument",
        name: "Top of Pilgrim Monument",
        emoji: "\u{1F305}",
        category: .bestViews,
        town: "Provincetown",
        description: "252 feet up, 116 steps and 60 ramps. The view from the top of the tallest all-granite structure in the US stretches from Race Point to Plymouth on a clear day. You'll see whales breaching if you bring binoculars.",
        localTip: "Go early morning. The tower gets hot in afternoon sun and the lines get long.",
        unlockTier: .legendary
    ),

    // MARK: Swimming Holes (4)

    HiddenGem(
        id: "swim-cliff-pond",
        name: "Cliff Pond",
        emoji: "\u{1F3CA}",
        category: .swimmingHoles,
        town: "Brewster",
        description: "Crystal clear freshwater in the middle of Nickerson State Park. Bring a kayak and explore the coves. The far shore has a rope swing the rangers pretend they don't know about. The water is clean enough to drink.",
        localTip: "Paddle to the far side for the rope swing. The main beach gets crowded but the kayak put-in doesn't.",
        unlockTier: .freebie
    ),
    HiddenGem(
        id: "swim-gull-pond",
        name: "Gull Pond",
        emoji: "\u{1F3CA}",
        category: .swimmingHoles,
        town: "Wellfleet",
        description: "One of the deepest kettle ponds on the Cape\u{2014}over 60 feet in places. The water is startlingly clear and stays cool even in August. Wellfleet kids have been swimming here for generations.",
        localTip: "The resident-only beach fills up, but there's a sneaky put-in spot at the boat launch.",
        unlockTier: .explorer
    ),
    HiddenGem(
        id: "swim-seymour-pond",
        name: "Seymour Pond",
        emoji: "\u{1F3CA}",
        category: .swimmingHoles,
        town: "Brewster",
        description: "A hidden kettle pond surrounded by nothing but trees. No lifeguards, no facilities, no crowds. Just you, the turtles, and water so clear you can see the sandy bottom 15 feet down.",
        localTip: "Bring a towel to sit on\u{2014}there's no sand beach, just a pine needle shore.",
        unlockTier: .adventurer
    ),
    HiddenGem(
        id: "swim-higgins-pond",
        name: "Higgins Pond",
        emoji: "\u{1F3CA}",
        category: .swimmingHoles,
        town: "Brewster",
        description: "Connected to Cliff Pond by a narrow channel you can kayak through. Most people don't realize it's there. The pond is smaller, quieter, and feels completely wild even though it's inside a state park.",
        localTip: "Kayak through the channel from Cliff Pond. You'll feel like an explorer.",
        unlockTier: .legendary
    ),

    // MARK: Hidden Walks (3)

    HiddenGem(
        id: "walk-beech-forest",
        name: "Beech Forest Trail",
        emoji: "\u{1F6B6}",
        category: .hiddenWalks,
        town: "Provincetown",
        description: "A magical loop through ancient beech trees draped in lichen. The canopy is so thick it feels like twilight at noon. In spring, lady slippers bloom along the boardwalk sections. It's a world away from Commercial Street.",
        localTip: "Go early morning for the best bird sighting. Warblers everywhere in May.",
        unlockTier: .freebie
    ),
    HiddenGem(
        id: "walk-crows-pasture",
        name: "Crow's Pasture",
        emoji: "\u{1F6B6}",
        category: .hiddenWalks,
        town: "Dennis",
        description: "An old farmstead turned conservation land where the trails wind through meadows down to a tidal flat. At low tide you can walk out to the sandbars. The osprey nest near the trailhead has been active for 20 years.",
        localTip: "Combine with a low-tide walk on the flats. Bring binoculars for the ospreys.",
        unlockTier: .explorer
    ),
    HiddenGem(
        id: "walk-atlantic-white-cedar",
        name: "Atlantic White Cedar Swamp Trail",
        emoji: "\u{1F6B6}",
        category: .hiddenWalks,
        town: "Wellfleet",
        description: "A boardwalk through a primeval swamp that feels like it belongs in another century. The cedar trees are ancient, the air smells incredible, and the silence is total. Thoreau walked through here and wrote about it.",
        localTip: "The boardwalk can be slippery. Wear shoes with grip, not flip-flops.",
        unlockTier: .legendary
    ),

    // MARK: Local Shops (3)

    HiddenGem(
        id: "shop-brewster-store",
        name: "The Brewster Store",
        emoji: "\u{1F6CD}",
        category: .localShops,
        town: "Brewster",
        description: "Operating since 1866, this general store has creaky floors, penny candy, and a front porch where locals have been swapping stories for over 150 years. The homemade fudge is dangerously good.",
        localTip: "Grab penny candy and sit on the front porch. Check the community board for local events.",
        unlockTier: .freebie
    ),
    HiddenGem(
        id: "shop-yankee-ingenuity",
        name: "Yankee Ingenuity",
        emoji: "\u{1F6CD}",
        category: .localShops,
        town: "Chatham",
        description: "A gallery of American craft that feels like a museum you can buy things from. Hand-blown glass, studio pottery, and jewelry by artists who actually live on the Cape. Nothing here is mass-produced.",
        localTip: "Ask about the artists\u{2014}the staff knows every maker personally.",
        unlockTier: .explorer
    ),
    HiddenGem(
        id: "shop-wellfleet-flea",
        name: "Wellfleet Flea Market",
        emoji: "\u{1F6CD}",
        category: .localShops,
        town: "Wellfleet",
        description: "Weekends and Wednesdays at the drive-in theater, this flea market is a Cape Cod institution. Vintage finds, local art, antique tools, and the best people-watching on Route 6. Bring cash and your haggling skills.",
        localTip: "Wednesday mornings are less crowded. The good stuff goes fast\u{2014}arrive at opening.",
        unlockTier: .legendary
    ),
]

// MARK: - HiddenGemsView

struct HiddenGemsView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var selectedCategory: GemCategory?
    @State private var expandedGemID: String?
    @State private var locationsVisited: Int = 0
    @State private var headerAppeared = false

    // MARK: - Computed

    private var totalGems: Int { allHiddenGems.count }

    private var unlockedCount: Int {
        allHiddenGems.filter { isUnlocked($0) }.count
    }

    private var filteredGems: [HiddenGem] {
        guard let selectedCategory else { return allHiddenGems }
        return allHiddenGems.filter { $0.category == selectedCategory }
    }

    private func isUnlocked(_ gem: HiddenGem) -> Bool {
        locationsVisited >= gem.unlockTier.locationsRequired
    }

    private func locationsNeeded(_ gem: HiddenGem) -> Int {
        max(0, gem.unlockTier.locationsRequired - locationsVisited)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    gemHeader
                        .staggered(index: 0)

                    progressHeader
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
            .navigationTitle("Hidden Gems")
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
                loadProgress()
                withAnimation(CodAnimation.gentle) {
                    headerAppeared = true
                }
            }
        }
    }

    // MARK: - Header

    private var gemHeader: some View {
        VStack(spacing: CodSpacing.sm) {
            Text("\u{1F48E}")
                .font(.system(size: 48))
                .codAccessibleHidden()

            Text("Hidden Gems")
                .codTextStyle(.heroTitle)
                .multilineTextAlignment(.center)
                .codAccessibleHeader("Hidden Gems")

            Text("Local secrets most visitors never find")
                .codTextStyle(.subtitle)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, CodSpacing.lg)
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: CodSpacing.md) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.capeCod.sunsetOrange)
                    .codAccessibleHidden()

                Text("Gems Found")
                    .codTextStyle(.cardTitle)

                Spacer()

                Text("\(unlockedCount) of \(totalGems) unlocked")
                    .codTextStyle(.caption)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.capeCod.surface)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.capeCod.oceanGradient)
                        .frame(
                            width: geometry.size.width * CGFloat(unlockedCount) / CGFloat(totalGems),
                            height: 8
                        )
                        .animation(CodAnimation.spring, value: unlockedCount)
                }
            }
            .frame(height: 8)

            // Tier milestones
            HStack(spacing: CodSpacing.xs) {
                ForEach(GemTier.allCases, id: \.self) { tier in
                    let achieved = locationsVisited >= tier.locationsRequired
                    HStack(spacing: CodSpacing.xs) {
                        Image(systemName: tier.icon)
                            .font(.system(size: 10))
                        Text(tier.displayName)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(achieved ? tier.color : Color.capeCod.driftwood.opacity(0.5))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        achieved
                            ? tier.color.opacity(0.12)
                            : Color.capeCod.surface
                    )
                    .clipShape(Capsule())

                    if tier != GemTier.allCases.last {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .codAccessibleGroup(label: "\(unlockedCount) of \(totalGems) hidden gems unlocked. \(locationsVisited) locations visited.")
    }

    // MARK: - Category Filters

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                ForEach(GemCategory.allCases, id: \.self) { category in
                    CodChip(
                        "\(category.emoji) \(category.displayName)",
                        style: .category(category.chipColor),
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
                Text(selectedCategory?.displayName ?? "All Gems")
                    .codTextStyle(.sectionTitle)
                    .codAccessibleHeader(selectedCategory?.displayName ?? "All Gems")

                Spacer()

                Text("\(filteredGems.count) gems")
                    .codTextStyle(.caption)
            }

            LazyVStack(spacing: CodSpacing.md) {
                ForEach(Array(filteredGems.enumerated()), id: \.element.id) { index, gem in
                    if isUnlocked(gem) {
                        unlockedGemCard(gem: gem)
                            .staggered(index: index)
                    } else {
                        lockedGemCard(gem: gem)
                            .staggered(index: index)
                    }
                }
            }
        }
    }

    // MARK: - Unlocked Gem Card

    private func unlockedGemCard(gem: HiddenGem) -> some View {
        let isExpanded = expandedGemID == gem.id

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                CodHaptic.light()
                withAnimation(CodAnimation.spring) {
                    expandedGemID = isExpanded ? nil : gem.id
                }
            } label: {
                VStack(alignment: .leading, spacing: CodSpacing.sm) {
                    HStack(alignment: .top, spacing: CodSpacing.sm) {
                        Text(gem.emoji)
                            .font(.system(size: 28))
                            .frame(width: 40, height: 40)
                            .codAccessibleHidden()

                        VStack(alignment: .leading, spacing: CodSpacing.xs) {
                            HStack {
                                Text(gem.name)
                                    .codTextStyle(.cardTitle)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.capeCod.driftwood)
                                    .codAccessibleHidden()
                            }

                            HStack(spacing: CodSpacing.sm) {
                                Label(gem.town, systemImage: "mappin")
                                    .codTextStyle(.caption)

                                CodChip(
                                    gem.category.displayName,
                                    style: .category(gem.category.chipColor)
                                )

                                Spacer()

                                tierBadge(gem.unlockTier)
                            }
                        }
                    }

                    if !isExpanded {
                        Text(gem.description)
                            .codTextStyle(.body)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(CodSpacing.cardPadding)
            }
            .buttonStyle(CodButtonPressStyle(variant: .ghost))
            .codAccessibleCard(
                label: "\(gem.name), \(gem.town), \(gem.category.displayName)",
                hint: isExpanded ? "Tap to collapse" : "Tap to expand details"
            )

            if isExpanded {
                VStack(alignment: .leading, spacing: CodSpacing.md) {
                    Divider()
                        .padding(.horizontal, CodSpacing.cardPadding)

                    VStack(alignment: .leading, spacing: CodSpacing.sm) {
                        Text(gem.description)
                            .codTextStyle(.storyBody)

                        // Local tip callout
                        HStack(alignment: .top, spacing: CodSpacing.sm) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.capeCod.sunsetOrange)
                                .codAccessibleHidden()

                            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                                Text("Local Tip")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.capeCod.sunsetOrange)

                                Text(gem.localTip)
                                    .font(.system(size: 14, weight: .regular, design: .serif))
                                    .italic()
                                    .foregroundStyle(Color.capeCod.sunsetOrange)
                            }
                        }
                        .padding(CodSpacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.capeCod.sunsetOrange.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))

                        // Share button
                        CodButton("Share This Gem", variant: .ghost, icon: "square.and.arrow.up") {
                            shareGem(gem)
                        }
                        .codAccessibleButton("Share \(gem.name)", hint: "Opens the share sheet")
                    }
                    .padding(.horizontal, CodSpacing.cardPadding)
                    .padding(.bottom, CodSpacing.cardPadding)
                }
                .transition(.codSlideUp)
            }
        }
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .pulsingGlow(color: gem.unlockTier.color, isActive: gem.unlockTier == .legendary)
    }

    // MARK: - Locked Gem Card

    private func lockedGemCard(gem: HiddenGem) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(alignment: .top, spacing: CodSpacing.sm) {
                ZStack {
                    Text(gem.emoji)
                        .font(.system(size: 28))
                        .blur(radius: 4)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(gem.unlockTier.color)
                }
                .frame(width: 40, height: 40)
                .codAccessibleHidden()

                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    HStack {
                        Text(gem.name)
                            .codTextStyle(.cardTitle)
                            .lineLimit(1)
                            .blur(radius: 5)
                            .codAccessibleHidden()

                        Spacer()

                        tierBadge(gem.unlockTier)
                    }

                    HStack(spacing: CodSpacing.sm) {
                        Label(gem.town, systemImage: "mappin")
                            .codTextStyle(.caption)
                            .blur(radius: 4)
                            .codAccessibleHidden()

                        CodChip(
                            gem.category.displayName,
                            style: .category(gem.category.chipColor)
                        )
                    }
                }
            }

            // Blurred preview
            Text(gem.description)
                .codTextStyle(.body)
                .lineLimit(2)
                .blur(radius: 6)
                .codAccessibleHidden()

            // Unlock requirement
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: gem.unlockTier.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(gem.unlockTier.color)

                Text("Visit \(locationsNeeded(gem)) more place\(locationsNeeded(gem) == 1 ? "" : "s") to unlock")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(gem.unlockTier.color)
            }
            .padding(.horizontal, CodSpacing.sm)
            .padding(.vertical, CodSpacing.xs + 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(gem.unlockTier.color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .opacity(0.75)
        .codAccessibleCard(
            label: "Locked gem in \(gem.category.displayName) category. Visit \(locationsNeeded(gem)) more places to unlock.",
            hint: "Explore more locations to unlock this hidden gem"
        )
    }

    // MARK: - Tier Badge

    private func tierBadge(_ tier: GemTier) -> some View {
        HStack(spacing: 3) {
            Image(systemName: tier.icon)
                .font(.system(size: 9))
            Text(tier.displayName)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(tier.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(tier.color.opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: - Persistence

    private static let locationsVisitedKey = "hiddenGems.locationsVisited"

    private func loadProgress() {
        locationsVisited = UserDefaults.standard.integer(forKey: Self.locationsVisitedKey)
    }

    // MARK: - Share

    private func shareGem(_ gem: HiddenGem) {
        CodHaptic.tap()
        let text = "I found a hidden gem on Cape Cod! \u{1F48E} \(gem.name) in \(gem.town) via @HeyCapeCode"

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

#Preview("Hidden Gems - Default") {
    HiddenGemsView()
}

#Preview("Hidden Gems - Sheet") {
    Text("Home")
        .sheet(isPresented: .constant(true)) {
            HiddenGemsView()
        }
}
