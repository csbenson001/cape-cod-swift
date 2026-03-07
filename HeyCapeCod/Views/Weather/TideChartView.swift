import SwiftUI

struct TideChartView: View {
    let viewModel: WeatherViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                // Station Info
                VStack(spacing: CodSpacing.sm) {
                    Text(viewModel.selectedStation.name)
                        .codTextStyle(.sectionTitle)
                    Text("Tide Predictions")
                        .codTextStyle(.caption)
                }

                // Tide Chart
                if !viewModel.tidePredictions.isEmpty {
                    tideChart
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

    private var tideChart: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            // Simple visual tide chart
            GeometryReader { geo in
                let predictions = viewModel.tidePredictions
                let maxHeight = predictions.map(\.height).max() ?? 1
                let minHeight = predictions.map(\.height).min() ?? 0
                let range = max(maxHeight - minHeight, 0.1)

                Path { path in
                    guard predictions.count > 1 else { return }
                    let stepX = geo.size.width / CGFloat(predictions.count - 1)

                    for (index, prediction) in predictions.enumerated() {
                        let x = CGFloat(index) * stepX
                        let normalizedHeight = (prediction.height - minHeight) / range
                        let y = geo.size.height * (1 - normalizedHeight)

                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.capeCod.oceanBlue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                // Data points
                ForEach(Array(predictions.enumerated()), id: \.element.id) { index, prediction in
                    let stepX = geo.size.width / CGFloat(predictions.count - 1)
                    let x = CGFloat(index) * stepX
                    let normalizedHeight = (prediction.height - minHeight) / range
                    let y = geo.size.height * (1 - normalizedHeight)

                    Circle()
                        .fill(prediction.type == .high ? Color.capeCod.oceanBlue : Color.capeCod.seafoam)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
            }
            .frame(height: 160)
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        }
    }

    private var predictionsList: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Predictions")
                .codTextStyle(.sectionTitle)

            ForEach(viewModel.tidePredictions) { prediction in
                HStack {
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

                if prediction.id != viewModel.tidePredictions.last?.id {
                    Divider()
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .codShadow(.card)
    }
}

#Preview {
    NavigationStack {
        TideChartView(viewModel: WeatherViewModel())
    }
}
