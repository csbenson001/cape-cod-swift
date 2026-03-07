import Foundation
import CoreLocation

struct TrafficReport: Codable, Equatable {
    var routes: [TrafficRoute]
    var incidents: [TrafficIncident]
    var bridgeStatus: BridgeStatus
    let fetchedAt: Date

    var isStale: Bool {
        Date.now.timeIntervalSince(fetchedAt) > 300 // 5 minutes
    }
}

struct TrafficRoute: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var origin: String
    var destination: String
    var currentTravelTime: TimeInterval
    var typicalTravelTime: TimeInterval
    var congestionLevel: CongestionLevel
    var distance: Double

    var delayMinutes: Int {
        max(0, Int((currentTravelTime - typicalTravelTime) / 60))
    }

    var travelTimeFormatted: String {
        let minutes = Int(currentTravelTime / 60)
        if minutes >= 60 {
            return "\(minutes / 60)h \(minutes % 60)m"
        }
        return "\(minutes) min"
    }
}

struct TrafficIncident: Identifiable, Codable, Equatable {
    let id: UUID
    var type: IncidentType
    var title: String
    var description: String
    var latitude: Double
    var longitude: Double
    var severity: IncidentSeverity
    var reportedAt: Date
    var estimatedClearTime: Date?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum CongestionLevel: String, Codable, Equatable, CaseIterable {
    case free, light, moderate, heavy, severe

    var displayName: String { rawValue.capitalized }

    var color: String {
        switch self {
        case .free: "duneGrass"
        case .light: "seafoam"
        case .moderate: "sandbarYellow"
        case .heavy: "sunsetOrange"
        case .severe: "cranberry"
        }
    }
}

enum IncidentType: String, Codable, Equatable {
    case accident, construction, closure, hazard, event

    var icon: String {
        switch self {
        case .accident: "car.side.rear.and.collision.and.car.side.front"
        case .construction: "cone.striped"
        case .closure: "xmark.circle.fill"
        case .hazard: "exclamationmark.triangle.fill"
        case .event: "calendar.badge.exclamationmark"
        }
    }
}

enum IncidentSeverity: String, Codable, Equatable {
    case minor, moderate, major, critical
}

// MARK: - Bridge Status

struct BridgeStatus: Codable, Equatable {
    var bourneBridge: BridgeCondition
    var sagamoreBridge: BridgeCondition

    struct BridgeCondition: Codable, Equatable {
        var status: Status
        var delayMinutes: Int
        var lastUpdated: Date

        enum Status: String, Codable, Equatable {
            case open, restricted, closed

            var displayName: String { rawValue.capitalized }

            var icon: String {
                switch self {
                case .open: "checkmark.circle.fill"
                case .restricted: "exclamationmark.triangle.fill"
                case .closed: "xmark.circle.fill"
                }
            }
        }
    }
}
