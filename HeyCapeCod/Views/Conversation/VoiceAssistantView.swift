import SwiftUI

/// Full-screen real-time voice conversation UI.
///
/// Features:
/// - Animated orb that responds to audio levels (input & output)
/// - Color shifts: Seafoam (listening) → Sunset Orange (AI speaking)
/// - Scrolling transcript of the conversation
/// - Swipe down to minimize into a floating mini-bubble
/// - Barge-in detection (tap while AI is speaking)
struct VoiceAssistantView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = VoiceAssistantViewModel()
    @State private var showEndConfirmation = false

    var body: some View {
        ZStack {
            // Full-screen dark background
            Color(hex: 0x0D2137)
                .ignoresSafeArea()

            if viewModel.isMinimized {
                // Mini-bubble mode — handled by parent via overlay
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
            // Top bar
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

            // State label
            stateLabel
                .padding(.top, CodSpacing.lg)

            Spacer()

            // Transcript
            if !viewModel.transcript.isEmpty {
                transcriptView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
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
            // Duration
            if viewModel.state.isActive {
                Text(formattedDuration)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            // Minimize button
            if viewModel.state.isActive {
                Button {
                    viewModel.toggleMinimized()
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }

            // Close button
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
        }
    }

    // MARK: - State Label

    private var stateLabel: some View {
        VStack(spacing: CodSpacing.sm) {
            Text(viewModel.state.label)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: viewModel.state)

            if !viewModel.hasConversationsRemaining && viewModel.state == .idle {
                Text("Daily limit reached")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.capeCod.sunsetOrange.opacity(0.8))
            } else if viewModel.state == .idle {
                Text("\(viewModel.conversationsRemaining) conversations remaining today")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
    }

    // MARK: - Transcript

    private var transcriptView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: CodSpacing.md) {
                    ForEach(viewModel.transcript) { entry in
                        TranscriptBubble(entry: entry)
                            .id(entry.id)
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
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, CodSpacing.lg)
                        .padding(.vertical, CodSpacing.sm + 2)
                        .background(.white.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Actions

    private func handleOrbTap() {
        switch viewModel.state {
        case .idle:
            Task { await viewModel.startConversation() }
        case .speaking:
            viewModel.handleBargeIn()
        case .error:
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
}

// MARK: - Voice Orb

/// The central animated circle that represents the AI's state.
///
/// - Idle: gentle pulse, muted color
/// - Listening: seafoam, reactive to input audio levels
/// - Processing: orbit animation, sunset orange
/// - Speaking: sunset orange, reactive to output audio levels
private struct VoiceOrb: View {
    let state: VoiceAssistantViewModel.VoiceState
    let audioLevel: Float

    // Animation state
    @State private var idlePulse: CGFloat = 1.0
    @State private var orbitAngle: Double = 0
    @State private var breathe: CGFloat = 1.0

    private let orbSize: CGFloat = 120

    var body: some View {
        ZStack {
            // Outer glow rings
            outerRings

            // Main orb
            mainOrb

            // Orbit dots (processing state)
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

    // MARK: - Outer Glow Rings

    private var outerRings: some View {
        let levelScale = CGFloat(audioLevel)

        return ZStack {
            // Ring 1 — outermost, faintest
            Circle()
                .fill(orbColor.opacity(0.04))
                .frame(width: orbSize * (1.8 + levelScale * 0.6), height: orbSize * (1.8 + levelScale * 0.6))
                .scaleEffect(breathe * 1.05)

            // Ring 2
            Circle()
                .fill(orbColor.opacity(0.08))
                .frame(width: orbSize * (1.5 + levelScale * 0.4), height: orbSize * (1.5 + levelScale * 0.4))
                .scaleEffect(breathe)

            // Ring 3 — closest to orb
            Circle()
                .fill(orbColor.opacity(0.12))
                .frame(width: orbSize * (1.25 + levelScale * 0.25), height: orbSize * (1.25 + levelScale * 0.25))
                .scaleEffect(breathe * 0.98)
        }
        .animation(.easeOut(duration: 0.08), value: audioLevel)
    }

    // MARK: - Main Orb

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

    // MARK: - Orbit Dots (Processing)

    private var orbitDots: some View {
        ForEach(0..<3, id: \.self) { index in
            Circle()
                .fill(.white.opacity(0.6))
                .frame(width: 8, height: 8)
                .offset(x: orbSize * 0.55)
                .rotationEffect(.degrees(orbitAngle + Double(index) * 120))
        }
    }

    // MARK: - Color

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

    // MARK: - Animations

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
                .font(.system(size: 14))
                .foregroundStyle(isUser ? .white : .white.opacity(0.85))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    isUser
                        ? Color.capeCod.oceanBlue.opacity(0.3)
                        : Color.white.opacity(0.08)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))

            if !isUser { Spacer(minLength: 40) }
        }
    }
}

// MARK: - Mini Voice Bubble (Floating Overlay)

/// A small floating bubble shown when the voice conversation is minimized.
/// Displayed as an overlay on the main app content.
struct VoiceMiniButton: View {
    let state: VoiceAssistantViewModel.VoiceState
    let audioLevel: Float
    let onTap: () -> Void

    @State private var pulse: CGFloat = 1.0

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Glow ring
                Circle()
                    .fill(bubbleColor.opacity(0.15))
                    .frame(width: 64, height: 64)
                    .scaleEffect(pulse)

                // Main bubble
                Circle()
                    .fill(bubbleColor)
                    .frame(width: 48, height: 48)
                    .shadow(color: bubbleColor.opacity(0.4), radius: 8)

                // Icon
                Image(systemName: bubbleIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulse = 1.15
            }
        }
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
