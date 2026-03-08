import Foundation

// MARK: - ChatContext

struct ChatContext: Sendable {
    var experienceMode: ExperienceMode = .adult
    var visitType: String = "tourist"
    var interests: [String] = []
    var userName: String = "friend"
    // Live data context
    var currentWeather: String?
    var currentTide: String?
    var bridgeStatus: String?
    var waterTemp: String?
    var nearbyPOIs: [String] = []
}

@preconcurrency @MainActor
protocol AIServiceProtocol: Sendable {
    func sendMessage(_ text: String, history: [Message], context: ChatContext) async throws -> String
    func streamMessage(_ text: String, history: [Message], context: ChatContext) -> AsyncThrowingStream<String, Error>
}

@preconcurrency @MainActor
@Observable
final class AIService: AIServiceProtocol {
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Send Message (via backend)

    func sendMessage(_ text: String, history: [Message], context: ChatContext = ChatContext()) async throws -> String {
        let request = try buildBackendRequest(text, history: history, context: context)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.requestFailed
        }

        if httpResponse.statusCode == 429 {
            throw AIServiceError.rateLimited
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw AIServiceError.requestFailed
        }

        return try parseChatResponse(data)
    }

    // MARK: - Stream Message (simulated via backend)

    /// The backend returns a complete response (not streamed), so we simulate
    /// a streaming effect by yielding the reply in small chunks.
    func streamMessage(_ text: String, history: [Message], context: ChatContext = ChatContext()) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let reply = try await self.sendMessage(text, history: history, context: context)

                    // Simulate streaming by yielding words progressively
                    let words = reply.split(separator: " ", omittingEmptySubsequences: false)
                    for (index, word) in words.enumerated() {
                        let chunk = index == 0 ? String(word) : " " + String(word)
                        continuation.yield(chunk)
                        // Small delay between words for natural feel
                        try await Task.sleep(for: .milliseconds(25))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Private

    private func buildBackendRequest(_ text: String, history: [Message], context: ChatContext) throws -> URLRequest {
        let baseURL = APIClient.shared.baseURL
        let url = baseURL.appendingPathComponent("chat")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = APIClient.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Build history array for the backend
        let historyPayload: [[String: String]] = history
            .filter { $0.role == .user || $0.role == .assistant }
            .suffix(20)
            .map { ["role": $0.role.rawValue, "content": $0.content] }

        var body: [String: Any] = [
            "message": text,
            "mode": context.experienceMode.rawValue,
            "history": historyPayload
        ]

        // Include live context as additional info in the message if available
        var contextParts: [String] = []
        if let weather = context.currentWeather { contextParts.append(weather) }
        if let tide = context.currentTide { contextParts.append(tide) }
        if let bridge = context.bridgeStatus { contextParts.append("Bridge: \(bridge)") }

        if !contextParts.isEmpty {
            // Prepend live context to the message so the backend's AI has it
            let contextNote = "[Live conditions: \(contextParts.joined(separator: "; "))]"
            body["message"] = "\(contextNote) \(text)"
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func parseChatResponse(_ data: Data) throws -> String {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let message = json["message"] as? String else {
            throw AIServiceError.invalidResponse
        }
        return message
    }
}

enum AIServiceError: LocalizedError {
    case invalidURL
    case requestFailed
    case invalidResponse
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid API URL."
        case .requestFailed: "Failed to get a response. Please try again."
        case .invalidResponse: "Received an unexpected response."
        case .rateLimited: "Too many requests. Please wait a moment."
        }
    }
}
