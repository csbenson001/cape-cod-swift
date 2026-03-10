import SwiftUI
import MapKit

/// Full-screen guided tour experience with step-by-step navigation,
/// map tracking, and story playback at each stop.
struct ActiveTourView: View {
    @Environment(\.dismiss) private var dismiss
    let tour: GuidedTour

    @State private var currentStopIndex = 0
    @State private var completedStops: Set<Int> = []
    @State private var showExitConfirmation = false
    @State private var storyPlayer: StoryPlayerViewModel?
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showQA = false
    @State private var showInfoCard = false

    private var stops: [PointOfInterest] {
        tour.resolvedStops(from: BundledContent.allPOIs)
    }

    private var currentStop: PointOfInterest? {
        guard currentStopIndex < stops.count else { return nil }
        return stops[currentStopIndex]
    }

    private var isLastStop: Bool {
        currentStopIndex >= stops.count - 1
    }

    private var isTourComplete: Bool {
        completedStops.count == stops.count
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Map
                tourMap
                    .ignoresSafeArea(edges: .top)

                // Bottom card
                bottomCard
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if completedStops.isEmpty {
                            dismiss()
                        } else {
                            showExitConfirmation = true
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.3), radius: 4)
                    }
                    .codAccessibleButton("End tour")
                }

                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(tour.name)
                            .codTextStyle(.label)
                            .foregroundStyle(.primary)
                        Text("Stop \(currentStopIndex + 1) of \(stops.count)")
                            .codTextStyle(.label)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .alert("End Tour?", isPresented: $showExitConfirmation) {
                Button("Continue Tour", role: .cancel) { }
                Button("End Tour", role: .destructive) { dismiss() }
            } message: {
                Text("You've completed \(completedStops.count) of \(stops.count) stops. Are you sure you want to end the tour?")
            }
            .sheet(item: $storyPlayer) { player in
                StoryPlayerView(viewModel: player)
            }
            .sheet(isPresented: $showQA) {
                if let stop = currentStop {
                    TourStopQAView(viewModel: TourStopQAViewModel(poi: stop))
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
            }
            .sheet(isPresented: $showInfoCard) {
                if let stop = currentStop {
                    TourStopInfoCard(poi: stop)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
            }
            .onChange(of: currentStopIndex) {
                focusOnCurrentStop()
            }
            .onAppear {
                focusOnCurrentStop()
            }
        }
    }

    // MARK: - Map

    private var tourMap: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()

            ForEach(Array(stops.enumerated()), id: \.element.id) { index, stop in
                Annotation(
                    stop.name,
                    coordinate: stop.coordinate,
                    anchor: .bottom
                ) {
                    ActiveTourPin(
                        number: index + 1,
                        isCompleted: completedStops.contains(index),
                        isCurrent: index == currentStopIndex
                    )
                }
            }

            // Route polyline between stops
            if stops.count > 1 {
                MapPolyline(coordinates: stops.map(\.coordinate))
                    .stroke(Color.capeCod.oceanBlue.opacity(0.4), style: StrokeStyle(lineWidth: 3, dash: [8, 5]))
            }
        }
        .mapStyle(.standard(elevation: .realistic, emphasis: .automatic, pointsOfInterest: .excludingAll))
        .mapControls {
            MapCompass()
            MapUserLocationButton()
        }
    }

    // MARK: - Bottom Card

    private var bottomCard: some View {
        VStack(spacing: 0) {
            // Progress bar
            tourProgressBar

            if isTourComplete {
                tourCompleteCard
            } else if let stop = currentStop {
                stopCard(stop: stop)
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 12, y: -4)
        .padding(.horizontal, CodSpacing.sm)
        .padding(.bottom, CodSpacing.sm)
    }

    // MARK: - Progress Bar

    private var tourProgressBar: some View {
        HStack(spacing: CodSpacing.xs) {
            ForEach(0..<stops.count, id: \.self) { index in
                Capsule()
                    .fill(
                        completedStops.contains(index) ? Color.capeCod.duneGrass :
                        index == currentStopIndex ? Color.capeCod.oceanBlue :
                        Color.capeCod.driftwood.opacity(0.2)
                    )
                    .frame(height: 4)
                    .animation(CodAnimation.quick, value: completedStops)
            }
        }
        .padding(.horizontal, CodSpacing.cardPadding)
        .padding(.top, CodSpacing.md)
    }

    // MARK: - Stop Card

    private func stopCard(stop: PointOfInterest) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            // Stop header
            HStack(spacing: CodSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.capeCod.oceanBlue)
                        .frame(width: 32, height: 32)

                    Text("\(currentStopIndex + 1)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(stop.name)
                        .codTextStyle(.cardTitle)
                    Text("\(stop.town.displayName) · \(stop.category.displayName)")
                        .codTextStyle(.caption)
                }

                Spacer()

                // Story button
                if let story = storyForCurrentMode(stop: stop) {
                    Button {
                        CodHaptic.tap()
                        let player = StoryPlayerViewModel()
                        player.loadAndPlay(poi: stop, story: story)
                        storyPlayer = player
                    } label: {
                        HStack(spacing: CodSpacing.xs) {
                            Image(systemName: "headphones")
                                .font(.system(size: 14))
                            Text("Story")
                                .codTextStyle(.label)
                        }
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .padding(.horizontal, CodSpacing.md)
                        .padding(.vertical, CodSpacing.sm)
                        .background(Color.capeCod.oceanBlue.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(CodButtonPressStyle(variant: .ghost))
                }
            }

            Text(stop.description)
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
                .lineLimit(3)

            // Quick action chips
            HStack(spacing: CodSpacing.sm) {
                stopQuickAction(icon: "questionmark.bubble.fill", label: "Q&A") {
                    CodHaptic.tap()
                    showQA = true
                }
                stopQuickAction(icon: "info.circle.fill", label: "Info") {
                    CodHaptic.tap()
                    showInfoCard = true
                }
                if !stop.facts.isEmpty {
                    stopQuickAction(icon: "lightbulb.fill", label: "Facts") {
                        CodHaptic.light()
                        showInfoCard = true
                    }
                }
                Spacer()
            }

            // Action buttons
            HStack(spacing: CodSpacing.md) {
                CodButton("Get Directions", variant: .secondary, icon: "arrow.triangle.turn.up.right.diamond.fill") {
                    openInMaps(stop: stop)
                }

                if completedStops.contains(currentStopIndex) {
                    if !isLastStop {
                        CodButton("Next Stop", icon: "arrow.right") {
                            CodHaptic.tap()
                            withAnimation(CodAnimation.spring) {
                                currentStopIndex += 1
                            }
                        }
                    }
                } else {
                    CodButton("Mark Visited", icon: "checkmark") {
                        CodHaptic.success()
                        withAnimation(CodAnimation.spring) {
                            completedStops.insert(currentStopIndex)
                            if !isLastStop {
                                currentStopIndex += 1
                            }
                        }
                    }
                }
            }
        }
        .padding(CodSpacing.cardPadding)
    }

    // MARK: - Quick Action Chip

    private func stopQuickAction(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(Color.capeCod.oceanBlue)
            .padding(.horizontal, CodSpacing.sm + 2)
            .padding(.vertical, CodSpacing.xs + 2)
            .background(Color.capeCod.oceanBlue.opacity(0.08))
            .clipShape(Capsule())
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleButton(label)
    }

    // MARK: - Tour Complete

    private var tourCompleteCard: some View {
        VStack(spacing: CodSpacing.lg) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.capeCod.sandbarYellow)

            VStack(spacing: CodSpacing.sm) {
                Text("Tour Complete!")
                    .codTextStyle(.sectionTitle)

                Text("You visited all \(stops.count) stops on the \(tour.name)!")
                    .codTextStyle(.body)
                    .foregroundStyle(Color.capeCod.textSecondary)
                    .multilineTextAlignment(.center)
            }

            CodButton("Done", icon: "checkmark.circle.fill", isFullWidth: true) {
                CodHaptic.success()
                dismiss()
            }
        }
        .padding(CodSpacing.cardPadding)
    }

    // MARK: - Helpers

    private func focusOnCurrentStop() {
        guard let stop = currentStop else { return }
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(
                center: stop.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))
        }
    }

    private func storyForCurrentMode(stop: PointOfInterest) -> StoryVariant? {
        let mode = UserProfileManager.shared.currentProfile?.experienceMode ?? .adult
        let storyMode: GeofenceManager.StoryMode = switch mode {
        case .kids: .kids
        case .family: .family
        default: .adult
        }
        return stop.stories.first { $0.mode == storyMode } ?? stop.stories.first
    }

    private func openInMaps(stop: PointOfInterest) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: stop.coordinate))
        mapItem.name = stop.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

// MARK: - Active Tour Pin

private struct ActiveTourPin: View {
    let number: Int
    let isCompleted: Bool
    let isCurrent: Bool

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(pinColor)
                    .frame(width: isCurrent ? 38 : 30, height: isCurrent ? 38 : 30)
                    .shadow(color: pinColor.opacity(0.4), radius: isCurrent ? 8 : 4)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: isCurrent ? 16 : 12, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(number)")
                        .font(.system(size: isCurrent ? 16 : 12, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .animation(CodAnimation.quick, value: isCurrent)
            .animation(CodAnimation.quick, value: isCompleted)

            Image(systemName: "triangle.fill")
                .font(.system(size: 8))
                .foregroundStyle(pinColor)
                .rotationEffect(.degrees(180))
                .offset(y: -3)
        }
    }

    private var pinColor: Color {
        if isCompleted { return Color.capeCod.duneGrass }
        if isCurrent { return Color.capeCod.oceanBlue }
        return Color.capeCod.driftwood.opacity(0.5)
    }
}

#Preview {
    ActiveTourView(tour: CuratedTours.lighthouseTrail)
}
