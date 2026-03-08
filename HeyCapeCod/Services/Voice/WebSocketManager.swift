import Foundation

/// Manages the WebSocket connection to the voice relay backend.
/// Protocol: wss://backend/voice
///
/// Outbound messages:
///   { "type": "audio", "audio": "<base64 PCM16>", "timestamp": <ms> }
///   { "type": "control", "action": "interrupt" | "end_turn" | "disconnect" }
///
/// Inbound messages:
///   { "type": "audio", "audio": "<base64>", "is_final": bool }
///   { "type": "transcript", "text": "...", "role": "user" | "assistant" }
///   { "type": "status", "state": "listening" | "thinking" | "speaking" }
///
/// TODO: (Prompt 14) Vercel serverless functions have a 10-second timeout (free tier)
/// or 60-second timeout (Pro). WebSocket connections are NOT supported on Vercel.
/// The voice relay backend must be deployed to a long-lived server platform such as
/// Railway, Render, or Fly.io that supports persistent WebSocket connections.
/// Update `serverURL` to point to the dedicated voice server once deployed.
@preconcurrency @MainActor
@Observable
final class WebSocketManager: NSObject {

    // MARK: - Singleton

    static let shared = WebSocketManager()

    // MARK: - Public State

    private(set) var connectionState: ConnectionState = .disconnected
    private(set) var lastError: Error?

    var isConnected: Bool {
        connectionState == .connected
    }

    enum ConnectionState: Equatable {
        case disconnected
        case connecting
        case connected
        case reconnecting(attempt: Int)
    }

    // MARK: - Inbound Message Types

    enum InboundMessage {
        case audio(data: Data, isFinal: Bool)
        case transcript(text: String, role: String)
        case status(state: String)
        case error(message: String)
    }

    // MARK: - Callbacks

    var onMessage: ((InboundMessage) -> Void)?
    var onConnectionStateChanged: ((ConnectionState) -> Void)?

    // MARK: - Configuration

    private let serverURL: URL
    private static let pingInterval: TimeInterval = 30
    private static let maxReconnectAttempts = 8
    private static let maxBackoffSeconds: TimeInterval = 30

    // MARK: - Private State

    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var pingTimer: Timer?
    private var reconnectAttempt = 0
    private var isIntentionalDisconnect = false
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Init

    init(serverURL: URL? = nil) {
        #if DEBUG
        self.serverURL = serverURL ?? URL(string: "ws://localhost:3000/api/voice")!
        #else
        self.serverURL = serverURL ?? URL(string: "wss://v0-cape-cod-ai-travel-assistant.vercel.app/api/voice")!
        #endif
        super.init()
    }

    // MARK: - Connection Lifecycle

    func connect() {
        guard connectionState == .disconnected || {
            if case .reconnecting = connectionState { return true }
            return false
        }() else { return }

        isIntentionalDisconnect = false
        updateState(.connecting)

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.waitsForConnectivity = true

        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)

        var request = URLRequest(url: serverURL)
        request.timeoutInterval = 10

        // Inject Firebase Auth token for user identification
        if let token = APIClient.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let task = session!.webSocketTask(with: request)
        self.webSocketTask = task
        task.resume()

        startReceiving()
        startPinging()
        // State will be set to .connected by the URLSessionWebSocketDelegate
        // when the handshake completes
    }

    func disconnect() {
        isIntentionalDisconnect = true
        sendControl(action: "disconnect")
        tearDown()
        updateState(.disconnected)
    }

    private func tearDown() {
        pingTimer?.invalidate()
        pingTimer = nil
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        session?.invalidateAndCancel()
        session = nil
    }

    // MARK: - Send Messages

    /// Send a base64-encoded audio chunk
    func sendAudio(_ base64Audio: String, timestamp: TimeInterval) {
        let payload: [String: Any] = [
            "type": "audio",
            "audio": base64Audio,
            "timestamp": timestamp
        ]
        sendJSON(payload)
    }

    /// Send a control message (interrupt, end_turn, disconnect)
    func sendControl(action: String) {
        let payload: [String: Any] = [
            "type": "control",
            "action": action
        ]
        sendJSON(payload)
    }

    private func sendJSON(_ payload: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let string = String(data: data, encoding: .utf8) else { return }

        webSocketTask?.send(.string(string)) { [weak self] error in
            if let error {
                print("[WebSocket] Send error: \(error.localizedDescription)")
                Task { @MainActor [weak self] in
                    self?.handleDisconnection(error: error)
                }
            }
        }
    }

    // MARK: - Receive Messages

    private func startReceiving() {
        webSocketTask?.receive { result in
            Task { @MainActor [weak self] in
                guard let self else { return }

                switch result {
                case .success(let message):
                    self.handleInboundMessage(message)
                    // Continue receiving
                    self.startReceiving()

                case .failure(let error):
                    print("[WebSocket] Receive error: \(error.localizedDescription)")
                    self.handleDisconnection(error: error)
                }
            }
        }
    }

    private func handleInboundMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            parseTextMessage(text)
        case .data(let data):
            if let text = String(data: data, encoding: .utf8) {
                parseTextMessage(text)
            }
        @unknown default:
            break
        }
    }

    private func parseTextMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else { return }

        let parsed: InboundMessage

        switch type {
        case "audio":
            let audioBase64 = json["audio"] as? String ?? ""
            let isFinal = json["is_final"] as? Bool ?? false
            guard let audioData = Data(base64Encoded: audioBase64) else { return }
            parsed = .audio(data: audioData, isFinal: isFinal)

        case "transcript":
            let text = json["text"] as? String ?? ""
            let role = json["role"] as? String ?? "assistant"
            parsed = .transcript(text: text, role: role)

        case "status":
            let state = json["state"] as? String ?? ""
            parsed = .status(state: state)

        case "error":
            let message = json["message"] as? String ?? "Unknown error"
            parsed = .error(message: message)

        default:
            return
        }

        Task { @MainActor [weak self] in
            self?.onMessage?(parsed)
        }
    }

    // MARK: - Ping/Pong Keep-Alive

    private func startPinging() {
        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(withTimeInterval: Self.pingInterval, repeats: true) { _ in
            Task { @MainActor [weak self] in
                self?.webSocketTask?.sendPing { error in
                    if let error {
                        print("[WebSocket] Ping failed: \(error.localizedDescription)")
                        Task { @MainActor [weak self] in
                            self?.handleDisconnection(error: error)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Reconnection

    private func handleDisconnection(error: Error?) {
        guard !isIntentionalDisconnect else { return }

        lastError = error
        tearDown()

        guard reconnectAttempt < Self.maxReconnectAttempts else {
            updateState(.disconnected)
            Task { @MainActor [weak self] in
                self?.onMessage?(.error(message: "Connection lost. Please try again."))
            }
            return
        }

        reconnectAttempt += 1
        let backoff = min(pow(2.0, Double(reconnectAttempt - 1)), Self.maxBackoffSeconds)
        updateState(.reconnecting(attempt: reconnectAttempt))

        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(backoff))
            guard let self, !self.isIntentionalDisconnect else { return }
            self.connect()
        }
    }

    private func updateState(_ state: ConnectionState) {
        Task { @MainActor [weak self] in
            self?.connectionState = state
            self?.onConnectionStateChanged?(state)
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketManager: URLSessionWebSocketDelegate {
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Task { @MainActor in
            updateState(.connected)
            reconnectAttempt = 0
        }
    }

    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        Task { @MainActor in
            handleDisconnection(error: nil)
        }
    }

    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Task { @MainActor in
            if let error {
                handleDisconnection(error: error)
            }
        }
    }
}
