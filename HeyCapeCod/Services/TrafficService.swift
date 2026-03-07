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
        // TODO: Integrate with MassDOT real-time traffic API
        // For now, return a structured placeholder that matches the API shape
        return TrafficReport(
            routes: Self.monitoredRoutes.enumerated().map { index, name in
                TrafficRoute(
                    id: UUID(),
                    name: name,
                    origin: index < 2 ? "Mainland" : "Bourne",
                    destination: index < 2 ? "Cape Cod" : "Provincetown",
                    currentTravelTime: 0,
                    typicalTravelTime: 0,
                    congestionLevel: .free,
                    distance: 0
                )
            },
            incidents: [],
            bridgeStatus: BridgeStatus(
                bourneBridge: BridgeStatus.BridgeCondition(
                    status: .open,
                    delayMinutes: 0,
                    lastUpdated: .now
                ),
                sagamoreBridge: BridgeStatus.BridgeCondition(
                    status: .open,
                    delayMinutes: 0,
                    lastUpdated: .now
                )
            ),
            fetchedAt: .now
        )
    }
}
