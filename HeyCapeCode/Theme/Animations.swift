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
}
