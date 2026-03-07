import SwiftUI
import Charts

/// Beautiful tide curve chart using Swift Charts.
/// Shows today + next 2 days of tides with current time marker.
struct TideChartView: View {
    let viewModel: WeatherViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                // Station Info
                VStack(spacing: CodSpacing.sm) {
                    Text(viewModel.selectedStation.name)
                        .codTextStyle(.sectionTitle)
                    Text("Tide Predictions — Next 3 Days")
                        .codTextStyle(.caption)
                }

                // Tide Chart
                if !viewModel.tidePredictions.isEmpty {
                    tideChart
                }

                // Context-aware tip
                if let tip = viewModel.tideTip {
                    tideTipCard(tip)
                }

                // Predictions List
                predictionsList
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.xxl)
        }
        .background(Color.capeCod.background)
        .navigationTitle("Tide Chart")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Swift Charts Tide Curve

    private var tideChart: some View {
        let predictions = viewModel.tidePredictions

        return VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Chart {
                // Tide curve
                ForEach(predictions) { prediction in
                    LineMark(
                        x: .value("Time", prediction.time),
                        y: .value("Height", prediction.height)
                    )
                    .foregroundStyle(Color.capeCod.oceanBlue.gradient)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))

                    AreaMark(
                        x: .value("Time", prediction.time),
                        y: .value("Height", prediction.height)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.capeCod.oceanBlue.opacity(0.2), Color.capeCod.oceanBlue.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }

                // High/low tide point markers
                ForEach(predictions) { prediction in
                    PointMark(
                        x: .value("Time", prediction.time),
                        y: .value("Height", prediction.height)
                    )
                    .foregroundStyle(prediction.type == .high ? Color.capeCod.oceanBlue : Color.capeCod.seafoam)
                    .symbolSize(40)
                    .annotation(position: prediction.type == .high ? .top : .bottom) {
                        VStack(spacing: 0) {
                            Text(prediction.type == .high ? "H" : "L")
                                .font(.system(size: 9, weight: .bold))
                            Text(prediction.timeFormatted)
                                .font(.system(size: 8))
                        }
                        .foregroundStyle(prediction.type == .high ? Color.capeCod.oceanBlue : Color.capeCod.seafoam)
                    }
                }

                // Current time marker
                RuleMark(x: .value("Now", Date.now))
                    .foregroundStyle(Color.capeCod.sunsetOrange)
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                    .annotation(position: .top, alignment: .center) {
                        Text("Now")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.capeCod.sunsetOrange)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.capeCod.sunsetOrange.opacity(0.12))
                            .clipShape(Capsule())
                    }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 4]))
                    AxisValueLabel {
                        if let height = value.as(Double.self) {
                            Text(String(format: "%.1f", height))
                                .font(.system(size: 10))
                        }
                    }
                }
            }
            .chartYAxisLabel("ft", position: .leading)
            .frame(height: 220)
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .adaptiveCardStyle()
    }

    // MARK: - Tip Card

    private func tideTipCard(_ tip: String) -> some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "lightbulb.fill")
                .font(.body)
                .foregroundStyle(Color.capeCod.sandbarYellow)

            Text(tip)
                .codTextStyle(.body)
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.sandbarYellow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
    }

    // MARK: - Predictions List

    private var predictionsList: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("All Predictions")
                .codTextStyle(.sectionTitle)

            // Group by day
            let grouped = Dictionary(grouping: viewModel.tidePredictions) { prediction in
                Calendar.current.startOfDay(for: prediction.time)
            }

            ForEach(grouped.keys.sorted(), id: \.self) { day in
                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    // Day header
                    Text(dayLabel(day))
                        .codTextStyle(.cardTitle)
                        .padding(.top, CodSpacing.sm)

                    ForEach(grouped[day] ?? []) { prediction in
                        HStack {
                            Circle()
                                .fill(prediction.type == .high ? Color.capeCod.oceanBlue : Color.capeCod.seafoam)
                                .frame(width: 8, height: 8)

                            Image(systemName: prediction.type.icon)
                                .foregroundStyle(prediction.type == .high ? Color.capeCod.oceanBlue : Color.capeCod.seafoam)
                                .frame(width: 24)

                            Text(prediction.type.displayName)
                                .codTextStyle(.body)

                            Spacer()

                            Text(prediction.heightFormatted)
                                .codTextStyle(.body)
                                .foregroundStyle(Color.capeCod.driftwood)

                            Text(prediction.timeFormatted)
                                .codTextStyle(.body)
                                .frame(width: 80, alignment: .trailing)
                        }
                        .padding(.vertical, CodSpacing.xs)
                        .opacity(prediction.time < .now ? 0.5 : 1.0)
                    }
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .adaptiveCardStyle()
    }

    private func dayLabel(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInTomorrow(date) { return "Tomorrow" }
        return date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }
}

#Preview {
    NavigationStack {
        TideChartView(viewModel: WeatherViewModel())
    }
}
