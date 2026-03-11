import SwiftUI

/// Full-screen mode selector with themed cards for each experience mode.
struct ExperienceModeSelectorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.lg) {
                headerSection
                modeCards
            }
            .padding(.bottom, CodSpacing.xxl)
        }
        .background(Color.capeCod.background)
        .navigationTitle("Experience Mode")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(Color.capeCod.sunsetOrange)
                .padding(.top, CodSpacing.lg)

            Text("Choose Your Experience")
                .codTextStyle(.sectionTitle)

            Text("Customize what you see and how content is presented.")
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CodSpacing.xl)
        }
    }

    // MARK: - Mode Cards

    private var modeCards: some View {
        VStack(spacing: CodSpacing.md) {
            ForEach(Array(ExperienceMode.allCases.enumerated()), id: \.element.id) { index, mode in
                modeCard(mode)
                    .staggered(index: index)
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    private func modeCard(_ mode: ExperienceMode) -> some View {
        let isSelected = appState.experienceMode == mode
        let accentColor = modeAccentColor(mode)

        return Button {
            withAnimation(CodAnimation.spring) {
                appState.experienceMode = mode
            }
            CodHaptic.success()
            updateProfileMode(mode)
        } label: {
            modeCardContent(mode: mode, isSelected: isSelected, accentColor: accentColor)
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleCard(
            label: "\(mode.displayName): \(mode.tagline)",
            hint: isSelected ? "Currently selected" : "Double tap to select"
        )
    }

    private func modeCardContent(
        mode: ExperienceMode,
        isSelected: Bool,
        accentColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            modeCardHeader(mode: mode, isSelected: isSelected, accentColor: accentColor)
            modeCardBody(mode: mode, accentColor: accentColor)
            modeCardTabs(mode: mode, accentColor: accentColor)
        }
        .padding(CodSpacing.cardPadding)
        .background(isSelected ? accentColor.opacity(0.06) : Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .stroke(isSelected ? accentColor : .clear, lineWidth: 2)
        )
        .adaptiveCardStyle()
    }

    private func modeCardHeader(
        mode: ExperienceMode,
        isSelected: Bool,
        accentColor: Color
    ) -> some View {
        HStack(spacing: CodSpacing.md) {
            Image(systemName: mode.icon)
                .font(.title2)
                .foregroundStyle(accentColor)
                .frame(width: 44, height: 44)
                .background(accentColor.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(mode.displayName)
                    .codTextStyle(.cardTitle)
                    .foregroundStyle(Color.capeCod.textPrimary)
                Text(mode.subtitle)
                    .codTextStyle(.caption)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(accentColor)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
    }

    private func modeCardBody(mode: ExperienceMode, accentColor: Color) -> some View {
        Text(mode.tagline)
            .codTextStyle(.body)
            .foregroundStyle(Color.capeCod.textSecondary)
    }

    private func modeCardTabs(mode: ExperienceMode, accentColor: Color) -> some View {
        HStack(spacing: CodSpacing.xs) {
            ForEach(mode.tabs) { tab in
                HStack(spacing: 3) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 10))
                    Text(tab.title)
                        .font(.system(size: 10, weight: .medium))
                }
                .padding(.horizontal, CodSpacing.sm)
                .padding(.vertical, CodSpacing.xs)
                .foregroundStyle(accentColor)
                .background(accentColor.opacity(0.1))
                .clipShape(Capsule())
            }
        }
    }

    // MARK: - Helpers

    private func modeAccentColor(_ mode: ExperienceMode) -> Color {
        switch mode {
        case .kids: Color.capeCod.sunsetOrange
        case .teen: Color.capeCod.seafoam
        case .adult: Color.capeCod.oceanBlue
        case .family: Color.capeCod.duneGrass
        }
    }

    private func updateProfileMode(_ mode: ExperienceMode) {
        if let profile = UserProfileManager.shared.currentProfile {
            profile.experienceMode = mode
            UserProfileManager.shared.saveProfile()
        }
    }
}

#Preview {
    NavigationStack {
        ExperienceModeSelectorView()
    }
    .environment(AppState())
}
