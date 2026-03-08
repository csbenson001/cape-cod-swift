import Foundation
import SwiftData

/// SwiftData-backed cache for offline POI data.
/// Three-tier data strategy:
/// 1. SwiftData cache (fastest — loaded on launch)
/// 2. API fetch (freshest — replaces cache on success)
/// 3. BundledContent (always available — never deleted)
@Model
final class CachedPOI {
    @Attribute(.unique) var id: String
    var name: String
    var descriptionText: String
    var latitude: Double
    var longitude: Double
    var radius: Int
    var category: String
    var town: String
    var address: String?
    var imageUrl: String?
    @Attribute(.transformable(by: NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue))
    var facts: [String]
    @Attribute(.transformable(by: NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue))
    var tips: [String]
    var priority: Int
    var cachedAt: Date

    init(from poi: POI) {
        self.id = poi.id
        self.name = poi.name
        self.descriptionText = poi.description
        self.latitude = poi.latitude
        self.longitude = poi.longitude
        self.radius = poi.radius
        self.category = poi.category.rawValue
        self.town = poi.town
        self.address = poi.address
        self.imageUrl = poi.imageUrl
        self.facts = poi.facts
        self.tips = poi.tips
        self.priority = poi.priority
        self.cachedAt = .now
    }

    func toPOI() -> POI {
        POI(
            id: id,
            name: name,
            description: descriptionText,
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            category: POICategory(rawValue: category) ?? .nature,
            town: town,
            address: address,
            imageUrl: imageUrl,
            facts: facts,
            tips: tips,
            priority: priority
        )
    }

    var isStale: Bool {
        Date.now.timeIntervalSince(cachedAt) > 3600 // 1 hour
    }

    var lastUpdatedText: String {
        let elapsed = Date.now.timeIntervalSince(cachedAt)
        if elapsed < 60 { return "Updated just now" }
        if elapsed < 3600 { return "Updated \(Int(elapsed / 60)) min ago" }
        return "Last updated \(Int(elapsed / 3600))h ago"
    }
}

@Model
final class CachedStory {
    @Attribute(.unique) var id: String
    var poiId: String?
    var title: String
    var mode: String?
    var category: String?
    var script: String?
    var durationSeconds: Int
    var isPremium: Bool
    var cachedAt: Date

    init(from story: APIStoryResponse) {
        self.id = story.id
        self.poiId = story.poiId
        self.title = story.title
        self.mode = story.mode?.rawValue
        self.category = story.category
        self.script = story.script
        self.durationSeconds = story.durationSeconds ?? 0
        self.isPremium = story.isPremium ?? false
        self.cachedAt = .now
    }

    func toAPIStoryResponse() -> APIStoryResponse? {
        // Decode back through JSON round-trip for simplicity
        let json: [String: Any] = [
            "id": id,
            "poiId": poiId ?? "",
            "title": title,
            "mode": mode ?? "",
            "category": category ?? "",
            "script": script ?? "",
            "durationSeconds": durationSeconds,
            "isPremium": isPremium,
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: json),
              let story = try? JSONDecoder().decode(APIStoryResponse.self, from: data) else { return nil }
        return story
    }
}
