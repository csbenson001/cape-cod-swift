import AVFoundation
import SwiftUI

/// Orchestrates the real-time voice conversation system.
///
/// State machine: idle → connecting → listening → processing → speaking → listening (loop)
///
/// Coordinates AudioEngine (capture), WebSocketManager (relay), and AudioPlayer (playback)
/// to deliver a seamless voice conversation experience.
@MainActor
@Observable
final class VoiceAssistantViewModel {

    // MARK: - Conversation State

    enum VoiceState: Equatable {
        case idle
        case connecting
        case listening
        case processing
        case speaking
        case error(String)

        var label: String {
            switch self {
            case .idle: "Tap to start"
            case .connecting: "Connecting..."
            case .listening: "Listening..."
            case .processing: "Thinking..."
            case .speaking: "Speaking..."
            case .error(let msg): msg
            }
        }

        var isActive: Bool {
            switch self {
            case .idle, .error: false
            default: true
            }
        }
    }

    // MARK: - Public State

    private(set) var state: VoiceState = .idle
    private(set) var transcript: [TranscriptEntry] = []
    private(set) var conversationDuration: TimeInterval = 0
    private(set) var isMinimized = false

    /// Audio levels for waveform visualization
    var inputLevel: Float { audioEngine.audioLevel }
    var outputLevel: Float { audioPlayer.outputLevel }

    /// Current active level based on state
    var activeLevel: Float {
        switch state {
        case .listening: inputLevel
        case .speaking: outputLevel
        default: 0
        }
    }

    // MARK: - Usage Limits

    private static let freeConversationsPerDay = 3
    private let conversationsUsedKey = "voiceConversationsUsed"
    private let conversationsDateKey = "voiceConversationsDate"

    var conversationsRemaining: Int {
        let today = Calendar.current.startOfDay(for: .now)
        let storedDate = UserDefaults.standard.object(forKey: conversationsDateKey) as? Date ?? .distantPast
        let storedDay = Calendar.current.startOfDay(for: storedDate)

        if today != storedDay {
            return Self.freeConversationsPerDay
        }
        return max(0, Self.freeConversationsPerDay - UserDefaults.standard.integer(forKey: conversationsUsedKey))
    }

    var hasConversationsRemaining: Bool { conversationsRemaining > 0 }

    // MARK: - Components

    private let audioEngine = AudioEngine()
    private let audioPlayer = AudioPlayer()
    private let webSocket: WebSocketManager

    // MARK: - Private State

    private var conversationStartTime: Date?
    private var durationTimer: Timer?
    private var currentAssistantTranscript = ""

    // MARK: - Init

    init(serverURL: URL = URL(string: "wss://api.heycapecod.com/voice")!) {
        self.webSocket = WebSocketManager(serverURL: serverURL)
        setupCallbacks()
    }

    // MARK: - Setup

    private func setupCallbacks() {
        // Audio capture → WebSocket
        audioEngine.onAudioChunk = { [weak self] base64Audio, timestamp in
            self?.webSocket.sendAudio(base64Audio, timestamp: timestamp)
        }

        // End of turn (1.5s silence) → notify backend
        audioEngine.onEndOfTurn = { [weak self] in
            guard self?.state == .listening else { return }
            self?.webSocket.sendControl(action: "end_turn")
            self?.transition(to: .processing)
        }

        // WebSocket → handle inbound messages
        webSocket.onMessage = { [weak self] message in
            self?.handleInboundMessage(message)
        }

        // Connection state tracking
        webSocket.onConnectionStateChanged = { [weak self] connectionState in
            self?.handleConnectionStateChange(connectionState)
        }
    }

    // MARK: - Session Lifecycle

    /// Start a new voice conversation
    func startConversation() async {
        guard hasConversationsRemaining else {
            transition(to: .error("Daily limit reached. Upgrade for unlimited conversations."))
            return
        }

        // Request microphone permission
        let granted = await requestMicrophonePermission()
        guard granted else {
            transition(to: .error("Microphone access required for voice conversations."))
            return
        }

        transition(to: .connecting)

        do {
            // Configure audio session for voice chat
            try audioPlayer.configureAudioSession()
            try audioPlayer.prepare()

            // Connect WebSocket
            webSocket.connect()

            // Start capturing audio
            try audioEngine.start()

            // Track conversation start
            conversationStartTime = Date()
            startDurationTimer()
            incrementConversationCount()

            transition(to: .listening)
        } catch {
            transition(to: .error("Failed to start: \(error.localizedDescription)"))
            cleanUp()
        }
    }

    /// End the current voice conversation
    func endConversation() {
        webSocket.sendControl(action: "disconnect")
        cleanUp()
        transition(to: .idle)
    }

    /// Toggle minimized state (swipe down to mini-bubble)
    func toggleMinimized() {
        isMinimized.toggle()
    }

    /// Handle barge-in: user starts speaking while AI is responding
    func handleBargeIn() {
        guard state == .speaking else { return }

        // Interrupt AI playback
        audioPlayer.interrupt()
        webSocket.sendControl(action: "interrupt")

        // Finalize the partial assistant transcript
        if !currentAssistantTranscript.isEmpty {
            finalizeAssistantTranscript()
        }

        transition(to: .listening)
    }

    // MARK: - State Machine

    private func transition(to newState: VoiceState) {
        let oldState = state
        state = newState

        // Handle state-specific logic
        switch newState {
        case .listening:
            // If we were speaking, AI was interrupted or finished
            if oldState == .speaking {
                // Audio engine should already be running
            }

        case .processing:
            // Stop sending audio while we wait for the response
            break

        case .speaking:
            // Pause audio capture during playback to avoid echo
            break

        case .idle:
            cleanUp()

        case .error:
            // Auto-recover after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let self else { return }
                if case .error = self.state {
                    self.transition(to: self.webSocket.connectionState == .connected ? .listening : .idle)
                }
            }

        case .connecting:
            break
        }
    }

    // MARK: - Inbound Message Handling

    private func handleInboundMessage(_ message: WebSocketManager.InboundMessage) {
        switch message {
        case .audio(let data, let isFinal):
            handleInboundAudio(data, isFinal: isFinal)

        case .transcript(let text, let role):
            handleTranscript(text, role: role)

        case .status(let serverState):
            handleStatusUpdate(serverState)

        case .error(let errorMessage):
            transition(to: .error(errorMessage))
        }
    }

    private func handleInboundAudio(_ data: Data, isFinal: Bool) {
        if state != .speaking {
            transition(to: .speaking)
        }

        audioPlayer.enqueueAudioData(data)

        if isFinal {
            audioPlayer.finalizePlayback()
        }
    }

    private func handleTranscript(_ text: String, role: String) {
        switch role {
        case "user":
            // Complete user transcript
            appendTranscript(.init(role: .user, text: text))

        case "assistant":
            // Accumulate assistant transcript (may arrive incrementally)
            currentAssistantTranscript = text

        default:
            break
        }
    }

    private func handleStatusUpdate(_ serverState: String) {
        switch serverState {
        case "listening":
            if state == .speaking || state == .processing {
                // AI finished speaking, loop back to listening
                finalizeAssistantTranscript()
                transition(to: .listening)
            }

        case "thinking":
            transition(to: .processing)

        case "speaking":
            transition(to: .speaking)

        default:
            break
        }
    }

    private func finalizeAssistantTranscript() {
        guard !currentAssistantTranscript.isEmpty else { return }
        appendTranscript(.init(role: .assistant, text: currentAssistantTranscript))
        currentAssistantTranscript = ""
    }

    // MARK: - Connection State

    private func handleConnectionStateChange(_ connectionState: WebSocketManager.ConnectionState) {
        switch connectionState {
        case .disconnected:
            if state.isActive {
                transition(to: .error("Connection lost. Reconnecting..."))
            }

        case .reconnecting(let attempt):
            if state.isActive {
                transition(to: .error("Reconnecting... (attempt \(attempt))"))
            }

        case .connected:
            if case .error = state {
                // Recovered from reconnection
                transition(to: .listening)
            }

        case .connecting:
            break
        }
    }

    // MARK: - Barge-In Detection

    /// Called when AudioEngine detects the user is speaking
    /// while state is .speaking (AI is responding)
    func checkBargeIn() {
        if state == .speaking && audioEngine.isSpeechDetected {
            handleBargeIn()
        }
    }

    // MARK: - Transcript

    private func appendTranscript(_ entry: TranscriptEntry) {
        transcript.append(entry)
    }

    // MARK: - Duration Tracking

    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.conversationStartTime else { return }
            self.conversationDuration = Date().timeIntervalSince(start)
        }
    }

    // MARK: - Usage Tracking

    private func incrementConversationCount() {
        let today = Calendar.current.startOfDay(for: .now)
        let storedDate = UserDefaults.standard.object(forKey: conversationsDateKey) as? Date ?? .distantPast
        let storedDay = Calendar.current.startOfDay(for: storedDate)

        if today != storedDay {
            // New day — reset counter
            UserDefaults.standard.set(1, forKey: conversationsUsedKey)
            UserDefaults.standard.set(today, forKey: conversationsDateKey)
        } else {
            let current = UserDefaults.standard.integer(forKey: conversationsUsedKey)
            UserDefaults.standard.set(current + 1, forKey: conversationsUsedKey)
        }
    }

    // MARK: - Permissions

    private func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    // MARK: - Cleanup

    private func cleanUp() {
        audioEngine.stop()
        audioPlayer.tearDown()
        audioPlayer.deactivateAudioSession()
        durationTimer?.invalidate()
        durationTimer = nil
        conversationStartTime = nil
        currentAssistantTranscript = ""
    }

    deinit {
        let webSocket = self.webSocket
        Task { @MainActor in
            webSocket.disconnect()
        }
    }
}

// MARK: - Transcript Entry

struct TranscriptEntry: Identifiable, Equatable {
    let id = UUID()
    let role: Role
    let text: String
    let timestamp = Date()

    enum Role {
        case user
        case assistant
    }
}
