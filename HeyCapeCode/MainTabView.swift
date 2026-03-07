import SwiftUI

// MARK: - MainTabView

/// The root tab navigation for Hey Cape Cod.
/// Voice tab has a raised center button to emphasize it as THE primary feature.
struct MainTabView: View {
    @State private var selectedTab: CodTab = .explore
    @State private var showVoiceAssistant = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case .explore:
                    placeholderView("Explore", icon: "map.fill")
                case .traffic:
                    placeholderView("Traffic", icon: "car.fill")
                case .voice:
                    EmptyView() // Voice is presented as a sheet/overlay
                case .beach:
                    placeholderView("Beaches", icon: "sun.max.fill")
                case .settings:
                    placeholderView("Settings", icon: "gearshape.fill")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            customTabBar
        }
        .background(Color.capeCod.background)
        .sheet(isPresented: $showVoiceAssistant) {
            voiceAssistantSheet
        }
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(.explore)
            tabButton(.traffic)

            // Center raised voice button
            voiceFAB
                .offset(y: -16)

            tabButton(.beach)
            tabButton(.settings)
        }
        .padding(.horizontal, CodSpacing.sm)
        .padding(.top, CodSpacing.sm)
        .padding(.bottom, CodSpacing.xs)
        .background(
            Rectangle()
                .fill(Color.capeCod.surfaceElevated)
                .shadow(color: .black.opacity(0.06), radius: 12, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Tab Button

    private func tabButton(_ tab: CodTab) -> some View {
        Button {
            withAnimation(.capeCodQuick) {
                selectedTab = tab
            }
            UISelectionFeedbackGenerator().selectionChanged()
        } label: {
            VStack(spacing: CodSpacing.xs) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                    .symbolVariant(selectedTab == tab ? .fill : .none)

                Text(tab.label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(selectedTab == tab ? Color.capeCod.primary : Color.capeCod.driftwood)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Voice FAB (Floating Action Button)

    private var voiceFAB: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            showVoiceAssistant = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color.capeCod.oceanGradient)
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.capeCod.oceanBlue.opacity(0.3), radius: 8, y: 4)

                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(CodButtonPressStyle(variant: .primary))
        .frame(maxWidth: .infinity)
    }

    // MARK: - Placeholder Content

    private func placeholderView(_ title: String, icon: String) -> some View {
        VStack(spacing: CodSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Color.capeCod.primary)
            Text(title)
                .codTextStyle(.heroTitle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Voice Assistant Sheet

    private var voiceAssistantSheet: some View {
        VStack(spacing: CodSpacing.xl) {
            Spacer()
            PulsingCircle(state: .idle) {
                // Handle voice tap
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.capeCod.background)
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Tab Enum

enum CodTab: String, CaseIterable {
    case explore, traffic, voice, beach, settings

    var icon: String {
        switch self {
        case .explore: return "map"
        case .traffic: return "car"
        case .voice: return "waveform.circle"
        case .beach: return "sun.max"
        case .settings: return "gearshape"
        }
    }

    var label: String {
        switch self {
        case .explore: return "Explore"
        case .traffic: return "Traffic"
        case .voice: return "Voice"
        case .beach: return "Beach"
        case .settings: return "Settings"
        }
    }
}

// MARK: - Preview

#Preview("Main Tab View") {
    MainTabView()
}
