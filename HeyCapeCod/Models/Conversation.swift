import Foundation

struct Conversation: Identifiable, Codable {
    let id: UUID
    var title: String
    var messages: [Message]
    let createdAt: Date
    var updatedAt: Date
    var isActive: Bool

    init(
        id: UUID = UUID(),
        title: String = "New Conversation",
        messages: [Message] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now,
        isActive: Bool = true
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isActive = isActive
    }

    var lastMessage: Message? { messages.last }

    var summary: String {
        if let first = messages.first(where: { $0.role == .user }) {
            return String(first.content.prefix(100))
        }
        return title
    }
}
