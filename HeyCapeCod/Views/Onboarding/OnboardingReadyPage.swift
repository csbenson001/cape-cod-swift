import SwiftUI

/// Screen 4: Summary of choices and "Start Exploring" action.
struct OnboardingReadyPage: View {
    let selectedMode: ExperienceMode
    let selectedInterests: Set<String>
    var selectedRegions: Set<String> = []
    var selectedTowns: Set<String> = []
    let onSignIn: () -> Void
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: CodSpacing.lg) {
            Spacer()

            celebrationIcon

            titleSection

            choicesSummary

            actionButtons

            signInLink

            Spacer()
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Celebration Icon

    private var celebrationIcon: some View {
        ZStack {
            Circle()
                .fill(Color.capeCod.seafoam.opacity(0.15))
                .frame(width: 110, height: 110)

            Circle()
                .fill(Color.capeCod.seafoam.opacity(0.08))
                .frame(width: 140, height: 140)

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.capeCod.oceanBlue, Color.capeCod.seafoam],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Text("You're all set!")
                .codTextStyle(.heroTitle)

            Text("Your Cape Cod adventure starts now")
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Choices Summary

    private var choicesSummary: some View {
        VStack(spacing: CodSpacing.md) {
            modeSummaryRow

            if !selectedInterests.isEmpty {
                interestsSummary
            }

            if !selectedRegions.isEmpty || !selectedTowns.isEmpty {
                areaSummary
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }

    private var modeSummaryRow: some View {
        HStack(spacing: CodSpacing.md) {
            Image(systemName: selectedMode.icon)
                .font(.title3)
                .foregroundStyle(modeColor)
                .frame(width: 36, height: 36)
                .background(modeColor.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Experience Mode")
                    .codTextStyle(.caption)
                Text(selectedMode.displayName)
                    .codTextStyle(.cardTitle)
            }

            Spacer()
        }
    }

    private var interestsSummary: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Interests")
                .codTextStyle(.caption)

            FlowLayout(spacing: CodSpacing.xs) {
                ForEach(sortedInterests, id: \.self) { interest in
                    interestChipLabel(interest)
                }
            }
        }
    }

    private func interestChipLabel(_ rawValue: String) -> some View {
        let interest = OnboardingInterest(rawValue: rawValue)
        let name = interest?.displayName ?? rawValue.capitalized

        return Text(name)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.capeCod.oceanBlue)
            .padding(.horizontal, CodSpacing.sm)
            .padding(.vertical, CodSpacing.xs)
            .background(Color.capeCod.oceanBlue.opacity(0.1))
            .clipShape(Capsule())
    }

    private var areaSummary: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Cape Cod Areas")
                .codTextStyle(.caption)

            FlowLayout(spacing: CodSpacing.xs) {
                ForEach(Array(selectedRegions).sorted(), id: \.self) { rawValue in
                    if let region = CapeCodRegion(rawValue: rawValue) {
                        Text(region.displayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.capeCod.oceanBlue)
                            .padding(.horizontal, CodSpacing.sm)
                            .padding(.vertical, CodSpacing.xs)
                            .background(Color.capeCod.oceanBlue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }

                ForEach(Array(selectedTowns).sorted(), id: \.self) { town in
                    Text(town)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.capeCod.deepNavy)
                        .padding(.horizontal, CodSpacing.sm)
                        .padding(.vertical, CodSpacing.xs)
                        .background(Color.capeCod.deepNavy.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var sortedInterests: [String] {
        Array(selectedInterests).sorted()
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        CodButton("Start Exploring", variant: .primary,
                  icon: "arrow.right", isFullWidth: true) {
            onStart()
        }
    }

    // MARK: - Sign In Link

    private var signInLink: some View {
        Button {
            onSignIn()
        } label: {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 14))
                Text("Sign in to save your progress")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(Color.capeCod.driftwood)
        }
    }

    private var modeColor: Color {
        switch selectedMode {
        case .kids: Color.capeCod.sunsetOrange
        case .teen: Color.capeCod.seafoam
        case .adult: Color.capeCod.oceanBlue
        case .family: Color.capeCod.duneGrass
        }
    }
}

#Preview {
    OnboardingReadyPage(
        selectedMode: .family,
        selectedInterests: ["beaches", "lighthouses", "seafood", "hiking"],
        onSignIn: {},
        onStart: {}
    )
}
