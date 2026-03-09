import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState

    @State private var selectedMode: ExperienceMode = .adult
    @State private var selectedVisitType: String = "tourist"
    @State private var selectedInterests: Set<String> = []
    @State private var selectedTideStation: TideStation = .hyannis
    @State private var notificationsEnabled = true
    @State private var storyTriggersEnabled = true
    @State private var showingSubscription = false
    @State private var showingSignOut = false

    private var auth: AuthManager { .shared }
    private var subscription: SubscriptionManager { .shared }
    private var profileManager: UserProfileManager { .shared }

    var body: some View {
        NavigationStack {
            List {
                profileHeaderSection
                experienceModeSection
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
        selectedMode = profile.experienceMode
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

    // MARK: - Experience Mode

    @ViewBuilder
    private var experienceModeSection: some View {
        Section {
            ForEach(ExperienceMode.allCases) { mode in
                modeCard(mode)
                    .listRowInsets(EdgeInsets(top: CodSpacing.xs, leading: CodSpacing.screenEdge, bottom: CodSpacing.xs, trailing: CodSpacing.screenEdge))
            }
        } header: {
            Text("Experience Mode")
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
            withAnimation(CodAnimation.quick) {
                selectedMode = mode
            }
            CodHaptic.selection()
            updateProfileMode(mode)
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

    private func updateProfileMode(_ mode: ExperienceMode) {
        if let profile = profileManager.currentProfile {
            profile.experienceMode = mode
            profileManager.saveProfile()
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
