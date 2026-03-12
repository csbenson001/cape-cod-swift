import SwiftUI
import MapKit

// MARK: - Shark Alert View

struct SharkAlertView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var service = SharkAlertService()
    @State private var selectedSighting: SharkSighting?
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.88, longitude: -69.98),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    heroBanner
                        .staggered(index: 0)

                    mapSection
                        .staggered(index: 1)

                    beachStatusSection
                        .staggered(index: 2)

                    timelineSection
                        .staggered(index: 3)

                    safetyTipsSection
                        .staggered(index: 4)

                    learnMoreSection
                        .staggered(index: 5)
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)
            .refreshable {
                await service.forceRefresh()
                CodHaptic.success()
            }
            .task {
                await service.fetchRecentSightings()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        CodHaptic.selection()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.capeCod.driftwood)
                    }
                    .codAccessibleButton("Close", hint: "Dismiss shark alerts")
                }
            }
        }
    }

    // MARK: - Hero Banner

    private var heroBanner: some View {
        VStack(spacing: CodSpacing.sm) {
            ZStack {
                Circle()
                    .fill(alertBackgroundColor.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: service.alertLevel.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(alertColor)
            }

            Text("Shark Alert")
                .codTextStyle(.heroTitle)
                .codAccessibleHeader("Shark Alert")

            Text("Cape Cod Outer Beaches")
                .codTextStyle(.subtitle)

            alertLevelBadge
                .padding(.top, CodSpacing.xs)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, CodSpacing.lg)
    }

    private var alertLevelBadge: some View {
        HStack(spacing: CodSpacing.xs) {
            Circle()
                .fill(alertColor)
                .frame(width: 8, height: 8)
                .pulsingGlow(color: alertColor, isActive: service.alertLevel == .high)

            Text("\(service.alertLevel.label) Activity")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(alertColor)

            Text(alertSummaryText)
                .codTextStyle(.caption)
        }
        .padding(.horizontal, CodSpacing.md)
        .padding(.vertical, CodSpacing.sm)
        .background(alertColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
    }

    // MARK: - Map Section

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Sighting Map")
                .codTextStyle(.sectionTitle)
                .codAccessibleHeader("Sighting Map")

            Map(coordinateRegion: .constant(mapRegion), annotationItems: service.sightings) { sighting in
                MapAnnotation(coordinate: sighting.coordinate) {
                    sharkMapPin(sighting: sighting)
                }
            }
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
    }

    private func sharkMapPin(sighting: SharkSighting) -> some View {
        Button {
            CodHaptic.tap()
            selectedSighting = sighting
        } label: {
            VStack(spacing: 0) {
                Text(sighting.isConfirmed ? "\u{1F988}" : "\u{2753}")
                    .font(.system(size: 24))
                    .shadow(radius: 2)

                if selectedSighting?.id == sighting.id {
                    Text(sighting.location)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.capeCod.textPrimary)
                        .padding(.horizontal, CodSpacing.xs)
                        .padding(.vertical, 2)
                        .background(Color.capeCod.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Beach Status Section

    private var beachStatusSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Beach Activity")
                .codTextStyle(.sectionTitle)
                .codAccessibleHeader("Beach Activity")

            LazyVStack(spacing: CodSpacing.sm) {
                ForEach(Array(outerCapeBeeches.enumerated()), id: \.element.name) { index, beach in
                    beachStatusRow(beach: beach)
                        .staggered(index: index, interval: 0.03)
                }
            }
        }
    }

    private func beachStatusRow(beach: BeachLocation) -> some View {
        let nearby = service.sightingsNear(
            latitude: beach.latitude, longitude: beach.longitude, radiusKm: 3.0
        )
        let cutoff48h = Date().addingTimeInterval(-48 * 3600)
        let recent = nearby.filter { $0.date >= cutoff48h }

        return HStack(spacing: CodSpacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(beach.name)
                    .codTextStyle(.cardTitle)
                Text(beach.town)
                    .codTextStyle(.caption)
            }

            Spacer()

            if recent.isEmpty {
                statusChip(text: "Clear", color: Color.capeCod.duneGrass)
            } else {
                statusChip(
                    text: "\(recent.count) recent",
                    color: recent.count >= 2 ? Color.capeCod.cranberry : Color.capeCod.sandbarYellow
                )
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private func statusChip(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, CodSpacing.sm)
            .padding(.vertical, CodSpacing.xs)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
    }

    // MARK: - Timeline Section

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Recent Sightings")
                .codTextStyle(.sectionTitle)
                .codAccessibleHeader("Recent Sightings")

            LazyVStack(spacing: CodSpacing.sm) {
                ForEach(Array(service.sightings.prefix(10).enumerated()), id: \.element.id) { index, sighting in
                    sightingCard(sighting: sighting)
                        .staggered(index: index, interval: 0.03)
                }
            }
        }
    }

    private func sightingCard(sighting: SharkSighting) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            // Header row
            HStack {
                Text("\u{1F988}")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(sighting.species)
                        .codTextStyle(.cardTitle)
                    Text(sighting.location)
                        .codTextStyle(.caption)
                }

                Spacer()

                if sighting.isConfirmed {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .font(.system(size: 16))
                }
            }

            // Description
            Text(sighting.description)
                .codTextStyle(.body)
                .fixedSize(horizontal: false, vertical: true)

            // Footer
            HStack {
                Label(sighting.date.sharkTimeAgo, systemImage: "clock")
                    .codTextStyle(.caption)

                Spacer()

                Text(sighting.source)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.capeCod.driftwood)
                    .padding(.horizontal, CodSpacing.sm)
                    .padding(.vertical, 2)
                    .background(Color.capeCod.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .codAccessibleCard(
            label: "\(sighting.species) at \(sighting.location), \(sighting.date.sharkTimeAgo)",
            hint: sighting.isConfirmed ? "Confirmed sighting" : "Unconfirmed report"
        )
    }

    // MARK: - Safety Tips

    private var safetyTipsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundStyle(Color.capeCod.oceanBlue)
                Text("Shark Safety Tips")
                    .codTextStyle(.sectionTitle)
            }
            .codAccessibleHeader("Shark Safety Tips")

            VStack(spacing: CodSpacing.sm) {
                ForEach(Array(SharkSafetyTips.tips.enumerated()), id: \.offset) { index, tip in
                    safetyTipRow(tip: tip)
                        .staggered(index: index, interval: 0.03)
                }
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
    }

    private func safetyTipRow(tip: (icon: String, title: String, detail: String)) -> some View {
        HStack(alignment: .top, spacing: CodSpacing.sm) {
            Image(systemName: tip.icon)
                .foregroundStyle(Color.capeCod.oceanBlue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(tip.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.capeCod.textPrimary)
                Text(tip.detail)
                    .codTextStyle(.caption)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Learn More & Sharktivity

    private var learnMoreSection: some View {
        VStack(spacing: CodSpacing.sm) {
            // Sharktivity App callout
            Button {
                CodHaptic.tap()
                // Deep link to Sharktivity app, fallback to App Store
                if let appURL = URL(string: "sharktivity://"),
                   UIApplication.shared.canOpenURL(appURL) {
                    openURL(appURL)
                } else if let storeURL = URL(string: "https://apps.apple.com/app/sharktivity/id1045412804") {
                    openURL(storeURL)
                }
            } label: {
                HStack(spacing: CodSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.capeCod.oceanBlue.opacity(0.12))
                            .frame(width: 44, height: 44)

                        Text("\u{1F988}")
                            .font(.system(size: 24))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sharktivity App")
                            .codTextStyle(.cardTitle)
                        Text("Get real-time shark alerts, report sightings, and track tagged sharks")
                            .codTextStyle(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Image(systemName: "arrow.down.app.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.capeCod.oceanBlue)
                        Text("GET")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.capeCod.oceanBlue)
                    }
                }
                .padding(CodSpacing.cardPadding)
                .background(Color.capeCod.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                        .stroke(Color.capeCod.oceanBlue.opacity(0.2), lineWidth: 1)
                )
                .adaptiveCardStyle()
            }
            .buttonStyle(CodButtonPressStyle(variant: .ghost))
            .codAccessibleButton("Sharktivity App", hint: "Opens Sharktivity in the App Store")

            // AWSC website
            Button {
                CodHaptic.tap()
                if let url = URL(string: "https://www.atlanticwhiteshark.org") {
                    openURL(url)
                }
            } label: {
                HStack(spacing: CodSpacing.md) {
                    Image(systemName: "globe")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .frame(width: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Atlantic White Shark Conservancy")
                            .codTextStyle(.cardTitle)
                        Text("Support shark research and conservation on Cape Cod")
                            .codTextStyle(.caption)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .foregroundStyle(Color.capeCod.driftwood)
                }
                .padding(CodSpacing.cardPadding)
                .background(Color.capeCod.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
                .adaptiveCardStyle()
            }
            .buttonStyle(CodButtonPressStyle(variant: .ghost))
            .codAccessibleButton("Atlantic White Shark Conservancy", hint: "Opens website in browser")

            // OCEARCH tracker
            Button {
                CodHaptic.tap()
                if let url = URL(string: "https://www.ocearch.org/tracker/") {
                    openURL(url)
                }
            } label: {
                HStack(spacing: CodSpacing.md) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.capeCod.seafoam)
                        .frame(width: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("OCEARCH Shark Tracker")
                            .codTextStyle(.cardTitle)
                        Text("Track GPS-tagged great white sharks in real time")
                            .codTextStyle(.caption)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .foregroundStyle(Color.capeCod.driftwood)
                }
                .padding(CodSpacing.cardPadding)
                .background(Color.capeCod.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
                .adaptiveCardStyle()
            }
            .buttonStyle(CodButtonPressStyle(variant: .ghost))
            .codAccessibleButton("OCEARCH Shark Tracker", hint: "Opens OCEARCH tracker in browser")
        }
    }

    // MARK: - Helpers

    private var alertColor: Color {
        switch service.alertLevel {
        case .high: return Color.capeCod.cranberry
        case .moderate: return Color.capeCod.sandbarYellow
        case .low: return Color.capeCod.duneGrass
        }
    }

    private var alertBackgroundColor: Color {
        switch service.alertLevel {
        case .high: return Color.capeCod.cranberry
        case .moderate: return Color.capeCod.sandbarYellow
        case .low: return Color.capeCod.seafoam
        }
    }

    private var alertSummaryText: String {
        let count = service.recentSightingCount
        switch count {
        case 0: return "No sightings in the last 48 hours"
        case 1: return "1 sighting in the last 48 hours"
        default: return "\(count) sightings in the last 48 hours"
        }
    }
}

// MARK: - Beach Location Data

struct BeachLocation {
    let name: String
    let town: String
    let latitude: Double
    let longitude: Double
}

private let outerCapeBeeches: [BeachLocation] = [
    BeachLocation(name: "Nauset Beach", town: "Orleans", latitude: 41.8344, longitude: -69.9517),
    BeachLocation(name: "Coast Guard Beach", town: "Eastham", latitude: 41.8492, longitude: -69.9475),
    BeachLocation(name: "Marconi Beach", town: "Wellfleet", latitude: 41.8894, longitude: -69.9614),
    BeachLocation(name: "White Crest Beach", town: "Wellfleet", latitude: 41.9131, longitude: -69.9694),
    BeachLocation(name: "Cahoon Hollow", town: "Wellfleet", latitude: 41.9225, longitude: -69.9731),
    BeachLocation(name: "Newcomb Hollow", town: "Wellfleet", latitude: 41.9311, longitude: -69.9756),
    BeachLocation(name: "Head of the Meadow", town: "Truro", latitude: 42.0561, longitude: -70.0783),
    BeachLocation(name: "Race Point", town: "Provincetown", latitude: 42.0717, longitude: -70.2089),
    BeachLocation(name: "Chatham Lighthouse Beach", town: "Chatham", latitude: 41.6714, longitude: -69.9508),
    BeachLocation(name: "Monomoy Island", town: "Chatham", latitude: 41.6044, longitude: -69.9858),
]

// MARK: - Date Formatting

private extension Date {
    var sharkTimeAgo: String {
        let interval = Date().timeIntervalSince(self)
        let hours = Int(interval / 3600)
        if hours < 1 { return "Just now" }
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        if days == 1 { return "1 day ago" }
        return "\(days) days ago"
    }
}

// MARK: - Preview

#Preview("Shark Alert") {
    SharkAlertView()
}
