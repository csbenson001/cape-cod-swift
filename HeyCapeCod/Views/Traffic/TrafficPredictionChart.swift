import SwiftUI
import Charts

// MARK: - Traffic Prediction Chart

/// Bar chart showing predicted delays by hour, color-coded by severity.
struct TrafficPredictionChart: View {
    let predictions: [TrafficPatternEngine.HourlyPrediction]
    let optimalStart: Int?
    let optimalEnd: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            headerRow

            chartView
                .frame(height: 200)

            legendRow
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack {
            Image(systemName: "chart.bar.fill")
                .foregroundStyle(Color.capeCod.oceanBlue)
            Text("Predicted Delays")
                .codTextStyle(.sectionTitle)
            Spacer()
        }
    }

    // MARK: - Chart

    private var chartView: some View {
        Chart {
            ForEach(predictions) { prediction in
                BarMark(
                    x: .value("Hour", prediction.hourLabel),
                    y: .value("Delay", prediction.expectedDelay)
                )
                .foregroundStyle(barColor(for: prediction.severity))
                .cornerRadius(CodRadius.sm)
            }

            // Optimal window overlay
            if let start = optimalStart, let end = optimalEnd {
                let startLabel = hourLabel(start)
                let endLabel = hourLabel(end)
                RectangleMark(
                    xStart: .value("Start", startLabel),
                    xEnd: .value("End", endLabel)
                )
                .foregroundStyle(Color.capeCod.duneGrass.opacity(0.12))
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 8)) { value in
                AxisValueLabel()
                    .font(.system(size: 9, weight: .medium))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                AxisValueLabel {
                    if let intVal = value.as(Int.self) {
                        Text("\(intVal)m")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color.capeCod.textSecondary)
                    }
                }
            }
        }
        .chartYAxisLabel("Minutes", alignment: .leading)
    }

    // MARK: - Legend

    private var legendRow: some View {
        HStack(spacing: CodSpacing.md) {
            legendItem(color: Color.capeCod.duneGrass, label: "<15 min")
            legendItem(color: Color.capeCod.sandbarYellow, label: "15-30")
            legendItem(color: Color.capeCod.sunsetOrange, label: "30-60")
            legendItem(color: Color.capeCod.lobsterRed, label: "60+")
        }
        .codTextStyle(.label)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: CodSpacing.xs) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
    }

    // MARK: - Helpers

    private func barColor(for severity: TrafficPatternEngine.TrafficSeverity) -> Color {
        switch severity {
        case .clear, .light: Color.capeCod.duneGrass
        case .moderate: Color.capeCod.sandbarYellow
        case .heavy: Color.capeCod.sunsetOrange
        case .severe: Color.capeCod.lobsterRed
        }
    }

    private func hourLabel(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let display = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(display)\(period)"
    }
}

#Preview {
    let predictions = TrafficPatternEngine.generateHourlyPredictions(
        date: .now,
        direction: .boston
    )
    TrafficPredictionChart(
        predictions: predictions,
        optimalStart: 6,
        optimalEnd: 9
    )
    .padding()
}
