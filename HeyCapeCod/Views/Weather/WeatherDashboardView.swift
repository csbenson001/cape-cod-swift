import SwiftUI

struct WeatherDashboardView: View {
    @State private var viewModel = WeatherViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    // Current Conditions Hero
                    currentConditionsHero

                    // Beach Recommendation Banner
                    if let rec = viewModel.beachRecommendation {
                        beachRecommendationBanner(rec)
                    }

                    // Hourly Forecast
                    if !viewModel.hourlyForecast.isEmpty {
                        hourlySection
                    }

                    // Tide Section
                    tideSection

                    // 7-Day Forecast
                    if !viewModel.dailyForecast.isEmpty {
                        dailySection
                    }

                    // Weather Alerts
                    if !viewModel.alerts.isEmpty {
                        alertsSection
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
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
                        .adaptiveCardStyle()
                    }
                    .buttonStyle(.plain)
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
            // Large weather icon + temperature
            HStack(alignment: .top, spacing: CodSpacing.lg) {
                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    Text(viewModel.currentTemperature)
                        .font(.system(size: 64, weight: .light, design: .rounded))
                        .foregroundStyle(Color.capeCod.textPrimary)

                    Text(viewModel.conditionName)
                        .codTextStyle(.cardTitle)

                    if let fl = viewModel.weather?.current.feelsLike {
                        Text("Feels like \(Int(fl.rounded()))°")
                            .codTextStyle(.caption)
                    }
                }

                Spacer()

                Image(systemName: viewModel.conditionIcon)
                    .font(.system(size: 56))
                    .symbolRenderingMode(.multicolor)
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }

            // Detail row: Wind, Humidity, UV, Water Temp
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
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.featured))
        .adaptiveCardStyle(cornerRadius: CodRadius.featured)
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

            // Factor pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.sm) {
                    ForEach(rec.factors, id: \.label) { factor in
                        HStack(spacing: CodSpacing.xs) {
                            Image(systemName: factor.icon)
                                .font(.caption2)
                            Text("\(factor.label): \(factor.value)")
                                .font(.system(size: 11, weight: .medium))
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
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
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

                            Text("\(Int(hour.temperature))°")
                                .codTextStyle(.body)

                            if hour.precipChance > 0 {
                                Text("\(hour.precipChance)%")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.capeCod.oceanBlue)
                            }
                        }
                        .frame(width: 56)
                    }
                }
            }
        }
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
                            .font(.system(size: 11, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundStyle(Color.capeCod.oceanBlue)
                }
            }

            // Next tide info
            if let next = viewModel.nextTide {
                HStack(spacing: CodSpacing.md) {
                    Image(systemName: viewModel.tideStatus == .rising ? "arrow.up" : "arrow.down")
                        .font(.title)
                        .foregroundStyle(Color.capeCod.oceanBlue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(viewModel.tideStatus.displayName) — \(next.type.displayName) at \(next.timeFormatted)")
                            .codTextStyle(.body)
                        if let timeUntil = viewModel.timeUntilNextTide {
                            Text("in \(timeUntil) (\(next.heightFormatted))")
                                .codTextStyle(.caption)
                        }
                    }
                }
            }

            // Tide tip
            if let tip = viewModel.tideTip {
                Text(tip)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .padding(CodSpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.capeCod.oceanBlue.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip))
            }

            NavigationLink {
                TideChartView(viewModel: viewModel)
            } label: {
                Text("View Full Tide Chart")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
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
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.capeCod.oceanBlue)
                            .frame(width: 36)
                    } else {
                        Spacer().frame(width: 36)
                    }

                    Spacer()

                    Text("\(Int(day.high))°")
                        .codTextStyle(.body)
                    Text("\(Int(day.low))°")
                        .codTextStyle(.caption)
                        .frame(width: 32)
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
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
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
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
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.capeCod.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(label)
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(Color.capeCod.textSecondary)
        }
    }
}

#Preview {
    WeatherDashboardView()
}
