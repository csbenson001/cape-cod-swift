import SwiftUI

// MARK: - Mood Discovery View

/// "I'm in the Mood For..." — browse Cape Cod dining by mood category,
/// see results grouped by proximity, rate spots, and complete quests.
struct MoodDiscoveryView: View {
    @State private var selectedMood: MoodCategory?
    @State private var selectedRegion: CapeCodRegion = .midCape
    @State private var ratingSpot: MoodSpot?
    @State private var pendingRating: Int = 0

    /// Simulated user location — the town the user is "near."
    @State private var userTown: String = "Hyannis"

    @AppStorage("moodQuestData") private var questDataJSON: String = "{}"
    @AppStorage("moodRatingsData") private var ratingsDataJSON: String = "{}"

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                headerSection
                regionPicker

                if let mood = selectedMood {
                    questBanner(for: mood)
                    resultsContent(for: mood)
                } else {
                    moodGrid
                }
            }
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background)
        .navigationTitle("Mood Discovery")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $ratingSpot) { spot in
            ratingSheet(for: spot)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("I'm in the Mood For...")
                .codTextStyle(.heroTitle)
                .foregroundStyle(Color.capeCod.textPrimary)
            Text("Tap a craving to find the best spots across Cape Cod.")
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.top, CodSpacing.md)
    }

    // MARK: - Region Picker

    private var regionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                ForEach(CapeCodRegion.allCases) { region in
                    regionChip(region)
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
    }

    private func regionChip(_ region: CapeCodRegion) -> some View {
        Button {
            withAnimation(CodAnimation.quick) { selectedRegion = region }
            CodHaptic.selection()
        } label: {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: region.icon)
                    .font(.system(size: 11))
                Text(region.rawValue)
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(selectedRegion == region ? Color.white : Color.capeCod.textPrimary)
            .padding(.horizontal, CodSpacing.md)
            .padding(.vertical, CodSpacing.sm)
            .background(selectedRegion == region ? Color.capeCod.oceanBlue : Color.capeCod.surfaceElevated)
            .clipShape(Capsule())
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
    }

    // MARK: - Mood Grid

    private var moodGrid: some View {
        LazyVGrid(columns: moodGridColumns, spacing: CodSpacing.md) {
            ForEach(Array(MoodCategory.allCases.enumerated()), id: \.element.id) { index, mood in
                moodTile(mood)
                    .staggered(index: index)
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    private var moodGridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: CodSpacing.md),
            GridItem(.flexible(), spacing: CodSpacing.md),
            GridItem(.flexible(), spacing: CodSpacing.md),
        ]
    }

    private func moodTile(_ mood: MoodCategory) -> some View {
        Button {
            withAnimation(CodAnimation.spring) { selectedMood = mood }
            CodHaptic.tap()
        } label: {
            VStack(spacing: CodSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(moodColor(mood).opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: mood.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(moodColor(mood))
                }

                Text(mood.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.capeCod.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Show quest progress dot if any progress exists
                let progress = questProgress(for: mood)
                if progress > 0 {
                    questProgressDots(progress: progress, goal: mood.questGoal)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, CodSpacing.md)
            .padding(.horizontal, CodSpacing.xs)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
    }

    private func questProgressDots(progress: Int, goal: Int) -> some View {
        HStack(spacing: 3) {
            ForEach(0..<goal, id: \.self) { index in
                Circle()
                    .fill(index < progress ? moodColor(selectedMood ?? .iceCream) : Color.capeCod.fog)
                    .frame(width: 5, height: 5)
            }
        }
    }

    // MARK: - Quest Banner

    private func questBanner(for mood: MoodCategory) -> some View {
        let progress = questProgress(for: mood)
        let goal = mood.questGoal
        let isComplete = progress >= goal

        return VStack(spacing: CodSpacing.sm) {
            HStack {
                Image(systemName: isComplete ? "trophy.fill" : "flag.fill")
                    .foregroundStyle(isComplete ? Color.capeCod.sandbarYellow : moodColor(mood))
                VStack(alignment: .leading, spacing: 2) {
                    Text(mood.questTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.capeCod.textPrimary)
                    Text(isComplete ? "Quest complete! You're a \(mood.displayName) expert!" : mood.questSubtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.capeCod.textSecondary)
                }
                Spacer()
                Text("\(progress)/\(goal)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(moodColor(mood))
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.capeCod.fog)
                        .frame(height: 6)
                    Capsule()
                        .fill(isComplete ? Color.capeCod.sandbarYellow : moodColor(mood))
                        .frame(width: geo.size.width * CGFloat(min(progress, goal)) / CGFloat(goal), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Results Content

    private func resultsContent(for mood: MoodCategory) -> some View {
        VStack(spacing: CodSpacing.sectionSpacing) {
            // Back button
            backToMoodsButton

            let allMatching = MoodDiscoveryData.spots(for: mood)
            let nearYou = allMatching.filter { isNearUser($0) }
            let inRegion = allMatching.filter { $0.region == selectedRegion && !isNearUser($0) }
            let acrossCape = allMatching.filter { $0.region != selectedRegion && !isNearUser($0) }

            if !nearYou.isEmpty {
                resultSection(title: "Near You", subtitle: "Within 5 miles of \(userTown)", spots: nearYou, mood: mood)
            }

            if !inRegion.isEmpty {
                resultSection(title: "In \(selectedRegion.rawValue)", subtitle: selectedRegion.towns.joined(separator: ", "), spots: inRegion, mood: mood)
            }

            if !acrossCape.isEmpty {
                resultSection(title: "Across the Cape", subtitle: "More great \(mood.displayName.lowercased()) spots", spots: acrossCape, mood: mood)
            }

            if nearYou.isEmpty && inRegion.isEmpty && acrossCape.isEmpty {
                emptyResultsState(mood: mood)
            }
        }
    }

    private var backToMoodsButton: some View {
        Button {
            withAnimation(CodAnimation.spring) { selectedMood = nil }
            CodHaptic.selection()
        } label: {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .semibold))
                Text("All Moods")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(Color.capeCod.oceanBlue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    private func resultSection(title: String, subtitle: String, spots: [MoodSpot], mood: MoodCategory) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .codTextStyle(.sectionTitle)
                Text(subtitle)
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.textSecondary)
            }
            .padding(.horizontal, CodSpacing.screenEdge)

            LazyVStack(spacing: CodSpacing.md) {
                ForEach(Array(spots.sorted { $0.rating > $1.rating }.enumerated()), id: \.element.id) { index, spot in
                    MoodSpotCard(
                        spot: spot,
                        mood: mood,
                        userRating: savedRating(for: spot.id),
                        onRate: { ratingSpot = spot }
                    )
                    .staggered(index: index)
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
    }

    private func emptyResultsState(mood: MoodCategory) -> some View {
        VStack(spacing: CodSpacing.lg) {
            Image(systemName: mood.icon)
                .font(.system(size: 48))
                .foregroundStyle(Color.capeCod.oceanBlue.opacity(0.3))
            Text("No \(mood.displayName.lowercased()) spots found")
                .codTextStyle(.sectionTitle)
                .multilineTextAlignment(.center)
            Text("Try selecting a different region")
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, CodSpacing.xxl)
    }

    // MARK: - Rating Sheet

    private func ratingSheet(for spot: MoodSpot) -> some View {
        NavigationStack {
            VStack(spacing: CodSpacing.xl) {
                Spacer()

                Image(systemName: selectedMood?.icon ?? "star.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(moodColor(selectedMood ?? .iceCream))

                Text("Rate \(spot.name)")
                    .codTextStyle(.sectionTitle)
                    .multilineTextAlignment(.center)

                Text(spot.bestFor)
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.textSecondary)

                ratingStars

                if pendingRating > 0 {
                    Text(ratingLabel(for: pendingRating))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.capeCod.textSecondary)
                        .transition(.opacity)
                }

                Spacer()

                CodButton(pendingRating > 0 ? "Save Rating" : "Skip", variant: pendingRating > 0 ? .primary : .ghost) {
                    if pendingRating > 0 {
                        saveRating(pendingRating, for: spot.id)
                        markQuestProgress(for: selectedMood ?? .iceCream, spotID: spot.id)
                        CodHaptic.success()
                    }
                    ratingSpot = nil
                    pendingRating = 0
                }
                .padding(.horizontal, CodSpacing.screenEdge)
            }
            .padding(.vertical, CodSpacing.xl)
            .background(Color.capeCod.background)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .onAppear {
                pendingRating = savedRating(for: spot.id)
            }
        }
    }

    private var ratingStars: some View {
        HStack(spacing: CodSpacing.md) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    withAnimation(CodAnimation.quick) { pendingRating = star }
                    CodHaptic.light()
                } label: {
                    Image(systemName: star <= pendingRating ? "star.fill" : "star")
                        .font(.system(size: 36))
                        .foregroundStyle(star <= pendingRating ? Color.capeCod.sandbarYellow : Color.capeCod.fog)
                        .scaleEffect(star <= pendingRating ? 1.1 : 1.0)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Helpers

    private func moodColor(_ mood: MoodCategory) -> Color {
        switch mood.color {
        case "seafoam": Color.capeCod.seafoam
        case "lobsterRed": Color.capeCod.lobsterRed
        case "sandbarYellow": Color.capeCod.sandbarYellow
        case "sunsetOrange": Color.capeCod.sunsetOrange
        case "oceanBlue": Color.capeCod.oceanBlue
        case "cranberry": Color.capeCod.cranberry
        case "driftwood": Color.capeCod.driftwood
        case "duneGrass": Color.capeCod.duneGrass
        case "sand": Color.capeCod.sand
        case "deepNavy": Color.capeCod.deepNavy
        default: Color.capeCod.oceanBlue
        }
    }

    /// Simulated proximity check — spots in the same town as the user are "near."
    private func isNearUser(_ spot: MoodSpot) -> Bool {
        spot.town.localizedCaseInsensitiveCompare(userTown) == .orderedSame
    }

    private func ratingLabel(for rating: Int) -> String {
        switch rating {
        case 1: "Not great"
        case 2: "It was okay"
        case 3: "Pretty good!"
        case 4: "Really great!"
        case 5: "Amazing!"
        default: ""
        }
    }

    // MARK: - Persistence Helpers

    private func savedRating(for spotID: String) -> Int {
        let dict = decodeDict(ratingsDataJSON)
        return dict[spotID] ?? 0
    }

    private func saveRating(_ rating: Int, for spotID: String) {
        var dict = decodeDict(ratingsDataJSON)
        dict[spotID] = rating
        ratingsDataJSON = encodeDict(dict)
    }

    private func questProgress(for mood: MoodCategory) -> Int {
        let dict = decodeDict(questDataJSON)
        return dict[mood.rawValue] ?? 0
    }

    private func markQuestProgress(for mood: MoodCategory, spotID: String) {
        // Only increment quest if this is a new rating (not re-rating)
        let existingRating = savedRating(for: spotID)
        guard existingRating == 0 else { return }
        var dict = decodeDict(questDataJSON)
        let current = dict[mood.rawValue] ?? 0
        dict[mood.rawValue] = current + 1
        questDataJSON = encodeDict(dict)
    }

    private func decodeDict(_ json: String) -> [String: Int] {
        guard let data = json.data(using: .utf8),
              let dict = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return dict
    }

    private func encodeDict(_ dict: [String: Int]) -> String {
        guard let data = try? JSONEncoder().encode(dict),
              let str = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return str
    }
}

// MARK: - Mood Spot Card

private struct MoodSpotCard: View {
    let spot: MoodSpot
    let mood: MoodCategory
    let userRating: Int
    let onRate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader
            cardDescription
            topItemChip
            cardFooter
        }
        .padding(.bottom, CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Card Sections

    private var cardHeader: some View {
        HStack(spacing: CodSpacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(spot.name)
                    .codTextStyle(.cardTitle)
                HStack(spacing: CodSpacing.xs) {
                    Text(spot.town)
                    Text("·")
                    Text(String(repeating: "$", count: spot.priceLevel))
                        .foregroundStyle(Color.capeCod.duneGrass)
                }
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.textSecondary)
            }

            Spacer()

            ratingBadge
        }
        .padding(CodSpacing.cardPadding)
    }

    private var ratingBadge: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                Text(String(format: "%.1f", spot.rating))
            }
            .foregroundStyle(Color.capeCod.sandbarYellow)
            .codTextStyle(.label)

            Text(spot.bestFor)
                .font(.system(size: 10))
                .foregroundStyle(Color.capeCod.textSecondary)
                .lineLimit(1)
        }
    }

    private var cardDescription: some View {
        Text(spot.description)
            .codTextStyle(.body)
            .foregroundStyle(Color.capeCod.textSecondary)
            .lineLimit(2)
            .padding(.horizontal, CodSpacing.cardPadding)
    }

    @ViewBuilder
    private var topItemChip: some View {
        if let topItem = spot.topItems[mood.rawValue] {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: mood.icon)
                    .font(.system(size: 10))
                Text("Try the \(topItem)")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(Color.capeCod.oceanBlue)
            .padding(.horizontal, CodSpacing.sm)
            .padding(.vertical, CodSpacing.xs)
            .background(Color.capeCod.oceanBlue.opacity(0.08))
            .clipShape(Capsule())
            .padding(.horizontal, CodSpacing.cardPadding)
            .padding(.top, CodSpacing.sm)
        }
    }

    private var cardFooter: some View {
        HStack {
            // User rating display
            if userRating > 0 {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= userRating ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundStyle(star <= userRating ? Color.capeCod.sandbarYellow : Color.capeCod.fog)
                    }
                    Text("Your rating")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.capeCod.textSecondary)
                }
            }

            Spacer()

            Button {
                onRate()
                CodHaptic.tap()
            } label: {
                HStack(spacing: CodSpacing.xs) {
                    Image(systemName: userRating > 0 ? "star.fill" : "star")
                        .font(.system(size: 11))
                    Text(userRating > 0 ? "Update" : "Rate This!")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(Color.capeCod.oceanBlue)
                .padding(.horizontal, CodSpacing.md)
                .padding(.vertical, CodSpacing.sm - 2)
                .background(Color.capeCod.oceanBlue.opacity(0.1))
                .clipShape(Capsule())
            }
            .buttonStyle(CodButtonPressStyle(variant: .ghost))
        }
        .padding(.horizontal, CodSpacing.cardPadding)
        .padding(.top, CodSpacing.sm)
    }
}

#Preview {
    NavigationStack {
        MoodDiscoveryView()
    }
}
