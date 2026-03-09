import SwiftUI
import MapKit

// MARK: - DiscoverHubView

/// A horizontally scrolling discovery hub showing feature entry-point cards.
/// Designed to be embedded as a section in HomeView.
struct DiscoverHubView: View {
    @Environment(AppState.self) private var appState

    @State private var showStoryPicker = false
    @State private var appeared = false

    private let cardWidth: CGFloat = 160
    private let cardHeight: CGFloat = 140

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.capeCod.sandbarYellow)

                Text("Discover")
                    .codTextStyle(.sectionTitle)

                Spacer()
            }
            .codAccessibleHeader("Discover")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.md) {
                    tellMeAStoryCard
                        .staggered(index: 0)

                    tourAchievementsCard
                        .staggered(index: 1)

                    chatWithAICard
                        .staggered(index: 2)
                }
            }
        }
        .onAppear {
            withAnimation(CodAnimation.spring) {
                appeared = true
            }
        }
        .navigationDestination(isPresented: $showStoryPicker) {
            TellMeAStoryView()
        }
    }

    // MARK: - Tell Me a Story Card

    private var tellMeAStoryCard: some View {
        Button {
            CodHaptic.tap()
            showStoryPicker = true
        } label: {
            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.capeCod.sunsetOrange.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: "book.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.capeCod.sunsetOrange)
                }

                Spacer()

                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    Text("Tell Me a Story")
                        .codTextStyle(.cardTitle)
                        .foregroundStyle(.white)

                    Text("Narrated tales of Cape Cod")
                        .codTextStyle(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(2)
                }
            }
            .padding(CodSpacing.cardPadding)
            .frame(width: cardWidth, height: cardHeight, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.capeCod.sunsetOrange, Color.capeCod.cranberry],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleCard(label: "Tell Me a Story", hint: "Browse narrated stories about Cape Cod locations")
    }

    // MARK: - Tour Achievements Card

    private var tourAchievementsCard: some View {
        NavigationLink {
            TourAchievementsView()
        } label: {
            let service = TourAchievementService.shared

            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                ZStack {
                    // Progress ring
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 3)
                        .frame(width: 44, height: 44)

                    Circle()
                        .trim(from: 0, to: service.overallProgress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    Text("Achievements")
                        .codTextStyle(.cardTitle)
                        .foregroundStyle(.white)

                    Text("\(service.unlockedCount) badges earned")
                        .codTextStyle(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(CodSpacing.cardPadding)
            .frame(width: cardWidth, height: cardHeight, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.capeCod.oceanBlue, Color.capeCod.seafoam],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleCard(label: "Tour Achievements", hint: "View your earned badges and progress")
    }

    // MARK: - Chat with AI Card

    private var chatWithAICard: some View {
        Button {
            CodHaptic.tap()
            appState.isChatPresented = true
        } label: {
            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    Text("Chat with AI")
                        .codTextStyle(.cardTitle)
                        .foregroundStyle(.white)

                    Text("Ask anything about the Cape")
                        .codTextStyle(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(2)
                }
            }
            .padding(CodSpacing.cardPadding)
            .frame(width: cardWidth, height: cardHeight, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.capeCod.deepNavy, Color.capeCod.oceanBlue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleCard(label: "Chat with Cape Cod AI", hint: "Start a text conversation with your AI guide")
    }
}

// MARK: - EnhancedActiveTourBottomSheet

/// A replacement bottom sheet for the active tour experience that integrates
/// story chapters, Q&A, and info card features into a quick-action bar.
struct EnhancedActiveTourBottomSheet: View {
    let tour: GuidedTour
    let stop: PointOfInterest
    let stopIndex: Int
    let totalStops: Int

    @Bindable var storyPlayer: StoryPlayerViewModel

    var onMarkVisited: () -> Void
    var onNextStop: () -> Void
    var onGetDirections: () -> Void

    @State private var isExpanded = false
    @State private var showQA = false
    @State private var showInfoCard = false
    @State private var showStoryPlayer = false
    @State private var dragOffset: CGFloat = 0

    private let expandThreshold: CGFloat = -60

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            dragHandle

            // Stop header
            stopHeader

            // Chapter progress bar (when story is playing)
            if storyPlayer.isPlaying || storyPlayer.progress > 0 {
                let chapters = StoryChapterService.generateChapters(
                    from: storyPlayer.currentStory?.script ?? "",
                    storyTitle: storyPlayer.currentStory?.title ?? ""
                )
                if !chapters.isEmpty {
                    ChapterProgressBar(
                        progress: $storyPlayer.progress,
                        chapters: chapters
                    ) { newProgress in
                        storyPlayer.seekToProgress()
                    }
                    .padding(.horizontal, CodSpacing.cardPadding)
                    .padding(.bottom, CodSpacing.sm)
                }
            }

            // Quick action bar
            quickActionBar

            // Expanded content
            if isExpanded {
                expandedContent
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 12, y: -4)
        .offset(y: max(0, dragOffset))
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    withAnimation(CodAnimation.spring) {
                        if value.translation.height < expandThreshold {
                            isExpanded = true
                        } else if value.translation.height > 60 {
                            isExpanded = false
                        }
                        dragOffset = 0
                    }
                }
        )
        .animation(CodAnimation.spring, value: isExpanded)
        .sheet(isPresented: $showQA) {
            TourStopQAView(viewModel: TourStopQAViewModel(poi: stop))
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showStoryPlayer) {
            StoryPlayerView(viewModel: storyPlayer)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showInfoCard) {
            tourStopInfoSheet
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Drag Handle

    private var dragHandle: some View {
        VStack(spacing: CodSpacing.xs) {
            Capsule()
                .fill(Color.capeCod.driftwood.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, CodSpacing.sm)

            Text(isExpanded ? "Swipe down to collapse" : "Swipe up for details")
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.driftwood.opacity(0.5))
        }
    }

    // MARK: - Stop Header

    private var stopHeader: some View {
        HStack(spacing: CodSpacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.capeCod.oceanBlue)
                    .frame(width: 32, height: 32)

                Text("\(stopIndex + 1)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(stop.name)
                    .codTextStyle(.cardTitle)

                Text("Stop \(stopIndex + 1) of \(totalStops) \u{00B7} \(stop.town.displayName)")
                    .codTextStyle(.caption)
            }

            Spacer()
        }
        .padding(.horizontal, CodSpacing.cardPadding)
        .padding(.vertical, CodSpacing.sm)
    }

    // MARK: - Quick Action Bar

    private var quickActionBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.md) {
                quickActionButton(icon: "arrow.triangle.turn.up.right.diamond.fill", label: "Directions") {
                    CodHaptic.tap()
                    onGetDirections()
                }

                quickActionButton(
                    icon: storyPlayer.isPlaying ? "pause.circle.fill" : "headphones",
                    label: "Story"
                ) {
                    CodHaptic.tap()
                    if storyPlayer.isPlaying || storyPlayer.progress > 0 {
                        storyPlayer.togglePlayPause()
                    } else {
                        showStoryPlayer = true
                    }
                }

                quickActionButton(icon: "questionmark.bubble.fill", label: "Q&A") {
                    CodHaptic.tap()
                    showQA = true
                }

                quickActionButton(icon: "info.circle.fill", label: "Info") {
                    CodHaptic.tap()
                    showInfoCard = true
                }

                quickActionButton(icon: "camera.fill", label: "Photos") {
                    CodHaptic.light()
                    // Photo feature placeholder
                }
            }
            .padding(.horizontal, CodSpacing.cardPadding)
        }
        .padding(.bottom, CodSpacing.sm)
    }

    private func quickActionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: CodSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .frame(width: 44, height: 44)
                    .background(Color.capeCod.oceanBlue.opacity(0.1))
                    .clipShape(Circle())

                Text(label)
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.textSecondary)
            }
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleButton(label)
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            // Description
            Text(stop.description)
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            // Quick facts
            if !stop.facts.isEmpty {
                VStack(alignment: .leading, spacing: CodSpacing.sm) {
                    Text("Quick Facts")
                        .codTextStyle(.cardTitle)

                    ForEach(stop.facts.prefix(3), id: \.self) { fact in
                        HStack(alignment: .top, spacing: CodSpacing.sm) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.capeCod.sandbarYellow)

                            Text(fact)
                                .codTextStyle(.caption)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            // Action buttons
            HStack(spacing: CodSpacing.md) {
                CodButton("Mark Visited", variant: .primary, icon: "checkmark") {
                    onMarkVisited()
                }

                CodButton("Next Stop", variant: .secondary, icon: "arrow.right") {
                    onNextStop()
                }
            }
        }
        .padding(.horizontal, CodSpacing.cardPadding)
        .padding(.bottom, CodSpacing.cardPadding)
    }

    // MARK: - Info Sheet

    private var tourStopInfoSheet: some View {
        NavigationStack {
            ScrollView {
                TourStopInfoCard(
                    stop: stop,
                    stopNumber: stopIndex + 1,
                    onListenTapped: {
                        showInfoCard = false
                        showStoryPlayer = true
                    },
                    onAskTapped: {
                        showInfoCard = false
                        showQA = true
                    },
                    onDirectionsTapped: {
                        showInfoCard = false
                        onGetDirections()
                    },
                    onShareTapped: {}
                )
            }
            .background(Color.capeCod.background)
            .navigationTitle(stop.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - TourCompletionCelebrationView

/// Full-screen celebration shown when a tour is completed, with particle effects,
/// stats summary, and achievement banners.
struct TourCompletionCelebrationView: View {
    let tour: GuidedTour
    let stopsVisited: Int
    let totalTime: TimeInterval
    let distance: String
    let newAchievements: [TourAchievement]

    var onShareTour: () -> Void
    var onRateTour: () -> Void
    var onExploreTours: () -> Void

    @State private var showContent = false
    @State private var showStats = false
    @State private var showAchievements = false
    @State private var showButtons = false
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.capeCod.deepNavy, Color(hex: 0x162233)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Confetti particles
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }

            // Content
            ScrollView {
                VStack(spacing: CodSpacing.xl) {
                    Spacer(minLength: CodSpacing.xxl)

                    // Celebration icon
                    if showContent {
                        celebrationHeader
                            .transition(.scale.combined(with: .opacity))
                    }

                    // Stats
                    if showStats {
                        statsSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Achievements
                    if showAchievements && !newAchievements.isEmpty {
                        achievementsSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Action buttons
                    if showButtons {
                        buttonsSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer(minLength: CodSpacing.xxl)
                }
                .padding(.horizontal, CodSpacing.screenEdge)
            }
        }
        .onAppear {
            startAnimationSequence()
            generateParticles()
        }
    }

    // MARK: - Celebration Header

    private var celebrationHeader: some View {
        VStack(spacing: CodSpacing.lg) {
            ZStack {
                Circle()
                    .fill(Color.capeCod.sandbarYellow.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: "party.popper.fill")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(Color.capeCod.sandbarYellow)
            }

            VStack(spacing: CodSpacing.sm) {
                Text("Tour Complete!")
                    .codTextStyle(.heroTitle)
                    .foregroundStyle(.white)

                Text("You completed the \(tour.name)!")
                    .codTextStyle(.subtitle)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .codAccessibleHeader("Tour Complete! You completed the \(tour.name)")
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        HStack(spacing: CodSpacing.md) {
            statCard(value: "\(stopsVisited)", label: "Stops", icon: "mappin.circle.fill")
            statCard(value: formattedTime, label: "Time", icon: "clock.fill")
            statCard(value: distance, label: "Distance", icon: "figure.walk")
        }
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.capeCod.seafoam)

            Text(value)
                .codTextStyle(.metric)
                .foregroundStyle(.white)

            Text(label)
                .codTextStyle(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CodSpacing.md)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        )
        .codAccessibleCard(label: "\(value) \(label)", hint: "Tour statistic")
    }

    // MARK: - Achievements Section

    private var achievementsSection: some View {
        VStack(spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.capeCod.sandbarYellow)

                Text("Achievements Unlocked!")
                    .codTextStyle(.sectionTitle)
                    .foregroundStyle(.white)

                Spacer()
            }

            ForEach(newAchievements, id: \.id) { achievement in
                HStack(spacing: CodSpacing.md) {
                    Image(systemName: achievement.icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.capeCod.sandbarYellow)
                        .frame(width: 48, height: 48)
                        .background(Color.capeCod.sandbarYellow.opacity(0.15))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: CodSpacing.xs) {
                        Text(achievement.displayName)
                            .codTextStyle(.cardTitle)
                            .foregroundStyle(.white)

                        Text(achievement.description)
                            .codTextStyle(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.capeCod.duneGrass)
                }
                .padding(CodSpacing.cardPadding)
                .background(.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                        .strokeBorder(Color.capeCod.sandbarYellow.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Buttons Section

    private var buttonsSection: some View {
        VStack(spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.md) {
                CodButton("Share Tour", variant: .secondary, icon: "square.and.arrow.up") {
                    onShareTour()
                }

                CodButton("Rate Tour", variant: .secondary, icon: "star.fill") {
                    onRateTour()
                }
            }

            CodButton("Explore More Tours", variant: .primary, icon: "map.fill", isFullWidth: true) {
                onExploreTours()
            }
        }
    }

    // MARK: - Helpers

    private var formattedTime: String {
        let hours = Int(totalTime) / 3600
        let minutes = (Int(totalTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    private func startAnimationSequence() {
        withAnimation(CodAnimation.spring.delay(0.2)) {
            showContent = true
        }
        withAnimation(CodAnimation.spring.delay(0.6)) {
            showStats = true
        }
        withAnimation(CodAnimation.spring.delay(1.0)) {
            showAchievements = true
        }
        withAnimation(CodAnimation.spring.delay(1.4)) {
            showButtons = true
        }
    }

    private func generateParticles() {
        let colors: [Color] = [
            Color.capeCod.sandbarYellow,
            Color.capeCod.sunsetOrange,
            Color.capeCod.seafoam,
            Color.capeCod.oceanBlue,
            Color.capeCod.cranberry,
            Color.capeCod.duneGrass,
        ]

        particles = (0..<40).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: -200...200),
                y: CGFloat.random(in: -400...400),
                size: CGFloat.random(in: 4...10),
                color: colors.randomElement() ?? .white,
                opacity: Double.random(in: 0.3...0.8)
            )
        }

        // Animate particles downward with stagger
        for index in particles.indices {
            withAnimation(
                .easeOut(duration: Double.random(in: 2.0...4.0))
                .delay(Double.random(in: 0...1.5))
                .repeatForever(autoreverses: false)
            ) {
                particles[index].y += 800
                particles[index].opacity = 0
            }
        }
    }
}

/// A single confetti particle for the celebration animation.
private struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
}

// MARK: - QuickAccessBar

/// A horizontal row of circular quick-access buttons for key features.
/// Can be dropped into any screen to provide fast navigation.
struct QuickAccessBar: View {
    @Environment(AppState.self) private var appState

    var onStoriesTapped: (() -> Void)?
    var onWeatherTapped: (() -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.lg) {
                quickAccessItem(
                    icon: "bubble.left.and.bubble.right.fill",
                    label: "Chat",
                    color: Color.capeCod.oceanBlue
                ) {
                    CodHaptic.tap()
                    appState.isChatPresented = true
                }

                quickAccessItem(
                    icon: "waveform.circle.fill",
                    label: "Voice",
                    color: Color.capeCod.seafoam
                ) {
                    CodHaptic.tap()
                    appState.isVoiceAssistantPresented = true
                }

                quickAccessItem(
                    icon: "book.fill",
                    label: "Stories",
                    color: Color.capeCod.sunsetOrange
                ) {
                    CodHaptic.tap()
                    onStoriesTapped?()
                }

                quickAccessItem(
                    icon: "trophy.fill",
                    label: "Awards",
                    color: Color.capeCod.sandbarYellow
                ) {
                    CodHaptic.selection()
                    // Navigate to achievements
                }

                quickAccessItem(
                    icon: "cloud.sun.fill",
                    label: "Weather",
                    color: Color.capeCod.duneGrass
                ) {
                    CodHaptic.selection()
                    onWeatherTapped?()
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
    }

    private func quickAccessItem(
        icon: String,
        label: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: CodSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(color)
                    .clipShape(Circle())
                    .shadow(color: color.opacity(0.3), radius: 6, y: 3)

                Text(label)
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.textSecondary)
            }
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleButton(label)
    }
}

// MARK: - StoryPlayerEnhancedView

/// Wraps the existing StoryPlayerView with a tabbed interface adding
/// chapters, highlights, and transcript views.
struct StoryPlayerEnhancedView: View {
    @Bindable var viewModel: StoryPlayerViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: StoryTab = .player
    @State private var chapters: [StoryChapter] = []

    private enum StoryTab: String, CaseIterable {
        case player = "Player"
        case chapters = "Chapters"
        case highlights = "Highlights"
        case transcript = "Transcript"
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.capeCod.deepNavy, Color(hex: 0x162233)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar

                // Tab content
                tabContent
                    .animation(CodAnimation.quick, value: selectedTab)

                // Tab selector
                tabSelector
            }
        }
        .onAppear {
            generateChapters()
        }
        .onChange(of: viewModel.currentStory?.title) {
            generateChapters()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 44, height: 44)
            }
            .codAccessibleButton("Close player")

            Spacer()

            Text(viewModel.poi?.name ?? "Story")
                .codTextStyle(.caption)
                .foregroundStyle(.white.opacity(0.5))

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, CodSpacing.sm)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .player:
            playerTabContent
        case .chapters:
            StoryChapterListView(
                viewModel: viewModel,
                chapters: chapters
            ) { _ in
                withAnimation(CodAnimation.quick) {
                    selectedTab = .player
                }
            }
        case .highlights:
            StoryHighlightsView(
                chapters: chapters,
                poi: viewModel.poi
            )
        case .transcript:
            StoryTranscriptView(
                viewModel: viewModel,
                chapters: chapters
            )
        }
    }

    // MARK: - Player Tab

    private var playerTabContent: some View {
        VStack(spacing: 0) {
            Spacer()

            // Artwork
            ZStack {
                Circle()
                    .fill(Color.capeCod.oceanBlue.opacity(0.15))
                    .frame(width: 200, height: 200)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.capeCod.oceanBlue, Color.capeCod.seafoam],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                    .shadow(color: Color.capeCod.oceanBlue.opacity(0.3), radius: 20)

                Image(systemName: viewModel.poi?.imageSystemName ?? "headphones")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(.white)
            }
            .codAccessibleHidden()

            Spacer()

            // Title
            VStack(spacing: CodSpacing.sm) {
                Text(viewModel.currentStory?.title ?? "")
                    .codTextStyle(.sectionTitle)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                if let poi = viewModel.poi {
                    Text("\(poi.town.displayName) \u{2022} \(poi.category.displayName)")
                        .codTextStyle(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)

            // Chapter progress bar
            if !chapters.isEmpty {
                ChapterProgressBar(
                    progress: $viewModel.progress,
                    chapters: chapters
                ) { _ in
                    viewModel.seekToProgress()
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.top, CodSpacing.lg)
            }

            // Progress time labels
            HStack {
                Text(viewModel.formattedElapsed)
                    .codTextStyle(.label)
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.4))
                Spacer()
                Text(viewModel.formattedRemaining)
                    .codTextStyle(.label)
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.top, CodSpacing.xs)

            // Controls
            HStack(spacing: CodSpacing.xl) {
                Button {
                    CodHaptic.light()
                    viewModel.rewind15()
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 52, height: 52)
                }
                .codAccessibleButton("Rewind 15 seconds")

                Button {
                    CodHaptic.tap()
                    viewModel.togglePlayPause()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.white)
                        .contentTransition(.symbolEffect(.replace))
                }
                .codAccessibleButton(viewModel.isPlaying ? "Pause" : "Play")

                Button {
                    CodHaptic.light()
                    viewModel.skip()
                } label: {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 52, height: 52)
                }
                .codAccessibleButton("Skip to next")
            }
            .padding(.top, CodSpacing.lg)

            Spacer()
        }
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(StoryTab.allCases, id: \.self) { tab in
                Button {
                    CodHaptic.selection()
                    withAnimation(CodAnimation.quick) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: CodSpacing.xs) {
                        Text(tab.rawValue)
                            .codTextStyle(.label)
                            .foregroundStyle(
                                selectedTab == tab
                                    ? Color.capeCod.seafoam
                                    : .white.opacity(0.4)
                            )

                        Capsule()
                            .fill(selectedTab == tab ? Color.capeCod.seafoam : .clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, CodSpacing.sm)
                }
                .codAccessibleButton(
                    tab.rawValue,
                    hint: selectedTab == tab ? "Currently selected" : "Switch to \(tab.rawValue)"
                )
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .background(Color.capeCod.deepNavy)
    }

    // MARK: - Helpers

    private func generateChapters() {
        guard let story = viewModel.currentStory else {
            chapters = []
            return
        }
        chapters = StoryChapterService.generateChapters(
            from: story.script,
            storyTitle: story.title
        )
    }
}

// MARK: - FeatureDiscoveryTooltip

/// A reusable tooltip / coach mark that highlights a new feature.
/// Stores dismissal state in UserDefaults so it only appears once per feature.
struct FeatureDiscoveryTooltip: View {
    let id: String
    let text: String
    let arrowEdge: Edge

    @State private var isVisible = false

    private var isShown: Bool {
        UserDefaults.standard.bool(forKey: "tooltip_dismissed_\(id)")
    }

    var body: some View {
        Group {
            if isVisible && !isShown {
                tooltipCard
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .onAppear {
            guard !isShown else { return }
            withAnimation(CodAnimation.spring.delay(0.8)) {
                isVisible = true
            }
        }
    }

    private var tooltipCard: some View {
        VStack(spacing: 0) {
            if arrowEdge == .top {
                arrowView
                    .rotationEffect(.degrees(0))
            }

            if arrowEdge == .left {
                HStack(spacing: 0) {
                    arrowView
                        .rotationEffect(.degrees(-90))
                    cardContent
                }
            } else if arrowEdge == .right {
                HStack(spacing: 0) {
                    cardContent
                    arrowView
                        .rotationEffect(.degrees(90))
                }
            } else {
                cardContent
            }

            if arrowEdge == .bottom {
                arrowView
                    .rotationEffect(.degrees(180))
            }
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(alignment: .top, spacing: CodSpacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.capeCod.seafoam)

                Text(text)
                    .codTextStyle(.body)
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                CodHaptic.light()
                withAnimation(CodAnimation.quick) {
                    isVisible = false
                }
                UserDefaults.standard.set(true, forKey: "tooltip_dismissed_\(id)")
            } label: {
                Text("Got it")
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.seafoam)
                    .padding(.horizontal, CodSpacing.md)
                    .padding(.vertical, CodSpacing.xs)
                    .background(Color.capeCod.seafoam.opacity(0.15))
                    .clipShape(Capsule())
            }
            .buttonStyle(CodButtonPressStyle(variant: .ghost))
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(CodSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .fill(Color.capeCod.deepNavy)
                .overlay(
                    RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                        .strokeBorder(Color.capeCod.seafoam.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.capeCod.deepNavy.opacity(0.4), radius: 12, y: 4)
    }

    private var arrowView: some View {
        Triangle()
            .fill(Color.capeCod.deepNavy)
            .frame(width: 16, height: 8)
            .overlay(
                Triangle()
                    .strokeBorder(Color.capeCod.seafoam.opacity(0.3), lineWidth: 1)
            )
    }
}

/// A simple triangle shape for tooltip arrows.
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

extension Triangle: InsettableShape {
    func inset(by amount: CGFloat) -> some InsettableShape {
        self
    }
}

// MARK: - MiniPlayerBar (Enhanced Integration)

/// A persistent mini player bar that observes an existing StoryPlayerViewModel
/// and provides expand-to-full-player behavior.
struct IntegrationMiniPlayerBar: View {
    @Bindable var viewModel: StoryPlayerViewModel
    var onExpand: () -> Void

    @State private var isVisible = false

    var body: some View {
        Group {
            if let data = viewModel.miniPlayerData, isVisible {
                MiniPlayerBar(
                    title: data.title,
                    subtitle: data.subtitle,
                    progress: data.progress,
                    isPlaying: data.isPlaying,
                    onPlayPause: { viewModel.togglePlayPause() },
                    onTap: { onExpand() },
                    onDismiss: {
                        withAnimation(CodAnimation.spring) {
                            viewModel.stop()
                            isVisible = false
                        }
                    }
                )
                .padding(.horizontal, CodSpacing.sm)
                .padding(.bottom, CodSpacing.xs)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(CodAnimation.spring, value: viewModel.miniPlayerData != nil)
        .onChange(of: viewModel.currentStory?.title) { _, newValue in
            if newValue != nil {
                withAnimation(CodAnimation.spring) {
                    isVisible = true
                }
            }
        }
        .onAppear {
            isVisible = viewModel.currentStory != nil
        }
    }
}

// MARK: - TellMeAStoryView (Stub)

/// Placeholder for the Tell Me a Story feature.
/// This view is expected to exist elsewhere; this stub allows navigation compilation.
struct TellMeAStoryView: View {
    var body: some View {
        Text("Tell Me a Story")
            .codTextStyle(.heroTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.capeCod.background)
            .navigationTitle("Stories")
    }
}

// MARK: - Previews

#Preview("Discover Hub") {
    NavigationStack {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                DiscoverHubView()
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
        .background(Color.capeCod.background)
    }
    .environment(AppState())
}

#Preview("Quick Access Bar") {
    VStack {
        Spacer()
        QuickAccessBar()
        Spacer()
    }
    .background(Color.capeCod.background)
    .environment(AppState())
}

#Preview("Tour Completion") {
    TourCompletionCelebrationView(
        tour: CuratedTours.lighthouseTrail,
        stopsVisited: 5,
        totalTime: 5400,
        distance: "3.2 mi",
        newAchievements: [.explorer],
        onShareTour: {},
        onRateTour: {},
        onExploreTours: {}
    )
}

#Preview("Enhanced Story Player") {
    StoryPlayerEnhancedView(
        viewModel: {
            let vm = StoryPlayerViewModel()
            vm.loadAndPlay(
                poi: .preview,
                story: PointOfInterest.preview.stories[0]
            )
            return vm
        }()
    )
}

#Preview("Feature Tooltip") {
    ZStack {
        Color.capeCod.background.ignoresSafeArea()

        VStack(spacing: CodSpacing.xl) {
            FeatureDiscoveryTooltip(
                id: "preview_top",
                text: "Try asking Cape Cod AI about the best beaches near you!",
                arrowEdge: .top
            )
            .frame(maxWidth: 280)

            FeatureDiscoveryTooltip(
                id: "preview_bottom",
                text: "Swipe up to see chapter details and highlights.",
                arrowEdge: .bottom
            )
            .frame(maxWidth: 280)
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }
}

#Preview("Enhanced Bottom Sheet") {
    ZStack(alignment: .bottom) {
        Color.capeCod.fog.ignoresSafeArea()

        EnhancedActiveTourBottomSheet(
            tour: CuratedTours.lighthouseTrail,
            stop: .preview,
            stopIndex: 0,
            totalStops: 5,
            storyPlayer: StoryPlayerViewModel(),
            onMarkVisited: {},
            onNextStop: {},
            onGetDirections: {}
        )
        .padding(.horizontal, CodSpacing.sm)
        .padding(.bottom, CodSpacing.sm)
    }
}

#Preview("Integration Mini Player") {
    VStack {
        Spacer()
        Text("Content goes here")
            .codTextStyle(.body)
        Spacer()

        IntegrationMiniPlayerBar(
            viewModel: {
                let vm = StoryPlayerViewModel()
                vm.loadAndPlay(
                    poi: .preview,
                    story: PointOfInterest.preview.stories[0]
                )
                return vm
            }(),
            onExpand: {}
        )
    }
    .background(Color.capeCod.background)
}
