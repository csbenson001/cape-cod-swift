import AVFoundation
import Accelerate

/// Captures microphone audio in PCM16 @ 24kHz, performs Voice Activity Detection,
/// and emits base64-encoded chunks (~100ms) for WebSocket transmission.
@preconcurrency @MainActor
@Observable
final class AudioEngine {

    // MARK: - Public State

    /// Current RMS audio level normalized to 0.0–1.0 for waveform visualization
    private(set) var audioLevel: Float = 0

    /// Whether the user is currently speaking (VAD triggered)
    private(set) var isSpeechDetected = false

    /// Whether the engine is actively capturing
    private(set) var isRunning = false

    // MARK: - Configuration

    /// OpenAI Realtime API requires 24kHz PCM16
    static let sampleRate: Double = 24_000
    static let channelCount: AVAudioChannelCount = 1
    static let bytesPerSample: Int = 2 // PCM16 = 2 bytes

    /// ~100ms of audio at 24kHz = 2400 samples = 4800 bytes
    private static let samplesPerChunk: Int = 2400
    private static let chunkDuration: TimeInterval = 0.1

    /// VAD thresholds
    private static let speechThresholdDB: Float = -40 // dBFS above which we consider speech
    private static let silenceThresholdDB: Float = -50 // dBFS below which we consider silence
    private static let endOfTurnSilenceDuration: TimeInterval = 1.5

    // MARK: - Callbacks

    /// Called with base64-encoded PCM16 chunks when speech is detected
    var onAudioChunk: ((String, TimeInterval) -> Void)?

    /// Called when silence persists beyond `endOfTurnSilenceDuration`, indicating end of turn
    var onEndOfTurn: (() -> Void)?

    // MARK: - Private State

    private var audioEngine: AVAudioEngine?
    private let targetFormat: AVAudioFormat
    private var converter: AVAudioConverter?

    /// Accumulation buffer for building ~100ms chunks
    private var accumulationBuffer = Data()

    /// Silence tracking for end-of-turn detection
    private var silenceStartTime: Date?
    private var hasNotifiedEndOfTurn = false

    /// Smoothed audio level for UI (exponential moving average)
    private var smoothedLevel: Float = 0
    private static let levelSmoothingFactor: Float = 0.3

    // MARK: - Init

    init() {
        // Create the target format: PCM16, 24kHz, mono
        self.targetFormat = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: Self.sampleRate,
            channels: Self.channelCount,
            interleaved: true
        )!
    }

    // MARK: - Lifecycle

    func start() throws {
        guard !isRunning else { return }

        let engine = AVAudioEngine()
        let inputNode = engine.inputNode

        // Get the hardware input format
        let hardwareFormat = inputNode.outputFormat(forBus: 0)
        guard hardwareFormat.sampleRate > 0 else {
            throw AudioEngineError.noInputAvailable
        }

        // Create a converter from hardware format → target 24kHz PCM16
        guard let conv = AVAudioConverter(from: hardwareFormat, to: targetFormat) else {
            throw AudioEngineError.converterCreationFailed
        }
        self.converter = conv

        // Calculate the tap buffer size: ~100ms worth of samples at the hardware rate
        let tapBufferSize = AVAudioFrameCount(hardwareFormat.sampleRate * Self.chunkDuration)

        inputNode.installTap(onBus: 0, bufferSize: tapBufferSize, format: hardwareFormat) { buffer, time in
            Task { @MainActor [weak self] in
                self?.processInputBuffer(buffer, time: time)
            }
        }

        engine.prepare()
        try engine.start()

        self.audioEngine = engine
        self.accumulationBuffer = Data()
        self.silenceStartTime = nil
        self.hasNotifiedEndOfTurn = false
        self.isRunning = true
    }

    func stop() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        converter = nil
        isRunning = false
        audioLevel = 0
        isSpeechDetected = false
        accumulationBuffer = Data()
        silenceStartTime = nil
    }

    // MARK: - Audio Processing Pipeline

    private func processInputBuffer(_ buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        // Step 1: Calculate RMS from the raw input for level metering
        let rmsDB = calculateRMSdB(buffer: buffer)
        let normalizedLevel = normalizeDBToLevel(rmsDB)

        Task { @MainActor [weak self] in
            guard let self else { return }
            self.smoothedLevel = Self.levelSmoothingFactor * normalizedLevel + (1 - Self.levelSmoothingFactor) * self.smoothedLevel
            self.audioLevel = self.smoothedLevel
        }

        // Step 2: Voice Activity Detection
        let speechActive = rmsDB > Self.speechThresholdDB
        let silenceActive = rmsDB < Self.silenceThresholdDB

        Task { @MainActor [weak self] in
            self?.isSpeechDetected = speechActive
        }

        // Step 3: Track silence for end-of-turn
        if silenceActive {
            if silenceStartTime == nil {
                silenceStartTime = Date()
            }
            if let start = silenceStartTime,
               Date().timeIntervalSince(start) >= Self.endOfTurnSilenceDuration,
               !hasNotifiedEndOfTurn {
                hasNotifiedEndOfTurn = true
                Task { @MainActor [weak self] in
                    self?.onEndOfTurn?()
                }
            }
        } else {
            silenceStartTime = nil
            hasNotifiedEndOfTurn = false
        }

        // Step 4: Convert to PCM16 @ 24kHz
        guard let converted = convertToTargetFormat(buffer) else { return }

        // Step 5: Extract raw PCM16 bytes and accumulate
        let pcmData = extractPCM16Data(from: converted)
        accumulationBuffer.append(pcmData)

        // Step 6: Emit complete chunks
        let chunkSize = Self.samplesPerChunk * Self.bytesPerSample
        while accumulationBuffer.count >= chunkSize {
            let chunk = accumulationBuffer.prefix(chunkSize)
            accumulationBuffer = Data(accumulationBuffer.dropFirst(chunkSize))

            // Only transmit if speech was recently active (include a little pre/post roll)
            let base64Chunk = chunk.base64EncodedString()
            let timestamp = Date().timeIntervalSince1970 * 1000

            Task { @MainActor [weak self] in
                self?.onAudioChunk?(base64Chunk, timestamp)
            }
        }
    }

    // MARK: - Format Conversion

    private func convertToTargetFormat(_ inputBuffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        guard let converter else { return nil }

        // Calculate the output frame capacity based on sample rate ratio
        let ratio = targetFormat.sampleRate / inputBuffer.format.sampleRate
        let outputFrameCount = AVAudioFrameCount(Double(inputBuffer.frameLength) * ratio)
        guard outputFrameCount > 0 else { return nil }

        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: outputFrameCount) else {
            return nil
        }

        var error: NSError?
        var inputConsumed = false

        converter.convert(to: outputBuffer, error: &error) { _, outStatus in
            if inputConsumed {
                outStatus.pointee = .noDataNow
                return nil
            }
            inputConsumed = true
            outStatus.pointee = .haveData
            return inputBuffer
        }

        if let error {
            print("[AudioEngine] Conversion error: \(error.localizedDescription)")
            return nil
        }

        return outputBuffer
    }

    private func extractPCM16Data(from buffer: AVAudioPCMBuffer) -> Data {
        let frameCount = Int(buffer.frameLength)
        guard frameCount > 0 else { return Data() }

        // PCM16 interleaved: int16Data is available
        guard let int16Ptr = buffer.int16ChannelData?[0] else { return Data() }

        return Data(bytes: int16Ptr, count: frameCount * Self.bytesPerSample)
    }

    // MARK: - Audio Analysis

    /// Calculate RMS in dBFS using Accelerate for efficiency
    private func calculateRMSdB(buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return -100 }
        let frameCount = Int(buffer.frameLength)
        guard frameCount > 0 else { return -100 }

        var rms: Float = 0
        vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(frameCount))

        // Convert to dBFS
        guard rms > 0 else { return -100 }
        return 20 * log10(rms)
    }

    /// Normalize dBFS to 0.0–1.0 range for UI visualization
    private func normalizeDBToLevel(_ db: Float) -> Float {
        // Map -60dB...0dB → 0.0...1.0
        let minDB: Float = -60
        let maxDB: Float = 0
        let clamped = max(minDB, min(maxDB, db))
        return (clamped - minDB) / (maxDB - minDB)
    }
}

// MARK: - Errors

enum AudioEngineError: LocalizedError {
    case noInputAvailable
    case converterCreationFailed

    var errorDescription: String? {
        switch self {
        case .noInputAvailable: "No microphone input available."
        case .converterCreationFailed: "Failed to create audio format converter."
        }
    }
}
