import SwiftUI

/// 4-page onboarding flow:
/// 1. Welcome hero with app branding
/// 2. Choose experience mode (kids/teen/adult/family)
/// 3. Select interests filtered by mode
/// 4. Summary + ready to explore
struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0
    @State private var selectedMode: ExperienceMode = .adult
    @State private var selectedInterests: Set<String> = []

    private let totalPages = 4

    var body: some View {
        ZStack {
            Color.capeCod.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                skipButton

                // Page content
                TabView(selection: $currentPage) {
                    OnboardingWelcomePage()
                        .tag(0)
                    OnboardingModePage(selectedMode: $selectedMode)
                        .tag(1)
                    OnboardingInterestsPage(
                        selectedMode: selectedMode,
                        selectedInterests: $selectedInterests
                    )
                    .tag(2)
                    OnboardingReadyPage(
                        selectedMode: selectedMode,
                        selectedInterests: selectedInterests,
                        onSignIn: { completeOnboarding() },
                        onStart: { completeOnboarding() }
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.capeCodSpring, value: currentPage)

                bottomControls
                    .padding(.horizontal, CodSpacing.screenEdge)
                    .padding(.bottom, CodSpacing.lg)
            }
        }
    }

    // MARK: - Skip Button

    private var skipButton: some View {
        HStack {
            Spacer()
            if currentPage < totalPages - 1 {
                Button {
                    withAnimation(.capeCodSpring) { currentPage = totalPages - 1 }
                    CodHaptic.light()
                } label: {
                    Text("Skip")
                        .codTextStyle(.body)
                        .foregroundStyle(Color.capeCod.driftwood)
                        .padding(.horizontal, CodSpacing.md)
                        .padding(.vertical, CodSpacing.xs)
                }
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.top, CodSpacing.xs)
        .frame(height: 36)
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        HStack {
            pageIndicator

            Spacer()

            if currentPage < totalPages - 1 {
                nextButton
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: CodSpacing.xs) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage
                          ? Color.capeCod.oceanBlue
                          : Color.capeCod.driftwood.opacity(0.3))
                    .frame(width: index == currentPage ? 20 : 6, height: 6)
                    .animation(.capeCodQuick, value: currentPage)
            }
        }
        .codAccessible(label: "Page \(currentPage + 1) of \(totalPages)")
    }

    private var nextButton: some View {
        Button {
            withAnimation(.capeCodSpring) { currentPage += 1 }
            CodHaptic.light()
        } label: {
            HStack(spacing: CodSpacing.xs) {
                Text(currentPage == 0 ? "Get Started" : "Next")
                    .codTextStyle(.cardTitle)
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, CodSpacing.lg)
            .padding(.vertical, CodSpacing.sm + 2)
            .background(Color.capeCod.oceanBlue)
            .clipShape(Capsule())
        }
        .buttonStyle(CodButtonPressStyle(variant: .primary))
    }

    // MARK: - Completion

    private func completeOnboarding() {
        // Save mode to UserDefaults
        UserDefaults.standard.set(selectedMode.rawValue, forKey: "experienceMode")
        appState.experienceMode = selectedMode

        // Save interests to UserDefaults
        UserDefaults.standard.set(Array(selectedInterests), forKey: "selectedInterests")

        // Sync to user profile if available
        if let profile = UserProfileManager.shared.currentProfile {
            profile.experienceMode = selectedMode
            profile.interests = Array(selectedInterests)
            UserProfileManager.shared.saveProfile()
        }

        CodHaptic.success()
        appState.hasCompletedOnboarding = true
    }
}

// MARK: - Interest (legacy, used by ProfileView)

/// Basic interest categories used in profile editing.
/// For the onboarding flow, see `OnboardingInterest` in OnboardingInterestsPage.swift.
enum Interest: String, CaseIterable, Identifiable {
    case beaches
    case history
    case food
    case nature
    case lighthouses
    case fishing
    case art
    case shopping
    case nightlife
    case family

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .beaches: "beach.umbrella"
        case .history: "building.columns"
        case .food: "fork.knife"
        case .nature: "leaf.fill"
        case .lighthouses: "light.beacon.max.fill"
        case .fishing: "fish.fill"
        case .art: "paintpalette.fill"
        case .shopping: "bag.fill"
        case .nightlife: "moon.stars.fill"
        case .family: "figure.2.and.child.holdinghands"
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
