import Foundation

@preconcurrency @MainActor
protocol TrafficServiceProtocol: Sendable {
    func fetchTrafficReport() async throws -> TrafficReport
}

@preconcurrency @MainActor
@Observable
final class TrafficService: TrafficServiceProtocol {
    private(set) var currentTraffic: TrafficResponse?
    private(set) var lastReport: TrafficReport?
    private(set) var isStale = false
    private(set) var lastUpdated: Date?

    private var refreshTask: Task<Void, Never>?
    private static let refreshInterval: TimeInterval = 300 // 5 minutes

    func fetchTrafficReport() async throws -> TrafficReport {
        // Return cached if fresh
        if let cached = lastReport, !cached.isStale {
            return cached
        }

        do {
            let response: TrafficResponse = try await APIClient.shared.get("/traffic")
            currentTraffic = response
            let report = response.toTrafficReport()
            lastReport = report
            lastUpdated = .now
            isStale = false
            print("✅ Loaded traffic data (recommendation: \(response.recommendation))")
            return report
        } catch {
            print("❌ Traffic API error: \(error.localizedDescription)")
            isStale = true
            if let cached = lastReport {
                return cached
            }
            throw error
        }
    }

    func fetchBridgeStatus() async throws -> BridgeStatus {
        let report = try await fetchTrafficReport()
        return report.bridgeStatus
    }

    /// Start auto-refreshing traffic every 5 minutes
    func startAutoRefresh() {
        stopAutoRefresh()
        refreshTask = Task {
            while !Task.isCancelled {
                _ = try? await fetchTrafficReport()
                try? await Task.sleep(for: .seconds(Self.refreshInterval))
            }
        }
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }
}

// MARK: - TrafficResponse → TrafficReport Mapping

extension TrafficResponse {
    func toTrafficReport() -> TrafficReport {
        TrafficReport(
            routes: [
                TrafficRoute(
                    id: UUID(), name: "Sagamore Bridge",
                    origin: "Mainland", destination: "Cape Cod",
                    currentTravelTime: TimeInterval(bridges.sagamore.delayMinutes * 60),
                    typicalTravelTime: 0,
                    congestionLevel: bridges.sagamore.status.toCongestionLevel,
                    distance: 0
                ),
                TrafficRoute(
                    id: UUID(), name: "Bourne Bridge",
                    origin: "Mainland", destination: "Cape Cod",
                    currentTravelTime: TimeInterval(bridges.bourne.delayMinutes * 60),
                    typicalTravelTime: 0,
                    congestionLevel: bridges.bourne.status.toCongestionLevel,
                    distance: 0
                ),
                TrafficRoute(
                    id: UUID(), name: "Route 6",
                    origin: "Bourne", destination: "Provincetown",
                    currentTravelTime: TimeInterval(routes.route6.delayMinutes * 60),
                    typicalTravelTime: 0,
                    congestionLevel: routes.route6.status.toCongestionLevel,
                    distance: 0
                ),
                TrafficRoute(
                    id: UUID(), name: "Route 3",
                    origin: "Plymouth", destination: "Sagamore",
                    currentTravelTime: TimeInterval(routes.route3.delayMinutes * 60),
                    typicalTravelTime: 0,
                    congestionLevel: routes.route3.status.toCongestionLevel,
                    distance: 0
                ),
            ],
            incidents: [],
            bridgeStatus: BridgeStatus(
                bourneBridge: .init(
                    status: bridges.bourne.status.toBridgeConditionStatus,
                    delayMinutes: bridges.bourne.delayMinutes,
                    lastUpdated: .now
                ),
                sagamoreBridge: .init(
                    status: bridges.sagamore.status.toBridgeConditionStatus,
                    delayMinutes: bridges.sagamore.delayMinutes,
                    lastUpdated: .now
                )
            ),
            fetchedAt: .now
        )
    }
}
