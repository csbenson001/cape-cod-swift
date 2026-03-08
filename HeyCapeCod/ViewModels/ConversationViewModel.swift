import Foundation

@preconcurrency @MainActor
@Observable
final class ConversationViewModel {
    var conversation: Conversation
    var inputText = ""
    var isProcessing = false
    var isListening = false
    var error: Error?

    // Live context summaries
    var weatherSummary: String?
    var tideSummary: String?
    var bridgeSummaryText: String?

    private let aiService: AIService
    private let audioService: AudioService
    private let weatherService: WeatherService
    private let tideService: TideService
    private let trafficService: TrafficService

    init(
        conversation: Conversation = Conversation(),
        aiService: AIService = AIService(),
        audioService: AudioService = AudioService(),
        weatherService: WeatherService = WeatherService(),
        tideService: TideService = TideService(),
        trafficService: TrafficService = TrafficService()
    ) {
        self.conversation = conversation
        self.aiService = aiService
        self.audioService = audioService
        self.weatherService = weatherService
        self.tideService = tideService
        self.trafficService = trafficService
    }

    // MARK: - Context

    private var chatContext: ChatContext {
        let profile = UserProfileManager.shared.currentProfile
        var ctx = ChatContext()
        ctx.experienceMode = profile?.experienceMode ?? .adult
        ctx.visitType = profile?.visitType ?? "tourist"
        ctx.interests = profile?.interests ?? []
        ctx.userName = profile?.displayName ?? "friend"
        ctx.currentWeather = weatherSummary
        ctx.currentTide = tideSummary
        ctx.bridgeStatus = bridgeSummaryText
        return ctx
    }

    func loadLiveContext() async {
        // Weather
        if let weather = try? await weatherService.fetchWeather(for: WeatherService.capeCodCenter) {
            weatherSummary = "Current weather: \(weather.current.temperatureFormatted), \(weather.current.condition.displayName)"
        }
        // Tides
        if let tides = try? await tideService.fetchTides(station: .hyannis) {
            if let next = tides.nextTide {
                tideSummary = "Next tide: \(next.type.displayName) at \(next.timeFormatted)"
            }
        }
        // Bridge
        if let status = try? await trafficService.fetchBridgeStatus() {
            let bourne = status.bourneBridge
            let sagamore = status.sagamoreBridge
            if bourne.delayMinutes == 0 && sagamore.delayMinutes == 0 {
                bridgeSummaryText = "Both bridges clear, no delays"
            } else {
                var parts: [String] = []
                if bourne.delayMinutes > 0 { parts.append("Bourne Bridge: \(bourne.delayMinutes)min delay") }
                if sagamore.delayMinutes > 0 { parts.append("Sagamore Bridge: \(sagamore.delayMinutes)min delay") }
                bridgeSummaryText = parts.joined(separator: ". ")
            }
        }
    }

    var messages: [Message] {
        conversation.messages.filter { $0.role != .system }
    }

    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isProcessing
    }

    // MARK: - Text Messages

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        inputText = ""
        let userMessage = Message.user(text)
        conversation.messages.append(userMessage)

        isProcessing = true
        defer { isProcessing = false }

        // Add streaming placeholder
        var assistantMessage = Message.assistant("")
        assistantMessage.isStreaming = true
        conversation.messages.append(assistantMessage)
        let streamIndex = conversation.messages.count - 1

        do {
            for try await chunk in aiService.streamMessage(text, history: Array(conversation.messages.dropLast()), context: chatContext) {
                conversation.messages[streamIndex].content += chunk
            }
            conversation.messages[streamIndex].isStreaming = false
            conversation.updatedAt = .now
        } catch {
            conversation.messages.removeLast()
            self.error = error
        }
    }

    // MARK: - Voice Input

    func toggleListening() async {
        if isListening {
            stopListening()
        } else {
            await startListening()
        }
    }

    private func startListening() async {
        let granted = await audioService.requestPermissions()
        guard granted else {
            error = AudioError.permissionDenied
            return
        }

        do {
            try audioService.startListening()
            isListening = true
        } catch {
            self.error = error
        }
    }

    private func stopListening() {
        audioService.stopListening()
        isListening = false

        let transcribed = audioService.transcribedText
        if !transcribed.isEmpty {
            inputText = transcribed
            audioService.transcribedText = ""
        }
    }

    var audioLevel: Float {
        audioService.audioLevel
    }
}
