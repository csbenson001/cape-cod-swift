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

/// Experience mode for story variants and dynamic tab configuration
enum ExperienceMode: String, Codable, CaseIterable, Identifiable {
    case kids
    case teen
    case adult
    case family

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .kids: "Kid Mode"
        case .teen: "Teen Mode"
        case .adult: "Adult Mode"
        case .family: "Family Mode"
        }
    }

    var subtitle: String {
        switch self {
        case .kids: "Ages 4-12"
        case .teen: "Ages 13-17"
        case .adult: "Full Experience"
        case .family: "Something for Everyone"
        }
    }

    var tagline: String {
        switch self {
        case .kids: "Ahoy, young explorer! Discover pirate treasure and sea creatures."
        case .teen: "Find the best spots, share your adventures, and explore."
        case .adult: "In-depth history, curated dining, and scenic tours."
        case .family: "All ages welcome \u{2014} activities and content for the whole crew."
        }
    }

    var icon: String {
        switch self {
        case .kids: "figure.child"
        case .teen: "figure.wave"
        case .adult: "figure.hiking"
        case .family: "figure.2.and.child.holdinghands"
        }
    }

    /// The tabs visible in each experience mode
    var tabs: [AppTab] {
        switch self {
        case .kids: [.home, .explore, .stories, .funZone, .profile]
        case .teen: [.home, .explore, .social, .events, .profile]
        case .adult: [.home, .explore, .tours, .dining, .profile]
        case .family: [.home, .explore, .tours, .dining, .profile]
        }
    }

    var themeColor: String {
        switch self {
        case .kids: "sunsetOrange"
        case .teen: "seafoam"
        case .adult: "oceanBlue"
        case .family: "duneGrass"
        }
    }
}

// MARK: - Story List Response

struct StoryListResponse: Codable {
    let stories: [APIStoryResponse]
    let count: Int
}
