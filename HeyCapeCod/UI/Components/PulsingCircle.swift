import SwiftUI

// MARK: - Voice Assistant State

enum VoiceAssistantState: Equatable {
    case idle
    case connecting
    case listening
    case thinking
    case speaking
    case error
}

// MARK: - PulsingCircle

/// The hero voice assistant button for Hey Cape Cod.
/// Three concentric circles that pulse outward. Transitions smoothly between states.
struct PulsingCircle: View {
    let state: VoiceAssistantState
    let audioLevels: [CGFloat]
    let onTap: () -> Void

    @State private var pulseScale: CGFloat = 1.0
    @State private var outerPulseScale: CGFloat = 1.0
    @State private var rotationAngle: Angle = .zero
    @State private var connectingDots: CGFloat = 0.0

    private let centerSize: CGFloat = 80

    init(
        state: VoiceAssistantState = .idle,
        audioLevels: [CGFloat] = [],
        onTap: @escaping () -> Void
    ) {
        self.state = state
        self.audioLevels = audioLevels
        self.onTap = onTap
    }

    var body: some View {
        VStack(spacing: CodSpacing.md) {
            ZStack {
                // Outer pulse ring
                Circle()
                    .fill(stateColor.opacity(0.08))
                    .frame(width: centerSize + CodSpacing.xxl, height: centerSize + CodSpacing.xxl)
                    .scaleEffect(outerPulseScale)

                // Middle pulse ring
                Circle()
                    .fill(stateColor.opacity(0.15))
                    .frame(width: centerSize + CodSpacing.lg, height: centerSize + CodSpacing.lg)
                    .scaleEffect(pulseScale)

                // Waveform ring (listening/speaking states)
                if state == .listening || state == .speaking {
                    WaveformView(
                        levels: audioLevels,
                        style: .circular(radius: centerSize / 2 + CodSpacing.xs),
                        color: stateColor,
                        barCount: 48
                    )
                }

                // Thinking orbital animation
                if state == .thinking {
                    thinkingOrbit
                }

                // Connecting dots
                if state == .connecting {
                    connectingAnimation
                }

                // Center button
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onTap()
                }) {
                    ZStack {
                        Circle()
                            .fill(centerGradient)
                            .frame(width: centerSize, height: centerSize)
                            .shadow(color: stateColor.opacity(0.3), radius: 12, y: CodSpacing.xs)

                        Image(systemName: stateIcon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
                .buttonStyle(CodButtonPressStyle(variant: .primary))
            }
            .frame(width: centerSize + 60, height: centerSize + 60)

            // Status label
            Text(stateLabel)
                .codTextStyle(.caption)
                .animation(.capeCodQuick, value: state)
        }
        .onChange(of: state) { _, newState in
            updateAnimations(for: newState)
        }
        .onAppear {
            updateAnimations(for: state)
        }
    }

    // MARK: - Thinking Orbit

    private var thinkingOrbit: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(stateColor)
                    .frame(width: CodSpacing.sm, height: CodSpacing.sm)
                    .offset(y: -(centerSize / 2 + CodSpacing.md))
                    .rotationEffect(rotationAngle + .degrees(Double(index) * 120))
            }
        }
    }

    // MARK: - Connecting Animation

    private var connectingAnimation: some View {
        HStack(spacing: CodSpacing.sm - 2) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(.white)
                    .frame(width: CodSpacing.sm - 2, height: CodSpacing.sm - 2)
                    .opacity(connectingDots > CGFloat(index) ? 1.0 : 0.3)
            }
        }
        .offset(y: centerSize / 2 + CodSpacing.screenEdge)
    }

    // MARK: - State Properties

    private var stateColor: Color {
        switch state {
        case .idle: return Color.capeCod.oceanBlue
        case .connecting: return Color.capeCod.oceanBlue
        case .listening: return Color.capeCod.aiListening
        case .thinking: return Color.capeCod.aiThinking
        case .speaking: return Color.capeCod.aiSpeaking
        case .error: return Color.capeCod.cranberry
        }
    }

    private var centerGradient: LinearGradient {
        switch state {
        case .idle, .connecting:
            return Color.capeCod.oceanGradient
        case .listening:
            return LinearGradient(colors: [Color.capeCod.seafoam, Color.capeCod.oceanBlue],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        case .thinking, .speaking:
            return Color.capeCod.sunsetGradient
        case .error:
            return LinearGradient(colors: [Color.capeCod.cranberry, Color.capeCod.lobsterRed],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var stateIcon: String {
        switch state {
        case .idle: return "mic.fill"
        case .connecting: return "mic.fill"
        case .listening: return "waveform"
        case .thinking: return "ellipsis"
        case .speaking: return "speaker.wave.2.fill"
        case .error: return "exclamationmark.triangle.fill"
        }
    }

    private var stateLabel: String {
        switch state {
        case .idle: return "Tap to ask"
        case .connecting: return "Connecting..."
        case .listening: return "Listening..."
        case .thinking: return "Thinking..."
        case .speaking: return "Speaking..."
        case .error: return "Tap to retry"
        }
    }

    // MARK: - Animation Control

    private func updateAnimations(for newState: VoiceAssistantState) {
        pulseScale = 1.0
        outerPulseScale = 1.0
        rotationAngle = .zero
        connectingDots = 0.0

        switch newState {
        case .idle:
            withAnimation(CodAnimation.pulse) {
                pulseScale = 1.08
                outerPulseScale = 1.12
            }

        case .connecting:
            withAnimation(CodAnimation.pulse.speed(2)) {
                pulseScale = 1.06
                outerPulseScale = 1.1
            }
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                connectingDots = 3.0
            }

        case .listening, .speaking:
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulseScale = 1.04
            }

        case .thinking:
            withAnimation(CodAnimation.orbit) {
                rotationAngle = .degrees(360)
            }
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }

        case .error:
            withAnimation(.capeCodQuick) {
                pulseScale = 1.0
                outerPulseScale = 1.0
            }
        }
    }
}

// MARK: - Preview

#Preview("Voice Button States") {
    let sampleAudio: [CGFloat] = (0..<48).map { i in
        0.2 + 0.8 * abs(sin(CGFloat(i) / 48 * .pi * 4))
    }

    ScrollView(.horizontal) {
        HStack(spacing: CodSpacing.xl) {
            VStack {
                PulsingCircle(state: .idle) {}
                Text("Idle").codTextStyle(.caption)
            }
            VStack {
                PulsingCircle(state: .listening, audioLevels: sampleAudio) {}
                Text("Listening").codTextStyle(.caption)
            }
            VStack {
                PulsingCircle(state: .thinking) {}
                Text("Thinking").codTextStyle(.caption)
            }
            VStack {
                PulsingCircle(state: .speaking, audioLevels: sampleAudio) {}
                Text("Speaking").codTextStyle(.caption)
            }
            VStack {
                PulsingCircle(state: .error) {}
                Text("Error").codTextStyle(.caption)
            }
        }
        .padding(CodSpacing.xl)
    }
    .background(Color.capeCod.background)
}
