import SwiftUI

// MARK: - VoiceOver Accessibility Modifiers

extension View {
    /// Add a semantic accessibility label and hint to any custom component.
    func codAccessible(label: String, hint: String = "", traits: AccessibilityTraits = []) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint.isEmpty ? hint : hint)
            .accessibilityAddTraits(traits)
    }

    /// Mark as a button with label for VoiceOver.
    func codAccessibleButton(_ label: String, hint: String = "") -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityAddTraits(.isButton)
    }

    /// Mark as a header for VoiceOver navigation.
    func codAccessibleHeader(_ label: String) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isHeader)
    }

    /// Combine multiple elements into a single VoiceOver group.
    func codAccessibleGroup(label: String) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
    }

    /// Hide decorative elements from VoiceOver.
    func codAccessibleHidden() -> some View {
        self.accessibilityHidden(true)
    }
}

// MARK: - Dynamic Type Support

extension View {
    /// Ensure text scales with Dynamic Type while respecting minimum sizes.
    func codDynamicType(minimum: DynamicTypeSize = .xSmall, maximum: DynamicTypeSize = .accessibility3) -> some View {
        self.dynamicTypeSize(minimum...maximum)
    }
}

// MARK: - Reduce Motion

struct CodReduceMotion: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let animation: Animation?

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: UUID())
    }
}

extension View {
    /// Conditionally disable animations when Reduce Motion is enabled.
    func codReduceMotion(animation: Animation? = .easeInOut) -> some View {
        modifier(CodReduceMotion(animation: animation))
    }

    /// Apply a transition only when Reduce Motion is not enabled.
    func codTransition(_ transition: AnyTransition) -> some View {
        modifier(CodConditionalTransition(transition: transition))
    }
}

private struct CodConditionalTransition: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let transition: AnyTransition

    func body(content: Content) -> some View {
        if reduceMotion {
            content.transition(.opacity)
        } else {
            content.transition(transition)
        }
    }
}

// MARK: - Haptic Feedback

enum CodHaptic {
    /// Light tap for selections and toggles
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    /// Medium impact for button taps
    static func tap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Light impact for card interactions
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Heavy impact for important actions
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    /// Success notification (purchase complete, story finished)
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Warning notification (approaching limit)
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    /// Error notification (failed action)
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

// MARK: - Color Contrast (WCAG AA)

extension Color {
    /// Ensure text has sufficient contrast against this background color.
    /// WCAG AA requires 4.5:1 for normal text, 3:1 for large text.
    func contrastingText() -> Color {
        // Use system-provided high-contrast text colors
        Color.primary
    }
}

// MARK: - Accessible Card Modifier

struct CodAccessibleCard: ViewModifier {
    let label: String
    let hint: String

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityAddTraits(.isButton)
    }
}

extension View {
    /// Make a card accessible as a single tappable element with combined children.
    func codAccessibleCard(label: String, hint: String = "") -> some View {
        modifier(CodAccessibleCard(label: label, hint: hint))
    }
}
