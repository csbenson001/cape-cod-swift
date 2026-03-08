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

                WeatherDashboardView()
                    .opacity(appState.selectedTab == .weather ? 1 : 0)

                TrafficView()
                    .opacity(appState.selectedTab == .traffic ? 1 : 0)

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
        HStack(spacing: 0) {
            tabButton(.home)
            tabButton(.explore)

            // Center raised action buttons (voice + chat)
            centerActions
                .offset(y: -CodSpacing.md)

            tabButton(.weather)
            tabButton(.profile)
        }
        .padding(.horizontal, CodSpacing.sm)
        .padding(.top, CodSpacing.sm)
        .padding(.bottom, CodSpacing.xs)
        .background(
            Rectangle()
                .fill(Color.capeCod.surfaceElevated)
                .shadow(color: .black.opacity(0.06), radius: 12, y: -CodSpacing.xs)
                .ignoresSafeArea(edges: .bottom)
        )
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
            VStack(spacing: CodSpacing.xs) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .symbolVariant(isSelected ? .fill : .none)

                Text(tab.title)
                    .codTextStyle(.tabLabel)
            }
            .foregroundStyle(isSelected ? Color.capeCod.primary : Color.capeCod.driftwood)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
        }
        .codAccessibleButton(
            tab.title,
            hint: isSelected ? "Currently selected" : "Switch to \(tab.title) tab"
        )
    }

    // MARK: - Center Actions (Voice + Chat)

    private var centerActions: some View {
        HStack(spacing: CodSpacing.sm) {
            // Chat button
            Button {
                CodHaptic.tap()
                appState.isChatPresented = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.capeCod.cardBackground)
                        .frame(width: 40, height: 40)
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)

                    Image(systemName: "keyboard")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.capeCod.oceanBlue)
                }
            }
            .codAccessibleButton("Text Chat", hint: "Start a text conversation")

            // Voice FAB (primary)
            Button {
                CodHaptic.tap()
                appState.isVoiceAssistantPresented = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.capeCod.oceanGradient)
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.capeCod.oceanBlue.opacity(0.3), radius: CodSpacing.sm, y: CodSpacing.xs)

                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(CodButtonPressStyle(variant: .primary))
            .codAccessibleButton("Voice Assistant", hint: "Start a voice conversation")
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
