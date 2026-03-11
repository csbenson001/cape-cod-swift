import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = HomeViewModel()
    @State private var showTellMeAStory = false
    @State private var showAchievements = false
    @State private var showBingo = false
    @State private var showBestBeach = false
    @State private var showBridgeTiming = false
    @State private var showRainyDay = false
    @State private var showPhotoStudio = false
    @State private var showBeachStatus = false
    @State private var showPackingList = false
    @State private var showPassport = false
    @State private var showHiddenGems = false
    @State private var showTidePlanner = false
    @State private var showTripSummary = false
    @State private var showSharkAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    // Greeting Header
                    greetingSection
                        .staggered(index: 0)

                    // Quick Glance Cards
                    quickGlanceSection
                        .staggered(index: 1)

                    // Shark Alert Banner
                    SharkAlertBanner()
                        .staggered(index: 2)

                    // Quick Actions — Best Beach, Bridge, Rainy Day
                    quickActionsSection
                        .staggered(index: 3)

                    // Discover Hub — Tell Me a Story, Chat, Bingo, Achievements
                    discoverHubSection
                        .staggered(index: 4)

                    // Today on Cape Cod - personalized insights
                    todaySection
                        .staggered(index: 5)

                    // Voice Assistant CTA
                    voiceAssistantCard
                        .staggered(index: 6)

                    // Featured Stories
                    if !viewModel.featuredStories.isEmpty {
                        storiesSection
                            .staggered(index: 7)
                    }

                    // Recent Conversations
                    if !viewModel.recentConversations.isEmpty {
                        recentSection
                            .staggered(index: 8)
                    }
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadDashboard()
            }
            .sheet(isPresented: $showTellMeAStory) {
                NavigationStack {
                    TellMeAStoryView()
                }
            }
            .sheet(isPresented: $showAchievements) {
                NavigationStack {
                    TourAchievementsView()
                }
            }
            .sheet(isPresented: $showBingo) {
                NavigationStack {
                    CapeCodBingoView()
                }
            }
            .sheet(isPresented: $showBestBeach) {
                NavigationStack {
                    BestBeachNowView(
                        weather: viewModel.weather,
                        tideData: viewModel.tideData
                    )
                }
            }
            .sheet(isPresented: $showBridgeTiming) {
                NavigationStack {
                    BridgeTimingView()
                }
            }
            .sheet(isPresented: $showRainyDay) {
                NavigationStack {
                    RainyDayView()
                }
            }
            .sheet(isPresented: $showPhotoStudio) {
                NavigationStack {
                    PhotoStudioView()
                }
            }
            .sheet(isPresented: $showBeachStatus) {
                NavigationStack {
                    BeachStatusView()
                }
            }
            .sheet(isPresented: $showPackingList) {
                NavigationStack {
                    PackingListView()
                }
            }
            .sheet(isPresented: $showPassport) {
                NavigationStack {
                    DigitalPassportView()
                }
            }
            .sheet(isPresented: $showHiddenGems) {
                NavigationStack {
                    HiddenGemsView()
                }
            }
            .sheet(isPresented: $showTidePlanner) {
                NavigationStack {
                    TidePlannerView()
                }
            }
            .sheet(isPresented: $showTripSummary) {
                NavigationStack {
                    TripSummaryView()
                }
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Right Now")
                .codTextStyle(.sectionTitle)
                .codAccessibleHeader("Right Now")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.sm) {
                    QuickActionButton(
                        icon: "beach.umbrella",
                        title: "Best Beach",
                        tint: Color.capeCod.oceanBlue
                    ) {
                        CodHaptic.tap()
                        showBestBeach = true
                    }

                    QuickActionButton(
                        icon: "parkingsign.circle.fill",
                        title: "Beach Status",
                        tint: Color.capeCod.seafoam
                    ) {
                        CodHaptic.tap()
                        showBeachStatus = true
                    }

                    QuickActionButton(
                        icon: "water.waves",
                        title: "Tide Planner",
                        tint: Color.capeCod.oceanBlue
                    ) {
                        CodHaptic.tap()
                        showTidePlanner = true
                    }

                    QuickActionButton(
                        icon: "car.fill",
                        title: "Bridge",
                        tint: Color.capeCod.duneGrass
                    ) {
                        CodHaptic.tap()
                        showBridgeTiming = true
                    }

                    QuickActionButton(
                        icon: "cloud.rain.fill",
                        title: "Rainy Day",
                        tint: Color.capeCod.driftwood
                    ) {
                        CodHaptic.tap()
                        showRainyDay = true
                    }
                }
            }
        }
    }

    // MARK: - Discover Hub

    private var discoverHubSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Discover")
                .codTextStyle(.sectionTitle)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.md) {
                    // Cape Cod Bingo
                    DiscoverCard(
                        icon: "checklist",
                        title: "Cape Cod Bingo",
                        subtitle: "Check off Cape Cod classics!",
                        gradientColors: [Color.capeCod.cranberry, Color.capeCod.sunsetOrange]
                    ) {
                        CodHaptic.tap()
                        showBingo = true
                    }

                    // Tell Me a Story
                    DiscoverCard(
                        icon: "book.closed.fill",
                        title: "Tell Me a Story",
                        subtitle: "AI Cape Cod tales for all ages",
                        gradientColors: [Color.capeCod.sunsetOrange, Color(hex: 0xE8B94E)]
                    ) {
                        CodHaptic.tap()
                        showTellMeAStory = true
                    }

                    // Chat with AI
                    DiscoverCard(
                        icon: "bubble.left.and.text.bubble.right.fill",
                        title: "Chat",
                        subtitle: "Ask anything about the Cape",
                        gradientColors: [Color.capeCod.oceanBlue, Color.capeCod.seafoam]
                    ) {
                        CodHaptic.tap()
                        appState.isChatPresented = true
                    }

                    // Tour Achievements
                    DiscoverCard(
                        icon: "trophy.fill",
                        title: "Achievements",
                        subtitle: "Track your Cape Cod journey",
                        gradientColors: [Color.capeCod.duneGrass, Color(hex: 0x7EC8B8)]
                    ) {
                        CodHaptic.tap()
                        showAchievements = true
                    }

                    // Photo Studio
                    DiscoverCard(
                        icon: "camera.fill",
                        title: "Photo Studio",
                        subtitle: "Cape Cod frames & stickers",
                        gradientColors: [Color(hex: 0xE91E63), Color(hex: 0xFF6B35)]
                    ) {
                        CodHaptic.tap()
                        showPhotoStudio = true
                    }

                    // Digital Passport
                    DiscoverCard(
                        icon: "mappin.and.ellipse",
                        title: "Passport",
                        subtitle: "Earn stamps & badges",
                        gradientColors: [Color(hex: 0x9C27B0), Color(hex: 0x3F51B5)]
                    ) {
                        CodHaptic.tap()
                        showPassport = true
                    }

                    // Hidden Gems
                    DiscoverCard(
                        icon: "sparkles",
                        title: "Hidden Gems",
                        subtitle: "Locals-only secrets",
                        gradientColors: [Color(hex: 0xFFD700), Color.capeCod.sunsetOrange]
                    ) {
                        CodHaptic.tap()
                        showHiddenGems = true
                    }

                    // Trip Summary
                    DiscoverCard(
                        icon: "square.and.arrow.up.fill",
                        title: "Trip Summary",
                        subtitle: "Share your Cape Cod week",
                        gradientColors: [Color.capeCod.deepNavy, Color.capeCod.oceanBlue]
                    ) {
                        CodHaptic.tap()
                        showTripSummary = true
                    }

                    // Packing List
                    DiscoverCard(
                        icon: "suitcase.fill",
                        title: "Packing List",
                        subtitle: "Smart Cape Cod packing",
                        gradientColors: [Color(hex: 0x795548), Color(hex: 0xBCAAA4)]
                    ) {
                        CodHaptic.tap()
                        showPackingList = true
                    }
                }
            }
        }
    }

    // MARK: - Greeting

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.xs) {
            Text(viewModel.greeting)
                .codTextStyle(.heroTitle)
            Text("Welcome to Cape Cod")
                .codTextStyle(.subtitle)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, CodSpacing.md)
        .codAccessibleHeader(viewModel.greeting)
    }

    // MARK: - Quick Glance

    private var quickGlanceSection: some View {
        VStack(spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.md) {
                MetricCard(
                    value: viewModel.temperatureString,
                    unit: "",
                    label: "Temperature",
                    icon: viewModel.conditionIcon,
                    tint: Color.capeCod.sunsetOrange
                )
                MetricCard(
                    value: viewModel.nextTideString,
                    unit: "",
                    label: "Next Tide",
                    icon: "water.waves",
                    tint: Color.capeCod.oceanBlue
                )
            }

            Button {
                // Bridge traffic info
            } label: {
                MetricCard(
                    value: viewModel.bridgeSummary,
                    unit: "",
                    label: "Bridge Traffic",
                    icon: "car.fill",
                    tint: Color.capeCod.duneGrass,
                    isLive: true
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Voice Assistant

    private var voiceAssistantCard: some View {
        Button {
            CodHaptic.tap()
            appState.isVoiceAssistantPresented = true
        } label: {
            HStack(spacing: CodSpacing.md) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.capeCod.oceanBlue)

                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    Text("Ask Cape Cod")
                        .codTextStyle(.sectionTitle)
                    Text("\"What beaches have the warmest water today?\"")
                        .codTextStyle(.caption)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.capeCod.driftwood)
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .buttonStyle(CodCardButtonStyle())
        .codAccessibleButton("Ask Cape Cod", hint: "Start a voice conversation with your AI travel companion")
    }

    // MARK: - Today on Cape Cod

    private var todaySection: some View {
        let profile = UserProfileManager.shared.currentProfile
        let mode = profile?.experienceMode ?? .adult
        let visitType = profile?.visitType ?? "tourist"

        return VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack {
                Image(systemName: "sun.horizon.fill")
                    .foregroundStyle(Color.capeCod.sunsetOrange)
                Text("Today on Cape Cod")
                    .codTextStyle(.sectionTitle)
            }

            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                // Weather-based suggestion
                if viewModel.temperatureString != "--°" {
                    todayInsightRow(
                        icon: viewModel.conditionIcon,
                        text: weatherSuggestion(temp: viewModel.temperatureString, mode: mode)
                    )
                }

                // Tide-based suggestion
                if viewModel.nextTideString != "Loading..." {
                    todayInsightRow(
                        icon: "water.waves",
                        text: tideSuggestion(tide: viewModel.nextTideString, mode: mode)
                    )
                }

                // Visit type suggestion
                todayInsightRow(
                    icon: visitType == "local" ? "house.fill" : (visitType == "dayTrip" ? "car.fill" : "mappin.and.ellipse"),
                    text: visitTypeSuggestion(visitType: visitType, mode: mode)
                )
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
    }

    private func todayInsightRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: CodSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(Color.capeCod.oceanBlue)
                .frame(width: 24)
            Text(text)
                .codTextStyle(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func weatherSuggestion(temp: String, mode: ExperienceMode) -> String {
        switch mode {
        case .kids: return "It's \(temp) outside — perfect for a beach adventure! 🏖️"
        case .teen: return "\(temp) today — great weather to explore some hidden spots."
        case .adult: return "Currently \(temp). A lovely day to explore Cape Cod's coastal trails or waterfront dining."
        case .family: return "It's \(temp) — great family weather! Pack sunscreen and snacks for a full day out."
        }
    }

    private func tideSuggestion(tide: String, mode: ExperienceMode) -> String {
        switch mode {
        case .kids: return "\(tide) — low tide is the best time to find crabs and sea shells! 🦀"
        case .teen: return "\(tide) — plan your beach time around the tides for the best experience."
        case .adult: return "\(tide). Plan beach walks and kayaking around the tide schedule."
        case .family: return "\(tide) — low tide means more sand for the kids to play on!"
        }
    }

    private func visitTypeSuggestion(visitType: String, mode: ExperienceMode) -> String {
        switch (visitType, mode) {
        case ("local", .kids): return "Explore your backyard! Check out the new exhibits at local nature centers."
        case ("local", _): return "Check out what's new this season — several restaurants have updated their spring menus."
        case ("dayTrip", .family): return "Family day trip tip: start at Upper Cape, pack lunch, and head to the beaches by noon!"
        case ("dayTrip", _): return "Maximize your day: start at the Upper Cape and work your way to the Outer Cape."
        case (_, .kids): return "Adventure awaits! The Cape Cod National Seashore has awesome nature trails! 🌊"
        case (_, .family): return "Family must-see: Cape Cod National Seashore. Arrive early for free parking at most beaches."
        default: return "Don't miss the Cape Cod National Seashore — free parking before 9 AM at most beaches."
        }
    }

    // MARK: - Stories

    private var storiesSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Stories Nearby")
                .codTextStyle(.sectionTitle)

            ForEach(Array(viewModel.featuredStories.enumerated()), id: \.element.id) { index, story in
                StoryRow(story: story)
                    .staggered(index: index, interval: 0.03)
            }
        }
    }

    // MARK: - Recent

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Recent Conversations")
                .codTextStyle(.sectionTitle)

            ForEach(Array(viewModel.recentConversations.enumerated()), id: \.element.id) { index, conversation in
                ConversationRow(conversation: conversation)
                    .staggered(index: index, interval: 0.03)
            }
        }
    }
}

// MARK: - Supporting Views

private struct StoryRow: View {
    let story: Story

    var body: some View {
        HStack(spacing: CodSpacing.md) {
            Image(systemName: story.category.icon)
                .font(.title2)
                .foregroundStyle(Color.capeCod.oceanBlue)
                .frame(width: 44, height: 44)
                .background(Color.capeCod.oceanBlue.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(story.title)
                    .codTextStyle(.body)
                Text("\(story.narrator) \u{00B7} \(story.formattedDuration)")
                    .codTextStyle(.caption)
            }

            Spacer()

            Image(systemName: story.isListened ? "checkmark.circle.fill" : "play.circle.fill")
                .foregroundStyle(story.isListened ? Color.capeCod.duneGrass : Color.capeCod.oceanBlue)
                .font(.title2)
                .contentTransition(.symbolEffect(.replace))
        }
        .padding(CodSpacing.sm)
        .codAccessibleCard(
            label: "\(story.title) by \(story.narrator), \(story.formattedDuration)\(story.isListened ? ", listened" : "")",
            hint: "Double tap to play"
        )
    }
}

private struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: CodSpacing.md) {
            Image(systemName: "bubble.left.fill")
                .foregroundStyle(Color.capeCod.seafoam)
                .frame(width: 36, height: 36)
                .background(Color.capeCod.seafoam.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(conversation.title)
                    .codTextStyle(.body)
                Text(conversation.summary)
                    .codTextStyle(.caption)
                    .lineLimit(1)
            }

            Spacer()

            Text(conversation.updatedAt.formatted(.relative(presentation: .named)))
                .codTextStyle(.label)
        }
        .padding(CodSpacing.sm)
        .codAccessibleCard(
            label: "\(conversation.title), \(conversation.updatedAt.formatted(.relative(presentation: .named)))",
            hint: "Double tap to continue conversation"
        )
    }
}

// MARK: - Discover Card

struct DiscoverCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradientColors: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(2)
                }
            }
            .frame(width: 150, height: 150)
            .padding(CodSpacing.cardPadding)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .codShadow(.card)
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleButton(title, hint: subtitle)
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: CodSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(tint)
                    .frame(width: 44, height: 44)
                    .background(tint.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))

                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.capeCod.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, CodSpacing.md)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleButton(title)
    }
}

#Preview {
    HomeView()
        .environment(AppState())
}
