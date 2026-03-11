import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState

    @State private var selectedVisitType: String = "tourist"
    @State private var selectedInterests: Set<String> = []
    @State private var selectedTideStation: TideStation = .hyannis
    @State private var notificationsEnabled = true
    @State private var storyTriggersEnabled = true
    @State private var showingSubscription = false
    @State private var showingSignOut = false
    @State private var showingModeSelector = false

    private var auth: AuthManager { .shared }
    private var subscription: SubscriptionManager { .shared }
    private var profileManager: UserProfileManager { .shared }

    var body: some View {
        NavigationStack {
            List {
                profileHeaderSection
                experienceModeSection
                aiMemorySection
                visitTypeSection
                interestsSection
                appearanceSection
                locationSection
                subscriptionSection
                aboutSection
                signOutSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.capeCod.background)
            .navigationTitle("Profile")
            .sheet(isPresented: $showingSubscription) {
                NavigationStack {
                    SubscriptionView()
                }
            }
            .sheet(isPresented: $showingModeSelector) {
                NavigationStack {
                    ExperienceModeSelectorView()
                }
            }
            .alert("Sign Out", isPresented: $showingSignOut) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    auth.signOut()
                    profileManager.clearProfile()
                }
            } message: {
                Text("Your data will be saved and available when you sign back in.")
            }
            .onAppear {
                loadProfileState()
            }
        }
    }

    // MARK: - Load Profile State

    private func loadProfileState() {
        guard let profile = profileManager.currentProfile else { return }
        appState.experienceMode = profile.experienceMode
        selectedVisitType = profile.visitType
        selectedInterests = Set(profile.interests)
    }

    // MARK: - Profile Header

    @ViewBuilder
    private var profileHeaderSection: some View {
        Section {
            if auth.isAuthenticated && !auth.isGuest {
                HStack(spacing: CodSpacing.md) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.capeCod.oceanBlue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(auth.displayName ?? "User")
                            .codTextStyle(.cardTitle)
                        if let email = auth.email {
                            Text(email)
                                .codTextStyle(.caption)
                        }
                    }
                }
                .padding(.vertical, CodSpacing.sm)
            } else {
                HStack(spacing: CodSpacing.md) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.capeCod.driftwood)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Guest")
                            .codTextStyle(.cardTitle)
                        Text("Sign in to sync your preferences and unlock more features")
                            .codTextStyle(.caption)
                    }
                }
                .padding(.vertical, CodSpacing.sm)

                Button {
                    CodHaptic.tap()
                    Task { try? await auth.signInWithApple() }
                } label: {
                    HStack(spacing: CodSpacing.sm) {
                        Image(systemName: "apple.logo")
                            .font(.title3)
                        Text("Sign in with Apple")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, CodSpacing.sm)
                    .foregroundStyle(.white)
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                }
                .codAccessibleButton("Sign in with Apple")
            }
        } header: {
            Text("Account")
        }
    }

    // MARK: - AI Memory

    @ViewBuilder
    private var aiMemorySection: some View {
        Section {
            NavigationLink {
                ChatMemoryView()
            } label: {
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: "brain")
                        .font(.title3)
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI Memory")
                            .codTextStyle(.body)
                        Text(ChatMemoryManager.shared.isEnabled
                            ? "\(ChatMemoryManager.shared.totalPreferenceCount) saved preferences"
                            : "Off")
                            .codTextStyle(.caption)
                            .foregroundStyle(Color.capeCod.textSecondary)
                    }
                }
            }
        } header: {
            Text("Assistant")
        }
    }

    // MARK: - Experience Mode

    @ViewBuilder
    private var experienceModeSection: some View {
        Section {
            Button {
                CodHaptic.tap()
                showingModeSelector = true
            } label: {
                HStack(spacing: CodSpacing.md) {
                    Image(systemName: appState.experienceMode.icon)
                        .font(.title2)
                        .foregroundStyle(modeAccentColor(appState.experienceMode))
                        .frame(width: 40, height: 40)
                        .background(modeAccentColor(appState.experienceMode).opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(appState.experienceMode.displayName)
                            .codTextStyle(.cardTitle)
                        Text(appState.experienceMode.subtitle)
                            .codTextStyle(.caption)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Color.capeCod.driftwood)
                }
            }
            .codAccessibleButton(
                "Experience Mode: \(appState.experienceMode.displayName)",
                hint: "Tap to change experience mode"
            )
        } header: {
            Text("Experience Mode")
        }
    }

    private func modeAccentColor(_ mode: ExperienceMode) -> Color {
        switch mode {
        case .kids: Color.capeCod.sunsetOrange
        case .teen: Color.capeCod.seafoam
        case .adult: Color.capeCod.oceanBlue
        case .family: Color.capeCod.duneGrass
        }
    }

    // MARK: - Visit Type

    @ViewBuilder
    private var visitTypeSection: some View {
        Section {
            Picker("Visit Type", selection: $selectedVisitType) {
                Text("Local").tag("local")
                Text("Tourist").tag("tourist")
                Text("Day Trip").tag("dayTrip")
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedVisitType) { _, newValue in
                CodHaptic.selection()
                if let profile = profileManager.currentProfile {
                    profile.visitType = newValue
                    profileManager.saveProfile()
                }
            }
        } header: {
            Text("Visit Type")
        }
    }

    // MARK: - Interests

    @ViewBuilder
    private var interestsSection: some View {
        Section {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 100), spacing: CodSpacing.sm)],
                spacing: CodSpacing.sm
            ) {
                ForEach(Interest.allCases) { interest in
                    interestPill(interest)
                }
            }
            .padding(.vertical, CodSpacing.xs)
        } header: {
            Text("Interests")
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
            updateProfileInterests()
        }
        .codAccessibleButton(
            "\(interest.displayName)",
            hint: isSelected ? "Selected. Double tap to remove." : "Double tap to add."
        )
    }

    private func updateProfileInterests() {
        if let profile = profileManager.currentProfile {
            profile.interests = Array(selectedInterests)
            profileManager.saveProfile()
        }
    }

    // MARK: - Appearance

    @ViewBuilder
    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: Binding(
                get: { appState.preferredColorScheme },
                set: { appState.preferredColorScheme = $0 }
            )) {
                Text("System").tag(Optional<ColorScheme>.none)
                Text("Light").tag(Optional<ColorScheme>.some(.light))
                Text("Dark").tag(Optional<ColorScheme>.some(.dark))
            }
        }
    }

    // MARK: - Location & Stories

    @ViewBuilder
    private var locationSection: some View {
        Section("Location & Stories") {
            Picker("Tide Station", selection: $selectedTideStation) {
                ForEach(TideStation.allCases) { station in
                    Text(station.name).tag(station)
                }
            }

            Toggle("GPS Story Triggers", isOn: $storyTriggersEnabled)
                .toggleStyle(.capeCod)

            Toggle("Notifications", isOn: $notificationsEnabled)
                .toggleStyle(.capeCod)
        }
    }

    // MARK: - Subscription

    @ViewBuilder
    private var subscriptionSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Plan")
                        .codTextStyle(.body)
                    Text(subscription.isSubscribed ? subscription.currentPlanName : "Free")
                        .codTextStyle(.caption)
                }
                Spacer()
                if subscription.isSubscribed {
                    Text("Active")
                        .codTextStyle(.label)
                        .foregroundStyle(Color.capeCod.duneGrass)
                        .padding(.horizontal, CodSpacing.sm)
                        .padding(.vertical, CodSpacing.xs)
                        .background(Color.capeCod.duneGrass.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            if !subscription.isSubscribed {
                Button {
                    CodHaptic.light()
                    showingSubscription = true
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(Color.capeCod.sunsetOrange)
                        Text("Upgrade to Premium")
                            .foregroundStyle(Color.capeCod.sunsetOrange)
                    }
                }
            }

            if !subscription.isSubscribed {
                HStack {
                    Text("Voice conversations")
                        .codTextStyle(.body)
                    Spacer()
                    Text("\(PaywallManager.shared.voiceConversationsRemaining)/\(PaywallManager.freeVoiceConversationsPerDay) remaining")
                        .codTextStyle(.caption)
                        .monospacedDigit()
                }

                HStack {
                    Text("Stories")
                        .codTextStyle(.body)
                    Spacer()
                    Text("\(PaywallManager.shared.storiesRemaining)/\(PaywallManager.freeStoriesPerDay) remaining")
                        .codTextStyle(.caption)
                        .monospacedDigit()
                }
            }

            if let expires = subscription.expirationDate, subscription.isSubscribed {
                HStack {
                    Text("Renews")
                        .codTextStyle(.body)
                    Spacer()
                    Text(expires.formatted(.dateTime.month().day().year()))
                        .codTextStyle(.caption)
                }
            }
        } header: {
            Text("Subscription")
        }
    }

    // MARK: - About

    @ViewBuilder
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .codTextStyle(.caption)
            }

            Link(destination: URL(string: "https://heycapecod.com")!) {
                Text("Website")
            }

            Link(destination: URL(string: "https://heycapecod.com/privacy")!) {
                Text("Privacy Policy")
            }
        }
    }

    // MARK: - Sign Out

    @ViewBuilder
    private var signOutSection: some View {
        if auth.isAuthenticated && !auth.isGuest {
            Section {
                Button(role: .destructive) {
                    showingSignOut = true
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
}
