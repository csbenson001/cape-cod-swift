import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        ZStack(alignment: .bottom) {
            // Tab content with cross-fade transition
            ZStack {
                HomeView()
                    .opacity(appState.selectedTab == .home ? 1 : 0)

                ExploreView()
                    .opacity(appState.selectedTab == .explore ? 1 : 0)

                TourListView()
                    .opacity(appState.selectedTab == .tours ? 1 : 0)

                RestaurantListView()
                    .opacity(appState.selectedTab == .dining ? 1 : 0)

                ProfileView()
                    .opacity(appState.selectedTab == .profile ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(CodAnimation.tabSwitch, value: appState.selectedTab)

            // Custom tab bar
            customTabBar
        }
        .background(Color.capeCod.background)
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
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        VStack(spacing: 0) {
            // Floating FABs above the tab bar
            HStack(spacing: CodSpacing.sm) {
                Spacer()

                // Text chat FAB
                chatFAB

                // Voice FAB (primary)
                voiceFAB
            }
            .padding(.trailing, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.sm)

            // Tab bar
            HStack(spacing: 0) {
                tabButton(.home)
                tabButton(.explore)
                tabButton(.tours)
                tabButton(.dining)
                tabButton(.profile)
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
        .codAccessible(label: "Tab bar")
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
