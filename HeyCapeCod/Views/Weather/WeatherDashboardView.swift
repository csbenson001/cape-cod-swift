import SwiftUI

struct WeatherDashboardView: View {
    @State private var viewModel = WeatherViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    // Current Conditions Hero
                    currentConditionsHero
                        .staggered(index: 0)

                    // Beach Recommendation Banner
                    if let rec = viewModel.beachRecommendation {
                        beachRecommendationBanner(rec)
                            .staggered(index: 1)
                    }

                    // Hourly Forecast
                    if !viewModel.hourlyForecast.isEmpty {
                        hourlySection
                            .staggered(index: 2)
                    }

                    // Tide Section
                    tideSection
                        .staggered(index: 3)

                    // 7-Day Forecast
                    if !viewModel.dailyForecast.isEmpty {
                        dailySection
                            .staggered(index: 4)
                    }

                    // Weather Alerts
                    if !viewModel.alerts.isEmpty {
                        alertsSection
                            .staggered(index: 5)
                    }

                    // Beach Conditions Link
                    NavigationLink {
                        BeachConditionsView(viewModel: viewModel)
                    } label: {
                        HStack {
                            Image(systemName: "beach.umbrella.fill")
                                .font(.title3)
                                .foregroundStyle(Color.capeCod.sunsetOrange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Beach Report Card")
                                    .codTextStyle(.cardTitle)
                                Text("Water temp, waves, UV, and more")
                                    .codTextStyle(.caption)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color.capeCod.driftwood)
                        }
                        .padding(CodSpacing.cardPadding)
                        .background(Color.capeCod.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
                        .adaptiveCardStyle()
                    }
                    .buttonStyle(.plain)
                    .staggered(index: 6)
                    .codAccessibleButton("Beach Report Card", hint: "View water temp, waves, UV, and more")
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.xxl)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Weather & Tides")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.load()
            }
        }
    }

    // MARK: - Current Conditions Hero

    private var currentConditionsHero: some View {
        VStack(spacing: CodSpacing.md) {
            HStack(alignment: .top, spacing: CodSpacing.lg) {
                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    Text(viewModel.currentTemperature)
                        .font(.system(size: 64, weight: .light, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.capeCod.textPrimary)

                    Text(viewModel.conditionName)
                        .codTextStyle(.cardTitle)

                    if let fl = viewModel.weather?.current.feelsLike {
                        Text("Feels like \(Int(fl.rounded()))\u{00B0}")
                            .codTextStyle(.caption)
                    }
                }

                Spacer()

                Image(systemName: viewModel.conditionIcon)
                    .font(.system(size: 56))
                    .symbolRenderingMode(.multicolor)
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }

            HStack(spacing: 0) {
                WeatherDetailPill(icon: "wind", label: "Wind", value: viewModel.windSummary)
                Spacer()
                WeatherDetailPill(icon: "humidity.fill", label: "Humidity", value: viewModel.humiditySummary)
                Spacer()
                WeatherDetailPill(icon: "sun.max.fill", label: "UV", value: "\(viewModel.uvIndex) \(viewModel.uvDescription)")
                if let waterTemp = viewModel.waterTempFormatted {
                    Spacer()
                    WeatherDetailPill(icon: "water.waves", label: "Water", value: waterTemp)
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.featured, style: .continuous))
        .adaptiveCardStyle(cornerRadius: CodRadius.featured)
        .codAccessibleGroup(label: "Current conditions: \(viewModel.currentTemperature), \(viewModel.conditionName)")
    }

    // MARK: - Beach Recommendation

    private func beachRecommendationBanner(_ rec: BeachRecommendation) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: rec.rating.icon)
                    .font(.title3)
                    .foregroundStyle(ratingColor(rec.rating))
                Text(rec.rating.rawValue)
                    .codTextStyle(.cardTitle)
                Spacer()
            }

            Text(rec.summary)
                .codTextStyle(.body)

            Text(rec.details)
                .codTextStyle(.caption)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.sm) {
                    ForEach(rec.factors, id: \.label) { factor in
                        HStack(spacing: CodSpacing.xs) {
                            Image(systemName: factor.icon)
                                .font(.caption2)
                            Text("\(factor.label): \(factor.value)")
                                .codTextStyle(.label)
                        }
                        .padding(.horizontal, CodSpacing.sm)
                        .padding(.vertical, CodSpacing.xs)
                        .background(factor.isPositive ? Color.capeCod.duneGrass.opacity(0.15) : Color.capeCod.sandbarYellow.opacity(0.15))
                        .foregroundStyle(factor.isPositive ? Color.capeCod.duneGrass : Color.capeCod.sandbarYellow)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(ratingColor(rec.rating).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }

    private func ratingColor(_ rating: BeachRecommendation.BeachRating) -> Color {
        switch rating {
        case .great: Color.capeCod.duneGrass
        case .good: Color.capeCod.oceanBlue
        case .caution: Color.capeCod.sandbarYellow
        case .notRecommended: Color.capeCod.cranberry
        }
    }

    // MARK: - Hourly

    private var hourlySection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Hourly Forecast")
                .codTextStyle(.sectionTitle)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.md) {
                    ForEach(viewModel.hourlyForecast.prefix(12)) { hour in
                        VStack(spacing: CodSpacing.sm) {
                            Text(hour.time.formatted(.dateTime.hour()))
                                .codTextStyle(.label)

                            Image(systemName: hour.condition.icon)
                                .symbolRenderingMode(.multicolor)
                                .font(.title3)

                            Text("\(Int(hour.temperature))\u{00B0}")
                                .codTextStyle(.body)
                                .monospacedDigit()

                            if hour.precipChance > 0 {
                                Text("\(hour.precipChance)%")
                                    .codTextStyle(.label)
                                    .foregroundStyle(Color.capeCod.oceanBlue)
                            }
                        }
                        .frame(width: 56)
                    }
                }
            }
        }
        .codAccessibleGroup(label: "Hourly forecast, \(viewModel.hourlyForecast.prefix(3).map { "\(Int($0.temperature)) degrees at \($0.time.formatted(.dateTime.hour()))" }.joined(separator: ", "))")
    }

    // MARK: - Tides

    private var tideSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack {
                Text("Tides")
                    .codTextStyle(.sectionTitle)
                Spacer()
                Menu {
                    ForEach(viewModel.tideStations) { station in
                        Button(station.name) {
                            Task { await viewModel.selectStation(station) }
                        }
                    }
                } label: {
                    HStack(spacing: CodSpacing.xs) {
                        Text(viewModel.selectedStation.name)
                            .codTextStyle(.label)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundStyle(Color.capeCod.oceanBlue)
                }
            }

            if let next = viewModel.nextTide {
                HStack(spacing: CodSpacing.md) {
                    Image(systemName: viewModel.tideStatus == .rising ? "arrow.up" : "arrow.down")
                        .font(.title)
                        .foregroundStyle(Color.capeCod.oceanBlue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(viewModel.tideStatus.displayName) \u{2014} \(next.type.displayName) at \(next.timeFormatted)")
                            .codTextStyle(.body)
                        if let timeUntil = viewModel.timeUntilNextTide {
                            Text("in \(timeUntil) (\(next.heightFormatted))")
                                .codTextStyle(.caption)
                        }
                    }
                }
                .codAccessibleGroup(label: "Tide is \(viewModel.tideStatus.displayName). Next \(next.type.displayName) at \(next.timeFormatted)")
            }

            if let tip = viewModel.tideTip {
                Text(tip)
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .padding(CodSpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.capeCod.oceanBlue.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
            }

            NavigationLink {
                TideChartView(viewModel: viewModel)
            } label: {
                Text("View Full Tide Chart")
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Daily

    private var dailySection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("7-Day Forecast")
                .codTextStyle(.sectionTitle)

            ForEach(viewModel.dailyForecast) { day in
                HStack {
                    Text(day.date.formatted(.dateTime.weekday(.abbreviated)))
                        .codTextStyle(.body)
                        .frame(width: 44, alignment: .leading)

                    Image(systemName: day.condition.icon)
                        .symbolRenderingMode(.multicolor)
                        .frame(width: 30)

                    if day.precipChance > 0 {
                        Text("\(day.precipChance)%")
                            .codTextStyle(.label)
                            .foregroundStyle(Color.capeCod.oceanBlue)
                            .frame(width: 36)
                    } else {
                        Spacer().frame(width: 36)
                    }

                    Spacer()

                    Text("\(Int(day.high))\u{00B0}")
                        .codTextStyle(.body)
                        .monospacedDigit()
                    Text("\(Int(day.low))\u{00B0}")
                        .codTextStyle(.caption)
                        .monospacedDigit()
                        .frame(width: 32)
                }
                .codAccessibleGroup(label: "\(day.date.formatted(.dateTime.weekday(.wide))): high \(Int(day.high)) degrees, low \(Int(day.low)) degrees, \(day.condition.description)")
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Alerts

    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Weather Alerts")
                .codTextStyle(.sectionTitle)

            ForEach(viewModel.alerts) { alert in
                HStack(spacing: CodSpacing.md) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.capeCod.cranberry)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(alert.title)
                            .codTextStyle(.cardTitle)
                        Text(alert.description)
                            .codTextStyle(.caption)
                            .lineLimit(2)
                    }
                }
                .padding(CodSpacing.cardPadding)
                .background(Color.capeCod.cranberry.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
                .codAccessibleGroup(label: "Weather alert: \(alert.title). \(alert.description)")
            }
        }
    }
}

// MARK: - Weather Detail Pill

private struct WeatherDetailPill: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: CodSpacing.xs) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color.capeCod.driftwood)
            Text(value)
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(label)
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
    }
}

#Preview {
    WeatherDashboardView()
}
