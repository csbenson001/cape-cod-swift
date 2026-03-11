import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    @State private var showOfflineStatus = false

    var body: some View {
        @Bindable var appState = appState

        ZStack(alignment: .bottom) {
            tabContent
            customTabBar
        }
        .background(Color.capeCod.background)
        .offlineBanner(isOffline: !OfflineCacheManager.shared.isOnline) {
            showOfflineStatus = true
        }
        .sheet(isPresented: $showOfflineStatus) {
            NavigationStack {
                OfflineStatusView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showOfflineStatus = false }
                        }
                    }
            }
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $appState.isVoiceAssistantPresented) {
            VoiceAssistantView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $appState.isChatPresented) {
            ChatView()
                .presentationDragIndicator(.visible)
        }
        .alert("Error", isPresented: $appState.showingError) {
            Button("OK") { appState.currentError = nil }
        } message: {
            if let error = appState.currentError {
                Text(error.localizedDescription)
            }
        }
        .onChange(of: appState.experienceMode) { _, newMode in
            // Reset to home if current tab isn't in new mode's tabs
            if !newMode.tabs.contains(appState.selectedTab) {
                appState.selectedTab = .home
            }
        }
    }

    // MARK: - Tab Content

    private var tabContent: some View {
        ZStack {
            ForEach(appState.visibleTabs) { tab in
                tabDestination(tab)
                    .opacity(appState.selectedTab == tab ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(CodAnimation.tabSwitch, value: appState.selectedTab)
    }

    @ViewBuilder
    private func tabDestination(_ tab: AppTab) -> some View {
        switch tab {
        case .home: HomeView()
        case .explore: ExploreView()
        case .tours: TourListView()
        case .dining: RestaurantListView()
        case .stories: TellMeAStoryView()
        case .funZone: FunZoneView()
        case .social: SocialHubView()
        case .events: EventsView()
        case .profile: ProfileView()
        }
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        VStack(spacing: 0) {
            fabRow
            tabBarButtons
        }
        .codAccessible(label: "Tab bar")
    }

    private var fabRow: some View {
        HStack(spacing: CodSpacing.sm) {
            Spacer()
            chatFAB
            voiceFAB
        }
        .padding(.trailing, CodSpacing.screenEdge)
        .padding(.bottom, CodSpacing.sm)
    }

    private var tabBarButtons: some View {
        HStack(spacing: 0) {
            ForEach(appState.visibleTabs) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, CodSpacing.xs)
        .padding(.top, 10)
        .padding(.bottom, CodSpacing.xs)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.capeCod.driftwood.opacity(0.12))
                        .frame(height: 0.5)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Tab Button

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = appState.selectedTab == tab

        return Button {
            withAnimation(CodAnimation.tabSwitch) {
                appState.selectedTab = tab
            }
            CodHaptic.selection()
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .symbolVariant(isSelected ? .fill : .none)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
            }
            .foregroundStyle(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.driftwood)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
        }
        .codAccessibleButton(
            tab.title,
            hint: isSelected ? "Currently selected" : "Switch to \(tab.title) tab"
        )
    }

    // MARK: - Chat FAB

    private var chatFAB: some View {
        Button {
            CodHaptic.tap()
            appState.isChatPresented = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color.capeCod.surfaceElevated)
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 3)

                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }
        }
        .codAccessibleButton("Text Chat", hint: "Open text chat with Cape Cod AI")
    }

    // MARK: - Voice FAB

    private var voiceFAB: some View {
        Menu {
            Button {
                CodHaptic.tap()
                appState.isVoiceAssistantPresented = true
            } label: {
                Label("Voice Assistant", systemImage: "waveform")
            }

            Button {
                CodHaptic.tap()
                appState.isChatPresented = true
            } label: {
                Label("Text Chat", systemImage: "keyboard")
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.capeCod.oceanGradient)
                    .frame(width: 52, height: 52)
                    .shadow(color: Color.capeCod.oceanBlue.opacity(0.25), radius: 10, y: 4)

                Image(systemName: "message.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
        } primaryAction: {
            CodHaptic.tap()
            appState.isVoiceAssistantPresented = true
        }
        .codAccessibleButton("AI Assistant", hint: "Tap for voice, hold for options")
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
