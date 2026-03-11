import SwiftUI

/// A persistent banner that slides down from the top when the device is offline.
/// Tappable to navigate to offline status details. Dismissable but reappears on navigation.
struct OfflineBanner: View {
    let isOffline: Bool
    var onTap: (() -> Void)? = nil

    @State private var isDismissed = false
    @State private var showBanner = false

    var body: some View {
        if isOffline && !isDismissed {
            bannerContent
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    withAnimation(CodAnimation.spring) {
                        showBanner = true
                    }
                }
                .onChange(of: isOffline) { _, offline in
                    if offline {
                        isDismissed = false
                        withAnimation(CodAnimation.spring) {
                            showBanner = true
                        }
                    }
                }
        }
    }

    private var bannerContent: some View {
        Button {
            CodHaptic.light()
            onTap?()
        } label: {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.capeCod.sunsetOrange)

                Text("You're offline — showing cached data")
                    .codTextStyle(.bannerText)
                    .foregroundStyle(Color.capeCod.textPrimary)

                Spacer()

                Button {
                    withAnimation(CodAnimation.quick) {
                        isDismissed = true
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.capeCod.textSecondary)
                        .frame(width: 24, height: 24)
                }
                .codAccessibleButton("Dismiss offline banner")
            }
            .padding(.horizontal, CodSpacing.md)
            .padding(.vertical, CodSpacing.sm + 2)
            .background(
                RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous)
                    .fill(Color.capeCod.sand.opacity(0.9))
            )
            .adaptiveCardStyle(cornerRadius: CodRadius.chip)
            .padding(.horizontal, CodSpacing.screenEdge)
        }
        .codAccessibleButton(
            "Offline mode active",
            hint: "Tap to see cached data details"
        )
    }
}

// MARK: - View Extension for Easy Usage

extension View {
    /// Overlays an offline banner at the top of the view.
    func offlineBanner(
        isOffline: Bool,
        onTap: (() -> Void)? = nil
    ) -> some View {
        overlay(alignment: .top) {
            OfflineBanner(isOffline: isOffline, onTap: onTap)
                .padding(.top, CodSpacing.xs)
        }
        .animation(CodAnimation.spring, value: isOffline)
    }
}

#Preview {
    VStack {
        OfflineBanner(isOffline: true)
        Spacer()
    }
    .background(Color.capeCod.background)
}
