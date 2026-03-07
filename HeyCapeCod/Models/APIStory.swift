import Foundation

/// A story from the backend API, associated with a POI.
struct APIStoryResponse: Codable, Identifiable {
    let id: String
    let poiId: String?
    let title: String
    let mode: ExperienceMode?
    let category: String?
    let script: String?
    let durationSeconds: Int?
    let isPremium: Bool?
    let narratorVoice: String?
    let audioUrl: String?
    let tags: [String]?
    let sortOrder: Int?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        poiId = try c.decodeIfPresent(String.self, forKey: .poiId)
        title = try c.decodeIfPresent(String.self, forKey: .title) ?? "Untitled"
        mode = try c.decodeIfPresent(ExperienceMode.self, forKey: .mode)
        category = try c.decodeIfPresent(String.self, forKey: .category)
        script = try c.decodeIfPresent(String.self, forKey: .script)
        durationSeconds = try c.decodeIfPresent(Int.self, forKey: .durationSeconds)
        isPremium = try c.decodeIfPresent(Bool.self, forKey: .isPremium)
        narratorVoice = try c.decodeIfPresent(String.self, forKey: .narratorVoice)
        audioUrl = try c.decodeIfPresent(String.self, forKey: .audioUrl)
        tags = try c.decodeIfPresent([String].self, forKey: .tags)
        sortOrder = try c.decodeIfPresent(Int.self, forKey: .sortOrder)
    }
}

/// Experience mode for story variants
enum ExperienceMode: String, Codable, CaseIterable, Identifiable {
    case kids
    case teen
    case adult
    case family

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }
}

// MARK: - Story List Response

struct StoryListResponse: Codable {
    let stories: [APIStoryResponse]
    let count: Int
}
