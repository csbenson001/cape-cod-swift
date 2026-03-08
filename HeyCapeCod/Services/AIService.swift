import Foundation

protocol AIServiceProtocol: Sendable {
    func sendMessage(_ text: String, history: [Message]) async throws -> String
    func streamMessage(_ text: String, history: [Message]) -> AsyncThrowingStream<String, Error>
}

@Observable
final class AIService: AIServiceProtocol, @unchecked Sendable {
    private let apiKey: String
    private let session: URLSession

    private let systemPrompt = """
    You are a friendly, knowledgeable Cape Cod travel assistant called "Hey Cape Cod." \
    You have deep local knowledge of all 15 towns on Cape Cod, from Bourne to Provincetown. \
    You know the best beaches, restaurants, lighthouses, nature trails, maritime history, \
    local events, tide schedules, and traffic patterns including the Bourne and Sagamore bridges. \
    You speak warmly like a well-traveled local friend — enthusiastic but not pushy. \
    Keep responses concise and actionable. When relevant, mention specific places by name \
    and suggest the best times to visit. You can help with real-time questions about weather, \
    tides, traffic, and local recommendations.
    """

    init(apiKey: String = "") {
        self.apiKey = apiKey
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    func sendMessage(_ text: String, history: [Message]) async throws -> String {
        let messages = buildMessages(text, history: history)
        let request = try buildRequest(messages: messages, stream: false)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AIServiceError.requestFailed
        }

        return try parseResponse(data)
    }

    func streamMessage(_ text: String, history: [Message]) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let messages = buildMessages(text, history: history)
                    let request = try buildRequest(messages: messages, stream: true)

                    let (bytes, response) = try await session.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        throw AIServiceError.requestFailed
                    }

                    for try await line in bytes.lines {
                        if line.hasPrefix("data: "),
                           let chunk = parseStreamChunk(String(line.dropFirst(6))) {
                            continuation.yield(chunk)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Private

    private func buildMessages(_ text: String, history: [Message]) -> [[String: String]] {
        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        for msg in history.suffix(20) {
            messages.append([
                "role": msg.role.rawValue,
                "content": msg.content
            ])
        }
        messages.append(["role": "user", "content": text])
        return messages
    }

    private func buildRequest(messages: [[String: String]], stream: Bool) throws -> URLRequest {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw AIServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 1024,
            "system": systemPrompt,
            "messages": messages.filter { $0["role"] != "system" },
            "stream": stream
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func parseResponse(_ data: Data) throws -> String {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let text = content.first?["text"] as? String else {
            throw AIServiceError.invalidResponse
        }
        return text
    }

    private func parseStreamChunk(_ json: String) -> String? {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = obj["type"] as? String,
              type == "content_block_delta",
              let delta = obj["delta"] as? [String: Any],
              let text = delta["text"] as? String else {
            return nil
        }
        return text
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
