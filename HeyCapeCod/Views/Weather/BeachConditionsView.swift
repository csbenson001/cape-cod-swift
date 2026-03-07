import SwiftUI

/// "Beach Report Card" — comprehensive beach conditions overview.
/// Shows water temp, waves, tides, UV, wind, shark alerts, lifeguard status,
/// and overall rating.
struct BeachConditionsView: View {
    let viewModel: WeatherViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.lg) {
                // Overall Rating Banner
                if let rec = viewModel.beachRecommendation {
                    overallRatingCard(rec)
                }

                // Conditions Grid
                conditionsGrid

                // Beach Recommendation
                if let rec = viewModel.beachRecommendation {
                    recommendationCard(rec)
                }

                // Shark Alert
                sharkAlertCard

                // Lifeguard Status
                lifeguardStatusCard

                // Sunscreen Reminder
                sunscreenReminder

                // Beach List
                beachListSection
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.xxl)
        }
        .background(Color.capeCod.background)
        .navigationTitle("Beach Conditions")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Overall Rating

    private func overallRatingCard(_ rec: BeachRecommendation) -> some View {
        VStack(spacing: CodSpacing.md) {
            Image(systemName: rec.rating.icon)
                .font(.system(size: 44))
                .foregroundStyle(ratingColor(rec.rating))

            Text(rec.rating.rawValue)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.capeCod.textPrimary)

            // Factor pills
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: CodSpacing.sm)], spacing: CodSpacing.sm) {
                ForEach(rec.factors, id: \.label) { factor in
                    HStack(spacing: 4) {
                        Image(systemName: factor.icon)
                            .font(.system(size: 10))
                        Text("\(factor.value)")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, CodSpacing.sm)
                    .padding(.vertical, CodSpacing.xs + 2)
                    .background(factor.isPositive ? Color.capeCod.duneGrass.opacity(0.12) : Color.capeCod.sandbarYellow.opacity(0.12))
                    .foregroundStyle(factor.isPositive ? Color.capeCod.duneGrass : Color.capeCod.sandbarYellow)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(CodSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(ratingColor(rec.rating).opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.featured))
        .codAccessibleGroup(label: "Beach rating: \(rec.rating.rawValue)")
    }

    // MARK: - Conditions Grid

    private var conditionsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CodSpacing.md) {
            // Water Temperature
            ConditionCard(
                icon: "water.waves",
                iconColor: Color.capeCod.oceanBlue,
                title: "Water Temp",
                value: viewModel.waterTempFormatted ?? "--",
                detail: waterTempDescription
            )

            // Wave Height
            ConditionCard(
                icon: "wind",
                iconColor: Color.capeCod.seafoam,
                title: "Waves",
                value: viewModel.waveHeightFormatted ?? "--",
                detail: waveDescription
            )

            // Current Tide
            ConditionCard(
                icon: viewModel.tideStatus.icon,
                iconColor: Color.capeCod.oceanBlue,
                title: "Tide",
                value: viewModel.tideStatus.displayName,
                detail: tideDescription
            )

            // UV Index
            ConditionCard(
                icon: "sun.max.fill",
                iconColor: uvColor,
                title: "UV Index",
                value: "\(viewModel.uvIndex)",
                detail: viewModel.uvDescription
            )

            // Wind
            ConditionCard(
                icon: "wind",
                iconColor: Color.capeCod.driftwood,
                title: "Wind",
                value: viewModel.windSummary,
                detail: windDescription
            )

            // Air Temperature
            ConditionCard(
                icon: "thermometer",
                iconColor: Color.capeCod.sunsetOrange,
                title: "Air Temp",
                value: viewModel.currentTemperature,
                detail: "Feels like \(viewModel.feelsLikeTemperature)"
            )
        }
    }

    // MARK: - Recommendation

    private func recommendationCard(_ rec: BeachRecommendation) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.capeCod.sandbarYellow)
                Text("Best Beach Right Now")
                    .codTextStyle(.cardTitle)
            }

            Text(rec.summary)
                .codTextStyle(.body)

            Text(rec.details)
                .codTextStyle(.caption)
        }
        .padding(CodSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .adaptiveCardStyle()
        .codAccessibleGroup(label: "Best Beach Right Now: \(rec.summary)")
    }

    // MARK: - Shark Alert

    private var sharkAlertCard: some View {
        // Seasonal shark advisory (June-October on outer Cape ocean beaches)
        let calendar = Calendar.current
        let month = calendar.component(.month, from: .now)
        let isSharkSeason = (6...10).contains(month)

        return VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(isSharkSeason ? Color.capeCod.cranberry : Color.capeCod.duneGrass)

                Text("Shark Advisory")
                    .codTextStyle(.cardTitle)

                Spacer()

                Text(isSharkSeason ? "Active Season" : "Low Season")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSharkSeason ? Color.capeCod.cranberry : Color.capeCod.duneGrass)
                    .padding(.horizontal, CodSpacing.sm)
                    .padding(.vertical, CodSpacing.xs)
                    .background((isSharkSeason ? Color.capeCod.cranberry : Color.capeCod.duneGrass).opacity(0.12))
                    .clipShape(Capsule())
            }

            if isSharkSeason {
                Text("Great white sharks are active along outer Cape ocean beaches (June-October). Avoid swimming near seals, stay in groups, and swim close to shore.")
                    .codTextStyle(.caption)
            } else {
                Text("Shark season typically runs June through October on outer Cape ocean beaches. Current risk is low.")
                    .codTextStyle(.caption)
            }

            Text("Source: Atlantic White Shark Conservancy")
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(Color.capeCod.driftwood)
        }
        .padding(CodSpacing.cardPadding)
        .background(isSharkSeason ? Color.capeCod.cranberry.opacity(0.06) : Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .adaptiveCardStyle()
        .codAccessibleGroup(label: "Shark Advisory: \(isSharkSeason ? "Active season, use caution on outer Cape ocean beaches" : "Low season, low risk")")
    }

    // MARK: - Lifeguard Status

    private var lifeguardStatusCard: some View {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: .now)
        let hour = calendar.component(.hour, from: .now)
        let isSummer = (6...9).contains(month)
        let isOnDuty = isSummer && (9...17).contains(hour)

        return VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "figure.open.water.swim")
                    .foregroundStyle(isOnDuty ? Color.capeCod.duneGrass : Color.capeCod.driftwood)

                Text("Lifeguards")
                    .codTextStyle(.cardTitle)

                Spacer()

                Text(isOnDuty ? "On Duty" : isSummer ? "Off Hours" : "Off Season")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isOnDuty ? Color.capeCod.duneGrass : Color.capeCod.driftwood)
                    .padding(.horizontal, CodSpacing.sm)
                    .padding(.vertical, CodSpacing.xs)
                    .background((isOnDuty ? Color.capeCod.duneGrass : Color.capeCod.driftwood).opacity(0.12))
                    .clipShape(Capsule())
            }

            if isSummer {
                Text("Most town beaches have lifeguards 9 AM - 5 PM daily, late June through Labor Day. National Seashore beaches have guards Memorial Day - Labor Day.")
                    .codTextStyle(.caption)
            } else {
                Text("Lifeguards are seasonal (late June - Labor Day). Swim at your own risk during off-season.")
                    .codTextStyle(.caption)
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .adaptiveCardStyle()
        .codAccessibleGroup(label: "Lifeguards: \(isOnDuty ? "On duty" : isSummer ? "Off hours" : "Off season")")
    }

    // MARK: - Sunscreen Reminder

    private var sunscreenReminder: some View {
        Group {
            if viewModel.uvIndex >= 3 {
                HStack(spacing: CodSpacing.md) {
                    Image(systemName: "sun.max.trianglebadge.exclamationmark.fill")
                        .font(.title2)
                        .foregroundStyle(uvColor)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sunscreen Reminder")
                            .codTextStyle(.cardTitle)
                        Text(sunscreenMessage)
                            .codTextStyle(.caption)
                    }
                }
                .padding(CodSpacing.cardPadding)
                .background(uvColor.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
                .codAccessibleGroup(label: "Sunscreen Reminder: \(sunscreenMessage)")
            }
        }
    }

    // MARK: - Beach List

    private var beachListSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Cape Cod Beaches")
                .codTextStyle(.sectionTitle)

            ForEach(BeachRecommendationEngine.beaches, id: \.id) { beach in
                HStack(spacing: CodSpacing.md) {
                    Image(systemName: beachSideIcon(beach.side))
                        .font(.title3)
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(beach.name)
                            .codTextStyle(.cardTitle)
                        HStack(spacing: CodSpacing.sm) {
                            Text(beach.town)
                                .codTextStyle(.caption)
                            if beach.isKidFriendly {
                                Text("Kid-Friendly")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(Color.capeCod.duneGrass)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.capeCod.duneGrass.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            if beach.hasTidePools {
                                Text("Tide Pools")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(Color.capeCod.seafoam)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.capeCod.seafoam.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, CodSpacing.xs)
                .codAccessibleGroup(label: "\(beach.name), \(beach.town)\(beach.isKidFriendly ? ", kid-friendly" : "")\(beach.hasTidePools ? ", has tide pools" : "")")

                if beach.id != BeachRecommendationEngine.beaches.last?.id {
                    Divider()
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .adaptiveCardStyle()
    }

    // MARK: - Helpers

    private var waterTempDescription: String {
        guard let temp = viewModel.waterTemperature else { return "No buoy data" }
        switch temp {
        case ..<55: return "Very cold"
        case 55..<62: return "Cold — wetsuit needed"
        case 62..<68: return "Cool — refreshing"
        case 68..<74: return "Comfortable"
        default: return "Warm"
        }
    }

    private var waveDescription: String {
        guard let height = viewModel.waveHeight else { return "No buoy data" }
        switch height {
        case ..<1: return "Flat — calm water"
        case 1..<3: return "Small — gentle waves"
        case 3..<5: return "Moderate surf"
        case 5..<8: return "Large — strong swimmers only"
        default: return "Heavy — dangerous"
        }
    }

    private var tideDescription: String {
        if let timeUntil = viewModel.timeUntilNextTide, let next = viewModel.nextTide {
            return "\(next.type.displayName) in \(timeUntil)"
        }
        return "Data unavailable"
    }

    private var windDescription: String {
        guard let speed = viewModel.weather?.current.windSpeed else { return "--" }
        switch speed {
        case ..<5: return "Calm"
        case 5..<15: return "Light breeze"
        case 15..<25: return "Breezy"
        default: return "Windy — choppy water"
        }
    }

    private var uvColor: Color {
        switch viewModel.uvIndex {
        case 0...2: return Color.capeCod.duneGrass
        case 3...5: return Color.capeCod.sandbarYellow
        case 6...7: return Color.capeCod.sunsetOrange
        default: return Color.capeCod.cranberry
        }
    }

    private var sunscreenMessage: String {
        switch viewModel.uvIndex {
        case 3...5: return "Apply SPF 30+ sunscreen. Reapply every 2 hours."
        case 6...7: return "UV is high! Use SPF 50+, seek shade during midday."
        case 8...10: return "Very high UV! Limit sun exposure, wear protective clothing."
        default: return "Extreme UV! Stay in shade, SPF 50+, protective clothing essential."
        }
    }

    private func beachSideIcon(_ side: CapeCodBeach.BeachSide) -> String {
        switch side {
        case .bayside: return "water.waves"
        case .oceanside: return "wind"
        case .sound: return "sailboat.fill"
        }
    }

    private func ratingColor(_ rating: BeachRecommendation.BeachRating) -> Color {
        switch rating {
        case .great: Color.capeCod.duneGrass
        case .good: Color.capeCod.oceanBlue
        case .caution: Color.capeCod.sandbarYellow
        case .notRecommended: Color.capeCod.cranberry
        }
    }
}

// MARK: - Condition Card

private struct ConditionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.capeCod.textSecondary)
            }

            Text(value)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.capeCod.textPrimary)

            Text(detail)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Color.capeCod.textSecondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .adaptiveCardStyle()
        .codAccessibleGroup(label: "\(title): \(value), \(detail)")
    }
}

#Preview {
    NavigationStack {
        BeachConditionsView(viewModel: WeatherViewModel())
    }
}
