import SwiftUI

// MARK: - MetricCard

/// Displays a prominent number with unit, optional trend arrow, and color-coded background.
/// Uses AnimatedCounter for smooth number transitions and optional pulsing glow for live data.
struct MetricCard: View {
    let value: String
    let unit: String
    let label: String
    let icon: String?
    let tint: Color
    let trend: MetricTrend?
    var isLive: Bool = false

    init(
        value: String,
        unit: String,
        label: String,
        icon: String? = nil,
        tint: Color = Color.capeCod.primary,
        trend: MetricTrend? = nil,
        isLive: Bool = false
    ) {
        self.value = value
        self.unit = unit
        self.label = label
        self.icon = icon
        self.tint = tint
        self.trend = trend
        self.isLive = isLive
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            // Header row: icon + label
            HStack(spacing: CodSpacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(tint)
                }
                Text(label)
                    .codTextStyle(.label)
            }

            // Metric value + unit
            HStack(alignment: .firstTextBaseline, spacing: CodSpacing.xs) {
                if let intValue = Int(value) {
                    AnimatedCounter(intValue, color: tint)
                } else {
                    Text(value)
                        .codTextStyle(.metric)
                        .foregroundStyle(tint)
                }

                Text(unit)
                    .codTextStyle(.metricUnit)

                if let trend {
                    Image(systemName: trend.icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(trend.color)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CodSpacing.cardPadding)
        .background(tint.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .strokeBorder(tint.opacity(0.15), lineWidth: 0.5)
        )
        .pulsingGlow(color: tint, isActive: isLive)
    }
}

// MARK: - Metric Trend

enum MetricTrend {
    case up, down, stable

    var icon: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }

    var color: Color {
        switch self {
        case .up: return Color.capeCod.cranberry
        case .down: return Color.capeCod.duneGrass
        case .stable: return Color.capeCod.driftwood
        }
    }
}

// MARK: - Preview

#Preview("Metric Cards") {
    VStack(spacing: CodSpacing.md) {
        HStack(spacing: CodSpacing.md) {
            MetricCard(
                value: "47",
                unit: "min",
                label: "Bourne Bridge",
                icon: "car.fill",
                tint: Color.capeCod.lobsterRed,
                trend: .up,
                isLive: true
            )

            MetricCard(
                value: "74",
                unit: "\u{00B0}F",
                label: "Water Temp",
                icon: "thermometer.medium",
                tint: Color.capeCod.oceanBlue,
                trend: .stable
            )
        }

        HStack(spacing: CodSpacing.md) {
            MetricCard(
                value: "2:34",
                unit: "PM",
                label: "Next High Tide",
                icon: "water.waves",
                tint: Color.capeCod.seafoam
            )

            MetricCard(
                value: "82",
                unit: "\u{00B0}F",
                label: "Air Temp",
                icon: "sun.max.fill",
                tint: Color.capeCod.sandbarYellow,
                trend: .down
            )
        }
    }
    .padding(CodSpacing.screenEdge)
    .background(Color.capeCod.background)
}
