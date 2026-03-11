import SwiftUI

// MARK: - Shark Alert Banner

/// Compact banner showing recent shark activity.
/// Tapping presents the full SharkAlertView.
struct SharkAlertBanner: View {
    @State private var service = SharkAlertService()
    @State private var showFullView = false

    var body: some View {
        Button {
            CodHaptic.tap()
            showFullView = true
        } label: {
            bannerContent
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleButton(
            accessibilityLabel,
            hint: "Tap to view shark alert details"
        )
        .task {
            await service.fetchRecentSightings()
        }
        .sheet(isPresented: $showFullView) {
            SharkAlertView()
        }
    }

    // MARK: - Banner Content

    private var bannerContent: some View {
        HStack(spacing: CodSpacing.sm) {
            // Icon
            ZStack {
                Circle()
                    .fill(bannerColor.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: service.alertLevel.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(bannerColor)
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text("Shark Activity")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.capeCod.textPrimary)

                Text(bannerMessage)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.capeCod.textSecondary)
            }

            Spacer()

            // Alert badge + chevron
            HStack(spacing: CodSpacing.xs) {
                Text(service.alertLevel.label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(bannerColor)
                    .padding(.horizontal, CodSpacing.sm)
                    .padding(.vertical, 3)
                    .background(bannerColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.capeCod.driftwood)
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .strokeBorder(bannerColor.opacity(0.25), lineWidth: 1)
        )
        .adaptiveCardStyle()
    }

    // MARK: - Helpers

    private var bannerColor: Color {
        switch service.alertLevel {
        case .high: return Color.capeCod.cranberry
        case .moderate: return Color.capeCod.sandbarYellow
        case .low: return Color.capeCod.duneGrass
        }
    }

    private var bannerMessage: String {
        let count = service.recentSightingCount
        switch count {
        case 0:
            return "No recent sightings near Cape Cod beaches"
        case 1:
            return "1 shark sighting in the last 48 hours"
        default:
            return "\(count) shark sightings in the last 48 hours"
        }
    }

    private var accessibilityLabel: String {
        "Shark Activity: \(service.alertLevel.label). \(bannerMessage)"
    }
}

// MARK: - Preview

#Preview("Shark Banner - Default") {
    VStack(spacing: CodSpacing.md) {
        SharkAlertBanner()
    }
    .padding(CodSpacing.screenEdge)
    .background(Color.capeCod.background)
}
