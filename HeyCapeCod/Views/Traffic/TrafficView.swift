import SwiftUI

struct TrafficView: View {
    @State private var trafficService = TrafficService()
    @State private var report: TrafficReport?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    if isLoading && report == nil {
                        // Loading state
                        VStack(spacing: CodSpacing.md) {
                            HStack(spacing: CodSpacing.md) {
                                LoadingSkeleton(variant: .metric)
                                LoadingSkeleton(variant: .metric)
                            }
                            LoadingSkeleton(variant: .card)
                        }
                        .padding(.horizontal, CodSpacing.screenEdge)
                    } else {
                        // Bridge Status
                        bridgeSection
                            .staggered(index: 0)

                        // Route Conditions
                        if let report, !report.routes.isEmpty {
                            routesSection(report.routes)
                                .staggered(index: 1)
                        }

                        // Active Incidents
                        if let report, !report.incidents.isEmpty {
                            incidentsSection(report.incidents)
                                .staggered(index: 2)
                        }

                        // Departure Advisor Link
                        departureAdvisorLink
                            .staggered(index: 3)
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
                        .pulsingGlow(
                            color: congestionColor(route.congestionLevel),
                            isActive: route.congestionLevel == .heavy || route.congestionLevel == .severe
                        )

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
                            .monospacedDigit()
                    }
                }
                .padding(.vertical, CodSpacing.xs)
                .codAccessibleGroup(
                    label: "\(route.name): \(route.congestionLevel.rawValue)\(route.delayMinutes > 0 ? ", \(route.delayMinutes) minute delay" : "")"
                )
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
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
                .codAccessibleGroup(label: "Incident: \(incident.title). \(incident.description)")
            }
        }
    }

    // MARK: - Departure Advisor Link

    private var departureAdvisorLink: some View {
        NavigationLink {
            DepartureAdvisorView()
        } label: {
            HStack(spacing: CodSpacing.md) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .frame(width: 44, height: 44)
                    .background(Color.capeCod.oceanBlue.opacity(0.1))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("Departure Advisor")
                        .codTextStyle(.cardTitle)
                        .foregroundStyle(Color.capeCod.textPrimary)
                    Text("Find the best time to leave and beat bridge traffic")
                        .codTextStyle(.caption)
                        .foregroundStyle(Color.capeCod.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.capeCod.driftwood)
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .buttonStyle(.plain)
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
                .contentTransition(.symbolEffect(.replace))

            Text(name)
                .codTextStyle(.cardTitle)
                .multilineTextAlignment(.center)

            Text(condition?.status.displayName ?? "Loading")
                .codTextStyle(.label)
                .foregroundStyle(statusColor)

            if let delay = condition?.delayMinutes, delay > 0 {
                HStack(spacing: 2) {
                    Text("+")
                        .codTextStyle(.label)
                        .foregroundStyle(Color.capeCod.sunsetOrange)
                    AnimatedCounter(delay, font: CapeCodTypography.label(), color: Color.capeCod.sunsetOrange)
                    Text("min")
                        .codTextStyle(.label)
                        .foregroundStyle(Color.capeCod.sunsetOrange)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .pulsingGlow(
            color: statusColor,
            isActive: condition?.status == .restricted || condition?.status == .closed
        )
        .codAccessibleGroup(
            label: "\(name): \(condition?.status.displayName ?? "Loading")\((condition?.delayMinutes ?? 0) > 0 ? ", \(condition!.delayMinutes) minute delay" : "")"
        )
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
