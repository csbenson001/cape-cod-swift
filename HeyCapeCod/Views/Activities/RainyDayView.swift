import SwiftUI

// MARK: - Models

struct RainyDayActivity: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let town: String
    let category: RainyDayCategory
    let ageRange: AgeRange
    let estimatedDuration: String
    let cost: CostLevel
    let tip: String
}

enum RainyDayCategory: String, CaseIterable {
    case museum, shopping, food, entertainment, creative, nature

    var displayName: String {
        switch self {
        case .museum: "Museums"
        case .shopping: "Shopping"
        case .food: "Food"
        case .entertainment: "Entertainment"
        case .creative: "Creative"
        case .nature: "Nature"
        }
    }

    var icon: String {
        switch self {
        case .museum: "building.columns.fill"
        case .shopping: "bag.fill"
        case .food: "fork.knife"
        case .entertainment: "gamecontroller.fill"
        case .creative: "paintpalette.fill"
        case .nature: "leaf.fill"
        }
    }

    var chipColor: CodChipColor {
        switch self {
        case .museum: .blue
        case .shopping: .brown
        case .food: .orange
        case .entertainment: .blue
        case .creative: .green
        case .nature: .green
        }
    }
}

enum AgeRange: String, CaseIterable {
    case allAges = "All Ages"
    case kidsUnder10 = "Kids"
    case teens = "Teens+"
    case adultsOnly = "Adults"

    var icon: String {
        switch self {
        case .allAges: "person.3.fill"
        case .kidsUnder10: "figure.and.child.holdinghands"
        case .teens: "person.fill"
        case .adultsOnly: "person.crop.circle.fill"
        }
    }
}

enum CostLevel: String, CaseIterable {
    case free = "Free"
    case budget = "Budget"
    case moderate = "Moderate"
    case splurge = "Splurge"

    var indicator: String {
        switch self {
        case .free: "Free"
        case .budget: "$"
        case .moderate: "$$"
        case .splurge: "$$$"
        }
    }

    var color: Color {
        switch self {
        case .free: Color.capeCod.duneGrass
        case .budget: Color.capeCod.oceanBlue
        case .moderate: Color.capeCod.sunsetOrange
        case .splurge: Color.capeCod.cranberry
        }
    }
}

// MARK: - Activity Database

private let rainyDayActivities: [RainyDayActivity] = [
    // Museums
    RainyDayActivity(
        id: "museum-natural-history",
        name: "Cape Cod Museum of Natural History",
        icon: "fossil.shell.fill",
        description: "Explore Cape Cod's natural wonders through interactive exhibits, live animal displays, and nature trails. Perfect for curious minds of all ages.",
        town: "Brewster",
        category: .museum,
        ageRange: .allAges,
        estimatedDuration: "2-3 hours",
        cost: .moderate,
        tip: "Don't miss the working beehive!"
    ),
    RainyDayActivity(
        id: "museum-whydah-pirate",
        name: "Whydah Pirate Museum",
        icon: "flag.fill",
        description: "See authentic artifacts from the only verified pirate shipwreck ever discovered. Captain Black Sam Bellamy's treasure awaits.",
        town: "West Yarmouth",
        category: .museum,
        ageRange: .allAges,
        estimatedDuration: "1-2 hours",
        cost: .moderate,
        tip: "Real pirate treasure on display"
    ),
    RainyDayActivity(
        id: "museum-heritage",
        name: "Heritage Museums & Gardens",
        icon: "tree.fill",
        description: "A sprawling museum complex with antique automobiles, American folk art, and beautiful indoor gardens. The carousel is a must.",
        town: "Sandwich",
        category: .museum,
        ageRange: .allAges,
        estimatedDuration: "2-3 hours",
        cost: .moderate,
        tip: "Indoor carousel is a hit with kids"
    ),
    RainyDayActivity(
        id: "museum-maritime",
        name: "Cape Cod Maritime Museum",
        icon: "sailboat.fill",
        description: "Discover the Cape's seafaring heritage through boat models, maritime artifacts, and hands-on exhibits about the region's fishing history.",
        town: "Hyannis",
        category: .museum,
        ageRange: .allAges,
        estimatedDuration: "1-2 hours",
        cost: .budget,
        tip: "Build a model boat workshop on weekends"
    ),
    RainyDayActivity(
        id: "museum-jfk",
        name: "JFK Hyannis Museum",
        icon: "star.fill",
        description: "Explore President Kennedy's deep connection to Cape Cod through photographs, oral histories, and multimedia exhibits.",
        town: "Hyannis",
        category: .museum,
        ageRange: .teens,
        estimatedDuration: "1 hour",
        cost: .budget,
        tip: "JFK's relationship with the Cape is fascinating"
    ),
    RainyDayActivity(
        id: "museum-pilgrim-monument",
        name: "Pilgrim Monument Museum",
        icon: "building.2.fill",
        description: "Learn about the Pilgrims' first landing in Provincetown and the history of the Outer Cape. Climb the monument if the rain stops!",
        town: "Provincetown",
        category: .museum,
        ageRange: .allAges,
        estimatedDuration: "1-2 hours",
        cost: .moderate,
        tip: "Climb the monument if the rain stops"
    ),

    // Shopping
    RainyDayActivity(
        id: "shopping-christmas-tree",
        name: "Christmas Tree Shops",
        icon: "gift.fill",
        description: "A Cape Cod institution for bargain hunting. Browse eclectic home goods, seasonal decor, and unexpected finds at great prices.",
        town: "Various",
        category: .shopping,
        ageRange: .allAges,
        estimatedDuration: "1-2 hours",
        cost: .budget,
        tip: "The original one in Yarmouth is an experience"
    ),
    RainyDayActivity(
        id: "shopping-chatham-main-st",
        name: "Main Street Chatham",
        icon: "storefront.fill",
        description: "Stroll charming boutiques, galleries, and candy shops along one of Cape Cod's most picturesque main streets.",
        town: "Chatham",
        category: .shopping,
        ageRange: .allAges,
        estimatedDuration: "2-3 hours",
        cost: .free,
        tip: "Watch the fishing fleet come in at Fish Pier"
    ),
    RainyDayActivity(
        id: "shopping-commercial-st",
        name: "Commercial Street",
        icon: "sparkles",
        description: "Browse the most eclectic shops on the Cape, from art galleries to vintage clothing to handmade jewelry in Provincetown's vibrant center.",
        town: "Provincetown",
        category: .shopping,
        ageRange: .teens,
        estimatedDuration: "2-3 hours",
        cost: .free,
        tip: "Most unique shops on the Cape"
    ),
    RainyDayActivity(
        id: "shopping-mashpee-commons",
        name: "Mashpee Commons",
        icon: "building.fill",
        description: "An open-air shopping village with covered walkways, featuring national brands and local boutiques plus restaurants.",
        town: "Mashpee",
        category: .shopping,
        ageRange: .allAges,
        estimatedDuration: "2-3 hours",
        cost: .moderate,
        tip: "Outdoor mall but covered walkways"
    ),

    // Food Experiences
    RainyDayActivity(
        id: "food-chip-factory",
        name: "Cape Cod Potato Chip Factory Tour",
        icon: "carrot.fill",
        description: "Take a self-guided tour of the factory where Cape Cod's famous chips are made. Watch the production line in action.",
        town: "Hyannis",
        category: .food,
        ageRange: .allAges,
        estimatedDuration: "30 min",
        cost: .free,
        tip: "Free samples at the end!"
    ),
    RainyDayActivity(
        id: "food-cooking-class",
        name: "Chatham Bars Inn Cooking Class",
        icon: "frying.pan.fill",
        description: "Learn to prepare New England coastal cuisine from expert chefs at one of Cape Cod's premier resorts.",
        town: "Chatham",
        category: .food,
        ageRange: .adultsOnly,
        estimatedDuration: "2 hours",
        cost: .splurge,
        tip: "Book in advance, worth every penny"
    ),
    RainyDayActivity(
        id: "food-ice-cream-crawl",
        name: "Ice Cream Crawl",
        icon: "cup.and.saucer.fill",
        description: "Tour the Cape's legendary ice cream shops. Compare flavors and find your favorite scoop across multiple towns.",
        town: "Various",
        category: .food,
        ageRange: .allAges,
        estimatedDuration: "2-3 hours",
        cost: .budget,
        tip: "Try Four Seas, Sundae School, and Emack & Bolio's"
    ),

    // Entertainment
    RainyDayActivity(
        id: "entertainment-mall-movies",
        name: "Cape Cod Mall & Movies",
        icon: "film.fill",
        description: "The Cape's only indoor mall with a cinema, retail stores, and food court. A rainy day standby for families.",
        town: "Hyannis",
        category: .entertainment,
        ageRange: .allAges,
        estimatedDuration: "2-3 hours",
        cost: .moderate,
        tip: "Only indoor mall on the Cape"
    ),
    RainyDayActivity(
        id: "entertainment-ryan-family",
        name: "Ryan Family Amusements",
        icon: "arcade.stick.console.fill",
        description: "Classic family fun center with bowling, arcade games, and amusements. Multiple locations across the Cape.",
        town: "Various",
        category: .entertainment,
        ageRange: .kidsUnder10,
        estimatedDuration: "1-2 hours",
        cost: .budget,
        tip: "Multiple locations, bowling & arcade"
    ),
    RainyDayActivity(
        id: "entertainment-cape-cinema",
        name: "Cape Cinema",
        icon: "theatermasks.fill",
        description: "A historic art-house cinema in Dennis with a stunning ceiling mural by artist Rockwell Kent. Independent and classic films.",
        town: "Dennis",
        category: .entertainment,
        ageRange: .allAges,
        estimatedDuration: "2 hours",
        cost: .budget,
        tip: "Beautiful art deco ceiling mural"
    ),

    // Creative
    RainyDayActivity(
        id: "creative-museum-of-art",
        name: "Cape Cod Museum of Art",
        icon: "photo.artframe",
        description: "Explore rotating exhibitions of Cape Cod and regional art. Check for plein air painting classes and workshops.",
        town: "Dennis",
        category: .creative,
        ageRange: .teens,
        estimatedDuration: "1-2 hours",
        cost: .budget,
        tip: "Plein air painting classes some days"
    ),
    RainyDayActivity(
        id: "creative-glass-museum",
        name: "Sandwich Glass Museum",
        icon: "hurricane",
        description: "Watch master glassblowers create stunning works of art and explore the history of the Sandwich Glass Company.",
        town: "Sandwich",
        category: .creative,
        ageRange: .allAges,
        estimatedDuration: "1-2 hours",
        cost: .budget,
        tip: "Live glassblowing demonstrations hourly"
    ),
    RainyDayActivity(
        id: "creative-paint-pottery",
        name: "Paint Pottery Studio",
        icon: "paintbrush.fill",
        description: "Choose a piece of pottery and paint your own Cape Cod souvenir. Great for all ages and no artistic skill needed.",
        town: "Various",
        category: .creative,
        ageRange: .allAges,
        estimatedDuration: "1-2 hours",
        cost: .moderate,
        tip: "Great rainy day activity for families"
    ),

    // Additional Creative
    RainyDayActivity(
        id: "creative-cape-cod-pottery",
        name: "Cape Cod Tileworks",
        icon: "square.grid.3x3.fill",
        description: "Watch artisans hand-paint Portuguese-inspired ceramic tiles. Create your own tile to take home as a unique souvenir.",
        town: "Chatham",
        category: .creative,
        ageRange: .allAges,
        estimatedDuration: "1-2 hours",
        cost: .moderate,
        tip: "Custom house number tiles make great gifts"
    ),

    // Additional Entertainment
    RainyDayActivity(
        id: "entertainment-cape-cod-playhouse",
        name: "Cape Playhouse",
        icon: "theatermask.and.paintbrush.fill",
        description: "America's oldest professional summer theater offers matinee performances and behind-the-scenes tours.",
        town: "Dennis",
        category: .entertainment,
        ageRange: .allAges,
        estimatedDuration: "2-3 hours",
        cost: .moderate,
        tip: "Children's theater shows on Friday mornings"
    ),
    RainyDayActivity(
        id: "entertainment-escape-room",
        name: "Cape Cod Escape Rooms",
        icon: "key.fill",
        description: "Test your problem-solving skills in themed escape rooms. Great team activity for families and groups.",
        town: "Hyannis",
        category: .entertainment,
        ageRange: .teens,
        estimatedDuration: "1-2 hours",
        cost: .moderate,
        tip: "Book ahead in summer, they fill up fast on rainy days"
    ),

    // Additional Food
    RainyDayActivity(
        id: "food-brewery-tour",
        name: "Cape Cod Beer Brewery Tour",
        icon: "mug.fill",
        description: "Tour a craft brewery and sample local brews. Learn about the brewing process and Cape Cod's craft beer scene.",
        town: "Hyannis",
        category: .food,
        ageRange: .adultsOnly,
        estimatedDuration: "1-2 hours",
        cost: .budget,
        tip: "Saturday tours include a souvenir pint glass"
    ),
    RainyDayActivity(
        id: "food-candy-manor",
        name: "The Candy Manor",
        icon: "birthday.cake.fill",
        description: "Watch handmade chocolates and candies being crafted in this charming Chatham shop. Tastings available.",
        town: "Chatham",
        category: .food,
        ageRange: .allAges,
        estimatedDuration: "30 min",
        cost: .budget,
        tip: "Their cranberry bark is a Cape Cod classic"
    ),

    // Nature (Indoor/Covered)
    RainyDayActivity(
        id: "nature-wellfleet-sanctuary",
        name: "Wellfleet Bay Wildlife Sanctuary",
        icon: "bird.fill",
        description: "Audubon's nature center features interactive exhibits about Cape Cod's ecosystems, wildlife, and conservation efforts.",
        town: "Wellfleet",
        category: .nature,
        ageRange: .allAges,
        estimatedDuration: "1-2 hours",
        cost: .budget,
        tip: "Nature center has great exhibits even in rain"
    ),
    RainyDayActivity(
        id: "nature-seashore-visitors",
        name: "Cape Cod National Seashore Visitor Centers",
        icon: "binoculars.fill",
        description: "Free exhibits about the Cape's geology, ecology, and maritime history. Ranger-led programs throughout the day.",
        town: "Eastham / Provincetown",
        category: .nature,
        ageRange: .allAges,
        estimatedDuration: "1 hour",
        cost: .free,
        tip: "Free ranger talks and exhibits"
    ),
]

// MARK: - Filter Type

private enum FilterSection: String, CaseIterable {
    case category = "Category"
    case age = "Age"
    case cost = "Cost"
}

// MARK: - RainyDayView

struct RainyDayView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var selectedCategory: RainyDayCategory?
    @State private var selectedAge: AgeRange?
    @State private var selectedCost: CostLevel?
    @State private var expandedActivityID: String?
    @State private var randomPickActivity: RainyDayActivity?
    @State private var showRandomPick = false
    @State private var isSpinning = false
    @State private var visitedIDs: Set<String> = []
    @State private var activeFilterSection: FilterSection = .category
    @State private var rainDropOffsets: [CGFloat] = (0..<20).map { _ in CGFloat.random(in: 0...1) }
    @State private var headerAppeared = false

    private let userMode: ExperienceMode

    // MARK: - Init

    init(userMode: ExperienceMode = .family) {
        self.userMode = userMode
    }

    // MARK: - Computed

    private var filteredActivities: [RainyDayActivity] {
        var result = rainyDayActivities

        // Mode-aware default sorting
        switch userMode {
        case .kids:
            result = result.filter { $0.ageRange == .allAges || $0.ageRange == .kidsUnder10 }
        case .family:
            result.sort { a, _ in
                a.ageRange == .allAges || a.ageRange == .kidsUnder10
            }
        case .adult:
            result.sort { a, _ in
                a.ageRange == .adultsOnly || a.ageRange == .teens
            }
        case .teen:
            result.sort { a, _ in
                a.ageRange == .teens || a.ageRange == .allAges
            }
        }

        if let selectedCategory {
            result = result.filter { $0.category == selectedCategory }
        }
        if let selectedAge {
            result = result.filter { $0.ageRange == selectedAge }
        }
        if let selectedCost {
            result = result.filter { $0.cost == selectedCost }
        }

        return result
    }

    private var activeFilterCount: Int {
        [selectedCategory != nil, selectedAge != nil, selectedCost != nil].filter(\.self).count
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                rainHeader
                    .staggered(index: 0)

                filterSection
                    .staggered(index: 1)

                pickForMeButton
                    .staggered(index: 2)

                activityList
                    .staggered(index: 3)

                rainCheckSection
                    .staggered(index: 4)

                shareSection
                    .staggered(index: 5)
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background)
        .navigationTitle("Rainy Day")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                clearFiltersButton
            }
        }
        .onAppear {
            loadVisited()
            withAnimation(CodAnimation.gentle) {
                headerAppeared = true
            }
        }
        .overlay {
            if showRandomPick, let activity = randomPickActivity {
                randomPickOverlay(activity: activity)
            }
        }
    }

    @ViewBuilder
    private var clearFiltersButton: some View {
        if activeFilterCount > 0 {
            Button {
                CodHaptic.selection()
                withAnimation(CodAnimation.spring) {
                    selectedCategory = nil
                    selectedAge = nil
                    selectedCost = nil
                }
            } label: {
                Text("Clear")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }
        }
    }

    // MARK: - Rain Header

    private var rainHeader: some View {
        VStack(spacing: CodSpacing.md) {
            ZStack {
                // Rain animation background
                RainAnimationView()
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.featured, style: .continuous))
                    .opacity(headerAppeared ? 0.3 : 0)

                VStack(spacing: CodSpacing.sm) {
                    Image(systemName: "cloud.rain.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .symbolEffect(.pulse, options: .repeating)
                        .codAccessibleHidden()

                    Text("Rainy Day? No Problem!")
                        .codTextStyle(.heroTitle)
                        .multilineTextAlignment(.center)
                        .codAccessibleHeader("Rainy Day? No Problem!")

                    Text("Indoor adventures on Cape Cod")
                        .codTextStyle(.subtitle)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, CodSpacing.lg)
            }
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            // Filter section tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.sm) {
                    ForEach(FilterSection.allCases, id: \.self) { section in
                        CodChip(
                            section.rawValue,
                            style: .filter,
                            isSelected: activeFilterSection == section
                        ) {
                            withAnimation(CodAnimation.quick) {
                                activeFilterSection = section
                            }
                        }
                        .codAccessibleButton(
                            "Filter by \(section.rawValue)",
                            hint: activeFilterSection == section ? "Currently selected" : "Tap to select"
                        )
                    }
                }
            }

            // Active filter pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.sm) {
                    switch activeFilterSection {
                    case .category:
                        ForEach(RainyDayCategory.allCases, id: \.self) { category in
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

                    case .age:
                        ForEach(AgeRange.allCases, id: \.self) { age in
                            CodChip(
                                age.rawValue,
                                style: .filter,
                                icon: age.icon,
                                isSelected: selectedAge == age
                            ) {
                                withAnimation(CodAnimation.spring) {
                                    selectedAge = selectedAge == age ? nil : age
                                }
                            }
                            .codAccessibleButton(
                                age.rawValue,
                                hint: selectedAge == age ? "Remove filter" : "Filter by \(age.rawValue)"
                            )
                        }

                    case .cost:
                        ForEach(CostLevel.allCases, id: \.self) { cost in
                            CodChip(
                                "\(cost.rawValue) \(cost.indicator)",
                                style: .filter,
                                isSelected: selectedCost == cost
                            ) {
                                withAnimation(CodAnimation.spring) {
                                    selectedCost = selectedCost == cost ? nil : cost
                                }
                            }
                            .codAccessibleButton(
                                cost.rawValue,
                                hint: selectedCost == cost ? "Remove filter" : "Filter by \(cost.rawValue)"
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Pick For Me

    private var pickForMeButton: some View {
        CodButton("Pick for Me!", variant: .accent, icon: "dice.fill", isFullWidth: true) {
            pickRandom()
        }
        .codAccessibleButton("Pick a random activity", hint: "Selects a random rainy day activity for you")
    }

    private func pickRandom() {
        CodHaptic.tap()
        isSpinning = true

        withAnimation(CodAnimation.spring) {
            randomPickActivity = filteredActivities.randomElement()
            showRandomPick = true
            isSpinning = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            CodHaptic.success()
        }
    }

    // MARK: - Random Pick Overlay

    private func randomPickOverlay(activity: RainyDayActivity) -> some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(CodAnimation.spring) {
                        showRandomPick = false
                    }
                }

            VStack(spacing: CodSpacing.lg) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.capeCod.sunsetOrange)
                    .codAccessibleHidden()

                Text("How about...")
                    .codTextStyle(.sectionTitle)

                VStack(spacing: CodSpacing.md) {
                    Image(systemName: activity.icon)
                        .font(.system(size: 36))
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .codAccessibleHidden()

                    Text(activity.name)
                        .codTextStyle(.cardTitle)
                        .multilineTextAlignment(.center)

                    Text(activity.town)
                        .codTextStyle(.caption)

                    Text(activity.description)
                        .codTextStyle(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, CodSpacing.md)

                    HStack(spacing: CodSpacing.md) {
                        Label(activity.estimatedDuration, systemImage: "clock")
                            .codTextStyle(.caption)
                        Label(activity.cost.indicator, systemImage: "dollarsign.circle")
                            .codTextStyle(.caption)
                    }

                    Text("\"\(activity.tip)\"")
                        .font(.system(size: 14, weight: .regular, design: .serif))
                        .italic()
                        .foregroundStyle(Color.capeCod.sunsetOrange)
                        .multilineTextAlignment(.center)
                        .padding(.top, CodSpacing.xs)
                }

                HStack(spacing: CodSpacing.md) {
                    CodButton("Try Again", variant: .ghost, icon: "arrow.clockwise") {
                        pickRandom()
                    }

                    CodButton("Love It!", variant: .primary, icon: "heart.fill") {
                        CodHaptic.success()
                        markVisited(activity.id)
                        withAnimation(CodAnimation.spring) {
                            showRandomPick = false
                        }
                    }
                }
            }
            .padding(CodSpacing.xl)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.featured, style: .continuous))
            .adaptiveCardStyle(cornerRadius: CodRadius.featured, shadow: .elevated)
            .padding(.horizontal, CodSpacing.screenEdge)
            .transition(.codScale)
            .codAccessibleCard(label: "Random activity suggestion: \(activity.name) in \(activity.town)")
        }
    }

    // MARK: - Activity List

    private var activityList: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack {
                Text("Activities")
                    .codTextStyle(.sectionTitle)
                    .codAccessibleHeader("Activities")

                Spacer()

                Text("\(filteredActivities.count) found")
                    .codTextStyle(.caption)
            }

            if filteredActivities.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: CodSpacing.md) {
                    ForEach(Array(filteredActivities.enumerated()), id: \.element.id) { index, activity in
                        activityCard(activity: activity)
                            .staggered(index: index)
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: CodSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(Color.capeCod.driftwood)
                .codAccessibleHidden()

            Text("No activities match your filters")
                .codTextStyle(.cardTitle)

            Text("Try adjusting your filters to see more options")
                .codTextStyle(.body)
                .multilineTextAlignment(.center)

            CodButton("Clear Filters", variant: .ghost, icon: "xmark.circle") {
                withAnimation(CodAnimation.spring) {
                    selectedCategory = nil
                    selectedAge = nil
                    selectedCost = nil
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CodSpacing.xxl)
    }

    // MARK: - Activity Card

    private func activityCard(activity: RainyDayActivity) -> some View {
        let isExpanded = expandedActivityID == activity.id
        let isVisited = visitedIDs.contains(activity.id)

        return VStack(alignment: .leading, spacing: 0) {
            // Card header - always visible
            Button {
                CodHaptic.light()
                withAnimation(CodAnimation.spring) {
                    expandedActivityID = isExpanded ? nil : activity.id
                }
            } label: {
                VStack(alignment: .leading, spacing: CodSpacing.sm) {
                    // Top row: icon, name, visited badge
                    HStack(alignment: .top, spacing: CodSpacing.sm) {
                        Image(systemName: activity.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(Color.capeCod.oceanBlue)
                            .frame(width: 36, height: 36)
                            .codAccessibleHidden()

                        VStack(alignment: .leading, spacing: CodSpacing.xs) {
                            HStack {
                                Text(activity.name)
                                    .codTextStyle(.cardTitle)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                if isVisited {
                                    CodCardBadge(text: "Visited", color: Color.capeCod.duneGrass)
                                }
                            }

                            // Town and duration
                            HStack(spacing: CodSpacing.sm) {
                                Label(activity.town, systemImage: "mappin")
                                    .codTextStyle(.caption)

                                Text("~")
                                    .codTextStyle(.caption)

                                Label(activity.estimatedDuration, systemImage: "clock")
                                    .codTextStyle(.caption)
                            }
                        }
                    }

                    // Bottom row: badges
                    HStack(spacing: CodSpacing.sm) {
                        CodChip(
                            activity.category.displayName,
                            style: .category(activity.category.chipColor),
                            icon: activity.category.icon
                        )

                        CodChip(activity.ageRange.rawValue, style: .mode, icon: activity.ageRange.icon)

                        Spacer()

                        Text(activity.cost.indicator)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(activity.cost.color)
                    }
                }
                .padding(CodSpacing.cardPadding)
            }
            .buttonStyle(CodButtonPressStyle(variant: .ghost))
            .codAccessibleCard(
                label: "\(activity.name), \(activity.town), \(activity.estimatedDuration), \(activity.cost.rawValue)\(isVisited ? ", visited" : "")",
                hint: isExpanded ? "Tap to collapse" : "Tap to expand details"
            )

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: CodSpacing.md) {
                    Divider()
                        .padding(.horizontal, CodSpacing.cardPadding)

                    VStack(alignment: .leading, spacing: CodSpacing.sm) {
                        Text(activity.description)
                            .codTextStyle(.body)

                        // Insider tip
                        HStack(alignment: .top, spacing: CodSpacing.sm) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.capeCod.sunsetOrange)
                                .codAccessibleHidden()

                            Text("Insider tip: \(activity.tip)")
                                .font(.system(size: 14, weight: .regular, design: .serif))
                                .italic()
                                .foregroundStyle(Color.capeCod.sunsetOrange)
                        }
                        .padding(CodSpacing.sm)
                        .background(Color.capeCod.sunsetOrange.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))

                        // Action buttons
                        HStack(spacing: CodSpacing.sm) {
                            if !isVisited {
                                CodButton("Mark Visited", variant: .ghost, icon: "checkmark.circle") {
                                    CodHaptic.success()
                                    markVisited(activity.id)
                                }
                            } else {
                                CodButton("Unmark", variant: .ghost, icon: "xmark.circle") {
                                    CodHaptic.selection()
                                    unmarkVisited(activity.id)
                                }
                            }
                        }
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
    }

    // MARK: - Rain Check Section

    private var rainCheckSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Rain Check")
                .codTextStyle(.sectionTitle)
                .codAccessibleHeader("Rain Check")

            VStack(alignment: .leading, spacing: CodSpacing.md) {
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 28))
                        .symbolRenderingMode(.multicolor)
                        .codAccessibleHidden()

                    VStack(alignment: .leading, spacing: CodSpacing.xs) {
                        Text("Rain expected until 2 PM, then clearing")
                            .codTextStyle(.cardTitle)

                        Text("Check back later for beach conditions")
                            .codTextStyle(.caption)
                    }
                }

                CodButton("Set an alert for when it clears up", variant: .ghost, icon: "bell.fill") {
                    CodHaptic.selection()
                    // Conceptual - shows the interaction
                }
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
    }

    // MARK: - Share Section

    private var shareSection: some View {
        CodButton("Share Rainy Day Ideas", variant: .outline, icon: "square.and.arrow.up", isFullWidth: true) {
            CodHaptic.tap()
            shareActivities()
        }
        .codAccessibleButton("Share rainy day ideas", hint: "Opens the share sheet with activity suggestions")
    }

    // MARK: - Persistence

    private static let visitedKey = "rainyDayVisitedActivities"

    private func loadVisited() {
        let saved = UserDefaults.standard.stringArray(forKey: Self.visitedKey) ?? []
        visitedIDs = Set(saved)
    }

    private func markVisited(_ id: String) {
        withAnimation(CodAnimation.spring) {
            visitedIDs.insert(id)
        }
        UserDefaults.standard.set(Array(visitedIDs), forKey: Self.visitedKey)
    }

    private func unmarkVisited(_ id: String) {
        withAnimation(CodAnimation.spring) {
            visitedIDs.remove(id)
        }
        UserDefaults.standard.set(Array(visitedIDs), forKey: Self.visitedKey)
    }

    // MARK: - Share

    private func shareActivities() {
        let activities = filteredActivities.prefix(10)
        var text = "Rainy day on Cape Cod? Here are some ideas:\n\n"
        for activity in activities {
            text += "- \(activity.name) (\(activity.town)) - \(activity.cost.indicator)\n"
        }
        text += "\nShared from Hey Cape Cod"

        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else { return }

        // Find the topmost presented view controller
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        topVC.present(activityVC, animated: true)
    }
}

// MARK: - Rain Animation View

private struct RainAnimationView: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.capeCod.oceanBlue.opacity(0.05)

                ForEach(0..<20, id: \.self) { index in
                    RainDrop(
                        startX: CGFloat.random(in: 0...geometry.size.width),
                        height: geometry.size.height,
                        delay: Double.random(in: 0...2),
                        animate: animate
                    )
                }
            }
        }
        .onAppear {
            animate = true
        }
    }
}

private struct RainDrop: View {
    let startX: CGFloat
    let height: CGFloat
    let delay: Double
    let animate: Bool

    @State private var yOffset: CGFloat = -20

    var body: some View {
        Capsule()
            .fill(Color.capeCod.oceanBlue.opacity(0.3))
            .frame(width: 2, height: 12)
            .position(x: startX, y: yOffset)
            .onAppear {
                guard animate else { return }
                withAnimation(
                    .linear(duration: Double.random(in: 0.8...1.5))
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    yOffset = height + 20
                }
            }
    }
}

// MARK: - CodButtonVariant extension for outline

private extension CodButtonVariant {
    static var outline: CodButtonVariant { .secondary }
}

// MARK: - Preview

#Preview("Rainy Day - Family Mode") {
    NavigationStack {
        RainyDayView(userMode: .family)
    }
}

#Preview("Rainy Day - Kids Mode") {
    NavigationStack {
        RainyDayView(userMode: .kids)
    }
}

#Preview("Rainy Day - Adult Mode") {
    NavigationStack {
        RainyDayView(userMode: .adult)
    }
}
