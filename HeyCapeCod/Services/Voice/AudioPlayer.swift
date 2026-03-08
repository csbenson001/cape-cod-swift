import AVFoundation
import Accelerate

/// Streams and plays PCM16 audio responses from the AI with gapless playback,
/// barge-in support (50ms fade-out), and proper AVAudioSession management.
@preconcurrency @MainActor
@Observable
final class AudioPlayer {

    // MARK: - Public State

    /// Current output level for waveform visualization (0.0–1.0)
    private(set) var outputLevel: Float = 0

    /// Whether audio is currently playing
    private(set) var isPlaying = false

    // MARK: - Configuration

    /// Must match AudioEngine's format for consistency with OpenAI's PCM16 24kHz
    private static let sampleRate: Double = 24_000
    private static let channelCount: AVAudioChannelCount = 1
    private static let fadeDuration: TimeInterval = 0.05 // 50ms fade for barge-in

    // MARK: - Audio Graph

    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var mixerNode: AVAudioMixerNode?
    private let playbackFormat: AVAudioFormat

    /// Queue of buffers waiting to be scheduled
    private var pendingBuffers: [AVAudioPCMBuffer] = []
    private let bufferQueue = DispatchQueue(label: "com.heycapecod.audioplayerqueue")

    /// Level metering
    private var levelTimer: Timer?
    private var smoothedLevel: Float = 0
    private static let levelSmoothingFactor: Float = 0.3

    // MARK: - Init

    init() {
        self.playbackFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: Self.sampleRate,
            channels: Self.channelCount,
            interleaved: false
        )!
    }

    // MARK: - Audio Session

    func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .voiceChat,
            options: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers]
        )
        try session.setPreferredSampleRate(Self.sampleRate)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - Engine Lifecycle

    func prepare() throws {
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        let mixer = AVAudioMixerNode()

        engine.attach(player)
        engine.attach(mixer)

        // player → mixer → mainMixer → output
        engine.connect(player, to: mixer, format: playbackFormat)
        engine.connect(mixer, to: engine.mainMixerNode, format: playbackFormat)

        // Install a tap on the mixer for output level metering
        mixer.installTap(onBus: 0, bufferSize: 1024, format: playbackFormat) { [weak self] buffer, _ in
            self?.updateOutputLevel(buffer: buffer)
        }

        engine.prepare()
        try engine.start()

        self.engine = engine
        self.playerNode = player
        self.mixerNode = mixer

        player.play()

        startLevelTimer()
    }

    func tearDown() {
        levelTimer?.invalidate()
        levelTimer = nil
        playerNode?.stop()
        mixerNode?.removeTap(onBus: 0)
        engine?.stop()
        engine = nil
        playerNode = nil
        mixerNode = nil
        isPlaying = false
        outputLevel = 0
        bufferQueue.sync { pendingBuffers.removeAll() }
    }

    // MARK: - Streaming Playback

    /// Enqueue a chunk of PCM16 audio data for gapless playback
    func enqueueAudioData(_ pcm16Data: Data) {
        guard let playerNode, playerNode.engine != nil else { return }

        guard let buffer = pcm16DataToFloatBuffer(pcm16Data) else { return }

        bufferQueue.sync {
            pendingBuffers.append(buffer)
        }

        scheduleNextBuffer()
    }

    private func scheduleNextBuffer() {
        guard let playerNode else { return }

        var buffer: AVAudioPCMBuffer?
        bufferQueue.sync {
            if !pendingBuffers.isEmpty {
                buffer = pendingBuffers.removeFirst()
            }
        }

        guard let buf = buffer else { return }

        Task { @MainActor [weak self] in
            self?.isPlaying = true
        }

        playerNode.scheduleBuffer(buf) { [weak self] in
            // When this buffer finishes, try to schedule the next one
            self?.scheduleNextBuffer()

            // Check if we're done
            self?.bufferQueue.sync {
                if self?.pendingBuffers.isEmpty == true {
                    Task { @MainActor [weak self] in
                        // Small delay to confirm no more buffers are incoming
                        try? await Task.sleep(for: .seconds(0.1))
                        self?.bufferQueue.sync {
                            if self?.pendingBuffers.isEmpty == true {
                                self?.isPlaying = false
                            }
                        }
                    }
                }
            }
        }
    }

    /// Called when all chunks for a response have been received
    func finalizePlayback() {
        // The completion handlers on scheduled buffers will
        // set isPlaying = false when the last buffer finishes
    }

    // MARK: - Barge-In (Interrupt)

    /// Immediately stop playback with a 50ms fade-out to avoid popping
    func interrupt() {
        guard let mixerNode, let playerNode else {
            clearBuffers()
            return
        }

        // Smooth 50ms fade to avoid audio pop
        let fadeSteps = 10
        let stepDuration = Self.fadeDuration / Double(fadeSteps)

        for step in 0...fadeSteps {
            let volume = Float(fadeSteps - step) / Float(fadeSteps)
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(stepDuration * Double(step)))
                mixerNode.outputVolume = volume
            }
        }

        // After fade completes, stop and reset
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(Self.fadeDuration + 0.01))
            playerNode.stop()
            self?.clearBuffers()
            mixerNode.outputVolume = 1.0
            playerNode.play() // Re-arm for next response

            self?.isPlaying = false
            self?.outputLevel = 0
        }
    }

    private func clearBuffers() {
        bufferQueue.sync { pendingBuffers.removeAll() }
    }

    // MARK: - PCM16 → Float32 Conversion

    private func pcm16DataToFloatBuffer(_ data: Data) -> AVAudioPCMBuffer? {
        let sampleCount = data.count / 2 // 2 bytes per PCM16 sample
        guard sampleCount > 0 else { return nil }

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: playbackFormat,
            frameCapacity: AVAudioFrameCount(sampleCount)
        ) else { return nil }

        buffer.frameLength = AVAudioFrameCount(sampleCount)

        guard let floatData = buffer.floatChannelData?[0] else { return nil }

        data.withUnsafeBytes { rawBuffer in
            guard let int16Ptr = rawBuffer.bindMemory(to: Int16.self).baseAddress else { return }

            // Use Accelerate to convert Int16 → Float32 and normalize to -1.0...1.0
            var float32Samples = [Float](repeating: 0, count: sampleCount)
            vDSP_vflt16(int16Ptr, 1, &float32Samples, 1, vDSP_Length(sampleCount))

            var scale: Float = 1.0 / 32768.0
            vDSP_vsmul(float32Samples, 1, &scale, floatData, 1, vDSP_Length(sampleCount))
        }

        return buffer
    }

    // MARK: - Output Level Metering

    private func updateOutputLevel(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)
        guard frameCount > 0 else { return }

        var rms: Float = 0
        vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(frameCount))

        // Normalize: rms of full-scale sine ≈ 0.707
        let normalized = min(1.0, rms / 0.5)
        let smoothed = Self.levelSmoothingFactor * normalized + (1 - Self.levelSmoothingFactor) * smoothedLevel
        smoothedLevel = smoothed

        Task { @MainActor [weak self] in
            self?.outputLevel = smoothed
        }
    }

    private func startLevelTimer() {
        // Reset level when no audio is playing
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if !self.isPlaying {
                    self.smoothedLevel *= 0.8
                    self.outputLevel = self.smoothedLevel
                }
            }
        }
    }
}
