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

                    // Quick Glance Cards
                    quickGlanceSection

                    // Voice Assistant CTA
                    voiceAssistantCard

                    // Featured Stories
                    if !viewModel.featuredStories.isEmpty {
                        storiesSection
                    }

                    // Recent Conversations
                    if !viewModel.recentConversations.isEmpty {
                        recentSection
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
    }

    // MARK: - Quick Glance

    private var quickGlanceSection: some View {
        VStack(spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.md) {
                MetricCard(
                    title: "Temperature",
                    value: viewModel.temperatureString,
                    icon: viewModel.conditionIcon
                )
                MetricCard(
                    title: "Next Tide",
                    value: viewModel.nextTideString,
                    icon: "water.waves"
                )
            }

            MetricCard(
                title: "Bridge Traffic",
                value: viewModel.bridgeSummary,
                icon: "car.fill"
            )
        }
    }

    // MARK: - Voice Assistant

    private var voiceAssistantCard: some View {
        Button {
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
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
            .codShadow(.card)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stories

    private var storiesSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Stories Nearby")
                .codTextStyle(.sectionTitle)

            ForEach(viewModel.featuredStories) { story in
                StoryRow(story: story)
            }
        }
    }

    // MARK: - Recent

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Recent Conversations")
                .codTextStyle(.sectionTitle)

            ForEach(viewModel.recentConversations) { conversation in
                ConversationRow(conversation: conversation)
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
                Text("\(story.narrator) · \(story.formattedDuration)")
                    .codTextStyle(.caption)
            }

            Spacer()

            Image(systemName: story.isListened ? "checkmark.circle.fill" : "play.circle.fill")
                .foregroundStyle(story.isListened ? Color.capeCod.duneGrass : Color.capeCod.oceanBlue)
                .font(.title2)
        }
        .padding(CodSpacing.sm)
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
    }
}

#Preview {
    HomeView()
        .environment(AppState())
}
