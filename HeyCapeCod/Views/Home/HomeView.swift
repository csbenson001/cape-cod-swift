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

                    // Voice Assistant CTA
                    voiceAssistantCard
                        .staggered(index: 2)

                    // Featured Stories
                    if !viewModel.featuredStories.isEmpty {
                        storiesSection
                            .staggered(index: 3)
                    }

                    // Recent Conversations
                    if !viewModel.recentConversations.isEmpty {
                        recentSection
                            .staggered(index: 4)
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
