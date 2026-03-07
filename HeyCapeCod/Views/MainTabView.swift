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

    // MARK: - Voice FAB

    private var voiceFAB: some View {
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
        .frame(maxWidth: .infinity)
        .codAccessibleButton("Voice Assistant", hint: "Start a voice conversation")
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
