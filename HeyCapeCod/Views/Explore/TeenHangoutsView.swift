import SwiftUI

// MARK: - Models

struct TeenSpot: Identifiable {
    let id: String
    let name: String
    let town: String
    let category: TeenCategory
    let vibeTag: String
    let whyItsCool: String
    let instagramRating: Int // 1–5
}

enum TeenCategory: String, CaseIterable {
    case aestheticVibes
    case musicAndRecords
    case beachHangouts
    case foodAndDrinks
    case shopping
    case activities

    var displayName: String {
        switch self {
        case .aestheticVibes: "Aesthetic Vibes"
        case .musicAndRecords: "Music & Records"
        case .beachHangouts: "Beach Hangouts"
        case .foodAndDrinks: "Food & Drinks"
        case .shopping: "Shopping"
        case .activities: "Activities"
        }
    }

    var icon: String {
        switch self {
        case .aestheticVibes: "sparkles"
        case .musicAndRecords: "music.note"
        case .beachHangouts: "beach.umbrella.fill"
        case .foodAndDrinks: "cup.and.saucer.fill"
        case .shopping: "bag.fill"
        case .activities: "figure.surfing"
        }
    }

    var chipColor: CodChipColor {
        switch self {
        case .aestheticVibes: .orange
        case .musicAndRecords: .brown
        case .beachHangouts: .blue
        case .foodAndDrinks: .orange
        case .shopping: .green
        case .activities: .blue
        }
    }
}

// MARK: - Teen Spot Database

private let allTeenSpots: [TeenSpot] = [

    // MARK: Aesthetic Vibes

    TeenSpot(
        id: "teen-lavender-farm",
        name: "Cape Cod Lavender Farm",
        town: "Harwich",
        category: .aestheticVibes,
        vibeTag: "Aesthetic",
        whyItsCool: "Rows and rows of purple lavender with ocean views in the background. Your feed will absolutely pop. They also sell lavender lemonade and handmade soaps which make sick gifts.",
        instagramRating: 5
    ),
    TeenSpot(
        id: "teen-nauset-light",
        name: "Nauset Lighthouse",
        town: "Eastham",
        category: .aestheticVibes,
        vibeTag: "Iconic",
        whyItsCool: "The red and white lighthouse on the cliff is basically a Cape Cod icon. Golden hour photos here are next level. Walk down the wooden stairs to the beach for a completely different vibe.",
        instagramRating: 5
    ),
    TeenSpot(
        id: "teen-ptown-murals",
        name: "Provincetown Street Art & Murals",
        town: "Provincetown",
        category: .aestheticVibes,
        vibeTag: "Artsy",
        whyItsCool: "Hidden murals and art installations pop up all over P-town. The alleyways between Commercial Street shops have some incredible pieces. It's like an outdoor gallery you can explore for free.",
        instagramRating: 4
    ),

    // MARK: Music & Records

    TeenSpot(
        id: "teen-earth-house",
        name: "Earth House",
        town: "Orleans",
        category: .musicAndRecords,
        vibeTag: "Aesthetic",
        whyItsCool: "This place is a whole vibe. Vinyl records, crystals, tapestries, incense, and the most chill atmosphere on the Cape. You could spend hours digging through the record bins. The back room is where the good stuff is.",
        instagramRating: 4
    ),
    TeenSpot(
        id: "teen-spinnaker",
        name: "Spinnaker Records",
        town: "Hyannis",
        category: .musicAndRecords,
        vibeTag: "Chill",
        whyItsCool: "Legit record store with a huge selection of new and used vinyl. The staff actually knows music and will give you solid recommendations. Grab some stickers and patches while you're at it.",
        instagramRating: 3
    ),

    // MARK: Beach Hangouts

    TeenSpot(
        id: "teen-nauset-beach",
        name: "Nauset Beach",
        town: "Orleans",
        category: .beachHangouts,
        vibeTag: "Adventure",
        whyItsCool: "The waves here are actually good enough to surf (or at least try). The parking lot has food trucks, and the energy is unmatched on a summer day. Shark sightings from the lifeguard stand make it extra intense.",
        instagramRating: 4
    ),
    TeenSpot(
        id: "teen-marconi-bluffs",
        name: "Marconi Beach Bluffs",
        town: "Wellfleet",
        category: .beachHangouts,
        vibeTag: "Adventure",
        whyItsCool: "The sandy cliffs are wild looking and you can sometimes spot sharks cruising the shoreline from up top. The stairs down to the beach feel like descending into another world. Sunset from the bluffs is unreal.",
        instagramRating: 5
    ),
    TeenSpot(
        id: "teen-beachcomber",
        name: "The Beachcomber",
        town: "Wellfleet",
        category: .beachHangouts,
        vibeTag: "Chill",
        whyItsCool: "The walk down the long wooden staircase through the dunes is an experience in itself. The vibe is super laid back and the beach is gorgeous. Even if you're just there for the scenery, it delivers.",
        instagramRating: 4
    ),

    // MARK: Food & Drinks

    TeenSpot(
        id: "teen-sundae-school",
        name: "Sundae School Ice Cream",
        town: "Dennis",
        category: .foodAndDrinks,
        vibeTag: "Classic",
        whyItsCool: "Old-school ice cream parlor with homemade flavors that actually taste different from chain stuff. The portions are massive and the toppings bar goes hard. The vintage vibe makes for great photos too.",
        instagramRating: 3
    ),
    TeenSpot(
        id: "teen-hole-in-one",
        name: "Hole In One Donuts",
        town: "Orleans",
        category: .foodAndDrinks,
        vibeTag: "Classic",
        whyItsCool: "They start making donuts before the sun comes up and people literally line up for these. The apple fritters are the size of your face. If you don't post the donut pic, did you even go to the Cape?",
        instagramRating: 3
    ),
    TeenSpot(
        id: "teen-knack",
        name: "The Knack",
        town: "Orleans",
        category: .foodAndDrinks,
        vibeTag: "Foodie",
        whyItsCool: "Lobster corn dogs. Need I say more? Chef-level street food in a tiny spot that sells out fast. The duck fat fries are insane. This is the kind of place you flex on your friends about.",
        instagramRating: 4
    ),

    // MARK: Shopping

    TeenSpot(
        id: "teen-commercial-st",
        name: "Commercial Street Shopping",
        town: "Provincetown",
        category: .shopping,
        vibeTag: "Eclectic",
        whyItsCool: "The most unique shopping strip you'll find anywhere. Vintage clothes, handmade jewelry, art galleries, and street performers everywhere. The people-watching alone is worth the trip. Zero boring chain stores.",
        instagramRating: 5
    ),
    TeenSpot(
        id: "teen-wellfleet-flea",
        name: "Wellfleet Flea Market",
        town: "Wellfleet",
        category: .shopping,
        vibeTag: "Vintage",
        whyItsCool: "Weekend flea market at the drive-in theater. Vintage finds, random treasures, and the best thrifting on the Cape. Go early for the good stuff. Cash is king here - bring small bills for haggling.",
        instagramRating: 3
    ),
    TeenSpot(
        id: "teen-chatham-shops",
        name: "Main Street Chatham Boutiques",
        town: "Chatham",
        category: .shopping,
        vibeTag: "Preppy",
        whyItsCool: "Classic New England Main Street with candy shops, boutiques, and galleries. Very preppy vibes but in a cute way. The Chatham Candy Manor has handmade chocolates that make great gifts (or snacks).",
        instagramRating: 4
    ),

    // MARK: Activities

    TeenSpot(
        id: "teen-rail-trail",
        name: "Cape Cod Rail Trail",
        town: "Various",
        category: .activities,
        vibeTag: "Adventure",
        whyItsCool: "22 miles of paved bike trail through forests, past ponds, and through cute towns. Rent bikes in any town along the route. Stop at the ice cream shops and ponds along the way. Bring a speaker for the ride.",
        instagramRating: 3
    ),
    TeenSpot(
        id: "teen-drive-in",
        name: "Wellfleet Drive-In Theatre",
        town: "Wellfleet",
        category: .activities,
        vibeTag: "Retro",
        whyItsCool: "One of the last drive-in theaters in the country and it's actually amazing. Double features on summer nights, plus a playground and snack bar. The whole thing feels like stepping back in time but in the best way.",
        instagramRating: 4
    ),
    TeenSpot(
        id: "teen-kayak",
        name: "Nauset Marsh Kayaking",
        town: "Eastham",
        category: .activities,
        vibeTag: "Adventure",
        whyItsCool: "Paddle through channels where seals pop up right next to your kayak. The marsh is huge and feels completely wild. On a calm day, the water is glass and you can see fish swimming underneath you.",
        instagramRating: 4
    ),
    TeenSpot(
        id: "teen-surfing",
        name: "Surf Lessons at Coast Guard Beach",
        town: "Eastham",
        category: .activities,
        vibeTag: "Adventure",
        whyItsCool: "The waves on the outer Cape are legit. Even if you've never surfed, the instructors here will get you standing up. Plus, telling people you surfed on Cape Cod hits different.",
        instagramRating: 4
    ),
]

// MARK: - TeenHangoutsView

struct TeenHangoutsView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var selectedCategory: TeenCategory?
    @State private var expandedSpotID: String?
    @State private var beenThereIDs: Set<String> = []
    @State private var headerAppeared = false

    // MARK: - Computed

    private var filteredSpots: [TeenSpot] {
        guard let selectedCategory else { return allTeenSpots }
        return allTeenSpots.filter { $0.category == selectedCategory }
    }

    private var beenThereCount: Int { beenThereIDs.count }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    teenHeader
                        .staggered(index: 0)

                    categoryChips
                        .staggered(index: 1)

                    spotsList
                        .staggered(index: 2)
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Cool Cape Cod")
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
                loadBeenThere()
                withAnimation(CodAnimation.gentle) {
                    headerAppeared = true
                }
            }
        }
    }

    // MARK: - Header

    private var teenHeader: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.capeCod.sunsetOrange)
                .symbolEffect(.pulse, options: .repeating)
                .codAccessibleHidden()

            Text("Cool Cape Cod")
                .codTextStyle(.heroTitle)
                .multilineTextAlignment(.center)
                .codAccessibleHeader("Cool Cape Cod")

            Text("The spots worth posting about")
                .codTextStyle(.subtitle)
                .multilineTextAlignment(.center)

            if beenThereCount > 0 {
                Text("\(beenThereCount) spot\(beenThereCount == 1 ? "" : "s") checked off")
                    .codTextStyle(.caption)
                    .padding(.top, CodSpacing.xs)
            }
        }
        .padding(.vertical, CodSpacing.lg)
    }

    // MARK: - Category Chips

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                ForEach(TeenCategory.allCases, id: \.self) { category in
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

    // MARK: - Spots List

    private var spotsList: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack {
                Text(selectedCategory?.displayName ?? "All Spots")
                    .codTextStyle(.sectionTitle)
                    .codAccessibleHeader(selectedCategory?.displayName ?? "All Spots")

                Spacer()

                Text("\(filteredSpots.count) spots")
                    .codTextStyle(.caption)
            }

            LazyVStack(spacing: CodSpacing.md) {
                ForEach(Array(filteredSpots.enumerated()), id: \.element.id) { index, spot in
                    spotCard(spot: spot)
                        .staggered(index: index)
                }
            }
        }
    }

    // MARK: - Spot Card

    private func spotCard(spot: TeenSpot) -> some View {
        let isExpanded = expandedSpotID == spot.id
        let beenThere = beenThereIDs.contains(spot.id)

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                CodHaptic.light()
                withAnimation(CodAnimation.spring) {
                    expandedSpotID = isExpanded ? nil : spot.id
                }
            } label: {
                spotCardHeader(spot: spot, isExpanded: isExpanded, beenThere: beenThere)
            }
            .buttonStyle(CodButtonPressStyle(variant: .ghost))
            .codAccessibleCard(
                label: "\(spot.name), \(spot.town), \(spot.vibeTag) vibe, \(spot.instagramRating) out of 5 camera rating\(beenThere ? ", been there" : "")",
                hint: isExpanded ? "Tap to collapse" : "Tap to expand details"
            )

            if isExpanded {
                spotCardExpanded(spot: spot, beenThere: beenThere)
            }
        }
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private func spotCardHeader(spot: TeenSpot, isExpanded: Bool, beenThere: Bool) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(alignment: .top, spacing: CodSpacing.sm) {
                Image(systemName: spot.category.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .frame(width: 36, height: 36)
                    .codAccessibleHidden()

                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    HStack {
                        Text(spot.name)
                            .codTextStyle(.cardTitle)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        if beenThere {
                            CodCardBadge(text: "Been There", color: Color.capeCod.duneGrass)
                        }

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.capeCod.driftwood)
                            .codAccessibleHidden()
                    }

                    HStack(spacing: CodSpacing.sm) {
                        Label(spot.town, systemImage: "mappin")
                            .codTextStyle(.caption)

                        vibeBadge(spot.vibeTag)

                        Spacer()

                        cameraRating(spot.instagramRating)
                    }
                }
            }

            if !isExpanded {
                Text(spot.whyItsCool)
                    .codTextStyle(.body)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(CodSpacing.cardPadding)
    }

    private func spotCardExpanded(spot: TeenSpot, beenThere: Bool) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Divider()
                .padding(.horizontal, CodSpacing.cardPadding)

            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                // Why it's cool section
                HStack(alignment: .top, spacing: CodSpacing.sm) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .codAccessibleHidden()

                    VStack(alignment: .leading, spacing: CodSpacing.xs) {
                        Text("Why It's Cool")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.capeCod.oceanBlue)

                        Text(spot.whyItsCool)
                            .codTextStyle(.body)
                    }
                }
                .padding(CodSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.capeCod.oceanBlue.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))

                // Actions
                HStack(spacing: CodSpacing.sm) {
                    if !beenThere {
                        CodButton("Been There", variant: .primary, icon: "checkmark.circle") {
                            CodHaptic.success()
                            markBeenThere(spot.id)
                        }
                    } else {
                        CodButton("Unmark", variant: .ghost, icon: "xmark.circle") {
                            CodHaptic.selection()
                            unmarkBeenThere(spot.id)
                        }
                    }

                    Spacer()

                    CodButton("Share", variant: .ghost, icon: "square.and.arrow.up") {
                        shareSpot(spot)
                    }
                }
            }
            .padding(.horizontal, CodSpacing.cardPadding)
            .padding(.bottom, CodSpacing.cardPadding)
        }
        .transition(.codSlideUp)
    }

    // MARK: - Vibe Badge

    private func vibeBadge(_ vibe: String) -> some View {
        let color = vibeColor(vibe)
        return HStack(spacing: 3) {
            Image(systemName: vibeIcon(vibe))
                .font(.system(size: 9))
            Text(vibe)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    private func vibeColor(_ vibe: String) -> Color {
        switch vibe {
        case "Aesthetic": Color.capeCod.sunsetOrange
        case "Chill": Color.capeCod.oceanBlue
        case "Adventure": Color.capeCod.duneGrass
        case "Classic": Color.capeCod.driftwood
        case "Foodie": Color.capeCod.cranberry
        case "Eclectic": Color(hex: 0xB48AE0)
        case "Vintage": Color.capeCod.driftwood
        case "Retro": Color.capeCod.sunsetOrange
        case "Artsy": Color(hex: 0xB48AE0)
        case "Iconic": Color.capeCod.oceanBlue
        case "Preppy": Color.capeCod.seafoam
        default: Color.capeCod.driftwood
        }
    }

    private func vibeIcon(_ vibe: String) -> String {
        switch vibe {
        case "Aesthetic": "sparkles"
        case "Chill": "leaf.fill"
        case "Adventure": "bolt.fill"
        case "Classic": "star.fill"
        case "Foodie": "fork.knife"
        case "Eclectic": "paintpalette.fill"
        case "Vintage": "clock.fill"
        case "Retro": "film.fill"
        case "Artsy": "paintbrush.fill"
        case "Iconic": "camera.fill"
        case "Preppy": "heart.fill"
        default: "circle.fill"
        }
    }

    // MARK: - Camera Rating

    private func cameraRating(_ rating: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "camera.fill" : "camera")
                    .font(.system(size: 10))
                    .foregroundStyle(index <= rating ? Color.capeCod.sunsetOrange : Color.capeCod.driftwood.opacity(0.3))
            }
        }
        .accessibilityLabel("\(rating) out of 5 Instagram-worthy rating")
    }

    // MARK: - Persistence

    private static let beenThereKey = "teenHangouts.beenThereIDs"

    private func loadBeenThere() {
        let saved = UserDefaults.standard.stringArray(forKey: Self.beenThereKey) ?? []
        beenThereIDs = Set(saved)
    }

    private func markBeenThere(_ id: String) {
        withAnimation(CodAnimation.spring) {
            beenThereIDs.insert(id)
        }
        UserDefaults.standard.set(Array(beenThereIDs), forKey: Self.beenThereKey)
    }

    private func unmarkBeenThere(_ id: String) {
        withAnimation(CodAnimation.spring) {
            beenThereIDs.remove(id)
        }
        UserDefaults.standard.set(Array(beenThereIDs), forKey: Self.beenThereKey)
    }

    // MARK: - Share

    private func shareSpot(_ spot: TeenSpot) {
        CodHaptic.tap()
        let cameras = String(repeating: "📸", count: spot.instagramRating)
        let text = "Found a cool spot on Cape Cod! \(spot.name) in \(spot.town) \(cameras) #CapeCod via @HeyCapeCode"

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

#Preview("Cool Cape Cod") {
    TeenHangoutsView()
}

#Preview("Cool Cape Cod - Sheet") {
    Text("Home")
        .sheet(isPresented: .constant(true)) {
            TeenHangoutsView()
        }
}
