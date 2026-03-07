import SwiftUI

// MARK: - CodButton

/// The button system for Hey Cape Cod.
/// Variants: `.primary`, `.secondary`, `.accent`, `.ghost`, `.icon`.
struct CodButton: View {
    let title: String
    let variant: CodButtonVariant
    let icon: String?
    let isFullWidth: Bool
    let action: () -> Void

    init(
        _ title: String,
        variant: CodButtonVariant = .primary,
        icon: String? = nil,
        isFullWidth: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.icon = icon
        self.isFullWidth = isFullWidth
        self.action = action
    }

    var body: some View {
        Button(action: {
            triggerHaptic()
            action()
        }) {
            HStack(spacing: CodSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(minHeight: 50)
            .padding(.horizontal, CodSpacing.lg)
            .foregroundStyle(variant.foregroundColor)
            .background(variant.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
            .overlay {
                if variant == .secondary {
                    RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous)
                        .strokeBorder(Color.capeCod.oceanBlue, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(CodButtonPressStyle(variant: variant))
    }

    private func triggerHaptic() {
        switch variant {
        case .primary, .accent:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        default:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

// MARK: - Icon-Only Button

/// Circular icon button for toolbar actions.
struct CodIconButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void

    init(_ icon: String, size: CGFloat = 44, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(Color.capeCod.primary)
                .frame(width: size, height: size)
                .background(Color.capeCod.surface)
                .clipShape(Circle())
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
    }
}

// MARK: - Button Variant

enum CodButtonVariant {
    case primary
    case secondary
    case accent
    case ghost

    var backgroundColor: Color {
        switch self {
        case .primary: return Color.capeCod.oceanBlue
        case .secondary: return .clear
        case .accent: return Color.capeCod.sunsetOrange
        case .ghost: return .clear
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary: return Color.capeCod.textOnPrimary
        case .secondary: return Color.capeCod.oceanBlue
        case .accent: return Color.capeCod.textOnPrimary
        case .ghost: return Color.capeCod.oceanBlue
        }
    }
}

// MARK: - Press Style

struct CodButtonPressStyle: ButtonStyle {
    let variant: CodButtonVariant

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.capeCodQuick, value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Buttons") {
    VStack(spacing: CodSpacing.md) {
        CodButton("Get Directions", variant: .primary, icon: "arrow.triangle.turn.up.right.diamond.fill", isFullWidth: true) {}
        CodButton("Save to Trip", variant: .secondary, icon: "bookmark") {}
        CodButton("Start Tour", variant: .accent, icon: "play.fill", isFullWidth: true) {}
        CodButton("Learn More", variant: .ghost, icon: "arrow.right") {}
        HStack(spacing: CodSpacing.md) {
            CodIconButton("heart") {}
            CodIconButton("square.and.arrow.up") {}
            CodIconButton("ellipsis") {}
        }
    }
    .padding(CodSpacing.screenEdge)
    .background(Color.capeCod.background)
}
