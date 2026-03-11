import Foundation

// MARK: - Chat Memory Model

struct ChatMemory: Codable, Equatable {
    var isEnabled: Bool = false
    var foodPreferences: [String] = []
    var favoriteBeaches: [String] = []
    var visitHistory: [String] = []
    var travelStyle: String = ""
    var dietaryRestrictions: [String] = []
    var interests: [String] = []
    var dislikes: [String] = []
    var familyInfo: String = ""
    var lastUpdated: Date = Date()
}

// MARK: - Memory Category

enum MemoryCategory: String, CaseIterable, Identifiable {
    case foodPreferences = "Food Preferences"
    case favoriteBeaches = "Favorite Beaches"
    case visitHistory = "Visit History"
    case travelStyle = "Travel Style"
    case dietaryRestrictions = "Dietary Restrictions"
    case interests = "Interests"
    case dislikes = "Dislikes"
    case familyInfo = "Family Info"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .foodPreferences: "fork.knife"
        case .favoriteBeaches: "beach.umbrella"
        case .visitHistory: "clock.arrow.circlepath"
        case .travelStyle: "figure.walk"
        case .dietaryRestrictions: "exclamationmark.triangle"
        case .interests: "star"
        case .dislikes: "hand.thumbsdown"
        case .familyInfo: "figure.2.and.child.holdinghands"
        }
    }
}

// MARK: - Detected Preference

struct DetectedPreference: Identifiable, Equatable {
    let id = UUID()
    let category: MemoryCategory
    let value: String
    let sourcePhrase: String
}

// MARK: - Chat Memory Manager

@MainActor
@Observable
final class ChatMemoryManager {
    static let shared = ChatMemoryManager()

    private(set) var memory = ChatMemory()
    private let storageKey = "chatMemory"

    var isEnabled: Bool {
        get { memory.isEnabled }
        set {
            memory.isEnabled = newValue
            saveMemory()
        }
    }

    private init() {
        loadMemory()
    }

    // MARK: - Persistence

    func saveMemory() {
        memory.lastUpdated = Date()
        if let data = try? JSONEncoder().encode(memory) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func loadMemory() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(ChatMemory.self, from: data) else {
            return
        }
        memory = decoded
    }

    func clearMemory() {
        let wasEnabled = memory.isEnabled
        memory = ChatMemory()
        memory.isEnabled = wasEnabled
        saveMemory()
    }

    // MARK: - Preference Management

    func addPreference(category: MemoryCategory, value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        switch category {
        case .foodPreferences:
            guard !memory.foodPreferences.contains(trimmed) else { return }
            memory.foodPreferences.append(trimmed)
        case .favoriteBeaches:
            guard !memory.favoriteBeaches.contains(trimmed) else { return }
            memory.favoriteBeaches.append(trimmed)
        case .visitHistory:
            guard !memory.visitHistory.contains(trimmed) else { return }
            memory.visitHistory.append(trimmed)
        case .travelStyle:
            memory.travelStyle = trimmed
        case .dietaryRestrictions:
            guard !memory.dietaryRestrictions.contains(trimmed) else { return }
            memory.dietaryRestrictions.append(trimmed)
        case .interests:
            guard !memory.interests.contains(trimmed) else { return }
            memory.interests.append(trimmed)
        case .dislikes:
            guard !memory.dislikes.contains(trimmed) else { return }
            memory.dislikes.append(trimmed)
        case .familyInfo:
            memory.familyInfo = trimmed
        }
        saveMemory()
    }

    func removePreference(category: MemoryCategory, value: String) {
        switch category {
        case .foodPreferences:
            memory.foodPreferences.removeAll { $0 == value }
        case .favoriteBeaches:
            memory.favoriteBeaches.removeAll { $0 == value }
        case .visitHistory:
            memory.visitHistory.removeAll { $0 == value }
        case .travelStyle:
            memory.travelStyle = ""
        case .dietaryRestrictions:
            memory.dietaryRestrictions.removeAll { $0 == value }
        case .interests:
            memory.interests.removeAll { $0 == value }
        case .dislikes:
            memory.dislikes.removeAll { $0 == value }
        case .familyInfo:
            memory.familyInfo = ""
        }
        saveMemory()
    }

    func preferences(for category: MemoryCategory) -> [String] {
        switch category {
        case .foodPreferences: memory.foodPreferences
        case .favoriteBeaches: memory.favoriteBeaches
        case .visitHistory: memory.visitHistory
        case .travelStyle: memory.travelStyle.isEmpty ? [] : [memory.travelStyle]
        case .dietaryRestrictions: memory.dietaryRestrictions
        case .interests: memory.interests
        case .dislikes: memory.dislikes
        case .familyInfo: memory.familyInfo.isEmpty ? [] : [memory.familyInfo]
        }
    }

    var totalPreferenceCount: Int {
        MemoryCategory.allCases.reduce(0) { $0 + preferences(for: $1).count }
    }

    // MARK: - AI Context String

    func memoryContextString() -> String? {
        guard memory.isEnabled else { return nil }

        var parts: [String] = []

        if !memory.foodPreferences.isEmpty {
            parts.append("Food: \(memory.foodPreferences.joined(separator: ", "))")
        }
        if !memory.dietaryRestrictions.isEmpty {
            parts.append("Dietary restrictions: \(memory.dietaryRestrictions.joined(separator: ", "))")
        }
        if !memory.favoriteBeaches.isEmpty {
            parts.append("Favorite beaches: \(memory.favoriteBeaches.joined(separator: ", "))")
        }
        if !memory.interests.isEmpty {
            parts.append("Interests: \(memory.interests.joined(separator: ", "))")
        }
        if !memory.dislikes.isEmpty {
            parts.append("Dislikes: \(memory.dislikes.joined(separator: ", "))")
        }
        if !memory.travelStyle.isEmpty {
            parts.append("Travel style: \(memory.travelStyle)")
        }
        if !memory.familyInfo.isEmpty {
            parts.append("Family: \(memory.familyInfo)")
        }
        if !memory.visitHistory.isEmpty {
            parts.append("Visit history: \(memory.visitHistory.joined(separator: ", "))")
        }

        guard !parts.isEmpty else { return nil }
        return "[User preferences: \(parts.joined(separator: ". ")).]"
    }

    // MARK: - Preference Extraction

    func extractMemoryFromConversation(_ messages: [Message]) -> [DetectedPreference] {
        guard memory.isEnabled else { return [] }

        var detected: [DetectedPreference] = []
        let userMessages = messages.filter { $0.role == .user }

        for message in userMessages {
            detected.append(contentsOf: extractFromText(message.content))
        }

        // Filter out preferences already stored
        return detected.filter { pref in
            !preferences(for: pref.category).contains(pref.value)
        }
    }

    private func extractFromText(_ text: String) -> [DetectedPreference] {
        let lower = text.lowercased()
        var results: [DetectedPreference] = []

        // Food patterns
        let foodPatterns: [(String, String)] = [
            ("i love ", "foodPreferences"),
            ("i really like ", "foodPreferences"),
            ("my favorite food is ", "foodPreferences"),
            ("i enjoy eating ", "foodPreferences"),
            ("i crave ", "foodPreferences"),
        ]

        // Dislike patterns
        let dislikePatterns: [(String, String)] = [
            ("i don't like ", "dislikes"),
            ("i dont like ", "dislikes"),
            ("i hate ", "dislikes"),
            ("i can't stand ", "dislikes"),
            ("i avoid ", "dislikes"),
            ("not a fan of ", "dislikes"),
        ]

        // Allergy / dietary patterns
        let dietPatterns: [(String, String)] = [
            ("i'm allergic to ", "dietaryRestrictions"),
            ("im allergic to ", "dietaryRestrictions"),
            ("i am allergic to ", "dietaryRestrictions"),
            ("i'm vegetarian", "dietaryRestrictions"),
            ("i'm vegan", "dietaryRestrictions"),
            ("i am vegan", "dietaryRestrictions"),
            ("i am vegetarian", "dietaryRestrictions"),
            ("gluten free", "dietaryRestrictions"),
            ("gluten-free", "dietaryRestrictions"),
            ("i can't eat ", "dietaryRestrictions"),
        ]

        // Family patterns
        let familyPatterns: [(String, String)] = [
            ("my kids are ", "familyInfo"),
            ("i have kids ", "familyInfo"),
            ("my children ", "familyInfo"),
            ("traveling with my family", "familyInfo"),
            ("we have a baby", "familyInfo"),
        ]

        // Interest patterns
        let interestPatterns: [(String, String)] = [
            ("i'm interested in ", "interests"),
            ("im interested in ", "interests"),
            ("i am interested in ", "interests"),
            ("i enjoy ", "interests"),
            ("my hobby is ", "interests"),
            ("i like to ", "interests"),
        ]

        // Travel style patterns
        let travelPatterns: [(String, String)] = [
            ("i prefer ", "travelStyle"),
            ("i like a relaxed ", "travelStyle"),
            ("adventure ", "travelStyle"),
            ("we like to take it easy", "travelStyle"),
        ]

        // Beach patterns
        let beachPatterns: [(String, String)] = [
            ("my favorite beach is ", "favoriteBeaches"),
            ("i love going to ", "favoriteBeaches"),
        ]

        // Visit patterns
        let visitPatterns: [(String, String)] = [
            ("i visited ", "visitHistory"),
            ("we went to ", "visitHistory"),
            ("last time i was at ", "visitHistory"),
        ]

        let allPatterns = foodPatterns + dislikePatterns + dietPatterns
            + familyPatterns + interestPatterns + travelPatterns
            + beachPatterns + visitPatterns

        for (pattern, categoryKey) in allPatterns {
            guard let range = lower.range(of: pattern) else { continue }

            let after = String(text[range.upperBound...])
            let extracted = extractPhrase(from: after)
            guard !extracted.isEmpty else { continue }

            let category = categoryFromKey(categoryKey)
            results.append(DetectedPreference(
                category: category,
                value: extracted,
                sourcePhrase: String(text[range.lowerBound...].prefix(pattern.count + extracted.count))
            ))
        }

        return results
    }

    private func extractPhrase(from text: String) -> String {
        // Take text up to the first punctuation or end, max 60 chars
        let terminators: [Character] = [".", ",", "!", "?", "\n"]
        var end = text.startIndex
        var length = 0

        for char in text {
            if terminators.contains(char) || length >= 60 { break }
            end = text.index(after: end)
            length += 1
        }

        return String(text[text.startIndex..<end])
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func categoryFromKey(_ key: String) -> MemoryCategory {
        switch key {
        case "foodPreferences": .foodPreferences
        case "favoriteBeaches": .favoriteBeaches
        case "visitHistory": .visitHistory
        case "travelStyle": .travelStyle
        case "dietaryRestrictions": .dietaryRestrictions
        case "interests": .interests
        case "dislikes": .dislikes
        case "familyInfo": .familyInfo
        default: .interests
        }
    }
}
