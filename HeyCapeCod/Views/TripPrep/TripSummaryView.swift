import SwiftUI
import PhotosUI

// MARK: - Persist On Change Modifier

private struct PersistOnChangeModifier: ViewModifier {
    let familyName: String
    let startDate: Date
    let endDate: Date
    let numberOfTravelers: Int
    let beachesVisited: Int
    let townsExplored: Int
    let lobsterRollsEaten: Int
    let sunsetsWatched: Int
    let milesWalked: String
    let favoriteBeach: String
    let bestMeal: String
    let bestRestaurant: String
    let mostVisitedTown: String
    let selectedStyle: TripCardStyle
    let persistAll: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: familyName) { _, _ in persistAll() }
            .onChange(of: startDate) { _, _ in persistAll() }
            .onChange(of: endDate) { _, _ in persistAll() }
            .onChange(of: numberOfTravelers) { _, _ in persistAll() }
            .onChange(of: beachesVisited) { _, _ in persistAll() }
            .onChange(of: townsExplored) { _, _ in persistAll() }
            .onChange(of: lobsterRollsEaten) { _, _ in persistAll() }
            .onChange(of: sunsetsWatched) { _, _ in persistAll() }
            .onChange(of: milesWalked) { _, _ in persistAll() }
            .onChange(of: favoriteBeach) { _, _ in persistAll() }
            .onChange(of: bestMeal) { _, _ in persistAll() }
            .onChange(of: bestRestaurant) { _, _ in persistAll() }
            .onChange(of: mostVisitedTown) { _, _ in persistAll() }
            .onChange(of: selectedStyle) { _, _ in persistAll() }
    }
}

// MARK: - Card Style Variant

enum TripCardStyle: String, CaseIterable, Identifiable {
    case ocean, sunset, sandy, classic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ocean: return "Ocean"
        case .sunset: return "Sunset"
        case .sandy: return "Sandy"
        case .classic: return "Classic"
        }
    }

    var icon: String {
        switch self {
        case .ocean: return "water.waves"
        case .sunset: return "sunset.fill"
        case .sandy: return "beach.umbrella.fill"
        case .classic: return "flag.fill"
        }
    }

    var backgroundGradient: LinearGradient {
        switch self {
        case .ocean:
            return LinearGradient(
                colors: [Color.capeCod.oceanBlue, Color.capeCod.deepNavy],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sunset:
            return LinearGradient(
                colors: [Color(hex: 0xE87040), Color(hex: 0xC94080), Color(hex: 0x6B2FA0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sandy:
            return LinearGradient(
                colors: [Color(hex: 0xD4A55A), Color(hex: 0xB8860B), Color(hex: 0x8B6914)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .classic:
            return LinearGradient(
                colors: [Color(hex: 0xF8F6F2), Color(hex: 0xEDE8E0)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    var primaryTextColor: Color {
        switch self {
        case .classic: return Color.capeCod.deepNavy
        default: return .white
        }
    }

    var secondaryTextColor: Color {
        switch self {
        case .classic: return Color.capeCod.oceanBlue
        default: return .white.opacity(0.8)
        }
    }

    var accentColor: Color {
        switch self {
        case .ocean: return Color.capeCod.seafoam
        case .sunset: return Color(hex: 0xFFD700)
        case .sandy: return Color(hex: 0xFFF8DC)
        case .classic: return Color.capeCod.sunsetOrange
        }
    }

    var dividerColor: Color {
        switch self {
        case .classic: return Color.capeCod.deepNavy.opacity(0.15)
        default: return .white.opacity(0.2)
        }
    }

    var chipBackground: Color {
        switch self {
        case .classic: return Color.capeCod.oceanBlue.opacity(0.08)
        default: return .white.opacity(0.15)
        }
    }
}

// MARK: - Trip Summary Persistence

private enum TripSummaryDefaults {
    static let prefix = "tripSummary."

    static func save(_ value: String, for key: String) {
        UserDefaults.standard.set(value, forKey: prefix + key)
    }

    static func save(_ value: Int, for key: String) {
        UserDefaults.standard.set(value, forKey: prefix + key)
    }

    static func save(_ value: Double, for key: String) {
        UserDefaults.standard.set(value, forKey: prefix + key)
    }

    static func save(_ value: Date, for key: String) {
        UserDefaults.standard.set(value.timeIntervalSince1970, forKey: prefix + key)
    }

    static func string(for key: String) -> String {
        UserDefaults.standard.string(forKey: prefix + key) ?? ""
    }

    static func int(for key: String) -> Int {
        UserDefaults.standard.integer(forKey: prefix + key)
    }

    static func double(for key: String) -> Double {
        UserDefaults.standard.double(forKey: prefix + key)
    }

    static func date(for key: String) -> Date {
        let interval = UserDefaults.standard.double(forKey: prefix + key)
        return interval > 0 ? Date(timeIntervalSince1970: interval) : .now
    }
}

// MARK: - Trip Summary View

struct TripSummaryView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: Trip Setup
    @State private var familyName: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var numberOfTravelers: Int

    // MARK: Auto-tracked Stats
    @State private var bingoSquares: Int = 0
    @State private var placesVisited: Int = 0
    @State private var explorerLevel: String = ""

    // MARK: Manual Stats
    @State private var beachesVisited: Int
    @State private var townsExplored: Int
    @State private var lobsterRollsEaten: Int
    @State private var sunsetsWatched: Int
    @State private var milesWalked: String
    @State private var favoriteBeach: String
    @State private var bestMeal: String
    @State private var bestRestaurant: String
    @State private var mostVisitedTown: String

    // MARK: UI State
    @State private var selectedStyle: TripCardStyle
    @State private var showingShareSheet = false
    @State private var showingPreview = false
    @State private var renderedImage: UIImage?
    @State private var saveSuccessful = false
    @State private var currentSection = 0

    init() {
        _familyName = State(initialValue: TripSummaryDefaults.string(for: "familyName"))
        _startDate = State(initialValue: TripSummaryDefaults.date(for: "startDate"))
        _endDate = State(initialValue: TripSummaryDefaults.date(for: "endDate"))
        _numberOfTravelers = State(initialValue: max(TripSummaryDefaults.int(for: "travelers"), 1))
        _beachesVisited = State(initialValue: TripSummaryDefaults.int(for: "beaches"))
        _townsExplored = State(initialValue: TripSummaryDefaults.int(for: "towns"))
        _lobsterRollsEaten = State(initialValue: TripSummaryDefaults.int(for: "lobsterRolls"))
        _sunsetsWatched = State(initialValue: TripSummaryDefaults.int(for: "sunsets"))
        _milesWalked = State(initialValue: TripSummaryDefaults.string(for: "miles"))
        _favoriteBeach = State(initialValue: TripSummaryDefaults.string(for: "favoriteBeach"))
        _bestMeal = State(initialValue: TripSummaryDefaults.string(for: "bestMeal"))
        _bestRestaurant = State(initialValue: TripSummaryDefaults.string(for: "bestRestaurant"))
        _mostVisitedTown = State(initialValue: TripSummaryDefaults.string(for: "mostVisitedTown"))
        _selectedStyle = State(initialValue: TripCardStyle(rawValue: TripSummaryDefaults.string(for: "cardStyle")) ?? .ocean)
    }

    // MARK: - Computed Properties

    private var tripDays: Int {
        max(Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0, 0)
    }

    private var seasonName: String {
        let month = Calendar.current.component(.month, from: startDate)
        switch month {
        case 3...5: return "Spring"
        case 6...8: return "Summer"
        case 9...11: return "Fall"
        default: return "Winter"
        }
    }

    private var tripYear: String {
        String(Calendar.current.component(.year, from: startDate))
    }

    private var shareTextContent: String {
        var lines: [String] = []
        lines.append("Our Cape Cod \(seasonName) \(tripYear)")
        if !familyName.isEmpty {
            lines.append(familyName)
        }
        lines.append("")
        lines.append("\(tripDays) Days | \(beachesVisited) Beaches | \(townsExplored) Towns | \(bingoSquares) Bingo Squares")
        lines.append("")
        if !favoriteBeach.isEmpty {
            lines.append("Favorite Beach: \(favoriteBeach)")
        }
        if !bestMeal.isEmpty {
            let restaurant = bestRestaurant.isEmpty ? "" : " at \(bestRestaurant)"
            lines.append("Best Meal: \(bestMeal)\(restaurant)")
        }
        if !mostVisitedTown.isEmpty {
            lines.append("Most Visited Town: \(mostVisitedTown)")
        }
        lines.append("")
        lines.append("\(lobsterRollsEaten) Lobster Rolls | \(sunsetsWatched) Sunsets | \(milesWalked.isEmpty ? "0" : milesWalked) Miles")
        lines.append("")
        lines.append("Made with Hey Cape Cod")
        lines.append("heycapecod.app")
        return lines.joined(separator: "\n")
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            mainScrollContent
                .background(Color.capeCod.background)
                .navigationTitle("Trip Summary")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { closeToolbar }
                .onAppear { loadAutoTrackedStats() }
                .overlay { saveOverlay }
                .modifier(PersistOnChangeModifier(
                    familyName: familyName, startDate: startDate, endDate: endDate,
                    numberOfTravelers: numberOfTravelers, beachesVisited: beachesVisited,
                    townsExplored: townsExplored, lobsterRollsEaten: lobsterRollsEaten,
                    sunsetsWatched: sunsetsWatched, milesWalked: milesWalked,
                    favoriteBeach: favoriteBeach, bestMeal: bestMeal,
                    bestRestaurant: bestRestaurant, mostVisitedTown: mostVisitedTown,
                    selectedStyle: selectedStyle, persistAll: persistAll
                ))
        }
    }

    private var mainScrollContent: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                tripSetupSection.staggered(index: 0)
                trackedStatsSection.staggered(index: 1)
                manualStatsSection.staggered(index: 2)
                highlightsSection.staggered(index: 3)
                cardStyleSection.staggered(index: 4)
                cardPreviewSection.staggered(index: 5)
                shareActionsSection.staggered(index: 6)
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
    }

    @ToolbarContentBuilder
    private var closeToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Close") {
                persistAll()
                dismiss()
            }
            .foregroundStyle(Color.capeCod.oceanBlue)
        }
    }

    @ViewBuilder
    private var saveOverlay: some View {
        if saveSuccessful {
            savedConfirmationOverlay
        }
    }

    // MARK: - Trip Setup Section

    private var tripSetupSection: some View {
        VStack(spacing: CodSpacing.md) {
            sectionHeader(title: "Trip Details", icon: "airplane.departure")

            VStack(spacing: CodSpacing.sm) {
                inputRow(label: "Family / Group Name") {
                    TextField("The Benson Family", text: $familyName)
                        .textFieldStyle(.plain)
                        .codTextStyle(.body)
                }

                Divider().foregroundStyle(Color.capeCod.cardBorder)

                inputRow(label: "Trip Start") {
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .labelsHidden()
                        .tint(Color.capeCod.oceanBlue)
                }

                Divider().foregroundStyle(Color.capeCod.cardBorder)

                inputRow(label: "Trip End") {
                    DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                        .labelsHidden()
                        .tint(Color.capeCod.oceanBlue)
                }

                Divider().foregroundStyle(Color.capeCod.cardBorder)

                inputRow(label: "Travelers") {
                    Stepper("\(numberOfTravelers)", value: $numberOfTravelers, in: 1...20)
                        .codTextStyle(.body)
                }
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
    }

    // MARK: - Auto-Tracked Stats Section

    private var trackedStatsSection: some View {
        VStack(spacing: CodSpacing.md) {
            sectionHeader(title: "Auto-Tracked Stats", icon: "chart.bar.fill")

            HStack(spacing: CodSpacing.md) {
                statChip(value: "\(bingoSquares)", label: "Bingo", icon: "checkmark.square.fill", color: Color.capeCod.sunsetOrange)
                statChip(value: "\(placesVisited)", label: "Places", icon: "mappin.circle.fill", color: Color.capeCod.oceanBlue)
                statChip(value: explorerLevel.isEmpty ? "New" : explorerLevel, label: "Level", icon: "star.fill", color: Color.capeCod.sandbarYellow)
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()

            Text("Pulled from your Bingo and Passport activity")
                .codTextStyle(.caption)
        }
    }

    // MARK: - Manual Stats Section

    private var manualStatsSection: some View {
        VStack(spacing: CodSpacing.md) {
            sectionHeader(title: "Your Stats", icon: "list.bullet.clipboard.fill")

            VStack(spacing: CodSpacing.sm) {
                stepperRow(label: "Beaches Visited", icon: "water.waves", value: $beachesVisited, range: 0...20)

                Divider().foregroundStyle(Color.capeCod.cardBorder)

                stepperRow(label: "Towns Explored", icon: "building.2.fill", value: $townsExplored, range: 0...15)

                Divider().foregroundStyle(Color.capeCod.cardBorder)

                stepperRow(label: "Lobster Rolls Eaten", icon: "fish.fill", value: $lobsterRollsEaten, range: 0...50)

                Divider().foregroundStyle(Color.capeCod.cardBorder)

                stepperRow(label: "Sunsets Watched", icon: "sunset.fill", value: $sunsetsWatched, range: 0...30)

                Divider().foregroundStyle(Color.capeCod.cardBorder)

                inputRow(label: "Miles Walked") {
                    TextField("0.0", text: $milesWalked)
                        .textFieldStyle(.plain)
                        .keyboardType(.decimalPad)
                        .codTextStyle(.body)
                        .multilineTextAlignment(.trailing)
                }
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
    }

    // MARK: - Highlights Section

    private var highlightsSection: some View {
        VStack(spacing: CodSpacing.md) {
            sectionHeader(title: "Highlights", icon: "sparkles")

            VStack(spacing: CodSpacing.sm) {
                inputRow(label: "Favorite Beach") {
                    TextField("Nauset Light Beach", text: $favoriteBeach)
                        .textFieldStyle(.plain)
                        .codTextStyle(.body)
                        .multilineTextAlignment(.trailing)
                }

                Divider().foregroundStyle(Color.capeCod.cardBorder)

                inputRow(label: "Best Meal") {
                    TextField("Lobster mac & cheese", text: $bestMeal)
                        .textFieldStyle(.plain)
                        .codTextStyle(.body)
                        .multilineTextAlignment(.trailing)
                }

                Divider().foregroundStyle(Color.capeCod.cardBorder)

                inputRow(label: "Restaurant") {
                    TextField("The Lobster Pot", text: $bestRestaurant)
                        .textFieldStyle(.plain)
                        .codTextStyle(.body)
                        .multilineTextAlignment(.trailing)
                }

                Divider().foregroundStyle(Color.capeCod.cardBorder)

                inputRow(label: "Most Visited Town") {
                    TextField("Provincetown", text: $mostVisitedTown)
                        .textFieldStyle(.plain)
                        .codTextStyle(.body)
                        .multilineTextAlignment(.trailing)
                }
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
    }

    // MARK: - Card Style Section

    private var cardStyleSection: some View {
        VStack(spacing: CodSpacing.md) {
            sectionHeader(title: "Card Style", icon: "paintpalette.fill")

            HStack(spacing: CodSpacing.sm) {
                ForEach(TripCardStyle.allCases) { style in
                    Button {
                        withAnimation(CodAnimation.spring) {
                            selectedStyle = style
                        }
                        CodHaptic.selection()
                    } label: {
                        VStack(spacing: CodSpacing.xs) {
                            ZStack {
                                RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous)
                                    .fill(style.backgroundGradient)
                                    .frame(height: 48)

                                Image(systemName: style.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(style.primaryTextColor)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous)
                                    .strokeBorder(
                                        selectedStyle == style ? Color.capeCod.oceanBlue : .clear,
                                        lineWidth: 2.5
                                    )
                            )

                            Text(style.displayName)
                                .font(.system(size: 11, weight: selectedStyle == style ? .bold : .medium))
                                .foregroundStyle(
                                    selectedStyle == style ? Color.capeCod.oceanBlue : Color.capeCod.textSecondary
                                )
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
    }

    // MARK: - Card Preview Section

    private var cardPreviewSection: some View {
        VStack(spacing: CodSpacing.md) {
            sectionHeader(title: "Preview", icon: "eye.fill")

            summaryCardView
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.featured, style: .continuous))
                .codShadow(.elevated)
        }
    }

    // MARK: - Share Actions Section

    private var shareActionsSection: some View {
        VStack(spacing: CodSpacing.sm) {
            // Share as Image
            Button {
                shareAsImage()
            } label: {
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Share as Image")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
                .foregroundStyle(Color.capeCod.textOnPrimary)
                .background(Color.capeCod.sunsetOrange)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
            }
            .buttonStyle(CodButtonPressStyle(variant: .accent))

            // Share as Text
            ShareLink(item: shareTextContent) {
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Share as Text")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
                .foregroundStyle(Color.capeCod.oceanBlue)
                .background(Color.capeCod.oceanBlue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
            }
            .buttonStyle(CodButtonPressStyle(variant: .primary))

            // Save to Photos
            Button {
                saveToPhotos()
            } label: {
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Save to Photos")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
                .foregroundStyle(Color.capeCod.textPrimary)
                .background(Color.capeCod.surface)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous)
                        .strokeBorder(Color.capeCod.cardBorder, lineWidth: 1)
                )
            }
            .buttonStyle(CodButtonPressStyle(variant: .primary))
        }
    }

    // MARK: - Summary Card (The Shareable Rendered View)

    @ViewBuilder
    private var summaryCardView: some View {
        let style = selectedStyle

        VStack(spacing: 0) {
            // Top decorative wave
            waveDecoration(style: style)
                .frame(height: 32)
                .clipped()

            VStack(spacing: 20) {
                // Header
                VStack(spacing: 6) {
                    Text("Our Cape Cod \(seasonName) \(tripYear)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .tracking(-0.3)
                        .foregroundStyle(style.primaryTextColor)

                    if !familyName.isEmpty {
                        Text(familyName)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(style.secondaryTextColor)
                    }
                }
                .padding(.top, 4)

                // Stat Grid
                cardStatGrid(style: style)

                // Divider
                Rectangle()
                    .fill(style.dividerColor)
                    .frame(height: 1)
                    .padding(.horizontal, 16)

                // Highlights
                if hasHighlights {
                    cardHighlightsSection(style: style)
                }

                // Fun Stats
                if hasFunStats {
                    cardFunStats(style: style)
                }

                // Bottom decorative wave
                waveDecorationBottom(style: style)
                    .frame(height: 20)
                    .clipped()

                // Footer
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "wave.3.right")
                            .font(.system(size: 10, weight: .medium))
                        Text("Made with Hey Cape Cod")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(style.secondaryTextColor)

                    Text("heycapecod.app")
                        .font(.system(size: 9, weight: .regular))
                        .foregroundStyle(style.secondaryTextColor.opacity(0.7))
                }
                .padding(.bottom, 4)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(style.backgroundGradient)
    }

    // MARK: - Card Components

    private func cardStatGrid(style: TripCardStyle) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 12
        ) {
            cardStatItem(value: "\(tripDays)", label: "Days", icon: "calendar", style: style)
            cardStatItem(value: "\(beachesVisited)", label: "Beaches", icon: "water.waves", style: style)
            cardStatItem(value: "\(townsExplored)", label: "Towns", icon: "building.2.fill", style: style)
            cardStatItem(value: "\(bingoSquares)", label: "Bingo", icon: "checkmark.square.fill", style: style)
        }
    }

    private func cardStatItem(value: String, label: String, icon: String, style: TripCardStyle) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(style.accentColor)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(style.primaryTextColor)
                .monospacedDigit()

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(style.secondaryTextColor)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(style.chipBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
    }

    private func cardHighlightsSection(style: TripCardStyle) -> some View {
        VStack(spacing: 10) {
            Text("HIGHLIGHTS")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(style.accentColor)

            VStack(spacing: 8) {
                if !favoriteBeach.isEmpty {
                    cardHighlightRow(icon: "sun.max.fill", label: "Favorite Beach", value: favoriteBeach, style: style)
                }
                if !bestMeal.isEmpty {
                    let mealText = bestRestaurant.isEmpty ? bestMeal : "\(bestMeal) at \(bestRestaurant)"
                    cardHighlightRow(icon: "fork.knife", label: "Best Meal", value: mealText, style: style)
                }
                if !mostVisitedTown.isEmpty {
                    cardHighlightRow(icon: "mappin.circle.fill", label: "Most Visited Town", value: mostVisitedTown, style: style)
                }
            }
        }
    }

    private func cardHighlightRow(icon: String, label: String, value: String, style: TripCardStyle) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(style.accentColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(style.secondaryTextColor)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(style.primaryTextColor)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(style.chipBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
    }

    private func cardFunStats(style: TripCardStyle) -> some View {
        HStack(spacing: 0) {
            if lobsterRollsEaten > 0 {
                cardFunStatItem(value: "\(lobsterRollsEaten)", label: "Lobster\nRolls", icon: "fish.fill", style: style)
            }
            if sunsetsWatched > 0 {
                cardFunStatItem(value: "\(sunsetsWatched)", label: "Sunsets\nWatched", icon: "sunset.fill", style: style)
            }
            if !milesWalked.isEmpty && milesWalked != "0" {
                cardFunStatItem(value: milesWalked, label: "Miles\nWalked", icon: "figure.walk", style: style)
            }
        }
    }

    private func cardFunStatItem(value: String, label: String, icon: String, style: TripCardStyle) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(style.accentColor)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(style.primaryTextColor)

            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(style.secondaryTextColor)
                .multilineTextAlignment(.center)
                .textCase(.uppercase)
                .tracking(0.3)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Decorative Wave Elements

    private func waveDecoration(style: TripCardStyle) -> some View {
        Canvas { context, size in
            let waveColor = style.accentColor.opacity(0.15)
            var path = Path()
            let wavelength = size.width / 3
            let amplitude: CGFloat = 8

            path.move(to: CGPoint(x: 0, y: size.height))
            for x in stride(from: 0, through: size.width, by: 2) {
                let relativeX = x / wavelength
                let y = size.height - amplitude * sin(relativeX * .pi * 2) - amplitude - 4
                path.addLine(to: CGPoint(x: x, y: y))
            }
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.closeSubpath()

            context.fill(path, with: .color(waveColor))

            // Second wave
            var path2 = Path()
            path2.move(to: CGPoint(x: 0, y: size.height))
            for x in stride(from: 0, through: size.width, by: 2) {
                let relativeX = x / wavelength
                let y = size.height - amplitude * 0.6 * sin(relativeX * .pi * 2 + 1.5) - amplitude * 0.5 - 2
                path2.addLine(to: CGPoint(x: x, y: y))
            }
            path2.addLine(to: CGPoint(x: size.width, y: size.height))
            path2.closeSubpath()

            context.fill(path2, with: .color(waveColor.opacity(0.7)))
        }
    }

    private func waveDecorationBottom(style: TripCardStyle) -> some View {
        Canvas { context, size in
            let waveColor = style.accentColor.opacity(0.12)
            var path = Path()
            let wavelength = size.width / 2.5
            let amplitude: CGFloat = 5

            path.move(to: CGPoint(x: 0, y: 0))
            for x in stride(from: 0, through: size.width, by: 2) {
                let relativeX = x / wavelength
                let y = amplitude * sin(relativeX * .pi * 2) + amplitude + 2
                path.addLine(to: CGPoint(x: x, y: y))
            }
            path.addLine(to: CGPoint(x: size.width, y: 0))
            path.closeSubpath()

            context.fill(path, with: .color(waveColor))
        }
    }

    // MARK: - Saved Confirmation Overlay

    private var savedConfirmationOverlay: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(Color.capeCod.seafoam)

            Text("Saved to Photos")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(CodSpacing.xl)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.featured, style: .continuous))
        .transition(.codScale)
    }

    // MARK: - Reusable Input Components

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.capeCod.oceanBlue)

            Text(title)
                .codTextStyle(.sectionTitle)

            Spacer()
        }
    }

    private func inputRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)

            Spacer()

            content()
        }
    }

    private func stepperRow(label: String, icon: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.capeCod.oceanBlue)
                .frame(width: 20)

            Text(label)
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)

            Spacer()

            Stepper("\(value.wrappedValue)", value: value, in: range) { editing in
                if !editing {
                    CodHaptic.light()
                }
            }
            .codTextStyle(.body)
        }
    }

    private func statChip(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: CodSpacing.xs) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
            }

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.capeCod.textPrimary)
                .monospacedDigit()

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.capeCod.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Computed Helpers

    private var hasHighlights: Bool {
        !favoriteBeach.isEmpty || !bestMeal.isEmpty || !mostVisitedTown.isEmpty
    }

    private var hasFunStats: Bool {
        lobsterRollsEaten > 0 || sunsetsWatched > 0 || (!milesWalked.isEmpty && milesWalked != "0")
    }

    // MARK: - Actions

    private func loadAutoTrackedStats() {
        // Bingo squares from BingoPersistence
        if let completedItems = UserDefaults.standard.array(forKey: "cape_cod_bingo_completed") as? [String] {
            bingoSquares = completedItems.count
        } else if let bingoData = UserDefaults.standard.object(forKey: "bingo.completedItems") {
            if let count = bingoData as? Int {
                bingoSquares = count
            } else if let items = bingoData as? [String] {
                bingoSquares = items.count
            }
        }

        // Passport check-ins
        placesVisited = UserDefaults.standard.integer(forKey: "passport.totalCheckins")

        // Explorer level
        explorerLevel = UserDefaults.standard.string(forKey: "passport.currentLevel") ?? ""
    }

    private func persistAll() {
        TripSummaryDefaults.save(familyName, for: "familyName")
        TripSummaryDefaults.save(startDate, for: "startDate")
        TripSummaryDefaults.save(endDate, for: "endDate")
        TripSummaryDefaults.save(numberOfTravelers, for: "travelers")
        TripSummaryDefaults.save(beachesVisited, for: "beaches")
        TripSummaryDefaults.save(townsExplored, for: "towns")
        TripSummaryDefaults.save(lobsterRollsEaten, for: "lobsterRolls")
        TripSummaryDefaults.save(sunsetsWatched, for: "sunsets")
        TripSummaryDefaults.save(milesWalked, for: "miles")
        TripSummaryDefaults.save(favoriteBeach, for: "favoriteBeach")
        TripSummaryDefaults.save(bestMeal, for: "bestMeal")
        TripSummaryDefaults.save(bestRestaurant, for: "bestRestaurant")
        TripSummaryDefaults.save(mostVisitedTown, for: "mostVisitedTown")
        TripSummaryDefaults.save(selectedStyle.rawValue, for: "cardStyle")
    }

    @MainActor
    private func renderCardImage() -> UIImage? {
        let renderer = ImageRenderer(content:
            summaryCardView
                .frame(width: 390)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.featured, style: .continuous))
        )
        renderer.scale = 3.0
        return renderer.uiImage
    }

    private func shareAsImage() {
        CodHaptic.selection()
        guard let image = renderCardImage() else { return }

        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = topVC.view
                popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            topVC.present(activityVC, animated: true)
        }
    }

    private func saveToPhotos() {
        CodHaptic.selection()
        guard let image = renderCardImage() else { return }

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

        withAnimation(CodAnimation.spring) {
            saveSuccessful = true
        }
        CodHaptic.success()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(CodAnimation.spring) {
                saveSuccessful = false
            }
        }
    }
}

// MARK: - Preview

#Preview("Trip Summary") {
    TripSummaryView()
}

#Preview("Trip Summary - Filled") {
    TripSummaryView()
        .onAppear {
            let prefix = "tripSummary."
            UserDefaults.standard.set("The Benson Family", forKey: prefix + "familyName")
            UserDefaults.standard.set(5, forKey: prefix + "beaches")
            UserDefaults.standard.set(7, forKey: prefix + "towns")
            UserDefaults.standard.set(12, forKey: prefix + "lobsterRolls")
            UserDefaults.standard.set(4, forKey: prefix + "sunsets")
            UserDefaults.standard.set("23.5", forKey: prefix + "miles")
            UserDefaults.standard.set("Nauset Light Beach", forKey: prefix + "favoriteBeach")
            UserDefaults.standard.set("Lobster mac & cheese", forKey: prefix + "bestMeal")
            UserDefaults.standard.set("The Lobster Pot", forKey: prefix + "bestRestaurant")
            UserDefaults.standard.set("Provincetown", forKey: prefix + "mostVisitedTown")
        }
}
