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
    private let apiKey: String
    private let session: URLSession

    init(apiKey: String = "") {
        self.apiKey = apiKey
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Build System Prompt

    func buildSystemPrompt(context: ChatContext) -> String {
        var prompt = """
        You are "Hey Cape Cod," a friendly Cape Cod travel assistant.

        **User Profile:**
        - Name: \(context.userName)
        - Experience mode: \(context.experienceMode.displayName)
        - Visit type: \(context.visitType)
        """

        if !context.interests.isEmpty {
            prompt += "\n- Interests: \(context.interests.joined(separator: ", "))"
        }

        // Mode-specific behavior
        switch context.experienceMode {
        case .kids:
            prompt += "\n\n**Mode-specific behavior:**\nUse fun, exciting language! Include pirate facts, animal facts, and adventure hooks. Keep it simple and enthusiastic."
        case .teen:
            prompt += "\n\n**Mode-specific behavior:**\nBe chill but informative. Include hidden gems, cool history, local legends, and Instagram-worthy spots."
        case .adult:
            prompt += "\n\n**Mode-specific behavior:**\nProvide detailed, sophisticated responses. Include dining recommendations, wine/cocktail spots, historical depth, and practical logistics."
        case .family:
            prompt += "\n\n**Mode-specific behavior:**\nBalance fun facts for kids with useful info for parents. Mention kid-friendliness, parking, facilities."
        }

        // Visit type behavior
        switch context.visitType {
        case "local":
            prompt += "\n\n**Visit type behavior:**\nSkip obvious tourist info. Focus on events, seasonal changes, local-only spots, new openings."
        case "dayTrip":
            prompt += "\n\n**Visit type behavior:**\nPrioritize efficiency — cluster nearby attractions, mention drive times, suggest optimal routes."
        default: // tourist
            prompt += "\n\n**Visit type behavior:**\nGive full context with directions, parking tips, best times to visit."
        }

        // Live conditions
        var liveConditions: [String] = []
        if let weather = context.currentWeather {
            liveConditions.append(weather)
        }
        if let tide = context.currentTide {
            liveConditions.append(tide)
        }
        if let bridge = context.bridgeStatus {
            liveConditions.append("Bridge traffic: \(bridge)")
        }
        if let waterTemp = context.waterTemp {
            liveConditions.append("Water temperature: \(waterTemp)")
        }

        if !liveConditions.isEmpty {
            prompt += "\n\n**Live Conditions (share when relevant):**\n"
            prompt += liveConditions.joined(separator: "\n")
        }

        // Nearby POIs
        if !context.nearbyPOIs.isEmpty {
            prompt += "\n\n**Nearby Points of Interest:**\n"
            prompt += context.nearbyPOIs.joined(separator: ", ")
        }

        prompt += "\n\nKeep responses concise and actionable. Mention specific places by name. You have deep knowledge of all 15 towns from Bourne to Provincetown."

        return prompt
    }

    func sendMessage(_ text: String, history: [Message], context: ChatContext = ChatContext()) async throws -> String {
        let systemPrompt = buildSystemPrompt(context: context)
        let messages = buildMessages(text, history: history, systemPrompt: systemPrompt)
        let request = try buildRequest(messages: messages, systemPrompt: systemPrompt, stream: false)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AIServiceError.requestFailed
        }

        return try parseResponse(data)
    }

    func streamMessage(_ text: String, history: [Message], context: ChatContext = ChatContext()) -> AsyncThrowingStream<String, Error> {
        let systemPrompt = buildSystemPrompt(context: context)
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let messages = buildMessages(text, history: history, systemPrompt: systemPrompt)
                    let request = try buildRequest(messages: messages, systemPrompt: systemPrompt, stream: true)

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

    private func buildMessages(_ text: String, history: [Message], systemPrompt: String) -> [[String: String]] {
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

    private func buildRequest(messages: [[String: String]], systemPrompt: String, stream: Bool) throws -> URLRequest {
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
