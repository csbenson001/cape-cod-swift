import SwiftUI

/// 4-page onboarding flow:
/// 1. Welcome animation with app branding
/// 2. Choose experience mode (kids/teen/adult/family)
/// 3. Select interests (beaches, history, food, etc.)
/// 4. Optional sign-in with skip
struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0
    @State private var selectedMode: ExperienceMode = .adult
    @State private var selectedInterests: Set<String> = []
    @State private var showSignIn = false

    private let totalPages = 4

    var body: some View {
        ZStack {
            Color.capeCod.background.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    modePage.tag(1)
                    interestsPage.tag(2)
                    signInPage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.capeCodSpring, value: currentPage)

                bottomControls
                    .padding(.horizontal, CodSpacing.screenEdge)
                    .padding(.bottom, CodSpacing.lg)
            }
        }
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: CodSpacing.xl) {
            Spacer()

            Image(systemName: "beach.umbrella.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.capeCod.oceanGradient)

            VStack(spacing: CodSpacing.md) {
                Text("Hey Cape Cod")
                    .codTextStyle(.heroTitle)

                Text("Your AI-powered Cape Cod companion.\nDiscover stories, check tides, find the perfect beach \u{2014} all hands-free.")
                    .codTextStyle(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CodSpacing.xl)
            }

            VStack(alignment: .leading, spacing: CodSpacing.md) {
                featureHighlight(icon: "mic.fill", color: Color.capeCod.sunsetOrange, text: "Voice-powered conversations about Cape Cod")
                    .staggered(index: 0, interval: 0.1)
                featureHighlight(icon: "location.fill", color: Color.capeCod.oceanBlue, text: "GPS-triggered stories as you explore")
                    .staggered(index: 1, interval: 0.1)
                featureHighlight(icon: "water.waves", color: Color.capeCod.seafoam, text: "Live tides, weather, and beach conditions")
                    .staggered(index: 2, interval: 0.1)
                featureHighlight(icon: "car.fill", color: Color.capeCod.duneGrass, text: "Real-time bridge and traffic updates")
                    .staggered(index: 3, interval: 0.1)
            }
            .padding(.horizontal, CodSpacing.xl)

            Spacer()
        }
    }

    private func featureHighlight(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: CodSpacing.md) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 28)
            Text(text)
                .codTextStyle(.body)
        }
    }

    // MARK: - Page 2: Choose Mode

    private var modePage: some View {
        VStack(spacing: CodSpacing.lg) {
            Spacer()

            VStack(spacing: CodSpacing.sm) {
                Text("Who's exploring today?")
                    .codTextStyle(.heroTitle)

                Text("We'll tailor stories and recommendations to your group.")
                    .codTextStyle(.body)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: CodSpacing.md) {
                ForEach(ExperienceMode.allCases) { mode in
                    modeCard(mode)
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)

            Spacer()
        }
    }

    private func modeCard(_ mode: ExperienceMode) -> some View {
        let isSelected = selectedMode == mode

        return HStack(spacing: CodSpacing.md) {
            Image(systemName: modeIcon(mode))
                .font(.title2)
                .foregroundStyle(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.driftwood)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(mode.displayName)
                    .codTextStyle(.cardTitle)
                Text(modeDescription(mode))
                    .codTextStyle(.caption)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(isSelected ? Color.capeCod.oceanBlue.opacity(0.08) : Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .stroke(isSelected ? Color.capeCod.oceanBlue : .clear, lineWidth: 2)
        )
        .onTapGesture {
            withAnimation(CodAnimation.quick) { selectedMode = mode }
            CodHaptic.selection()
        }
        .codAccessibleCard(
            label: "\(mode.displayName): \(modeDescription(mode))",
            hint: isSelected ? "Currently selected" : "Double tap to select"
        )
    }

    private func modeIcon(_ mode: ExperienceMode) -> String {
        switch mode {
        case .kids: "figure.child"
        case .teen: "figure.wave"
        case .adult: "figure.hiking"
        case .family: "figure.2.and.child.holdinghands"
        }
    }

    private func modeDescription(_ mode: ExperienceMode) -> String {
        switch mode {
        case .kids: "Fun facts, pirate stories, and nature adventures"
        case .teen: "Cool history, local legends, and hidden gems"
        case .adult: "In-depth history, dining tips, and local insights"
        case .family: "Something for everyone \u{2014} balanced and engaging"
        }
    }

    // MARK: - Page 3: Select Interests

    private var interestsPage: some View {
        VStack(spacing: CodSpacing.lg) {
            Spacer()

            VStack(spacing: CodSpacing.sm) {
                Text("What interests you?")
                    .codTextStyle(.heroTitle)

                Text("Pick a few topics and we'll highlight what matters to you.")
                    .codTextStyle(.body)
                    .multilineTextAlignment(.center)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: CodSpacing.sm)], spacing: CodSpacing.sm) {
                ForEach(Interest.allCases) { interest in
                    interestPill(interest)
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)

            Spacer()
        }
    }

    private func interestPill(_ interest: Interest) -> some View {
        let isSelected = selectedInterests.contains(interest.rawValue)

        return VStack(spacing: CodSpacing.xs) {
            Image(systemName: interest.icon)
                .font(.title3)
            Text(interest.displayName)
                .codTextStyle(.label)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CodSpacing.md)
        .foregroundStyle(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.textSecondary)
        .background(isSelected ? Color.capeCod.oceanBlue.opacity(0.1) : Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .stroke(isSelected ? Color.capeCod.oceanBlue : .clear, lineWidth: 1.5)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(CodAnimation.bouncy, value: isSelected)
        .onTapGesture {
            if isSelected {
                selectedInterests.remove(interest.rawValue)
            } else {
                selectedInterests.insert(interest.rawValue)
            }
            CodHaptic.selection()
        }
        .codAccessibleButton(
            "\(interest.displayName)",
            hint: isSelected ? "Selected. Double tap to remove." : "Double tap to add."
        )
    }

    // MARK: - Page 4: Sign In

    private var signInPage: some View {
        VStack(spacing: CodSpacing.lg) {
            Spacer()

            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 56))
                .foregroundStyle(Color.capeCod.oceanBlue)

            VStack(spacing: CodSpacing.sm) {
                Text("Create an Account")
                    .codTextStyle(.heroTitle)

                Text("Save your preferences, sync across devices, and track your Cape Cod adventures.")
                    .codTextStyle(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CodSpacing.xl)
            }

            VStack(spacing: CodSpacing.md) {
                SignInWithAppleButton {
                    Task {
                        try? await AuthManager.shared.signInWithApple()
                        completeOnboarding()
                    }
                }
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))

                Button {
                    AuthManager.shared.continueAsGuest()
                    completeOnboarding()
                } label: {
                    Text("Continue as Guest")
                        .codTextStyle(.body)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .background(Color.capeCod.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous)
                                .stroke(Color.capeCod.oceanBlue, lineWidth: 1.5)
                        )
                }
            }
            .padding(.horizontal, CodSpacing.xl)

            Text("You can always sign in later from Settings.")
                .codTextStyle(.caption)

            Spacer()
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        HStack {
            HStack(spacing: CodSpacing.xs) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? Color.capeCod.oceanBlue : Color.capeCod.driftwood.opacity(0.3))
                        .frame(width: index == currentPage ? 20 : 6, height: 6)
                        .animation(.capeCodQuick, value: currentPage)
                }
            }
            .codAccessible(label: "Page \(currentPage + 1) of \(totalPages)")

            Spacer()

            if currentPage < totalPages - 1 {
                HStack(spacing: CodSpacing.md) {
                    if currentPage > 0 {
                        Button("Skip") {
                            withAnimation { currentPage = totalPages - 1 }
                        }
                        .codTextStyle(.body)
                        .foregroundStyle(Color.capeCod.driftwood)
                    }

                    Button {
                        withAnimation(.capeCodSpring) { currentPage += 1 }
                        CodHaptic.light()
                    } label: {
                        HStack(spacing: CodSpacing.xs) {
                            Text("Next")
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
            }
        }
    }

    // MARK: - Helpers

    private func completeOnboarding() {
        CodHaptic.success()
        if let profile = UserProfileManager.shared.currentProfile {
            profile.experienceMode = selectedMode
            profile.interests = Array(selectedInterests)
            UserProfileManager.shared.saveProfile()
        }
        appState.hasCompletedOnboarding = true
    }
}

// MARK: - Sign In with Apple Button

private struct SignInWithAppleButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "apple.logo")
                    .font(.title3)
                Text("Sign in with Apple")
                    .codTextStyle(.cardTitle)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundStyle(.white)
            .background(.black)
        }
        .codAccessibleButton("Sign in with Apple")
    }
}

// MARK: - Interest

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
