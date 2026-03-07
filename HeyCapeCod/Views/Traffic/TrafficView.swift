import SwiftUI

struct TrafficView: View {
    @State private var trafficService = TrafficService()
    @State private var report: TrafficReport?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    // Bridge Status
                    bridgeSection

                    // Route Conditions
                    if let report, !report.routes.isEmpty {
                        routesSection(report.routes)
                    }

                    // Active Incidents
                    if let report, !report.incidents.isEmpty {
                        incidentsSection(report.incidents)
                    }
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.xxl)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Traffic")
            .refreshable {
                await loadTraffic()
            }
            .task {
                await loadTraffic()
            }
        }
    }

    // MARK: - Bridges

    private var bridgeSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Cape Cod Bridges")
                .codTextStyle(.sectionTitle)

            HStack(spacing: CodSpacing.md) {
                BridgeCard(
                    name: "Bourne Bridge",
                    condition: report?.bridgeStatus.bourneBridge
                )
                BridgeCard(
                    name: "Sagamore Bridge",
                    condition: report?.bridgeStatus.sagamoreBridge
                )
            }
        }
    }

    // MARK: - Routes

    private func routesSection(_ routes: [TrafficRoute]) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Route Conditions")
                .codTextStyle(.sectionTitle)

            ForEach(routes) { route in
                HStack {
                    Circle()
                        .fill(congestionColor(route.congestionLevel))
                        .frame(width: 12, height: 12)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(route.name)
                            .codTextStyle(.body)
                        if route.delayMinutes > 0 {
                            Text("+\(route.delayMinutes) min delay")
                                .codTextStyle(.label)
                                .foregroundStyle(Color.capeCod.sunsetOrange)
                        }
                    }

                    Spacer()

                    if route.currentTravelTime > 0 {
                        Text(route.travelTimeFormatted)
                            .codTextStyle(.body)
                    }
                }
                .padding(.vertical, CodSpacing.xs)
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .codShadow(.card)
    }

    // MARK: - Incidents

    private func incidentsSection(_ incidents: [TrafficIncident]) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Active Incidents")
                .codTextStyle(.sectionTitle)

            ForEach(incidents) { incident in
                HStack(spacing: CodSpacing.md) {
                    Image(systemName: incident.type.icon)
                        .foregroundStyle(Color.capeCod.cranberry)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(incident.title)
                            .codTextStyle(.body)
                        Text(incident.description)
                            .codTextStyle(.caption)
                            .lineLimit(2)
                        Text("Reported \(incident.reportedAt.formatted(.relative(presentation: .named)))")
                            .codTextStyle(.label)
                    }
                }
                .padding(CodSpacing.sm)
            }
        }
    }

    private func congestionColor(_ level: CongestionLevel) -> Color {
        switch level {
        case .free: Color.capeCod.duneGrass
        case .light: Color.capeCod.seafoam
        case .moderate: Color.capeCod.sandbarYellow
        case .heavy: Color.capeCod.sunsetOrange
        case .severe: Color.capeCod.cranberry
        }
    }

    private func loadTraffic() async {
        isLoading = true
        defer { isLoading = false }
        do { report = try await trafficService.fetchTrafficReport() }
        catch {}
    }
}

// MARK: - Bridge Card

private struct BridgeCard: View {
    let name: String
    let condition: BridgeStatus.BridgeCondition?

    var body: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: condition?.status.icon ?? "questionmark.circle")
                .font(.title)
                .foregroundStyle(statusColor)

            Text(name)
                .codTextStyle(.cardTitle)
                .multilineTextAlignment(.center)

            Text(condition?.status.displayName ?? "Loading")
                .codTextStyle(.label)
                .foregroundStyle(statusColor)

            if let delay = condition?.delayMinutes, delay > 0 {
                Text("+\(delay) min")
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.sunsetOrange)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .codShadow(.card)
    }

    private var statusColor: Color {
        switch condition?.status {
        case .open: Color.capeCod.duneGrass
        case .restricted: Color.capeCod.sandbarYellow
        case .closed: Color.capeCod.cranberry
        case nil: Color.capeCod.driftwood
        }
    }
}

#Preview {
    TrafficView()
}
