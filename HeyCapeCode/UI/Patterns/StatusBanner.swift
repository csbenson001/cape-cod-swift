import SwiftUI

// MARK: - StatusBanner

/// Contextual banner that slides in from top with spring animation.
/// Auto-dismisses after 5 seconds or on tap. Color-coded by severity.
struct StatusBanner: View {
    let message: String
    let style: BannerStyle
    var icon: String? = nil
    var actionLabel: String? = nil
    var onAction: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: CodSpacing.sm) {
            // Icon
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(style.foreground)
            }

            // Message
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(style.foreground)
                .lineLimit(2)

            Spacer(minLength: CodSpacing.xs)

            // Optional action button
            if let actionLabel, let onAction {
                Button(action: onAction) {
                    Text(actionLabel)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(style.foreground)
                        .padding(.horizontal, CodSpacing.sm)
                        .padding(.vertical, CodSpacing.xs)
                        .background(style.foreground.opacity(0.2), in: Capsule())
                }
            }
        }
        .padding(.horizontal, CodSpacing.md)
        .padding(.vertical, CodSpacing.sm + 2)
        .background(style.background)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
        .codShadow(.elevated)
        .padding(.horizontal, CodSpacing.screenEdge)
    }
}

// MARK: - Banner Style

enum BannerStyle {
    case info
    case warning
    case danger
    case success

    var background: Color {
        switch self {
        case .info: return Color.capeCod.oceanBlue
        case .warning: return Color.capeCod.sandbarYellow
        case .danger: return Color.capeCod.cranberry
        case .success: return Color.capeCod.seafoam
        }
    }

    var foreground: Color {
        switch self {
        case .info: return .white
        case .warning: return Color(hex: 0x3A2A00)
        case .danger: return .white
        case .success: return Color(hex: 0x0A3A2A)
        }
    }
}

// MARK: - Banner Modifier

/// Attach banners to any view. Manages presentation, animation, and auto-dismiss.
struct BannerModifier: ViewModifier {
    @Binding var banner: BannerData?

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let data = banner {
                StatusBanner(
                    message: data.message,
                    style: data.style,
                    icon: data.icon,
                    actionLabel: data.actionLabel,
                    onAction: {
                        data.onAction?()
                        withAnimation(CodAnimation.spring) {
                            banner = nil
                        }
                    },
                    onDismiss: {
                        withAnimation(CodAnimation.spring) {
                            banner = nil
                        }
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    withAnimation(CodAnimation.spring) {
                        banner = nil
                    }
                }
                .task {
                    try? await Task.sleep(for: .seconds(data.autoDismissAfter))
                    withAnimation(CodAnimation.spring) {
                        banner = nil
                    }
                }
                .padding(.top, CodSpacing.sm)
            }
        }
        .animation(CodAnimation.spring, value: banner != nil)
    }
}

// MARK: - Banner Data

struct BannerData: Equatable {
    let id = UUID()
    let message: String
    let style: BannerStyle
    var icon: String? = nil
    var actionLabel: String? = nil
    var autoDismissAfter: TimeInterval = 5.0
    // Non-equatable action closure — excluded from Equatable
    var onAction: (() -> Void)? = nil

    static func == (lhs: BannerData, rhs: BannerData) -> Bool {
        lhs.id == rhs.id
    }
}

extension View {
    func banner(_ data: Binding<BannerData?>) -> some View {
        modifier(BannerModifier(banner: data))
    }
}

// MARK: - Preview

#Preview("Status Banners") {
    StatusBannerPreview()
}

private struct StatusBannerPreview: View {
    @State private var activeBanner: BannerData?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.lg) {
                    Text("Tap a button to show a banner")
                        .codTextStyle(.body)

                    // Banner triggers
                    bannerButton(
                        "Shark Warning",
                        banner: BannerData(
                            message: "Shark spotted near Nauset Beach — swim with caution",
                            style: .danger,
                            icon: "exclamationmark.triangle.fill",
                            actionLabel: "Details"
                        )
                    )

                    bannerButton(
                        "Traffic Alert",
                        banner: BannerData(
                            message: "Sagamore Bridge: 45 min delay",
                            style: .warning,
                            icon: "car.fill",
                            actionLabel: "Routes"
                        )
                    )

                    bannerButton(
                        "Tide Alert",
                        banner: BannerData(
                            message: "Low tide at Skaket in 30 min — perfect for tide pooling!",
                            style: .info,
                            icon: "water.waves"
                        )
                    )

                    bannerButton(
                        "Trip Saved",
                        banner: BannerData(
                            message: "Your Cape Cod trip was saved successfully.",
                            style: .success,
                            icon: "checkmark.circle.fill"
                        )
                    )

                    // Static showcase of all styles
                    VStack(spacing: CodSpacing.md) {
                        Text("All Styles").codTextStyle(.sectionTitle)

                        StatusBanner(
                            message: "Shark spotted near Nauset Beach",
                            style: .danger,
                            icon: "exclamationmark.triangle.fill",
                            actionLabel: "Details"
                        )

                        StatusBanner(
                            message: "Sagamore Bridge: 45 min delay",
                            style: .warning,
                            icon: "car.fill",
                            actionLabel: "Routes"
                        )

                        StatusBanner(
                            message: "Low tide at Skaket in 30 min",
                            style: .info,
                            icon: "water.waves"
                        )

                        StatusBanner(
                            message: "Trip saved successfully",
                            style: .success,
                            icon: "checkmark.circle.fill"
                        )
                    }
                    .padding(.top, CodSpacing.xl)
                }
                .padding(CodSpacing.screenEdge)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Banners")
        }
        .banner($activeBanner)
    }

    private func bannerButton(_ label: String, banner data: BannerData) -> some View {
        CodButton(label, variant: .secondary) {
            withAnimation(CodAnimation.spring) {
                activeBanner = data
            }
        }
    }
}
