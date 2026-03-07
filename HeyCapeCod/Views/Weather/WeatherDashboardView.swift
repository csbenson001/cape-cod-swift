import SwiftUI

struct WeatherDashboardView: View {
    @State private var viewModel = WeatherViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    // Current Conditions
                    currentConditions

                    // Beach Day Banner
                    if viewModel.isBeachDay {
                        beachDayBanner
                    }

                    // Hourly Forecast
                    if !viewModel.hourlyForecast.isEmpty {
                        hourlySection
                    }

                    // Tide Section
                    tideSection

                    // Daily Forecast
                    if !viewModel.dailyForecast.isEmpty {
                        dailySection
                    }

                    // Weather Alerts
                    if !viewModel.alerts.isEmpty {
                        alertsSection
                    }
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

    // MARK: - Current Conditions

    private var currentConditions: some View {
        VStack(spacing: CodSpacing.md) {
            Image(systemName: viewModel.conditionIcon)
                .font(.system(size: 56))
                .foregroundStyle(Color.capeCod.oceanBlue)
                .symbolRenderingMode(.multicolor)

            Text(viewModel.currentTemperature)
                .codTextStyle(.heroTitle)

            Text(viewModel.conditionName)
                .codTextStyle(.subtitle)

            HStack(spacing: CodSpacing.lg) {
                WeatherDetail(icon: "wind", label: "Wind", value: viewModel.windSummary)
                WeatherDetail(icon: "humidity.fill", label: "Humidity", value: viewModel.humiditySummary)
                WeatherDetail(icon: "sun.max.fill", label: "UV Index", value: "\(viewModel.weather?.current.uvIndex ?? 0)")
            }
        }
        .padding(.vertical, CodSpacing.lg)
    }

    private var beachDayBanner: some View {
        HStack(spacing: CodSpacing.md) {
            Image(systemName: "beach.umbrella.fill")
                .font(.title2)
                .foregroundStyle(Color.capeCod.sunsetOrange)

            VStack(alignment: .leading, spacing: 2) {
                Text("Beach Day!")
                    .codTextStyle(.cardTitle)
                Text("Perfect conditions for the beach today")
                    .codTextStyle(.caption)
            }
            Spacer()
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.sunsetOrange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
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
                                    .codTextStyle(.label)
                                    .foregroundStyle(Color.capeCod.oceanBlue)
                            }
                        }
                        .frame(width: 60)
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
                            .codTextStyle(.label)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundStyle(Color.capeCod.oceanBlue)
                }
            }

            if let next = viewModel.nextTide {
                HStack(spacing: CodSpacing.md) {
                    Image(systemName: viewModel.tideStatus.icon)
                        .font(.title)
                        .foregroundStyle(Color.capeCod.oceanBlue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(viewModel.tideStatus.displayName) — \(next.type.displayName) at \(next.timeFormatted)")
                            .codTextStyle(.body)
                        Text(next.heightFormatted)
                            .codTextStyle(.caption)
                    }
                }
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
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .codShadow(.card)
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

                    Text("\(Int(day.high))°")
                        .codTextStyle(.body)
                    Text("\(Int(day.low))°")
                        .codTextStyle(.caption)
                        .frame(width: 32)
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .codShadow(.card)
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

// MARK: - Weather Detail

private struct WeatherDetail: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: CodSpacing.xs) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.capeCod.driftwood)
            Text(value)
                .codTextStyle(.body)
            Text(label)
                .codTextStyle(.label)
        }
    }
}

#Preview {
    WeatherDashboardView()
}
