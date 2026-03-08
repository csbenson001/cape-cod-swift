import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = HomeViewModel()

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

                    // Today on Cape Cod - personalized insights
                    todaySection
                        .staggered(index: 2)

                    // Voice Assistant CTA
                    voiceAssistantCard
                        .staggered(index: 3)

                    // Featured Stories
                    if !viewModel.featuredStories.isEmpty {
                        storiesSection
                            .staggered(index: 4)
                    }

                    // Recent Conversations
                    if !viewModel.recentConversations.isEmpty {
                        recentSection
                            .staggered(index: 5)
                    }
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.xxl)
            }
            .background(Color.capeCod.background)
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadDashboard()
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
                withAnimation(CodAnimation.tabSwitch) {
                    appState.selectedTab = .traffic
                }
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

#Preview {
    HomeView()
        .environment(AppState())
}
