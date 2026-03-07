import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var showVoiceAssistant = false

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

                SettingsView()
                    .opacity(appState.selectedTab == .settings ? 1 : 0)
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

            // Center raised voice button
            voiceFAB
                .offset(y: -CodSpacing.md)

            tabButton(.weather)
            tabButton(.traffic)
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
    }

    // MARK: - Tab Button

    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            withAnimation(CodAnimation.tabSwitch) {
                appState.selectedTab = tab
            }
            UISelectionFeedbackGenerator().selectionChanged()
        } label: {
            VStack(spacing: CodSpacing.xs) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: appState.selectedTab == tab ? .semibold : .regular))
                    .symbolVariant(appState.selectedTab == tab ? .fill : .none)

                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(appState.selectedTab == tab ? Color.capeCod.primary : Color.capeCod.driftwood)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Voice FAB

    private var voiceFAB: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
