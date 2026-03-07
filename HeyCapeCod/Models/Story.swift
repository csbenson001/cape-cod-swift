import Foundation
import CoreLocation

struct Story: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var narrator: String
    var category: StoryCategory
    var duration: TimeInterval
    var audioURL: URL?
    var locationID: UUID?
    var triggerLatitude: Double?
    var triggerLongitude: Double?
    var triggerRadius: Double
    var imageURL: URL?
    var isListened: Bool

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        narrator: String = "Cape Cod Guide",
        category: StoryCategory = .history,
        duration: TimeInterval = 0,
        audioURL: URL? = nil,
        locationID: UUID? = nil,
        triggerLatitude: Double? = nil,
        triggerLongitude: Double? = nil,
        triggerRadius: Double = 200,
        imageURL: URL? = nil,
        isListened: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.narrator = narrator
        self.category = category
        self.duration = duration
        self.audioURL = audioURL
        self.locationID = locationID
        self.triggerLatitude = triggerLatitude
        self.triggerLongitude = triggerLongitude
        self.triggerRadius = triggerRadius
        self.imageURL = imageURL
        self.isListened = isListened
    }

    var triggerCoordinate: CLLocationCoordinate2D? {
        guard let lat = triggerLatitude, let lon = triggerLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

enum StoryCategory: String, Codable, CaseIterable, Identifiable {
    case history
    case nature
    case maritime
    case legend
    case culture
    case food

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .history: "book.fill"
        case .nature: "leaf.fill"
        case .maritime: "water.waves"
        case .legend: "star.fill"
        case .culture: "paintpalette.fill"
        case .food: "fork.knife"
        }
    }
}
