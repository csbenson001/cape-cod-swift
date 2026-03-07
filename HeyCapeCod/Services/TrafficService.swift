import Foundation

protocol TrafficServiceProtocol: Sendable {
    func fetchTrafficReport() async throws -> TrafficReport
}

@Observable
final class TrafficService: TrafficServiceProtocol {
    private let session: URLSession
    private var cachedReport: TrafficReport?

    // Key Cape Cod routes
    static let monitoredRoutes = [
        "Sagamore Bridge",
        "Bourne Bridge",
        "Route 6 (Mid-Cape Highway)",
        "Route 6A (Old King's Highway)",
        "Route 28"
    ]

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: config)
    }

    func fetchTrafficReport() async throws -> TrafficReport {
        if let cached = cachedReport, !cached.isStale {
            return cached
        }

        // MassDOT traffic data integration point
        // In production, this would call the MassDOT API and/or Apple Maps traffic API
        let report = try await fetchFromAPI()
        cachedReport = report
        return report
    }

    func fetchBridgeStatus() async throws -> BridgeStatus {
        // Integration point for real-time bridge status
        // Bourne and Sagamore bridge data from MassDOT
        let report = try await fetchTrafficReport()
        return report.bridgeStatus
    }

    // MARK: - Private

    private func fetchFromAPI() async throws -> TrafficReport {
        // Fetch from our backend which aggregates MassDOT + Google fallback
        let response: TrafficAPIResponse = try await APIClient.shared.get("/api/traffic")
        return response.toTrafficReport()
    }
}

// MARK: - Backend Response Mapping

private struct TrafficAPIResponse: Codable {
    let bridges: BridgesData
    let routes: RoutesData
    let recommendation: String
    let isStale: Bool?
    let updatedAt: String

    struct BridgesData: Codable {
        let sagamore: BridgeData
        let bourne: BridgeData
    }

    struct BridgeData: Codable {
        let delayMinutes: Int
        let status: String
        let direction: String
        let lastUpdated: String
    }

    struct RoutesData: Codable {
        let route6: RouteData
        let route3: RouteData
    }

    struct RouteData: Codable {
        let status: String
        let delayMinutes: Int
    }

    func toTrafficReport() -> TrafficReport {
        TrafficReport(
            routes: [
                TrafficRoute(id: UUID(), name: "Sagamore Bridge", origin: "Mainland", destination: "Cape Cod",
                    currentTravelTime: TimeInterval(bridges.sagamore.delayMinutes * 60), typicalTravelTime: 0,
                    congestionLevel: mapCongestion(bridges.sagamore.status), distance: 0),
                TrafficRoute(id: UUID(), name: "Bourne Bridge", origin: "Mainland", destination: "Cape Cod",
                    currentTravelTime: TimeInterval(bridges.bourne.delayMinutes * 60), typicalTravelTime: 0,
                    congestionLevel: mapCongestion(bridges.bourne.status), distance: 0),
                TrafficRoute(id: UUID(), name: "Route 6", origin: "Bourne", destination: "Provincetown",
                    currentTravelTime: TimeInterval(routes.route6.delayMinutes * 60), typicalTravelTime: 0,
                    congestionLevel: mapCongestion(routes.route6.status), distance: 0),
                TrafficRoute(id: UUID(), name: "Route 3", origin: "Plymouth", destination: "Sagamore",
                    currentTravelTime: TimeInterval(routes.route3.delayMinutes * 60), typicalTravelTime: 0,
                    congestionLevel: mapCongestion(routes.route3.status), distance: 0),
            ],
            incidents: [],
            bridgeStatus: BridgeStatus(
                bourneBridge: .init(status: mapBridgeStatus(bridges.bourne.status),
                    delayMinutes: bridges.bourne.delayMinutes, lastUpdated: .now),
                sagamoreBridge: .init(status: mapBridgeStatus(bridges.sagamore.status),
                    delayMinutes: bridges.sagamore.delayMinutes, lastUpdated: .now)
            ),
            fetchedAt: .now
        )
    }

    private func mapCongestion(_ status: String) -> CongestionLevel {
        switch status {
        case "clear": .free
        case "moderate": .moderate
        case "heavy": .heavy
        case "severe": .severe
        default: .light
        }
    }

    private func mapBridgeStatus(_ status: String) -> BridgeStatus.BridgeCondition.Status {
        switch status {
        case "clear": .open
        case "heavy", "severe": .restricted
        case "closed": .closed
        default: .open
        }
    }
}
