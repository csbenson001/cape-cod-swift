import SwiftUI
import MapKit

/// Interactive Cape Cod map with custom POI annotations, geofence circles,
/// category filters, and tap-to-detail navigation.
struct ExploreMapView: View {
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.78, longitude: -70.10),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.6)
        )
    )
    @State private var selectedPOI: PointOfInterest?
    @State private var selectedCategory: LocationCategory?
    @State private var showGeofenceRadius = false

    private let locationManager: LocationManager
    private let allPOIs: [PointOfInterest]

    init(locationManager: LocationManager, pois: [PointOfInterest] = CapeCodContent.allPOIs) {
        self.locationManager = locationManager
        self.allPOIs = pois
    }

    private var filteredPOIs: [PointOfInterest] {
        guard let category = selectedCategory else { return allPOIs }
        return allPOIs.filter { $0.category == category }
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Map
            Map(position: $cameraPosition, selection: $selectedPOI) {
                // User location
                UserAnnotation()

                // POI annotations
                ForEach(filteredPOIs) { poi in
                    Annotation(poi.name, coordinate: poi.coordinate, anchor: .bottom) {
                        POIAnnotationView(poi: poi, isSelected: selectedPOI?.id == poi.id)
                    }
                    .tag(poi)
                    .annotationTitles(.hidden)
                }

                // Geofence radius circles
                if showGeofenceRadius {
                    ForEach(filteredPOIs) { poi in
                        MapCircle(center: poi.coordinate, radius: poi.geofenceRadius)
                            .foregroundStyle(annotationColor(for: poi.category).opacity(0.08))
                            .stroke(annotationColor(for: poi.category).opacity(0.25), lineWidth: 1)
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic, emphasis: .automatic, pointsOfInterest: .excludingAll))
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .ignoresSafeArea(edges: .top)

            // Category filter bar
            VStack(spacing: 0) {
                categoryFilterBar
                    .padding(.top, 8)

                Spacer()
            }
        }
        .sheet(item: $selectedPOI) { poi in
            POIDetailSheet(poi: poi, locationManager: locationManager)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showGeofenceRadius.toggle()
                } label: {
                    Image(systemName: showGeofenceRadius ? "circle.dashed.inset.filled" : "circle.dashed")
                        .foregroundStyle(showGeofenceRadius ? Color.capeCod.oceanBlue : Color.capeCod.textSecondary)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    centerOnUser()
                } label: {
                    Image(systemName: "location.fill")
                        .foregroundStyle(Color.capeCod.oceanBlue)
                }
            }
        }
    }

    // MARK: - Category Filter

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                // "All" chip
                FilterChip(
                    label: "All",
                    icon: "map.fill",
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation { selectedCategory = nil }
                }

                ForEach(mapCategories, id: \.self) { category in
                    FilterChip(
                        label: category.displayName,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
    }

    /// Categories that appear in our POI set
    private var mapCategories: [LocationCategory] {
        let used = Set(allPOIs.map(\.category))
        return LocationCategory.allCases.filter { used.contains($0) }
    }

    // MARK: - Actions

    private func centerOnUser() {
        guard let location = locationManager.currentLocation else { return }
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }

    // MARK: - Helpers

    private func annotationColor(for category: LocationCategory) -> Color {
        switch category {
        case .beach: Color.capeCod.oceanBlue
        case .restaurant: Color.capeCod.sunsetOrange
        case .historic, .museum: Color(hex: 0x8B6914)
        case .nature: Color.capeCod.duneGrass
        case .lighthouse: Color.capeCod.sandbarYellow
        case .entertainment: Color(hex: 0x9B59B6)
        case .marina: Color.capeCod.oceanBlue
        default: Color.capeCod.driftwood
        }
    }
}

// MARK: - POI Annotation View

private struct POIAnnotationView: View {
    let poi: PointOfInterest
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 2) {
            // Pin circle with icon
            ZStack {
                Circle()
                    .fill(pinColor)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .shadow(color: pinColor.opacity(0.4), radius: isSelected ? 8 : 4)

                Image(systemName: pinIcon)
                    .font(.system(size: isSelected ? 18 : 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            // Pin tail
            Triangle()
                .fill(pinColor)
                .frame(width: 12, height: 6)
                .rotationEffect(.degrees(180))
        }
        .animation(CodAnimation.quick, value: isSelected)
    }

    private var pinColor: Color {
        switch poi.category {
        case .beach: Color.capeCod.oceanBlue
        case .restaurant: Color.capeCod.sunsetOrange
        case .historic, .museum: Color(hex: 0x8B6914)
        case .nature: Color.capeCod.duneGrass
        case .lighthouse: Color.capeCod.sandbarYellow
        case .entertainment: Color(hex: 0x9B59B6)
        case .marina: Color.capeCod.oceanBlue
        default: Color.capeCod.driftwood
        }
    }

    private var pinIcon: String {
        switch poi.category {
        case .beach: "umbrella.fill"
        case .restaurant: "fork.knife"
        case .historic: "clock.fill"
        case .museum: "building.columns.fill"
        case .nature: "leaf.fill"
        case .lighthouse: "light.beacon.max.fill"
        case .entertainment: "theatermasks.fill"
        case .marina: "sailboat.fill"
        default: "mappin.circle.fill"
        }
    }
}

// MARK: - Pin Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(label)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.capeCod.oceanBlue : .ultraThinMaterial)
            .foregroundStyle(isSelected ? .white : Color.capeCod.textPrimary)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - POI Detail Sheet

struct POIDetailSheet: View {
    let poi: PointOfInterest
    let locationManager: LocationManager
    @State private var storyPlayer: StoryPlayerViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CodSpacing.lg) {
                // Header
                headerSection

                Divider()

                // Description
                Text(poi.description)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.capeCod.textPrimary)
                    .lineSpacing(4)

                // Stories
                if !poi.stories.isEmpty {
                    storiesSection
                }

                // Quick Facts
                if !poi.facts.isEmpty {
                    factsSection
                }

                // Insider Tips
                if !poi.tips.isEmpty {
                    tipsSection
                }

                // Actions
                actionsSection
            }
            .padding(CodSpacing.screenEdge)
            .padding(.top, CodSpacing.sm)
        }
        .sheet(item: $storyPlayer) { player in
            StoryPlayerView(viewModel: player)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: poi.category.icon)
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .font(.system(size: 14))
                Text(poi.category.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .textCase(.uppercase)

                Spacer()

                if let dist = locationManager.formattedDistance(to: poi.coordinate) {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text(dist)
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.capeCod.driftwood)
                }
            }

            Text(poi.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.capeCod.textPrimary)

            Text("\(poi.town.displayName) \u{2022} \(poi.town.region.rawValue)")
                .font(.system(size: 14))
                .foregroundStyle(Color.capeCod.textSecondary)
        }
    }

    // MARK: - Stories

    private var storiesSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Label("Stories", systemImage: "headphones")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.capeCod.textPrimary)

            ForEach(poi.stories) { story in
                Button {
                    let player = StoryPlayerViewModel()
                    player.loadAndPlay(poi: poi, story: story)
                    storyPlayer = player
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(story.title)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.capeCod.textPrimary)
                            HStack(spacing: CodSpacing.sm) {
                                Label(story.mode.displayName, systemImage: modeIcon(story.mode))
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.capeCod.textSecondary)
                                Text("\u{2022}")
                                    .foregroundStyle(Color.capeCod.textSecondary)
                                Text(formatDuration(story.duration))
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.capeCod.textSecondary)
                            }
                        }
                        Spacer()
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.capeCod.oceanBlue)
                    }
                    .padding(CodSpacing.md)
                    .background(Color.capeCod.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Facts

    private var factsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Label("Quick Facts", systemImage: "lightbulb.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.capeCod.textPrimary)

            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                ForEach(Array(poi.facts.enumerated()), id: \.offset) { _, fact in
                    HStack(alignment: .top, spacing: CodSpacing.sm) {
                        Circle()
                            .fill(Color.capeCod.seafoam)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)
                        Text(fact)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.capeCod.textPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Tips

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Label("Insider Tips", systemImage: "star.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.capeCod.textPrimary)

            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                ForEach(Array(poi.tips.enumerated()), id: \.offset) { _, tip in
                    HStack(alignment: .top, spacing: CodSpacing.sm) {
                        Image(systemName: "hand.point.right.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.capeCod.sunsetOrange)
                            .padding(.top, 4)
                        Text(tip)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.capeCod.textPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: CodSpacing.md) {
            CodButton("Navigate Here", variant: .primary, icon: "arrow.triangle.turn.up.right.diamond.fill", isFullWidth: true) {
                openInMaps()
            }
        }
        .padding(.top, CodSpacing.sm)
    }

    // MARK: - Helpers

    private func openInMaps() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: poi.coordinate))
        mapItem.name = poi.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    private func modeIcon(_ mode: GeofenceManager.StoryMode) -> String {
        switch mode {
        case .adult: "person.fill"
        case .kids: "figure.child"
        case .family: "figure.2.and.child.holdinghands"
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

// MARK: - Make StoryPlayerViewModel Identifiable for sheet

extension StoryPlayerViewModel: Identifiable {
    var id: ObjectIdentifier { ObjectIdentifier(self) }
}

// MARK: - Make PointOfInterest Hashable for Map selection

extension PointOfInterest: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Preview

#Preview("Explore Map") {
    NavigationStack {
        ExploreMapView(locationManager: LocationManager())
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("POI Detail") {
    POIDetailSheet(
        poi: CapeCodContent.allPOIs[0],
        locationManager: LocationManager()
    )
}
