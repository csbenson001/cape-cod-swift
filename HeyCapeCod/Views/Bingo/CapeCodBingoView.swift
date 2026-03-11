import SwiftUI

// MARK: - Bingo Category

enum BingoCategory: String, Codable, CaseIterable {
    case food, nature, culture, adventure, classic

    var displayName: String {
        switch self {
        case .food: return "Food"
        case .nature: return "Nature"
        case .culture: return "Culture"
        case .adventure: return "Adventure"
        case .classic: return "Classic"
        }
    }

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .nature: return "leaf.fill"
        case .culture: return "building.columns.fill"
        case .adventure: return "figure.hiking"
        case .classic: return "star.fill"
        }
    }

    var tintColor: Color {
        switch self {
        case .food: return Color.capeCod.sunsetOrange
        case .nature: return Color.capeCod.duneGrass
        case .culture: return Color.capeCod.oceanBlue
        case .adventure: return Color.capeCod.seafoam
        case .classic: return Color.capeCod.sandbarYellow
        }
    }
}

// MARK: - Bingo Item

struct BingoItem: Identifiable, Codable {
    let id: String
    let title: String
    let icon: String
    let description: String
    var isCompleted: Bool
    let category: BingoCategory

    /// Whether this is the free center square.
    var isFreeSquare: Bool { id == "classic_sand_toes" }
}

// MARK: - Bingo Items Data

extension BingoItem {

    /// The canonical 25-item bingo card, laid out row by row for a 5x5 grid.
    /// The center square (index 12) is the FREE square.
    static func defaultItems() -> [BingoItem] {
        [
            // Row 1
            BingoItem(id: "food_lobster_roll", title: "Eat a Lobster Roll", icon: "fish.fill", description: "Enjoy a classic New England lobster roll from any Cape restaurant or shack", isCompleted: false, category: .food),
            BingoItem(id: "nature_seal", title: "See a Seal", icon: "pawprint.fill", description: "Spot a seal in the wild — Chatham and Monomoy are hotspots", isCompleted: false, category: .nature),
            BingoItem(id: "culture_lighthouse", title: "Visit a Lighthouse", icon: "location.north.line.fill", description: "Tour or photograph any of Cape Cod's iconic lighthouses", isCompleted: false, category: .culture),
            BingoItem(id: "adventure_canal", title: "Walk the Canal", icon: "figure.walk", description: "Walk, jog, or bike along the Cape Cod Canal path", isCompleted: false, category: .adventure),
            BingoItem(id: "classic_bridge", title: "Cross a Bridge", icon: "car.fill", description: "Cross the Bourne or Sagamore Bridge onto (or off of) the Cape", isCompleted: false, category: .classic),

            // Row 2
            BingoItem(id: "food_chowder", title: "Try Clam Chowder", icon: "mug.fill", description: "Taste a bowl of New England clam chowder — creamy, not red!", isCompleted: false, category: .food),
            BingoItem(id: "nature_whale", title: "Spot a Whale", icon: "water.waves", description: "See a whale on a whale-watching trip or from the shore", isCompleted: false, category: .nature),
            BingoItem(id: "culture_museum", title: "Tour a Museum", icon: "building.columns", description: "Visit any Cape Cod museum — history, art, or maritime", isCompleted: false, category: .culture),
            BingoItem(id: "adventure_sandcastle", title: "Build a Sandcastle", icon: "beach.umbrella.fill", description: "Sculpt a sandcastle (or sand creation) on any Cape beach", isCompleted: false, category: .adventure),
            BingoItem(id: "classic_shingled", title: "Shingled Cottage", icon: "house.fill", description: "Spot a classic gray-shingled Cape Cod cottage", isCompleted: false, category: .classic),

            // Row 3
            BingoItem(id: "food_cape_codder", title: "Cape Codder Drink", icon: "wineglass.fill", description: "Sip a Cape Codder cocktail (or cranberry juice for kids!)", isCompleted: false, category: .food),
            BingoItem(id: "nature_hermit_crab", title: "Find a Hermit Crab", icon: "tortoise.fill", description: "Discover a hermit crab in a tide pool or on the beach", isCompleted: false, category: .nature),
            // CENTER — FREE SQUARE (index 12)
            BingoItem(id: "classic_sand_toes", title: "Sand in Your Toes", icon: "star.fill", description: "Get sand between your toes on any Cape Cod beach — it's mandatory!", isCompleted: true, category: .classic),
            BingoItem(id: "adventure_tide_pool", title: "Go Tide Pooling", icon: "drop.fill", description: "Explore tide pools and discover sea life at low tide", isCompleted: false, category: .adventure),
            BingoItem(id: "culture_art", title: "See Cape Art", icon: "paintpalette.fill", description: "Admire a piece of Cape Cod art — gallery, sculpture, or street art", isCompleted: false, category: .culture),

            // Row 4
            BingoItem(id: "food_waffle_cone", title: "Waffle Cone Time", icon: "snowflake", description: "Get ice cream in a waffle cone from a local shop", isCompleted: false, category: .food),
            BingoItem(id: "nature_sunset", title: "Bay Sunset", icon: "sunset.fill", description: "Watch the sun set over Cape Cod Bay — pure magic", isCompleted: false, category: .nature),
            BingoItem(id: "culture_provincetown", title: "Visit P-town", icon: "building.2.fill", description: "Explore Provincetown — art galleries, shops, and harbor views", isCompleted: false, category: .culture),
            BingoItem(id: "adventure_ferry", title: "Take a Ferry", icon: "ferry.fill", description: "Ride a ferry — to the islands, across the harbor, or a shuttle", isCompleted: false, category: .adventure),
            BingoItem(id: "classic_foghorn", title: "Hear a Foghorn", icon: "speaker.wave.3.fill", description: "Hear the deep, haunting blast of a foghorn on a misty day", isCompleted: false, category: .classic),

            // Row 5
            BingoItem(id: "food_clam_shack", title: "Eat at a Clam Shack", icon: "takeoutbag.and.cup.and.straw.fill", description: "Dine at a roadside clam shack — fried clams, lobster, the works", isCompleted: false, category: .food),
            BingoItem(id: "nature_plover", title: "See a Piping Plover", icon: "bird.fill", description: "Spot an endangered piping plover on the beach — look, don't disturb!", isCompleted: false, category: .nature),
            BingoItem(id: "culture_event", title: "Attend an Event", icon: "ticket.fill", description: "Go to a local Cape Cod event — fair, concert, parade, or festival", isCompleted: false, category: .culture),
            BingoItem(id: "adventure_kayak", title: "Kayak or SUP", icon: "oar.2.crossed", description: "Paddle a kayak or stand-up paddleboard on Cape waters", isCompleted: false, category: .adventure),
            BingoItem(id: "classic_roadside", title: "Roadside Stand Buy", icon: "bag.fill", description: "Buy something from a roadside farm stand or local vendor", isCompleted: false, category: .classic),
        ]
    }
}

// MARK: - Bingo Persistence

private enum BingoPersistence {
    static let completedKey = "cape_cod_bingo_completed"
    static let completionDatesKey = "cape_cod_bingo_dates"

    static func loadCompletedIDs() -> Set<String> {
        guard let data = UserDefaults.standard.array(forKey: completedKey) as? [String] else {
            // Free square is always completed
            return ["classic_sand_toes"]
        }
        var ids = Set(data)
        ids.insert("classic_sand_toes")
        return ids
    }

    static func saveCompletedIDs(_ ids: Set<String>) {
        UserDefaults.standard.set(Array(ids), forKey: completedKey)
    }

    static func loadCompletionDates() -> [String: Date] {
        guard let data = UserDefaults.standard.data(forKey: completionDatesKey),
              let dates = try? JSONDecoder().decode([String: Date].self, from: data) else {
            return ["classic_sand_toes": .now]
        }
        return dates
    }

    static func saveCompletionDates(_ dates: [String: Date]) {
        if let data = try? JSONEncoder().encode(dates) {
            UserDefaults.standard.set(data, forKey: completionDatesKey)
        }
    }
}

// MARK: - Cape Cod Bingo View

struct CapeCodBingoView: View {
    @State private var items: [BingoItem] = BingoItem.defaultItems()
    @State private var completedIDs: Set<String> = BingoPersistence.loadCompletedIDs()
    @State private var completionDates: [String: Date] = BingoPersistence.loadCompletionDates()
    @State private var celebratingIndex: Int?
    @State private var showBingo = false
    @State private var bingoLines: [[Int]] = []

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 5)

    private var completedCount: Int { completedIDs.count }
    private var progress: Double { Double(completedCount) / 25.0 }

    private var shareText: String {
        let hasBingo = !bingoLines.isEmpty
        if hasBingo {
            return "I got BINGO on Cape Cod! \u{1F389} \(completedCount)/25 squares completed on my Cape Cod vacation. #CapeCodBingo #HeyCapeCodeApp"
        }
        return "I've checked off \(completedCount)/25 on my Cape Cod Bingo card! \u{1F30A} #CapeCodBingo #HeyCapeCodeApp"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                headerSection
                    .staggered(index: 0)

                progressSection
                    .staggered(index: 1)

                bingoGrid
                    .staggered(index: 2)

                shareSection
                    .staggered(index: 3)
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background)
        .overlay {
            if showBingo {
                bingoCelebrationOverlay
            }
        }
        .navigationTitle("Cape Cod Bingo")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            syncCompletionState()
            bingoLines = detectBingoLines()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.capeCod.oceanBlue.opacity(0.12))
                    .frame(width: 72, height: 72)

                Image(systemName: "book.closed.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color.capeCod.oceanGradient)
            }

            Text("Cape Cod Bingo")
                .codTextStyle(.heroTitle)
                .codAccessibleHeader("Cape Cod Bingo")

            Text("Check off Cape Cod classics!")
                .codTextStyle(.subtitle)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, CodSpacing.md)
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: CodSpacing.sm) {
            HStack {
                Text("\(completedCount) of 25")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.capeCod.textPrimary)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.capeCod.fog)
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.capeCod.oceanGradient)
                        .frame(width: geometry.size.width * progress, height: 10)
                        .animation(CodAnimation.spring, value: progress)
                }
            }
            .frame(height: 10)
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .codAccessible(label: "\(completedCount) of 25 squares completed, \(Int(progress * 100)) percent")
    }

    // MARK: - Bingo Grid

    private var bingoGrid: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                BingoSquareView(
                    item: item,
                    isCompleted: completedIDs.contains(item.id),
                    isCelebrating: celebratingIndex == index,
                    isInBingoLine: bingoLines.contains(where: { $0.contains(index) })
                ) {
                    toggleItem(at: index)
                }
            }
        }
        .padding(CodSpacing.xs)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Share

    private var shareSection: some View {
        ShareLink(item: shareText) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                Text("Share My Card")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50)
            .padding(.horizontal, CodSpacing.lg)
            .foregroundStyle(Color.capeCod.textOnPrimary)
            .background(Color.capeCod.sunsetOrange)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
        }
        .buttonStyle(CodButtonPressStyle(variant: .accent))
        .codAccessibleButton("Share My Card", hint: "Share your Cape Cod Bingo progress on social media")
    }

    // MARK: - Bingo Celebration Overlay

    private var bingoCelebrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(CodAnimation.spring) {
                        showBingo = false
                    }
                }

            VStack(spacing: CodSpacing.lg) {
                // Confetti-like burst of icons
                ZStack {
                    ForEach(0..<8, id: \.self) { i in
                        Image(systemName: celebrationIcons[i % celebrationIcons.count])
                            .font(.system(size: 24))
                            .foregroundStyle(celebrationColors[i % celebrationColors.count])
                            .offset(
                                x: cos(Double(i) * .pi / 4) * 60,
                                y: sin(Double(i) * .pi / 4) * 60
                            )
                            .opacity(showBingo ? 1 : 0)
                            .scaleEffect(showBingo ? 1 : 0.2)
                            .animation(
                                CodAnimation.spring.delay(Double(i) * 0.05),
                                value: showBingo
                            )
                    }

                    Text("BINGO!")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(Color.capeCod.sunsetGradient)
                        .scaleEffect(showBingo ? 1 : 0.3)
                        .animation(CodAnimation.bouncy, value: showBingo)
                }

                Text("You got 5 in a row!")
                    .codTextStyle(.sectionTitle)
                    .foregroundStyle(.white)

                Button {
                    withAnimation(CodAnimation.spring) {
                        showBingo = false
                    }
                } label: {
                    Text("Keep Playing")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.capeCod.textOnPrimary)
                        .padding(.horizontal, CodSpacing.xl)
                        .padding(.vertical, CodSpacing.sm + 4)
                        .background(Color.capeCod.oceanBlue)
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                }
                .buttonStyle(CodButtonPressStyle(variant: .primary))
            }
            .padding(CodSpacing.xl)
        }
        .transition(.opacity)
        .codAccessible(label: "Bingo! You got 5 in a row!", hint: "Tap anywhere to dismiss")
    }

    private let celebrationIcons = [
        "star.fill", "sparkle", "fish.fill", "sun.max.fill",
        "heart.fill", "leaf.fill", "flag.fill", "hands.clap.fill"
    ]

    private let celebrationColors: [Color] = [
        Color.capeCod.sunsetOrange, Color.capeCod.oceanBlue,
        Color.capeCod.seafoam, Color.capeCod.sandbarYellow,
        Color.capeCod.cranberry, Color.capeCod.duneGrass,
        Color.capeCod.sunsetOrange, Color.capeCod.oceanBlue
    ]

    // MARK: - Actions

    private func toggleItem(at index: Int) {
        let item = items[index]

        // Don't allow unchecking the free square
        if item.isFreeSquare { return }

        let wasCompleted = completedIDs.contains(item.id)

        if wasCompleted {
            // Uncheck
            completedIDs.remove(item.id)
            completionDates.removeValue(forKey: item.id)
            CodHaptic.light()
        } else {
            // Check off
            completedIDs.insert(item.id)
            completionDates[item.id] = .now
            CodHaptic.success()

            // Celebration animation
            celebratingIndex = index
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                celebratingIndex = nil
            }

            // Check for bingo
            let newBingoLines = detectBingoLines()
            if newBingoLines.count > bingoLines.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(CodAnimation.spring) {
                        showBingo = true
                    }
                    // Haptic burst for bingo
                    for i in 0..<3 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                            CodHaptic.success()
                        }
                    }
                }
            }
            bingoLines = newBingoLines
        }

        items[index].isCompleted = completedIDs.contains(item.id)
        persist()
    }

    private func syncCompletionState() {
        for i in items.indices {
            items[i].isCompleted = completedIDs.contains(items[i].id)
        }
    }

    private func persist() {
        BingoPersistence.saveCompletedIDs(completedIDs)
        BingoPersistence.saveCompletionDates(completionDates)
    }

    // MARK: - Bingo Detection

    /// Returns all winning lines (rows, columns, diagonals) that are fully completed.
    private func detectBingoLines() -> [[Int]] {
        var lines: [[Int]] = []

        // Rows
        for row in 0..<5 {
            let indices = (0..<5).map { row * 5 + $0 }
            if indices.allSatisfy({ completedIDs.contains(items[$0].id) }) {
                lines.append(indices)
            }
        }

        // Columns
        for col in 0..<5 {
            let indices = (0..<5).map { $0 * 5 + col }
            if indices.allSatisfy({ completedIDs.contains(items[$0].id) }) {
                lines.append(indices)
            }
        }

        // Diagonal top-left to bottom-right
        let diag1 = [0, 6, 12, 18, 24]
        if diag1.allSatisfy({ completedIDs.contains(items[$0].id) }) {
            lines.append(diag1)
        }

        // Diagonal top-right to bottom-left
        let diag2 = [4, 8, 12, 16, 20]
        if diag2.allSatisfy({ completedIDs.contains(items[$0].id) }) {
            lines.append(diag2)
        }

        return lines
    }
}

// MARK: - Bingo Square View

private struct BingoSquareView: View {
    let item: BingoItem
    let isCompleted: Bool
    let isCelebrating: Bool
    let isInBingoLine: Bool
    let onTap: () -> Void

    @State private var animateCheck = false

    var body: some View {
        Button(action: onTap) {
            GeometryReader { geometry in
                let size = geometry.size
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous)
                        .fill(backgroundColor)

                    // Bingo line highlight
                    if isInBingoLine && isCompleted {
                        RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous)
                            .strokeBorder(item.category.tintColor, lineWidth: 2)
                    }

                    if item.isFreeSquare {
                        freeSquareContent(size: size)
                    } else if isCompleted {
                        completedContent(size: size)
                    } else {
                        uncompletedContent(size: size)
                    }
                }
                .frame(width: size.width, height: size.width) // Force square aspect ratio
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(BingoSquarePressStyle())
        .scaleEffect(isCelebrating ? 1.15 : 1.0)
        .animation(CodAnimation.bouncy, value: isCelebrating)
        .codAccessibleButton(
            item.title,
            hint: item.isFreeSquare
                ? "Free square, already completed"
                : (isCompleted ? "Completed. Double tap to uncheck." : "Not completed. Double tap to check off. \(item.description)")
        )
    }

    // MARK: - Free Square

    private func freeSquareContent(size: CGSize) -> some View {
        VStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.system(size: min(size.width * 0.3, 20), weight: .bold))
                .foregroundStyle(Color.capeCod.sandbarYellow)

            Text("FREE")
                .font(.system(size: min(size.width * 0.16, 10), weight: .black, design: .rounded))
                .foregroundStyle(Color.capeCod.sandbarYellow)
                .tracking(1)

            Text(item.title)
                .font(.system(size: min(size.width * 0.13, 8), weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .padding(2)
    }

    // MARK: - Completed Square

    private func completedContent(size: CGSize) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 2) {
                Image(systemName: item.icon)
                    .font(.system(size: min(size.width * 0.28, 18), weight: .semibold))
                    .foregroundStyle(.white)

                Text(item.title)
                    .font(.system(size: min(size.width * 0.14, 9), weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .padding(2)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: min(size.width * 0.2, 14)))
                .foregroundStyle(.white)
                .padding(3)
        }
    }

    // MARK: - Uncompleted Square

    private func uncompletedContent(size: CGSize) -> some View {
        VStack(spacing: 2) {
            Image(systemName: item.icon)
                .font(.system(size: min(size.width * 0.28, 18), weight: .medium))
                .foregroundStyle(item.category.tintColor.opacity(0.7))

            Text(item.title)
                .font(.system(size: min(size.width * 0.14, 9), weight: .medium))
                .foregroundStyle(Color.capeCod.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .padding(2)
    }

    // MARK: - Background Color

    private var backgroundColor: Color {
        if item.isFreeSquare {
            return Color.capeCod.deepNavy
        }
        if isCompleted {
            return item.category.tintColor
        }
        return Color.capeCod.surface
    }
}

// MARK: - Bingo Square Press Style

private struct BingoSquarePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.capeCodQuick, value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Cape Cod Bingo") {
    NavigationStack {
        CapeCodBingoView()
    }
}

#Preview("Bingo - Some Completed") {
    NavigationStack {
        CapeCodBingoView()
            .onAppear {
                // Simulate some completed items for preview
                let sampleIDs = [
                    "food_lobster_roll", "nature_seal", "culture_lighthouse",
                    "adventure_canal", "classic_sand_toes", "food_chowder",
                    "nature_sunset", "classic_bridge"
                ]
                UserDefaults.standard.set(sampleIDs, forKey: "cape_cod_bingo_completed")
            }
    }
}
