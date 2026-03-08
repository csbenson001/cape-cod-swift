import SwiftUI
import MapKit

struct TourDetailView: View {
    let tour: GuidedTour
    @State private var activeTour: GuidedTour?
    @State private var storyPlayer: StoryPlayerViewModel?

    private var stops: [PointOfInterest] {
        tour.resolvedStops(from: BundledContent.allPOIs)
    }

    private var region: MKCoordinateRegion {
        guard !stops.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 41.78, longitude: -70.10),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.6)
            )
        }

        let lats = stops.map(\.coordinate.latitude)
        let lngs = stops.map(\.coordinate.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (lats.min()! + lats.max()!) / 2,
            longitude: (lngs.min()! + lngs.max()!) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.05, (lats.max()! - lats.min()!) * 1.4),
            longitudeDelta: max(0.05, (lngs.max()! - lngs.min()!) * 1.4)
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Map overview
                tourMap
                    .frame(height: 260)

                VStack(alignment: .leading, spacing: CodSpacing.sectionSpacing) {
                    // Header
                    headerSection

                    // Description
                    Text(tour.description)
                        .codTextStyle(.body)
                        .foregroundStyle(Color.capeCod.textSecondary)

                    // Tour metadata
                    metadataSection

                    Divider()

                    // Stops
                    stopsSection

                    // Start tour button
                    CodButton("Start Tour", variant: .primary, icon: "play.fill", isFullWidth: true) {
                        CodHaptic.tap()
                        activeTour = tour
                    }
                    .padding(.top, CodSpacing.sm)
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.top, CodSpacing.lg)
                .padding(.bottom, CodSpacing.xxl)
            }
        }
        .background(Color.capeCod.background)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $activeTour) { tour in
            ActiveTourView(tour: tour)
        }
        .sheet(item: $storyPlayer) { player in
            StoryPlayerView(viewModel: player)
        }
    }

    // MARK: - Map

    private var tourMap: some View {
        Map(initialPosition: .region(region)) {
            ForEach(Array(stops.enumerated()), id: \.element.id) { index, stop in
                Annotation(
                    "\(index + 1). \(stop.name)",
                    coordinate: stop.coordinate,
                    anchor: .bottom
                ) {
                    TourStopPin(number: index + 1, category: stop.category)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic, emphasis: .automatic, pointsOfInterest: .excludingAll))
        .allowsHitTesting(false)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: tour.icon)
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .font(.system(size: 14))
                Text(tour.category.displayName)
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.oceanBlue)

                if let region = tour.region {
                    Text("·")
                        .foregroundStyle(Color.capeCod.driftwood)
                    Text(region.rawValue)
                        .codTextStyle(.label)
                        .foregroundStyle(Color.capeCod.driftwood)
                }
            }

            Text(tour.name)
                .codTextStyle(.heroTitle)

            Text(tour.subtitle)
                .codTextStyle(.subtitle)
        }
    }

    // MARK: - Metadata

    private var metadataSection: some View {
        HStack(spacing: 0) {
            metadataItem(icon: "clock", label: "Duration", value: tour.estimatedDuration)
            Spacer()
            metadataItem(icon: "car", label: "Distance", value: tour.distance)
            Spacer()
            metadataItem(icon: "mappin.circle", label: "Stops", value: "\(stops.count)")
            Spacer()
            metadataItem(icon: "figure.walk", label: "Level", value: tour.difficulty.displayName)
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private func metadataItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: CodSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.capeCod.oceanBlue)
            Text(value)
                .codTextStyle(.body)
            Text(label)
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
    }

    // MARK: - Stops Section

    private var stopsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Tour Stops")
                .codTextStyle(.sectionTitle)

            ForEach(Array(stops.enumerated()), id: \.element.id) { index, stop in
                TourStopCard(
                    stop: stop,
                    number: index + 1,
                    isLast: index == stops.count - 1,
                    onPlayStory: { story in
                        CodHaptic.tap()
                        let player = StoryPlayerViewModel()
                        player.loadAndPlay(poi: stop, story: story)
                        storyPlayer = player
                    }
                )
            }
        }
    }
}

// MARK: - Tour Stop Pin

struct TourStopPin: View {
    let number: Int
    let category: LocationCategory

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(Color.capeCod.oceanBlue)
                    .frame(width: 32, height: 32)
                    .shadow(color: Color.capeCod.oceanBlue.opacity(0.3), radius: 4)

                Text("\(number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }

            // Pin tail
            Image(systemName: "triangle.fill")
                .font(.system(size: 8))
                .foregroundStyle(Color.capeCod.oceanBlue)
                .rotationEffect(.degrees(180))
                .offset(y: -3)
        }
    }
}

// MARK: - Tour Stop Card

private struct TourStopCard: View {
    let stop: PointOfInterest
    let number: Int
    let isLast: Bool
    var onPlayStory: ((StoryVariant) -> Void)?

    private var currentModeStory: StoryVariant? {
        let mode = UserProfileManager.shared.currentProfile?.experienceMode ?? .adult
        let storyMode: GeofenceManager.StoryMode = switch mode {
        case .kids: .kids
        case .family: .family
        default: .adult
        }
        return stop.stories.first { $0.mode == storyMode } ?? stop.stories.first
    }

    var body: some View {
        HStack(alignment: .top, spacing: CodSpacing.md) {
            // Timeline indicator
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color.capeCod.oceanBlue)
                        .frame(width: 28, height: 28)

                    Text("\(number)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }

                if !isLast {
                    Rectangle()
                        .fill(Color.capeCod.oceanBlue.opacity(0.2))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 28)

            // Card content
            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: stop.category.icon)
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .font(.system(size: 12))
                    Text(stop.category.displayName)
                        .codTextStyle(.label)
                        .foregroundStyle(Color.capeCod.oceanBlue)
                }

                Text(stop.name)
                    .codTextStyle(.cardTitle)

                Text("\(stop.town.displayName) · \(stop.town.region.rawValue)")
                    .codTextStyle(.caption)

                Text(stop.description)
                    .codTextStyle(.body)
                    .foregroundStyle(Color.capeCod.textSecondary)
                    .lineLimit(3)

                // Story button
                if let story = currentModeStory {
                    Button {
                        onPlayStory?(story)
                    } label: {
                        HStack(spacing: CodSpacing.sm) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 20))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(story.title)
                                    .codTextStyle(.label)
                                Text(formatDuration(story.duration))
                                    .codTextStyle(.label)
                                    .foregroundStyle(Color.capeCod.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "headphones")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.capeCod.driftwood)
                        }
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .padding(CodSpacing.sm + 2)
                        .background(Color.capeCod.oceanBlue.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
                    }
                    .buttonStyle(CodButtonPressStyle(variant: .ghost))
                }

                // Quick facts preview
                if let fact = stop.facts.first {
                    HStack(alignment: .top, spacing: CodSpacing.sm) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.capeCod.sandbarYellow)
                            .padding(.top, 3)
                        Text(fact)
                            .codTextStyle(.label)
                            .foregroundStyle(Color.capeCod.textSecondary)
                    }
                }
            }
            .padding(.bottom, isLast ? 0 : CodSpacing.lg)
        }
        .codAccessibleCard(
            label: "Stop \(number): \(stop.name), \(stop.town.displayName)",
            hint: currentModeStory != nil ? "Has audio story available" : ""
        )
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

// MARK: - Make GuidedTour Identifiable for fullScreenCover

#Preview {
    NavigationStack {
        TourDetailView(tour: CuratedTours.lighthouseTrail)
    }
}
