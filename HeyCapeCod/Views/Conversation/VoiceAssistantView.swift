import SwiftUI

/// Full-screen real-time voice conversation UI.
///
/// Features:
/// - Animated orb that responds to audio levels (input & output)
/// - Color shifts: Seafoam (listening) -> Sunset Orange (AI speaking)
/// - Floating bubble particles for coastal atmosphere
/// - Scrolling transcript of the conversation
/// - Swipe down to minimize into a floating mini-bubble
/// - Barge-in detection (tap while AI is speaking)
struct VoiceAssistantView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel = VoiceAssistantViewModel()
    @State private var showEndConfirmation = false

    var body: some View {
        ZStack {
            // Full-screen dark background using theme color
            Color.capeCod.deepNavy
                .ignoresSafeArea()

            // Ambient bubble particles
            if !reduceMotion {
                BubbleParticles()
                    .opacity(0.6)
                    .allowsHitTesting(false)
            }

            if viewModel.isMinimized {
                Color.clear
            } else {
                fullScreenContent
            }
        }
        .statusBarHidden(true)
        .gesture(
            DragGesture(minimumDistance: 80)
                .onEnded { value in
                    if value.translation.height > 80 {
                        viewModel.toggleMinimized()
                    }
                }
        )
        .confirmationDialog("End Conversation?", isPresented: $showEndConfirmation) {
            Button("End Conversation", role: .destructive) {
                viewModel.endConversation()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Full Screen Layout

    private var fullScreenContent: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.top, CodSpacing.sm)

            Spacer()

            // Central orb
            VoiceOrb(
                state: viewModel.state,
                audioLevel: viewModel.activeLevel
            )
            .onTapGesture {
                handleOrbTap()
            }
            .codAccessibleButton(
                orbAccessibilityLabel,
                hint: orbAccessibilityHint
            )

            // State label
            stateLabel
                .padding(.top, CodSpacing.lg)

            Spacer()

            // Transcript
            if !viewModel.transcript.isEmpty {
                transcriptView
                    .transition(.codSlideUp)
            }

            // Bottom controls
            bottomControls
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.lg)
        }
        .animation(CodAnimation.spring, value: viewModel.state)
        .animation(CodAnimation.spring, value: viewModel.transcript.count)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            if viewModel.state.isActive {
                Text(formattedDuration)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            if viewModel.state.isActive {
                Button {
                    viewModel.toggleMinimized()
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .codAccessibleButton("Minimize conversation")
            }

            Button {
                if viewModel.state.isActive {
                    showEndConfirmation = true
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .codAccessibleButton("Close voice assistant")
        }
    }

    // MARK: - State Label

    private var stateLabel: some View {
        VStack(spacing: CodSpacing.sm) {
            Text(viewModel.state.label)
                .codTextStyle(.cardTitle)
                .foregroundStyle(.white.opacity(0.8))
                .contentTransition(.numericText())
                .animation(CodAnimation.tabSwitch, value: viewModel.state)

            if !viewModel.hasConversationsRemaining && viewModel.state == .idle {
                Text("Daily limit reached")
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.sunsetOrange.opacity(0.8))
            } else if viewModel.state == .idle {
                Text("\(viewModel.conversationsRemaining) conversations remaining today")
                    .codTextStyle(.caption)
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
    }

    // MARK: - Transcript

    private var transcriptView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: CodSpacing.md) {
                    ForEach(Array(viewModel.transcript.enumerated()), id: \.element.id) { index, entry in
                        TranscriptBubble(entry: entry)
                            .id(entry.id)
                            .staggered(index: index, interval: 0.03)
                    }
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.vertical, CodSpacing.sm)
            }
            .frame(maxHeight: 220)
            .mask(
                LinearGradient(
                    colors: [.clear, .white, .white, .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .onChange(of: viewModel.transcript.count) {
                if let last = viewModel.transcript.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        HStack {
            if viewModel.state.isActive {
                Button {
                    showEndConfirmation = true
                } label: {
                    Text("End")
                        .codTextStyle(.body)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, CodSpacing.lg)
                        .padding(.vertical, CodSpacing.sm + 2)
                        .background(.white.opacity(0.1))
                        .clipShape(Capsule())
                }
                .codAccessibleButton("End conversation")
            }
        }
    }

    // MARK: - Actions

    private func handleOrbTap() {
        switch viewModel.state {
        case .idle:
            CodHaptic.tap()
            Task { await viewModel.startConversation() }
        case .speaking:
            CodHaptic.light()
            viewModel.handleBargeIn()
        case .error:
            CodHaptic.tap()
            Task { await viewModel.startConversation() }
        default:
            break
        }
    }

    private var formattedDuration: String {
        let minutes = Int(viewModel.conversationDuration) / 60
        let seconds = Int(viewModel.conversationDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Accessibility

    private var orbAccessibilityLabel: String {
        switch viewModel.state {
        case .idle: "Start voice conversation"
        case .connecting: "Connecting"
        case .listening: "Listening to you"
        case .processing: "Processing your question"
        case .speaking: "AI is responding. Tap to interrupt."
        case .error: "Error occurred. Tap to retry."
        }
    }

    private var orbAccessibilityHint: String {
        switch viewModel.state {
        case .idle: "Double tap to start a voice conversation with Cape Cod AI"
        case .speaking: "Double tap to interrupt and ask a new question"
        default: ""
        }
    }
}

// MARK: - Voice Orb

private struct VoiceOrb: View {
    let state: VoiceAssistantViewModel.VoiceState
    let audioLevel: Float

    @State private var idlePulse: CGFloat = 1.0
    @State private var orbitAngle: Double = 0
    @State private var breathe: CGFloat = 1.0

    private let orbSize: CGFloat = 120

    var body: some View {
        ZStack {
            outerRings
            mainOrb

            if state == .processing {
                orbitDots
            }
        }
        .frame(width: orbSize * 2.5, height: orbSize * 2.5)
        .onChange(of: state) { _, newState in
            updateAnimations(for: newState)
        }
        .onAppear {
            updateAnimations(for: state)
        }
    }

    private var outerRings: some View {
        let levelScale = CGFloat(audioLevel)

        return ZStack {
            Circle()
                .fill(orbColor.opacity(0.04))
                .frame(width: orbSize * (1.8 + levelScale * 0.6), height: orbSize * (1.8 + levelScale * 0.6))
                .scaleEffect(breathe * 1.05)

            Circle()
                .fill(orbColor.opacity(0.08))
                .frame(width: orbSize * (1.5 + levelScale * 0.4), height: orbSize * (1.5 + levelScale * 0.4))
                .scaleEffect(breathe)

            Circle()
                .fill(orbColor.opacity(0.12))
                .frame(width: orbSize * (1.25 + levelScale * 0.25), height: orbSize * (1.25 + levelScale * 0.25))
                .scaleEffect(breathe * 0.98)
        }
        .animation(.easeOut(duration: 0.08), value: audioLevel)
    }

    private var mainOrb: some View {
        let levelScale = 1.0 + CGFloat(audioLevel) * 0.15

        return Circle()
            .fill(
                RadialGradient(
                    colors: [orbColor.opacity(0.9), orbColor],
                    center: .center,
                    startRadius: 0,
                    endRadius: orbSize / 2
                )
            )
            .frame(width: orbSize, height: orbSize)
            .scaleEffect(state == .idle ? idlePulse : levelScale)
            .shadow(color: orbColor.opacity(0.4), radius: 20 + CGFloat(audioLevel) * 20)
            .animation(.easeOut(duration: 0.08), value: audioLevel)
    }

    private var orbitDots: some View {
        ForEach(0..<3, id: \.self) { index in
            Circle()
                .fill(.white.opacity(0.6))
                .frame(width: 8, height: 8)
                .offset(x: orbSize * 0.55)
                .rotationEffect(.degrees(orbitAngle + Double(index) * 120))
        }
    }

    private var orbColor: Color {
        switch state {
        case .idle: Color.capeCod.driftwood.opacity(0.6)
        case .connecting: Color.capeCod.seafoam.opacity(0.5)
        case .listening: Color.capeCod.seafoam
        case .processing: Color.capeCod.sunsetOrange
        case .speaking: Color.capeCod.sunsetOrange
        case .error: Color.capeCod.cranberry
        }
    }

    private func updateAnimations(for newState: VoiceAssistantViewModel.VoiceState) {
        switch newState {
        case .idle:
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                idlePulse = 1.06
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                breathe = 1.03
            }
            withAnimation { orbitAngle = 0 }

        case .connecting:
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                breathe = 1.05
            }

        case .listening:
            withAnimation { idlePulse = 1.0 }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                breathe = 1.02
            }

        case .processing:
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                orbitAngle = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                breathe = 1.04
            }

        case .speaking:
            withAnimation { orbitAngle = 0 }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                breathe = 1.02
            }

        case .error:
            withAnimation(.easeInOut(duration: 0.5).repeatCount(3, autoreverses: true)) {
                idlePulse = 1.1
            }
        }
    }
}

// MARK: - Transcript Bubble

private struct TranscriptBubble: View {
    let entry: TranscriptEntry
    private var isUser: Bool { entry.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 40) }

            Text(entry.text)
                .codTextStyle(.body)
                .foregroundStyle(isUser ? .white : .white.opacity(0.85))
                .padding(.horizontal, CodSpacing.md)
                .padding(.vertical, CodSpacing.sm + 2)
                .background(
                    isUser
                        ? Color.capeCod.oceanBlue.opacity(0.3)
                        : Color.white.opacity(0.08)
                )
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))

            if !isUser { Spacer(minLength: 40) }
        }
        .codAccessible(
            label: "\(isUser ? "You" : "Cape Cod AI") said: \(entry.text)"
        )
    }
}

// MARK: - Mini Voice Bubble (Floating Overlay)

struct VoiceMiniButton: View {
    let state: VoiceAssistantViewModel.VoiceState
    let audioLevel: Float
    let onTap: () -> Void

    @State private var pulse: CGFloat = 1.0

    var body: some View {
        Button(action: {
            CodHaptic.light()
            onTap()
        }) {
            ZStack {
                Circle()
                    .fill(bubbleColor.opacity(0.15))
                    .frame(width: 64, height: 64)
                    .scaleEffect(pulse)

                Circle()
                    .fill(bubbleColor)
                    .frame(width: 48, height: 48)
                    .shadow(color: bubbleColor.opacity(0.4), radius: 8)

                Image(systemName: bubbleIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(CodAnimation.pulse) {
                pulse = 1.15
            }
        }
        .codAccessibleButton("Return to voice conversation", hint: "Double tap to expand")
    }

    private var bubbleColor: Color {
        switch state {
        case .listening: Color.capeCod.seafoam
        case .speaking: Color.capeCod.sunsetOrange
        case .processing: Color.capeCod.sunsetOrange.opacity(0.7)
        default: Color.capeCod.oceanBlue
        }
    }

    private var bubbleIcon: String {
        switch state {
        case .listening: "waveform"
        case .speaking: "speaker.wave.2.fill"
        case .processing: "ellipsis"
        default: "mic.fill"
        }
    }
}

// MARK: - Preview

#Preview("Voice Assistant - Idle") {
    VoiceAssistantView()
}

#Preview("Mini Bubble") {
    ZStack {
        Color.capeCod.background.ignoresSafeArea()

        VStack {
            Spacer()
            HStack {
                Spacer()
                VoiceMiniButton(
                    state: .listening,
                    audioLevel: 0.5,
                    onTap: {}
                )
                .padding()
            }
        }
    }
}
