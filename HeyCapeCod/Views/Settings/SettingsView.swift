import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTideStation: TideStation = .hyannis
    @State private var notificationsEnabled = true
    @State private var storyTriggersEnabled = true
    @State private var showingDesignSystem = false
    @State private var showingSubscription = false
    @State private var showingSignOut = false

    private var auth: AuthManager { .shared }
    private var subscription: SubscriptionManager { .shared }

    var body: some View {
        NavigationStack {
            List {
                // Account
                Section {
                    if auth.isAuthenticated && !auth.isGuest {
                        HStack(spacing: CodSpacing.md) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 40))
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
                        .padding(.vertical, CodSpacing.xs)
                    } else {
                        HStack(spacing: CodSpacing.md) {
                            Image(systemName: "person.crop.circle.badge.questionmark")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.capeCod.driftwood)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Guest")
                                    .codTextStyle(.cardTitle)
                                Text("Sign in to sync your data")
                                    .codTextStyle(.caption)
                            }
                        }
                        .padding(.vertical, CodSpacing.xs)

                        Button {
                            CodHaptic.tap()
                            Task { try? await auth.signInWithApple() }
                        } label: {
                            HStack {
                                Image(systemName: "apple.logo")
                                Text("Sign in with Apple")
                            }
                        }
                    }
                } header: {
                    Text("Account")
                }

                // Subscription
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

                // AI Memory
                Section("Assistant") {
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
                }

                // Appearance
                Section("Appearance") {
                    NavigationLink {
                        ThemePickerView()
                    } label: {
                        HStack(spacing: CodSpacing.sm) {
                            Image(systemName: ThemeManager.shared.currentTheme.icon)
                                .font(.title3)
                                .foregroundStyle(Color.capeCod.oceanBlue)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("App Theme")
                                    .codTextStyle(.body)
                                Text(ThemeManager.shared.currentTheme.displayName)
                                    .codTextStyle(.caption)
                                    .foregroundStyle(Color.capeCod.textSecondary)
                            }
                        }
                    }

                    Picker("Mode", selection: Binding(
                        get: { appState.preferredColorScheme },
                        set: { appState.preferredColorScheme = $0 }
                    )) {
                        Text("System").tag(Optional<ColorScheme>.none)
                        Text("Light").tag(Optional<ColorScheme>.some(.light))
                        Text("Dark").tag(Optional<ColorScheme>.some(.dark))
                    }
                }

                // Offline Mode
                Section("Offline") {
                    NavigationLink {
                        OfflineStatusView()
                    } label: {
                        HStack(spacing: CodSpacing.sm) {
                            Image(systemName: OfflineCacheManager.shared.isOnline ? "wifi" : "wifi.slash")
                                .font(.title3)
                                .foregroundStyle(
                                    OfflineCacheManager.shared.isOnline
                                        ? Color.capeCod.duneGrass
                                        : Color.capeCod.sunsetOrange
                                )
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Offline Mode")
                                    .codTextStyle(.body)
                                Text(OfflineCacheManager.shared.isOnline
                                    ? "Connected"
                                    : "Offline — using cached data")
                                    .codTextStyle(.caption)
                                    .foregroundStyle(Color.capeCod.textSecondary)
                            }
                        }
                    }
                }

                // Location
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

                // About
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

                // Sign Out
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

                // Developer
                #if DEBUG
                Section("Developer") {
                    Button("Design System Preview") {
                        showingDesignSystem = true
                    }
                }
                #endif
            }
            .scrollContentBackground(.hidden)
            .background(Color.capeCod.background)
            .navigationTitle("Settings")
            .sheet(isPresented: $showingDesignSystem) {
                NavigationStack {
                    DesignSystemPreview()
                }
            }
            .sheet(isPresented: $showingSubscription) {
                NavigationStack {
                    SubscriptionView()
                }
            }
            .alert("Sign Out", isPresented: $showingSignOut) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    auth.signOut()
                    UserProfileManager.shared.clearProfile()
                }
            } message: {
                Text("Your data will be saved and available when you sign back in.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
