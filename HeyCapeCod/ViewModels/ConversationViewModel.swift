import Foundation

@preconcurrency @MainActor
@Observable
final class ConversationViewModel {
    var conversation: Conversation
    var inputText = ""
    var isProcessing = false
    var isListening = false
    var error: Error?

    private let aiService: AIService
    private let audioService: AudioService

    init(
        conversation: Conversation = Conversation(),
        aiService: AIService = AIService(),
        audioService: AudioService = AudioService()
    ) {
        self.conversation = conversation
        self.aiService = aiService
        self.audioService = audioService
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
            for try await chunk in aiService.streamMessage(text, history: Array(conversation.messages.dropLast())) {
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
