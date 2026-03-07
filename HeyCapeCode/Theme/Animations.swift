import SwiftUI

// MARK: - Cape Cod Animation Constants

/// Reusable animation curves inspired by ocean waves —
/// smooth, natural, never frantic.
enum CodAnimation {
    /// Smooth spring for UI interactions (cards, sheets, navigation)
    static let spring = Animation.spring(response: 0.35, dampingFraction: 0.7)

    /// Quick spring for button presses and micro-interactions
    static let quick = Animation.spring(response: 0.25, dampingFraction: 0.8)

    /// Gentle ease for background animations and ambient motion
    static let gentle = Animation.easeInOut(duration: 1.0)

    /// Repeating pulse for drawing attention (voice button idle state)
    static let pulse = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)

    /// Shimmer animation for loading skeletons
    static let shimmer = Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: false)

    /// Waveform animation for audio visualization
    static let waveform = Animation.spring(response: 0.15, dampingFraction: 0.6)

    /// Rotation for thinking spinner
    static let orbit = Animation.linear(duration: 2.0).repeatForever(autoreverses: false)

    /// Bouncy spring for favorite/like button
    static let bouncy = Animation.spring(response: 0.3, dampingFraction: 0.5)

    /// Tab content cross-fade
    static let tabSwitch = Animation.easeInOut(duration: 0.2)
}

// MARK: - Stagger Animation Modifier

/// Applies staggered appearance animation to list items.
/// Each item delays by `staggerInterval` * its index.
struct StaggeredAppearance: ViewModifier {
    let index: Int
    let staggerInterval: Double

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 12)
            .onAppear {
                withAnimation(CodAnimation.spring.delay(Double(index) * staggerInterval)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    /// Animates view appearance with a stagger delay based on index.
    func staggered(index: Int, interval: Double = 0.05) -> some View {
        modifier(StaggeredAppearance(index: index, staggerInterval: interval))
    }
}

// MARK: - Animated Counter

/// Smoothly animates between numeric values (odometer effect).
struct AnimatedCounter: View {
    let value: Int
    let font: Font
    let color: Color

    @State private var displayedValue: Int = 0

    init(_ value: Int, font: Font = CapeCodTypography.metric(), color: Color = Color.capeCod.textPrimary) {
        self.value = value
        self.font = font
        self.color = color
    }

    var body: some View {
        Text("\(displayedValue)")
            .font(font)
            .monospacedDigit()
            .foregroundStyle(color)
            .contentTransition(.numericText(value: displayedValue))
            .animation(CodAnimation.spring, value: displayedValue)
            .onChange(of: value) { _, newValue in
                displayedValue = newValue
            }
            .onAppear {
                displayedValue = value
            }
    }
}

// MARK: - Pulsing Glow

/// Wraps content with a subtle pulsing glow for active/live metrics.
struct PulsingGlow: ViewModifier {
    let color: Color
    let isActive: Bool

    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .shadow(
                color: isActive ? color.opacity(isPulsing ? 0.3 : 0.1) : .clear,
                radius: isPulsing ? 8 : 4
            )
            .onAppear {
                guard isActive else { return }
                withAnimation(CodAnimation.pulse) {
                    isPulsing = true
                }
            }
            .onChange(of: isActive) { _, active in
                if active {
                    withAnimation(CodAnimation.pulse) {
                        isPulsing = true
                    }
                } else {
                    isPulsing = false
                }
            }
    }
}

extension View {
    func pulsingGlow(color: Color, isActive: Bool = true) -> some View {
        modifier(PulsingGlow(color: color, isActive: isActive))
    }
}

// MARK: - Transition Helpers

extension AnyTransition {
    /// Slide up and fade in — for content appearing on screen
    static var codSlideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }

    /// Scale and fade — for elements appearing in-place
    static var codScale: AnyTransition {
        .scale(scale: 0.9).combined(with: .opacity)
    }

    /// Cross-fade for tab content switching
    static var codCrossFade: AnyTransition {
        .opacity
    }

    /// Map pin drop animation
    static var codPinDrop: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.3, anchor: .bottom).combined(with: .opacity),
            removal: .scale(scale: 0.8).combined(with: .opacity)
        )
    }
}
