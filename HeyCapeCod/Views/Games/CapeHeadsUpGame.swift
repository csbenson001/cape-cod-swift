import SwiftUI
import CoreMotion

// MARK: - Game Data

enum HeadsUpCategory: String, CaseIterable, Identifiable {
    case beaches = "Cape Cod Beaches"
    case foods = "Cape Cod Foods"
    case towns = "Cape Cod Towns"
    case wildlife = "Cape Cod Wildlife"
    case activities = "Cape Cod Activities"
    case landmarks = "Cape Cod Landmarks"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .beaches: "beach.umbrella"
        case .foods: "fork.knife"
        case .towns: "building.2"
        case .wildlife: "pawprint"
        case .activities: "figure.surfing"
        case .landmarks: "mappin.and.ellipse"
        }
    }

    var color: Color {
        switch self {
        case .beaches: Color.capeCod.oceanBlue
        case .foods: Color.capeCod.lobsterRed
        case .towns: Color.capeCod.deepNavy
        case .wildlife: Color.capeCod.duneGrass
        case .activities: Color.capeCod.sunsetOrange
        case .landmarks: Color.capeCod.cranberry
        }
    }

    var items: [String] {
        switch self {
        case .beaches:
            return [
                "Nauset Beach", "Coast Guard Beach", "Marconi Beach",
                "Race Point Beach", "Herring Cove Beach", "Craigville Beach",
                "Old Silver Beach", "Sandy Neck Beach", "Skaket Beach",
                "Mayflower Beach", "Corporation Beach", "Chapin Beach",
                "West Dennis Beach", "Kalmus Beach", "Breakwater Beach",
                "Head of the Meadow Beach", "Newcomb Hollow Beach",
                "Cahoon Hollow Beach", "White Crest Beach", "Longnook Beach",
                "Ballston Beach", "Great Hollow Beach", "Paines Creek Beach",
                "Sea Gull Beach", "Ridgevale Beach"
            ]
        case .foods:
            return [
                "Lobster Roll", "Clam Chowder", "Fried Clams",
                "Oysters on the Half Shell", "Fish and Chips", "Lobster Bisque",
                "Steamers", "Quahog", "Cape Cod Potato Chips",
                "Cranberry Bog Juice", "Lobster Mac and Cheese", "Cod Fish Tacos",
                "Clam Bake", "Stuffed Quahog", "Portuguese Linguica",
                "Blueberry Pie", "Saltwater Taffy", "Corn on the Cob",
                "Cape Cod Beer", "Soft Serve Ice Cream", "Raw Bar Platter",
                "Scallops", "Crab Cakes", "Lobster Tail",
                "New England Clam Bake"
            ]
        case .towns:
            return [
                "Chatham", "Provincetown", "Hyannis", "Falmouth",
                "Sandwich", "Brewster", "Orleans", "Wellfleet",
                "Truro", "Eastham", "Dennis", "Yarmouth",
                "Barnstable", "Mashpee", "Bourne", "Harwich",
                "Centerville", "Osterville", "Cotuit", "Dennisport",
                "Marstons Mills", "West Yarmouth", "South Yarmouth",
                "Bass River", "North Truro"
            ]
        case .wildlife:
            return [
                "Gray Seal", "Great White Shark", "Horseshoe Crab",
                "Humpback Whale", "Piping Plover", "Osprey",
                "Blue Crab", "Diamondback Terrapin", "Snowy Egret",
                "Red Fox", "Striped Bass", "Bluefish",
                "Hermit Crab", "Moon Jellyfish", "Eastern Box Turtle",
                "Great Blue Heron", "Cormorant", "Fiddler Crab",
                "Minnow", "Starfish", "Monarch Butterfly",
                "Coyote", "Harbor Seal", "Right Whale",
                "Sand Dollar"
            ]
        case .activities:
            return [
                "Whale Watching", "Kayaking", "Paddleboarding",
                "Cape Cod Rail Trail Biking", "Fishing Charter",
                "Seal Watching Cruise", "Mini Golf", "Go Kart Racing",
                "Parasailing", "Sailing", "Surfing",
                "Tide Pool Exploring", "Berry Picking",
                "Antiquing", "Wine Tasting", "Sunset Cruise",
                "Clam Digging", "Boogie Boarding", "Beach Bonfire",
                "Lighthouse Tour", "Sand Castle Building",
                "Cape Cod Canal Walk", "Dune Tour",
                "Kite Flying", "Shell Collecting"
            ]
        case .landmarks:
            return [
                "Cape Cod Canal", "Pilgrim Monument", "Highland Lighthouse",
                "Chatham Lighthouse", "Nauset Lighthouse", "Sagamore Bridge",
                "Bourne Bridge", "Cape Cod National Seashore", "Nobska Lighthouse",
                "Race Point Lighthouse", "Sandwich Boardwalk", "Marconi Station",
                "Cape Cod Museum of Natural History", "Heritage Museums and Gardens",
                "Whydah Pirate Museum", "Edward Gorey House",
                "Provincetown Art Association", "Shining Sea Bikeway",
                "Stage Harbor Lighthouse", "Bass Hole Boardwalk",
                "Hyannis Harbor", "John F. Kennedy Memorial",
                "Cape Cod Potato Chip Factory", "Wellfleet Drive-In Theater",
                "Nickerson State Park"
            ]
        }
    }
}

// MARK: - Game State

enum HeadsUpPhase {
    case categorySelection
    case countdown
    case playing
    case results
}

struct HeadsUpResult: Identifiable {
    let id = UUID()
    let word: String
    let correct: Bool
}

// MARK: - Motion Manager

@Observable
final class TiltDetector {
    private let motionManager = CMMotionManager()
    private(set) var tiltDirection: TiltDirection = .neutral

    enum TiltDirection {
        case up, down, neutral
    }

    func startDetecting() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            let pitch = motion.attitude.pitch
            if pitch > 0.6 {
                self.tiltDirection = .up
            } else if pitch < -0.3 {
                self.tiltDirection = .down
            } else {
                self.tiltDirection = .neutral
            }
        }
    }

    func stopDetecting() {
        motionManager.stopDeviceMotionUpdates()
        tiltDirection = .neutral
    }
}

// MARK: - Game View Model

@Observable
final class HeadsUpGameViewModel {
    var phase: HeadsUpPhase = .categorySelection
    var selectedCategory: HeadsUpCategory?
    var timerDuration: Int = 60
    var timeRemaining: Int = 60
    var countdownValue: Int = 3
    var results: [HeadsUpResult] = []
    var flashColor: Color? = nil

    private var shuffledItems: [String] = []
    private var currentIndex: Int = 0
    private var timer: Timer?
    private var lastTilt: TiltDetector.TiltDirection = .neutral
    private var canRegisterTilt = true

    let tiltDetector = TiltDetector()

    var currentWord: String {
        guard currentIndex < shuffledItems.count else { return "" }
        return shuffledItems[currentIndex]
    }

    var score: Int {
        results.filter(\.correct).count
    }

    var skipped: Int {
        results.filter { !$0.correct }.count
    }

    var correctResults: [HeadsUpResult] {
        results.filter(\.correct)
    }

    var skippedResults: [HeadsUpResult] {
        results.filter { !$0.correct }
    }

    // MARK: - Actions

    func selectCategory(_ category: HeadsUpCategory) {
        selectedCategory = category
        shuffledItems = category.items.shuffled()
        currentIndex = 0
        results = []
        countdownValue = 3
        phase = .countdown
        startCountdown()
    }

    func handleTilt(_ direction: TiltDetector.TiltDirection) {
        guard phase == .playing, canRegisterTilt else { return }

        switch direction {
        case .down where lastTilt != .down:
            markCorrect()
        case .up where lastTilt != .up:
            markSkip()
        default:
            break
        }
        lastTilt = direction
    }

    func playAgain() {
        phase = .categorySelection
        selectedCategory = nil
        results = []
        flashColor = nil
        tiltDetector.stopDetecting()
        stopTimer()
    }

    func resetToCategories() {
        playAgain()
    }

    // MARK: - Private

    private func markCorrect() {
        guard currentIndex < shuffledItems.count else { return }
        results.append(HeadsUpResult(word: shuffledItems[currentIndex], correct: true))
        CodHaptic.success()
        showFlash(.green)
        advanceWord()
    }

    private func markSkip() {
        guard currentIndex < shuffledItems.count else { return }
        results.append(HeadsUpResult(word: shuffledItems[currentIndex], correct: false))
        CodHaptic.error()
        showFlash(.red)
        advanceWord()
    }

    private func advanceWord() {
        canRegisterTilt = false
        currentIndex += 1
        if currentIndex >= shuffledItems.count {
            shuffledItems.append(contentsOf: (selectedCategory?.items ?? []).shuffled())
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.canRegisterTilt = true
        }
    }

    private func showFlash(_ color: Color) {
        flashColor = color
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.flashColor = nil
        }
    }

    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.countdownValue > 1 {
                self.countdownValue -= 1
                CodHaptic.light()
            } else {
                self.stopTimer()
                CodHaptic.tap()
                self.startGame()
            }
        }
    }

    private func startGame() {
        timeRemaining = timerDuration
        phase = .playing
        lastTilt = .neutral
        canRegisterTilt = true
        tiltDetector.startDetecting()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                if self.timeRemaining <= 5 && self.timeRemaining > 0 {
                    CodHaptic.light()
                }
            } else {
                self.endGame()
            }
        }
    }

    private func endGame() {
        stopTimer()
        tiltDetector.stopDetecting()
        CodHaptic.heavy()
        phase = .results
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Main Game View

struct CapeHeadsUpGame: View {
    @State private var viewModel = HeadsUpGameViewModel()

    var body: some View {
        ZStack {
            Color.capeCod.background
                .ignoresSafeArea()

            switch viewModel.phase {
            case .categorySelection:
                CategorySelectionView(viewModel: viewModel)
                    .transition(.codScale)
            case .countdown:
                CountdownView(value: viewModel.countdownValue)
                    .transition(.codScale)
            case .playing:
                PlayingView(viewModel: viewModel)
                    .transition(.codScale)
            case .results:
                ResultsView(viewModel: viewModel)
                    .transition(.codScale)
            }
        }
        .animation(CodAnimation.spring, value: viewModel.phase == .categorySelection)
        .animation(CodAnimation.spring, value: viewModel.phase == .countdown)
        .animation(CodAnimation.spring, value: viewModel.phase == .playing)
        .animation(CodAnimation.spring, value: viewModel.phase == .results)
    }
}

// MARK: - Category Selection

private struct CategorySelectionView: View {
    let viewModel: HeadsUpGameViewModel
    @State private var selectedDuration = 60

    private let durationOptions = [30, 45, 60, 90]

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.lg) {
                headerSection
                timerPickerSection
                categoriesGrid
                Spacer(minLength: CodSpacing.tabBarClearance)
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.top, CodSpacing.lg)
        }
    }

    private var headerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                .font(.system(size: 48))
                .foregroundStyle(Color.capeCod.oceanBlue)

            Text("Heads Up!")
                .codTextStyle(.heroTitle)

            Text("Cape Cod Edition")
                .codTextStyle(.subtitle)

            Text("Hold the phone to your forehead.\nOther players give clues!")
                .codTextStyle(.body)
                .multilineTextAlignment(.center)
                .padding(.top, CodSpacing.xs)
        }
    }

    private var timerPickerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Text("ROUND LENGTH")
                .codTextStyle(.label)

            HStack(spacing: CodSpacing.sm) {
                ForEach(durationOptions, id: \.self) { seconds in
                    TimerChip(
                        seconds: seconds,
                        isSelected: selectedDuration == seconds
                    ) {
                        CodHaptic.selection()
                        selectedDuration = seconds
                        viewModel.timerDuration = seconds
                    }
                }
            }
        }
        .padding(.vertical, CodSpacing.sm)
    }

    private var categoriesGrid: some View {
        VStack(spacing: CodSpacing.sm) {
            Text("PICK A CATEGORY")
                .codTextStyle(.label)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: CodSpacing.md),
                    GridItem(.flexible(), spacing: CodSpacing.md)
                ],
                spacing: CodSpacing.md
            ) {
                ForEach(HeadsUpCategory.allCases) { category in
                    CategoryCard(category: category) {
                        CodHaptic.tap()
                        viewModel.selectCategory(category)
                    }
                    .staggered(index: HeadsUpCategory.allCases.firstIndex(of: category) ?? 0)
                }
            }
        }
    }
}

// MARK: - Timer Chip

private struct TimerChip: View {
    let seconds: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(seconds)s")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isSelected ? Color.capeCod.textOnPrimary : Color.capeCod.textPrimary)
                .padding(.horizontal, CodSpacing.md)
                .padding(.vertical, CodSpacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.surface)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isSelected ? Color.clear : Color.capeCod.cardBorder,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category Card

private struct CategoryCard: View {
    let category: HeadsUpCategory
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: CodSpacing.sm) {
                Image(systemName: category.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(category.color)

                Text(category.rawValue)
                    .codTextStyle(.cardTitle)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text("\(category.items.count) items")
                    .codTextStyle(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Countdown View

private struct CountdownView: View {
    let value: Int

    var body: some View {
        VStack(spacing: CodSpacing.lg) {
            Text("Get Ready!")
                .codTextStyle(.sectionTitle)

            Text("\(value)")
                .font(.system(size: 120, weight: .bold, design: .rounded))
                .foregroundStyle(Color.capeCod.oceanBlue)
                .contentTransition(.numericText())
                .animation(CodAnimation.spring, value: value)

            Text("Hold the phone to your forehead")
                .codTextStyle(.body)
                .multilineTextAlignment(.center)

            Image(systemName: "iphone.gen3")
                .font(.system(size: 40))
                .foregroundStyle(Color.capeCod.textSecondary)
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Playing View

private struct PlayingView: View {
    @Bindable var viewModel: HeadsUpGameViewModel

    var body: some View {
        ZStack {
            gameContent
            flashOverlay
        }
        .ignoresSafeArea()
        .onChange(of: viewModel.tiltDetector.tiltDirection) { _, newValue in
            viewModel.handleTilt(newValue)
        }
    }

    private var gameContent: some View {
        VStack(spacing: CodSpacing.lg) {
            timerBar
            Spacer()
            wordDisplay
            Spacer()
            scoreIndicator
            instructionHints
        }
        .padding(CodSpacing.screenEdge)
        .padding(.vertical, CodSpacing.xl)
    }

    private var timerBar: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundStyle(timerColor)
            Text("\(viewModel.timeRemaining)")
                .font(.system(size: 28, weight: .bold).monospacedDigit())
                .foregroundStyle(timerColor)
                .contentTransition(.numericText())
                .animation(CodAnimation.quick, value: viewModel.timeRemaining)
        }
    }

    private var timerColor: Color {
        if viewModel.timeRemaining <= 10 {
            return Color.capeCod.lobsterRed
        } else if viewModel.timeRemaining <= 20 {
            return Color.capeCod.sunsetOrange
        }
        return Color.capeCod.textPrimary
    }

    private var wordDisplay: some View {
        Text(viewModel.currentWord)
            .font(.system(size: 52, weight: .bold, design: .rounded))
            .foregroundStyle(Color.capeCod.textPrimary)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.4)
            .lineLimit(3)
            .padding(.horizontal, CodSpacing.lg)
            .id(viewModel.currentWord)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.8).combined(with: .opacity),
                removal: .scale(scale: 1.2).combined(with: .opacity)
            ))
            .animation(CodAnimation.spring, value: viewModel.currentWord)
    }

    private var scoreIndicator: some View {
        HStack(spacing: CodSpacing.xl) {
            VStack(spacing: CodSpacing.xs) {
                Text("\(viewModel.score)")
                    .font(.system(size: 32, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color.capeCod.duneGrass)
                Text("Correct")
                    .codTextStyle(.caption)
            }

            VStack(spacing: CodSpacing.xs) {
                Text("\(viewModel.skipped)")
                    .font(.system(size: 32, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color.capeCod.lobsterRed)
                Text("Skipped")
                    .codTextStyle(.caption)
            }
        }
    }

    private var instructionHints: some View {
        HStack(spacing: CodSpacing.xl) {
            Label("Tilt down = Correct", systemImage: "arrow.down")
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.duneGrass)
            Label("Tilt up = Skip", systemImage: "arrow.up")
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.lobsterRed)
        }
    }

    private var flashOverlay: some View {
        Group {
            if let color = viewModel.flashColor {
                color.opacity(0.35)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
                    .animation(CodAnimation.quick, value: viewModel.flashColor == nil)

                Image(systemName: color == .green ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                    .transition(.codScale)
            }
        }
    }
}

// MARK: - Results View

private struct ResultsView: View {
    let viewModel: HeadsUpGameViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.lg) {
                scoreHeader
                resultsList
                actionButtons
                Spacer(minLength: CodSpacing.tabBarClearance)
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.top, CodSpacing.xl)
        }
    }

    private var scoreHeader: some View {
        VStack(spacing: CodSpacing.sm) {
            Text(cheerMessage)
                .codTextStyle(.heroTitle)
                .multilineTextAlignment(.center)

            Text("\(viewModel.score)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(Color.capeCod.oceanBlue)

            Text("out of \(viewModel.results.count)")
                .codTextStyle(.subtitle)

            if let category = viewModel.selectedCategory {
                Text(category.rawValue)
                    .codTextStyle(.caption)
            }
        }
    }

    private var cheerMessage: String {
        let ratio = viewModel.results.isEmpty ? 0 : Double(viewModel.score) / Double(viewModel.results.count)
        switch ratio {
        case 0.8...: return "Amazing!"
        case 0.6..<0.8: return "Great Job!"
        case 0.4..<0.6: return "Not Bad!"
        default: return "Keep Trying!"
        }
    }

    private var resultsList: some View {
        VStack(spacing: CodSpacing.xs) {
            if !viewModel.correctResults.isEmpty {
                resultSection(title: "CORRECT", items: viewModel.correctResults, color: Color.capeCod.duneGrass)
            }

            if !viewModel.skippedResults.isEmpty {
                resultSection(title: "SKIPPED", items: viewModel.skippedResults, color: Color.capeCod.lobsterRed)
            }
        }
    }

    private func resultSection(title: String, items: [HeadsUpResult], color: Color) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text(title)
                .codTextStyle(.label)
                .foregroundStyle(color)

            VStack(spacing: 0) {
                ForEach(items) { item in
                    HStack {
                        Image(systemName: item.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(color)
                        Text(item.word)
                            .codTextStyle(.body)
                        Spacer()
                    }
                    .padding(.vertical, CodSpacing.sm)
                    .padding(.horizontal, CodSpacing.cardPadding)

                    if item.id != items.last?.id {
                        Divider()
                            .padding(.horizontal, CodSpacing.cardPadding)
                    }
                }
            }
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
    }

    private var actionButtons: some View {
        VStack(spacing: CodSpacing.md) {
            Button {
                CodHaptic.tap()
                viewModel.playAgain()
            } label: {
                Label("Play Again", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.capeCod.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, CodSpacing.md)
                    .background(Color.capeCod.oceanBlue)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
            }
            .buttonStyle(.plain)

            ShareLink(item: shareText) {
                Label("Share Score", systemImage: "square.and.arrow.up")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, CodSpacing.md)
                    .background(Color.capeCod.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous)
                            .strokeBorder(Color.capeCod.oceanBlue, lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var shareText: String {
        let category = viewModel.selectedCategory?.rawValue ?? "Cape Cod"
        return "I scored \(viewModel.score) out of \(viewModel.results.count) in \(category) Heads Up! -- Hey Cape Cod"
    }
}

// MARK: - Preview

#Preview {
    CapeHeadsUpGame()
}
