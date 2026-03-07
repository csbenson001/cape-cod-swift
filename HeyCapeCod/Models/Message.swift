import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: UUID
    let role: Role
    var content: String
    let timestamp: Date
    var audioURL: URL?
    var isStreaming: Bool

    init(
        id: UUID = UUID(),
        role: Role,
        content: String,
        timestamp: Date = .now,
        audioURL: URL? = nil,
        isStreaming: Bool = false
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.audioURL = audioURL
        self.isStreaming = isStreaming
    }

    enum Role: String, Codable {
        case user
        case assistant
        case system
    }

    static func user(_ content: String) -> Message {
        Message(role: .user, content: content)
    }

    static func assistant(_ content: String) -> Message {
        Message(role: .assistant, content: content)
    }

    static func system(_ content: String) -> Message {
        Message(role: .system, content: content)
    }
}
