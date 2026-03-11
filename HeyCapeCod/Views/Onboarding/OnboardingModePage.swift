import SwiftUI

/// Screen 2: Experience mode selection with substantial tappable cards.
struct OnboardingModePage: View {
    @Binding var selectedMode: ExperienceMode

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: CodSpacing.lg) {
                Spacer()
                    .frame(height: CodSpacing.xl)

                headerSection

                VStack(spacing: CodSpacing.md) {
                    ForEach(ExperienceMode.allCases) { mode in
                        ModeSelectionCard(
                            mode: mode,
                            isSelected: selectedMode == mode
                        ) {
                            withAnimation(CodAnimation.quick) {
                                selectedMode = mode
                            }
                            CodHaptic.selection()
                        }
                        .staggered(index: ExperienceMode.allCases.firstIndex(of: mode) ?? 0,
                                   interval: 0.08)
                    }
                }
                .padding(.horizontal, CodSpacing.screenEdge)

                Spacer()
                    .frame(height: CodSpacing.xxl)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Text("Who's exploring Cape Cod?")
                .codTextStyle(.heroTitle)
                .multilineTextAlignment(.center)

            Text("We'll tailor stories and recommendations to your group.")
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CodSpacing.xl)
        }
    }
}

// MARK: - Mode Selection Card

private struct ModeSelectionCard: View {
    let mode: ExperienceMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: CodSpacing.md) {
            // Icon circle
            iconView

            // Text content
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: CodSpacing.sm) {
                    Text(mode.displayName)
                        .codTextStyle(.cardTitle)

                    Text(ageRange)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(accentColor.opacity(0.8))
                        .padding(.horizontal, CodSpacing.sm)
                        .padding(.vertical, 2)
                        .background(accentColor.opacity(0.12))
                        .clipShape(Capsule())
                }

                Text(tagline)
                    .codTextStyle(.caption)
                    .lineLimit(2)
            }

            Spacer()

            // Checkmark
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(accentColor)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(
            isSelected
                ? accentColor.opacity(0.08)
                : Color.capeCod.surfaceElevated
        )
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .stroke(isSelected ? accentColor : .clear, lineWidth: 2)
        )
        .onTapGesture(perform: onTap)
        .codAccessibleCard(
            label: "\(mode.displayName), \(ageRange): \(tagline)",
            hint: isSelected ? "Currently selected" : "Double tap to select"
        )
    }

    private var iconView: some View {
        ZStack {
            Circle()
                .fill(accentColor.opacity(isSelected ? 0.2 : 0.1))
                .frame(width: 52, height: 52)

            Image(systemName: iconName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(isSelected ? accentColor : Color.capeCod.driftwood)
        }
    }

    private var iconName: String {
        switch mode {
        case .kids: "party.popper.fill"
        case .teen: "camera.fill"
        case .adult: "safari.fill"
        case .family: "figure.2.and.child.holdinghands"
        }
    }

    private var ageRange: String {
        switch mode {
        case .kids: "Ages 4-12"
        case .teen: "Ages 13-17"
        case .adult: "18+"
        case .family: "All Ages"
        }
    }

    private var tagline: String {
        switch mode {
        case .kids: "Treasure hunts, stories & fun!"
        case .teen: "Photos, events & beach vibes"
        case .adult: "Dining, tours & local secrets"
        case .family: "Fun for everyone"
        }
    }

    private var accentColor: Color {
        switch mode {
        case .kids: Color.capeCod.sunsetOrange
        case .teen: Color.capeCod.seafoam
        case .adult: Color.capeCod.oceanBlue
        case .family: Color.capeCod.duneGrass
        }
    }
}

#Preview {
    OnboardingModePage(selectedMode: .constant(.adult))
}
