import Foundation

/// Traffic response from the backend API (/api/traffic).
struct TrafficResponse: Codable {
    let bridges: BridgeStatusResponse
    let routes: RouteStatusResponse
    let recommendation: String
    let updatedAt: String

    struct BridgeStatusResponse: Codable {
        let sagamore: BridgeInfo
        let bourne: BridgeInfo
    }

    struct BridgeInfo: Codable {
        let delayMinutes: Int
        let status: TrafficLevel
        let direction: String
        let lastUpdated: String
    }

    struct RouteStatusResponse: Codable {
        let route6: RouteInfo
        let route3: RouteInfo
    }

    struct RouteInfo: Codable {
        let status: TrafficLevel
        let delayMinutes: Int
    }
}

enum TrafficLevel: String, Codable, CaseIterable {
    case clear
    case moderate
    case heavy
    case severe

    var displayName: String { rawValue.capitalized }

    var color: String {
        switch self {
        case .clear: "duneGrass"
        case .moderate: "sandbarYellow"
        case .heavy: "sunsetOrange"
        case .severe: "cranberry"
        }
    }

    /// Map to legacy CongestionLevel
    var toCongestionLevel: CongestionLevel {
        switch self {
        case .clear: .free
        case .moderate: .moderate
        case .heavy: .heavy
        case .severe: .severe
        }
    }

    /// Map to legacy BridgeCondition.Status
    var toBridgeConditionStatus: BridgeStatus.BridgeCondition.Status {
        switch self {
        case .clear: .open
        case .moderate: .open
        case .heavy: .restricted
        case .severe: .restricted
        }
    }
}
