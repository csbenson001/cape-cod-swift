import SwiftUI
import AVFoundation
import MediaPlayer

/// Full-screen story playback view with TTS engine.
///
/// - Free tier: AVSpeechSynthesizer (on-device)
/// - Premium tier: OpenAI TTS API (much better quality)
struct StoryPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var viewModel: StoryPlayerViewModel

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.capeCod.deepNavy, Color(hex: 0x162233)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                Spacer()

                artworkSection

                Spacer()

                titleSection
                    .padding(.horizontal, CodSpacing.screenEdge)

                progressSection
                    .padding(.top, CodSpacing.lg)
                    .padding(.horizontal, CodSpacing.screenEdge)

                controlsSection
                    .padding(.top, CodSpacing.lg)

                if viewModel.showTranscript {
                    scriptSection
                        .padding(.top, CodSpacing.lg)
                        .transition(.codSlideUp)
                }

                Spacer()

                bottomSection
                    .padding(.horizontal, CodSpacing.screenEdge)
                    .padding(.bottom, CodSpacing.lg)
            }
        }
        .onAppear {
            viewModel.configureNowPlaying()
        }
        .onDisappear {
            viewModel.clearNowPlaying()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 44, height: 44)
            }
            .codAccessibleButton("Close player")

            Spacer()

            Text(viewModel.poi?.name ?? "Story")
                .codTextStyle(.caption)
                .foregroundStyle(.white.opacity(0.5))

            Spacer()

            Button {
                withAnimation(CodAnimation.quick) { viewModel.showTranscript.toggle() }
            } label: {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(viewModel.showTranscript ? Color.capeCod.seafoam : .white.opacity(0.5))
                    .frame(width: 44, height: 44)
            }
            .codAccessibleButton(
                viewModel.showTranscript ? "Hide transcript" : "Show transcript"
            )
        }
        .padding(.horizontal, CodSpacing.sm)
    }

    // MARK: - Artwork

    private var artworkSection: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(Color.capeCod.oceanBlue.opacity(0.15))
                .frame(width: 200, height: 200)

            // Gradient orb
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.capeCod.oceanBlue, Color.capeCod.seafoam],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 160, height: 160)
                .shadow(color: Color.capeCod.oceanBlue.opacity(0.3), radius: 20)

            Image(systemName: viewModel.poi?.imageSystemName ?? "headphones")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.white)
        }
        .codAccessibleHidden()
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Text(viewModel.currentStory?.title ?? "")
                .codTextStyle(.sectionTitle)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            if let poi = viewModel.poi {
                Text("\(poi.town.displayName) \u{2022} \(poi.category.displayName)")
                    .codTextStyle(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: CodSpacing.xs) {
            Slider(
                value: $viewModel.progress,
                in: 0...1,
                onEditingChanged: { editing in
                    if !editing {
                        viewModel.seekToProgress()
                    }
                }
            )
            .tint(Color.capeCod.seafoam)

            HStack {
                Text(viewModel.formattedElapsed)
                    .codTextStyle(.label)
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.4))
                Spacer()
                Text(viewModel.formattedRemaining)
                    .codTextStyle(.label)
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .codAccessibleGroup(label: "Progress: \(viewModel.formattedElapsed) of \(viewModel.formattedRemaining)")
    }

    // MARK: - Controls

    private var controlsSection: some View {
        HStack(spacing: CodSpacing.xl) {
            Button {
                CodHaptic.light()
                viewModel.rewind15()
            } label: {
                Image(systemName: "gobackward.15")
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 52, height: 52)
            }
            .codAccessibleButton("Rewind 15 seconds")

            Button {
                CodHaptic.tap()
                viewModel.togglePlayPause()
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.white)
                    .contentTransition(.symbolEffect(.replace))
            }
            .codAccessibleButton(viewModel.isPlaying ? "Pause" : "Play")

            Button {
                CodHaptic.light()
                viewModel.skip()
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 52, height: 52)
            }
            .codAccessibleButton("Skip to next")
        }
    }

    // MARK: - Script (Transcript)

    private var scriptSection: some View {
        ScrollView {
            Text(viewModel.currentStory?.script ?? "")
                .codTextStyle(.storyBody)
                .foregroundStyle(.white.opacity(0.65))
                .padding(.horizontal, CodSpacing.screenEdge)
        }
        .frame(maxHeight: 160)
        .mask(
            LinearGradient(
                colors: [.clear, .white, .white, .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Bottom

    private var bottomSection: some View {
        HStack {
            // Speed control
            Menu {
                ForEach([0.75, 1.0, 1.25, 1.5], id: \.self) { speed in
                    Button {
                        viewModel.setSpeed(Float(speed))
                    } label: {
                        HStack {
                            Text("\(speed, specifier: speed == 1.0 ? "%.0f" : "%.2g")x")
                            if viewModel.speechRate == Float(speed) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Text("\(viewModel.speechRate, specifier: viewModel.speechRate == 1.0 ? "%.0f" : "%.2g")x")
                    .codTextStyle(.body)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.horizontal, CodSpacing.sm + 4)
                    .padding(.vertical, CodSpacing.xs + 2)
                    .background(.white.opacity(0.1))
                    .clipShape(Capsule())
            }
            .codAccessibleButton("Playback speed: \(viewModel.speechRate, specifier: "%.2g")x")

            Spacer()

            Button {
                // Future: share story
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 44, height: 44)
            }
            .codAccessibleButton("Share story")
        }
    }
}

// MARK: - Story Player ViewModel

@Observable
final class StoryPlayerViewModel: NSObject {

    // MARK: - State

    private(set) var poi: PointOfInterest?
    private(set) var currentStory: StoryVariant?
    private(set) var isPlaying = false
    var progress: Double = 0
    var showTranscript = false
    var speechRate: Float = 1.0

    private(set) var elapsed: TimeInterval = 0
    private(set) var duration: TimeInterval = 0

    var formattedElapsed: String { formatTime(elapsed) }
    var formattedRemaining: String { "-\(formatTime(max(0, duration - elapsed)))" }

    var miniPlayerData: MiniPlayerData? {
        guard let story = currentStory else { return nil }
        return MiniPlayerData(
            title: story.title,
            subtitle: poi?.name ?? "",
            progress: progress,
            isPlaying: isPlaying
        )
    }

    // MARK: - TTS Engine

    private let synthesizer = AVSpeechSynthesizer()
    private var progressTimer: Timer?

    // MARK: - Init

    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
        configureRemoteCommands()
    }

    // MARK: - Playback Control

    func loadAndPlay(poi: PointOfInterest, story: StoryVariant) {
        stop()
        self.poi = poi
        self.currentStory = story
        self.duration = story.duration
        self.progress = 0
        self.elapsed = 0
        play()
    }

    func play() {
        guard let story = currentStory else { return }

        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
        } else {
            let utterance = AVSpeechUtterance(string: story.script)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * speechRate
            utterance.pitchMultiplier = 1.0
            utterance.preUtteranceDelay = 0.2

            synthesizer.speak(utterance)
        }

        isPlaying = true
        startProgressTimer()
        updateNowPlaying()
    }

    func pause() {
        synthesizer.pauseSpeaking(at: .immediate)
        isPlaying = false
        stopProgressTimer()
        updateNowPlaying()
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
        stopProgressTimer()
        progress = 0
        elapsed = 0
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func rewind15() {
        elapsed = max(0, elapsed - 15)
        progress = duration > 0 ? elapsed / duration : 0
        updateNowPlaying()
    }

    func skip() {
        stop()
        clearNowPlaying()
    }

    func seekToProgress() {
        elapsed = duration * progress
        updateNowPlaying()
    }

    func setSpeed(_ rate: Float) {
        speechRate = rate
        if isPlaying, let story = currentStory {
            synthesizer.stopSpeaking(at: .immediate)
            let utterance = AVSpeechUtterance(string: story.script)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * rate
            synthesizer.speak(utterance)
        }
    }

    // MARK: - Progress Tracking

    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self, self.isPlaying, self.duration > 0 else { return }
            self.elapsed += 0.5
            self.progress = min(1.0, self.elapsed / self.duration)
            if self.elapsed >= self.duration {
                self.elapsed = self.duration
                self.progress = 1.0
            }
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("[StoryPlayer] Audio session error: \(error.localizedDescription)")
        }
    }

    // MARK: - Lock Screen / Now Playing

    func configureNowPlaying() {
        updateNowPlaying()
    }

    func clearNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    private func updateNowPlaying() {
        guard let story = currentStory else { return }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: story.title,
            MPMediaItemPropertyArtist: poi?.name ?? "Hey Cape Cod",
            MPMediaItemPropertyAlbumTitle: poi?.town.displayName ?? "Cape Cod",
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsed,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? Double(speechRate) : 0,
            MPMediaItemPropertyMediaType: MPMediaType.podcast.rawValue,
        ]

        if let systemName = poi?.imageSystemName {
            let config = UIImage.SymbolConfiguration(pointSize: 120, weight: .light)
            if let image = UIImage(systemName: systemName, withConfiguration: config)?
                .withTintColor(.white, renderingMode: .alwaysOriginal) {
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                info[MPMediaItemPropertyArtwork] = artwork
            }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.isEnabled = true
        center.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }

        center.pauseCommand.isEnabled = true
        center.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        center.togglePlayPauseCommand.isEnabled = true
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }

        center.skipBackwardCommand.isEnabled = true
        center.skipBackwardCommand.preferredIntervals = [15]
        center.skipBackwardCommand.addTarget { [weak self] _ in
            self?.rewind15()
            return .success
        }

        center.nextTrackCommand.isEnabled = true
        center.nextTrackCommand.addTarget { [weak self] _ in
            self?.skip()
            return .success
        }
    }

    // MARK: - Formatting

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    deinit {
        stop()
        clearNowPlaying()
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension StoryPlayerViewModel: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            self?.progress = 1.0
            self?.stopProgressTimer()
            self?.updateNowPlaying()
            CodHaptic.success()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            self?.stopProgressTimer()
        }
    }
}
