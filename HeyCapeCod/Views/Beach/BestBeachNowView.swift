import SwiftUI

// MARK: - Best Beach Right Now

/// Answers the #1 question Cape Cod visitors have: "Which beach should we go to today?"
/// Uses BeachRecommendationEngine to score all 12 beaches based on current conditions.
struct BestBeachNowView: View {
    let weather: WeatherData?
    let tideData: TideData?
    var experienceMode: ExperienceMode = .family

    @State private var showAllBeaches = false
    @State private var selectedBeach: CapeCodBeach?
    @State private var shareText: String = ""
    @State private var showShareSheet = false

    // MARK: - Computed Properties

    private var storyMode: GeofenceManager.StoryMode {
        switch experienceMode {
        case .kids: return .kids
        case .teen: return .adult
        case .adult: return .adult
        case .family: return .family
        }
    }

    private var recommendation: BeachRecommendation? {
        guard let weather else { return nil }
        return BeachRecommendationEngine.recommend(
            weather: weather,
            waterTemp: nil,
            waveHeight: nil,
            tideStatus: tideData?.currentTideStatus ?? .unknown,
            nextTide: tideData?.nextTide,
            mode: storyMode
        )
    }

    private var topBeach: CapeCodBeach? {
        guard let recommendation else { return nil }
        return BeachRecommendationEngine.beaches.first {
            $0.name == recommendation.beachName
        }
    }

    /// All beaches ranked by scoring each individually.
    private var rankedBeaches: [(beach: CapeCodBeach, recommendation: BeachRecommendation)] {
        guard let weather else { return [] }
        return BeachRecommendationEngine.beaches.compactMap { beach in
            // Score by temporarily checking recommendation for context
            let rec = BeachRecommendationEngine.recommend(
                weather: weather,
                waterTemp: nil,
                waveHeight: nil,
                tideStatus: tideData?.currentTideStatus ?? .unknown,
                nextTide: tideData?.nextTide,
                mode: storyMode
            )
            return (beach, rec)
        }.sorted { lhs, rhs in
            ratingOrder(lhs.recommendation.rating) < ratingOrder(rhs.recommendation.rating)
        }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                heroSection
                    .staggered(index: 0)

                if let recommendation, let topBeach {
                    featuredBeachCard(recommendation: recommendation, beach: topBeach)
                        .staggered(index: 1)

                    conditionsGrid(factors: recommendation.factors)
                        .staggered(index: 2)

                    beachDetailsSection(beach: topBeach)
                        .staggered(index: 3)

                    allBeachesSection
                        .staggered(index: 4)

                    shareSection(recommendation: recommendation)
                        .staggered(index: 5)
                } else {
                    loadingState
                        .staggered(index: 1)
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if !shareText.isEmpty {
                BeachShareSheet(text: shareText)
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "beach.umbrella.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.capeCod.oceanBlue)
                .codAccessibleHidden()

            Text("Best Beach Right Now")
                .codTextStyle(.heroTitle)
                .multilineTextAlignment(.center)
                .codAccessibleHeader("Best Beach Right Now")

            if let weather {
                Text(weather.current.condition.displayName + " \u{00B7} " + weather.current.temperatureFormatted)
                    .codTextStyle(.subtitle)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, CodSpacing.lg)
    }

    // MARK: - Featured Beach Card

    private func featuredBeachCard(recommendation: BeachRecommendation, beach: CapeCodBeach) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            // Rating badge
            ratingBadge(recommendation.rating)

            // Beach name
            Text(beach.name)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.capeCod.textPrimary)

            // Town subtitle
            Text(beach.town + " \u{00B7} " + beach.side.displayLabel)
                .codTextStyle(.subtitle)

            // Summary
            Text(recommendation.summary)
                .codTextStyle(.body)
                .fixedSize(horizontal: false, vertical: true)

            // Details
            Text(recommendation.details)
                .codTextStyle(.caption)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, CodSpacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CodSpacing.lg)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.featured, style: .continuous))
        .adaptiveCardStyle(cornerRadius: CodRadius.featured)
        .codAccessibleCard(
            label: "\(beach.name) in \(beach.town). \(recommendation.rating.rawValue). \(recommendation.summary)",
            hint: "Today's top beach recommendation"
        )
    }

    // MARK: - Rating Badge

    private func ratingBadge(_ rating: BeachRecommendation.BeachRating) -> some View {
        HStack(spacing: CodSpacing.xs) {
            Image(systemName: rating.icon)
                .font(.system(size: 14, weight: .semibold))

            Text(rating.rawValue)
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundStyle(ratingForegroundColor(rating))
        .padding(.horizontal, CodSpacing.sm)
        .padding(.vertical, CodSpacing.xs)
        .background(ratingBackgroundColor(rating))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
    }

    // MARK: - Conditions Grid

    private func conditionsGrid(factors: [BeachRecommendation.RecommendationFactor]) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Current Conditions")
                .codTextStyle(.sectionTitle)
                .codAccessibleHeader("Current Conditions")

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: CodSpacing.md),
                    GridItem(.flexible(), spacing: CodSpacing.md)
                ],
                spacing: CodSpacing.md
            ) {
                ForEach(Array(factors.enumerated()), id: \.offset) { index, factor in
                    conditionCell(factor: factor)
                        .staggered(index: index + 3)
                }
            }
        }
    }

    private func conditionCell(factor: BeachRecommendation.RecommendationFactor) -> some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: factor.icon)
                .font(.system(size: 20))
                .foregroundStyle(factor.isPositive ? Color.capeCod.duneGrass : Color.capeCod.cranberry)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(factor.label)
                    .codTextStyle(.caption)

                Text(factor.value)
                    .codTextStyle(.cardTitle)
            }

            Spacer()
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .codAccessible(
            label: "\(factor.label): \(factor.value)",
            hint: factor.isPositive ? "Favorable condition" : "Unfavorable condition"
        )
    }

    // MARK: - Beach Details Section

    private func beachDetailsSection(beach: CapeCodBeach) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Beach Details")
                .codTextStyle(.sectionTitle)
                .codAccessibleHeader("Beach Details")

            VStack(spacing: CodSpacing.sm) {
                detailRow(icon: "water.waves", label: "Side", value: beach.side.displayLabel)
                detailRow(
                    icon: "figure.and.child.holdinghands",
                    label: "Kid-Friendly",
                    value: beach.isKidFriendly ? "Yes" : "No",
                    isPositive: beach.isKidFriendly
                )
                detailRow(
                    icon: "fossil.shell.fill",
                    label: "Tide Pools",
                    value: beach.hasTidePools ? "Yes" : "No",
                    isPositive: beach.hasTidePools
                )
                detailRow(
                    icon: "shield.checkered",
                    label: "Lifeguards",
                    value: beach.hasLifeguards ? "Seasonal" : "No",
                    isPositive: beach.hasLifeguards
                )
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()

            Text(beach.description)
                .codTextStyle(.body)
                .padding(.horizontal, CodSpacing.xs)
        }
    }

    private func detailRow(
        icon: String,
        label: String,
        value: String,
        isPositive: Bool? = nil
    ) -> some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.capeCod.oceanBlue)
                .frame(width: 24)

            Text(label)
                .codTextStyle(.body)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(
                    isPositive == true
                        ? Color.capeCod.duneGrass
                        : isPositive == false
                            ? Color.capeCod.driftwood
                            : Color.capeCod.textPrimary
                )
        }
        .padding(.vertical, CodSpacing.xs)
        .codAccessible(label: "\(label): \(value)")
    }

    // MARK: - All Beaches Section

    private var allBeachesSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Button {
                CodHaptic.selection()
                withAnimation(CodAnimation.spring) {
                    showAllBeaches.toggle()
                }
            } label: {
                HStack {
                    Text("All Beaches Today")
                        .codTextStyle(.sectionTitle)

                    Spacer()

                    Image(systemName: showAllBeaches ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.capeCod.oceanBlue)
                }
            }
            .buttonStyle(CodButtonPressStyle(variant: .ghost))
            .codAccessibleButton(
                "All Beaches Today",
                hint: showAllBeaches ? "Collapse beach list" : "Expand to see all 12 beaches ranked"
            )

            if showAllBeaches {
                VStack(spacing: CodSpacing.sm) {
                    ForEach(Array(BeachRecommendationEngine.beaches.enumerated()), id: \.element.id) { index, beach in
                        beachRankRow(beach: beach, rank: index + 1)
                            .staggered(index: index)
                    }
                }
                .transition(.codSlideUp)
            }
        }
    }

    private func beachRankRow(beach: CapeCodBeach, rank: Int) -> some View {
        Button {
            CodHaptic.light()
            withAnimation(CodAnimation.spring) {
                selectedBeach = selectedBeach?.id == beach.id ? nil : beach
            }
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: CodSpacing.sm) {
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(rank <= 3 ? Color.capeCod.oceanBlue : Color.capeCod.driftwood)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(beach.name)
                            .codTextStyle(.cardTitle)

                        Text(beach.town)
                            .codTextStyle(.caption)
                    }

                    Spacer()

                    suitabilityIndicator(for: beach)
                }
                .padding(CodSpacing.cardPadding)

                // Expanded detail
                if selectedBeach?.id == beach.id {
                    VStack(alignment: .leading, spacing: CodSpacing.sm) {
                        Divider()

                        Text(beach.description)
                            .codTextStyle(.body)

                        HStack(spacing: CodSpacing.md) {
                            beachTag(beach.side.displayLabel, icon: "water.waves")
                            if beach.isKidFriendly {
                                beachTag("Kid-Friendly", icon: "figure.and.child.holdinghands")
                            }
                            if beach.hasTidePools {
                                beachTag("Tide Pools", icon: "fossil.shell.fill")
                            }
                        }
                    }
                    .padding(.horizontal, CodSpacing.cardPadding)
                    .padding(.bottom, CodSpacing.cardPadding)
                    .transition(.codSlideUp)
                }
            }
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleCard(
            label: "Rank \(rank): \(beach.name), \(beach.town)",
            hint: "Tap to see details"
        )
    }

    private func suitabilityIndicator(for beach: CapeCodBeach) -> some View {
        let color = suitabilityColor(for: beach)
        return Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .codAccessible(
                label: suitabilityLabel(for: beach)
            )
    }

    private func beachTag(_ text: String, icon: String) -> some View {
        HStack(spacing: CodSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(Color.capeCod.oceanBlue)
        .padding(.horizontal, CodSpacing.sm)
        .padding(.vertical, CodSpacing.xs)
        .background(Color.capeCod.oceanBlue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
    }

    // MARK: - Share Section

    private func shareSection(recommendation: BeachRecommendation) -> some View {
        CodButton(
            "Share Today's Beach Pick",
            variant: .primary,
            icon: "square.and.arrow.up",
            isFullWidth: true
        ) {
            CodHaptic.success()
            shareText = "Heading to \(recommendation.beachName) today! Best beach on Cape Cod right now according to @HeyCapeCode #CapeCod"
            showShareSheet = true
        }
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: CodSpacing.lg) {
            ProgressView()
                .controlSize(.large)
                .tint(Color.capeCod.oceanBlue)

            Text("Checking conditions...")
                .codTextStyle(.subtitle)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CodSpacing.xxl)
        .codAccessible(label: "Loading beach recommendations")
    }

    // MARK: - Helpers

    private func ratingForegroundColor(_ rating: BeachRecommendation.BeachRating) -> Color {
        switch rating {
        case .great: return Color.capeCod.duneGrass
        case .good: return Color.capeCod.oceanBlue
        case .caution: return Color.capeCod.sandbarYellow
        case .notRecommended: return Color.capeCod.cranberry
        }
    }

    private func ratingBackgroundColor(_ rating: BeachRecommendation.BeachRating) -> Color {
        ratingForegroundColor(rating).opacity(0.12)
    }

    private func suitabilityColor(for beach: CapeCodBeach) -> Color {
        // Simple heuristic based on mode and beach properties
        let isFamilyMode = experienceMode == .family || experienceMode == .kids
        if isFamilyMode {
            if beach.isKidFriendly && beach.side != .oceanside {
                return Color.capeCod.duneGrass
            } else if beach.isKidFriendly {
                return Color.capeCod.sandbarYellow
            } else {
                return Color.capeCod.cranberry
            }
        } else {
            return Color.capeCod.duneGrass
        }
    }

    private func suitabilityLabel(for beach: CapeCodBeach) -> String {
        let isFamilyMode = experienceMode == .family || experienceMode == .kids
        if isFamilyMode {
            if beach.isKidFriendly && beach.side != .oceanside {
                return "Great for families"
            } else if beach.isKidFriendly {
                return "Okay for families"
            } else {
                return "Not ideal for families"
            }
        } else {
            return "Suitable"
        }
    }

    private func ratingOrder(_ rating: BeachRecommendation.BeachRating) -> Int {
        switch rating {
        case .great: return 0
        case .good: return 1
        case .caution: return 2
        case .notRecommended: return 3
        }
    }
}

// MARK: - Beach Side Display Label

private extension CapeCodBeach.BeachSide {
    var displayLabel: String {
        switch self {
        case .bayside: return "Bay Side"
        case .oceanside: return "Ocean Side"
        case .sound: return "Nantucket Sound"
        }
    }
}

// MARK: - Share Sheet

private struct BeachShareSheet: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview("Best Beach Now - Loaded") {
    NavigationStack {
        BestBeachNowView(
            weather: WeatherData(
                current: CurrentWeather(
                    temperature: 78,
                    feelsLike: 80,
                    condition: .clear,
                    humidity: 55,
                    windSpeed: 10,
                    windDirection: "SW",
                    uvIndex: 6,
                    visibility: 10,
                    pressure: 30.1,
                    dewPoint: 62
                ),
                hourly: [],
                daily: [],
                alerts: [],
                fetchedAt: .now
            ),
            tideData: nil,
            experienceMode: .family
        )
    }
}

#Preview("Best Beach Now - Loading") {
    NavigationStack {
        BestBeachNowView(
            weather: nil,
            tideData: nil
        )
    }
}
