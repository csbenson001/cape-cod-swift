import SwiftUI

// MARK: - ChatView

struct ChatView: View {
    @State private var viewModel = ConversationViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var showScrollToBottom = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.capeCod.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Messages or empty state
                    messageList

                    // Input bar
                    chatInputBar
                }
            }
            .navigationTitle("Ask Cape Cod")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        CodHaptic.tap()
                        withAnimation(CodAnimation.spring) {
                            viewModel = ConversationViewModel()
                            isInputFocused = false
                        }
                    } label: {
                        Image(systemName: "plus.bubble")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Color.capeCod.oceanBlue)
                    }
                    .codAccessibleButton("New Chat", hint: "Start a new conversation")
                }
            }
            .task {
                await viewModel.loadLiveContext()
            }
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: CodSpacing.sm) {
                    if viewModel.messages.isEmpty {
                        chatEmptyState
                            .transition(.opacity)
                    } else {
                        // Top spacer for breathing room
                        Color.clear.frame(height: CodSpacing.sm)

                        ForEach(viewModel.messages) { message in
                            ChatMessageBubble(message: message)
                                .id(message.id)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }

                        // Typing indicator when processing and last message is not streaming
                        if viewModel.isProcessing, let last = viewModel.messages.last, !last.isStreaming {
                            HStack {
                                TypingIndicator()
                                Spacer(minLength: 60)
                            }
                            .padding(.horizontal, CodSpacing.screenEdge)
                            .transition(.codScale)
                        }

                        // Bottom anchor for scrolling
                        Color.clear
                            .frame(height: 1)
                            .id("bottom_anchor")
                    }
                }
                .padding(.bottom, CodSpacing.sm)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.messages.last?.content) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.isProcessing) {
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(CodAnimation.spring) {
            if let last = viewModel.messages.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            } else {
                proxy.scrollTo("bottom_anchor", anchor: .bottom)
            }
        }
    }

    // MARK: - Empty State

    private var chatEmptyState: some View {
        VStack(spacing: CodSpacing.lg) {
            Spacer()
                .frame(height: CodSpacing.xxl)

            // Welcoming illustration
            ZStack {
                Circle()
                    .fill(Color.capeCod.oceanBlue.opacity(0.08))
                    .frame(width: 100, height: 100)

                Circle()
                    .fill(Color.capeCod.oceanBlue.opacity(0.05))
                    .frame(width: 140, height: 140)

                Image(systemName: "bubble.left.and.text.bubble.right.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.capeCod.oceanBlue.opacity(0.6))
                    .symbolRenderingMode(.hierarchical)
            }
            .codAccessibleHidden()

            VStack(spacing: CodSpacing.sm) {
                Text("Ask me anything about Cape Cod")
                    .codTextStyle(.cardTitle)
                    .multilineTextAlignment(.center)

                Text("Beaches, restaurants, history, activities & more")
                    .codTextStyle(.caption)
                    .multilineTextAlignment(.center)
            }

            // Suggestion chips in a 2-column grid
            suggestionGrid
                .padding(.top, CodSpacing.sm)
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    private var suggestionGrid: some View {
        let profile = UserProfileManager.shared.currentProfile
        let mode = profile?.experienceMode ?? .adult

        let suggestions: [(icon: String, text: String, query: String)] = {
            switch mode {
            case .kids:
                return [
                    ("binoculars", "Pirate adventures!", "Where can I go on a pirate adventure on Cape Cod?"),
                    ("tortoise", "Cool animals to see", "What cool animals can I see on Cape Cod?"),
                    ("beach.umbrella", "Best beaches for kids?", "What are the most fun beaches for kids on Cape Cod?"),
                    ("star", "Treasure hunting spots", "Are there any treasure hunting or geocaching spots on Cape Cod?"),
                    ("fish", "Go fishing!", "Where can kids go fishing on Cape Cod?"),
                    ("sparkles", "Fun rainy day stuff", "What are the most fun things for kids to do on a rainy day on Cape Cod?")
                ]
            case .teen:
                return [
                    ("camera", "Instagram-worthy spots", "What are the most Instagram-worthy spots on Cape Cod?"),
                    ("map", "Hidden gems & secret spots", "What are some hidden gems and secret spots on Cape Cod that most tourists miss?"),
                    ("water.waves", "Best surfing spots", "Where are the best surfing spots on Cape Cod?"),
                    ("moon.stars", "Spooky legends & ghost stories", "Tell me about spooky legends and ghost stories on Cape Cod"),
                    ("fork.knife", "Best cheap eats", "Where are the best cheap eats and food trucks on Cape Cod?"),
                    ("figure.hiking", "Adventure activities", "What are the coolest adventure activities for teens on Cape Cod?")
                ]
            case .family:
                return [
                    ("beach.umbrella", "Best beaches for families?", "What are the best beaches for families on Cape Cod? Include parking and facilities info."),
                    ("fork.knife", "Kid-friendly restaurants", "Where are the best kid-friendly restaurants on Cape Cod?"),
                    ("water.waves", "Whale watching tips", "Tell me about whale watching on Cape Cod — best times, companies, and tips for families"),
                    ("cloud.rain", "Rainy day with kids?", "What are the best things to do with kids on a rainy day on Cape Cod?"),
                    ("car", "Day trip routes", "What's the best day trip route for families on Cape Cod?"),
                    ("tent", "Camping with kids", "Where are the best family-friendly campgrounds on Cape Cod?")
                ]
            case .adult:
                return [
                    ("beach.umbrella", "Best beaches for families?", "What are the best beaches for families on Cape Cod?"),
                    ("fork.knife", "Where to eat in Provincetown?", "Where are the best restaurants in Provincetown?"),
                    ("water.waves", "Whale watching tips", "Tell me about whale watching on Cape Cod — best times, companies, and tips"),
                    ("building.columns", "History of the Cape Cod Canal", "Tell me about the history of the Cape Cod Canal"),
                    ("cloud.rain", "What to do on a rainy day?", "What are the best things to do on a rainy day on Cape Cod?"),
                    ("sunset", "Best sunset spots", "Where are the best sunset viewing spots on Cape Cod?")
                ]
            }
        }()

        return LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: CodSpacing.sm),
                GridItem(.flexible(), spacing: CodSpacing.sm)
            ],
            spacing: CodSpacing.sm
        ) {
            ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                SuggestionCard(
                    icon: suggestion.icon,
                    text: suggestion.text
                ) {
                    CodHaptic.light()
                    viewModel.inputText = suggestion.query
                    Task { await viewModel.sendMessage() }
                }
                .staggered(index: index)
            }
        }
    }

    // MARK: - Input Bar

    private var chatInputBar: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundStyle(Color.capeCod.driftwood.opacity(0.2))

            HStack(alignment: .bottom, spacing: CodSpacing.sm) {
                // Mic button
                Button {
                    CodHaptic.selection()
                    Task { await viewModel.toggleListening() }
                } label: {
                    Image(systemName: viewModel.isListening ? "mic.fill" : "mic")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(
                            viewModel.isListening
                                ? Color.capeCod.cranberry
                                : Color.capeCod.driftwood
                        )
                        .frame(width: 36, height: 36)
                        .background(
                            viewModel.isListening
                                ? Color.capeCod.cranberry.opacity(0.12)
                                : Color.clear
                        )
                        .clipShape(Circle())
                        .animation(CodAnimation.quick, value: viewModel.isListening)
                }
                .codAccessibleButton(
                    viewModel.isListening ? "Stop listening" : "Start voice input",
                    hint: viewModel.isListening ? "Tap to stop recording" : "Tap to dictate your question"
                )

                // Text field with rounded background
                TextField("Ask about Cape Cod...", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .codTextStyle(.body)
                    .lineLimit(1...5)
                    .focused($isInputFocused)
                    .padding(.horizontal, CodSpacing.md)
                    .padding(.vertical, CodSpacing.sm + 2)
                    .background(Color.capeCod.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                isInputFocused
                                    ? Color.capeCod.oceanBlue.opacity(0.4)
                                    : Color.capeCod.driftwood.opacity(0.15),
                                lineWidth: 1
                            )
                    )
                    .animation(CodAnimation.quick, value: isInputFocused)

                // Send button
                Button {
                    CodHaptic.tap()
                    Task { await viewModel.sendMessage() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            viewModel.canSend
                                ? Color.capeCod.oceanBlue
                                : Color.capeCod.driftwood.opacity(0.3)
                        )
                        .animation(CodAnimation.quick, value: viewModel.canSend)
                }
                .disabled(!viewModel.canSend)
                .codAccessibleButton(
                    "Send message",
                    hint: viewModel.canSend ? "Send your question" : "Type a message first"
                )
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.vertical, CodSpacing.sm + 2)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Chat Message Bubble

private struct ChatMessageBubble: View {
    let message: Message
    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: CodSpacing.xs) {
            if isUser { Spacer(minLength: 48) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: CodSpacing.xs) {
                // Message content
                if message.isStreaming && message.content.isEmpty {
                    TypingIndicator()
                } else {
                    messageContent
                }

                // Timestamp
                Text(message.timestamp, style: .time)
                    .font(.system(size: 11))
                    .foregroundStyle(
                        isUser
                            ? Color.white.opacity(0.6)
                            : Color.capeCod.textSecondary.opacity(0.6)
                    )
            }
            .padding(.horizontal, CodSpacing.md)
            .padding(.vertical, CodSpacing.sm + 2)
            .background(bubbleBackground)
            .clipShape(ChatBubbleShape(isUser: isUser))

            if !isUser { Spacer(minLength: 48) }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    @ViewBuilder
    private var messageContent: some View {
        if isUser {
            Text(message.content)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.white)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            formattedAssistantText(message.content)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var bubbleBackground: some View {
        Group {
            if isUser {
                Color.capeCod.oceanBlue
            } else {
                Color.capeCod.cardBackground
            }
        }
    }

    // MARK: - Markdown-like Rendering

    /// Renders assistant text with basic bold support using **text** syntax.
    private func formattedAssistantText(_ text: String) -> some View {
        let components = parseBoldText(text)
        return components.reduce(Text("")) { result, component in
            switch component {
            case .plain(let str):
                return result + Text(str)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color.capeCod.primaryText)
            case .bold(let str):
                return result + Text(str)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.capeCod.primaryText)
            }
        }
    }

    private enum TextComponent {
        case plain(String)
        case bold(String)
    }

    private func parseBoldText(_ text: String) -> [TextComponent] {
        var components: [TextComponent] = []
        var remaining = text

        while let startRange = remaining.range(of: "**") {
            // Add plain text before the marker
            let plainText = String(remaining[remaining.startIndex..<startRange.lowerBound])
            if !plainText.isEmpty {
                components.append(.plain(plainText))
            }

            // Find the closing **
            let afterStart = remaining[startRange.upperBound...]
            if let endRange = afterStart.range(of: "**") {
                let boldText = String(afterStart[afterStart.startIndex..<endRange.lowerBound])
                components.append(.bold(boldText))
                remaining = String(afterStart[endRange.upperBound...])
            } else {
                // No closing marker, treat rest as plain
                remaining = String(remaining[startRange.lowerBound...])
                components.append(.plain(remaining))
                return components
            }
        }

        if !remaining.isEmpty {
            components.append(.plain(remaining))
        }

        return components
    }
}

// MARK: - Chat Bubble Shape

/// Custom bubble shape with a small tail on the appropriate side.
private struct ChatBubbleShape: Shape {
    let isUser: Bool

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = CodRadius.card
        let tailSize: CGFloat = 6

        var path = Path()

        if isUser {
            // Rounded rect with slightly less rounding on bottom-right
            path.addRoundedRect(
                in: CGRect(x: rect.minX, y: rect.minY,
                           width: rect.width - tailSize / 2, height: rect.height),
                cornerSize: CGSize(width: radius, height: radius),
                style: .continuous
            )
        } else {
            // Rounded rect with slightly less rounding on bottom-left
            path.addRoundedRect(
                in: CGRect(x: tailSize / 2, y: rect.minY,
                           width: rect.width - tailSize / 2, height: rect.height),
                cornerSize: CGSize(width: radius, height: radius),
                style: .continuous
            )
        }

        return path
    }
}

// MARK: - Suggestion Card

private struct SuggestionCard: View {
    let icon: String
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.capeCod.oceanBlue)

                Text(text)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.capeCod.primaryText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleButton(text, hint: "Tap to ask this question")
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animatingDot0 = false
    @State private var animatingDot1 = false
    @State private var animatingDot2 = false

    private let dotSize: CGFloat = 8
    private let animationDuration: Double = 0.4
    private let staggerDelay: Double = 0.15

    var body: some View {
        HStack(spacing: CodSpacing.xs + 1) {
            dot(isAnimating: animatingDot0)
            dot(isAnimating: animatingDot1)
            dot(isAnimating: animatingDot2)
        }
        .padding(.horizontal, CodSpacing.md)
        .padding(.vertical, CodSpacing.sm + 4)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .onAppear {
            startAnimation()
        }
    }

    private func dot(isAnimating: Bool) -> some View {
        Circle()
            .fill(Color.capeCod.driftwood.opacity(isAnimating ? 0.9 : 0.35))
            .frame(width: dotSize, height: dotSize)
            .offset(y: isAnimating ? -4 : 2)
    }

    private func startAnimation() {
        let baseDuration = animationDuration
        let delay = staggerDelay

        // Dot 0
        withAnimation(
            .easeInOut(duration: baseDuration)
            .repeatForever(autoreverses: true)
        ) {
            animatingDot0 = true
        }

        // Dot 1 — staggered
        withAnimation(
            .easeInOut(duration: baseDuration)
            .repeatForever(autoreverses: true)
            .delay(delay)
        ) {
            animatingDot1 = true
        }

        // Dot 2 — staggered more
        withAnimation(
            .easeInOut(duration: baseDuration)
            .repeatForever(autoreverses: true)
            .delay(delay * 2)
        ) {
            animatingDot2 = true
        }
    }
}

// MARK: - Preview

#Preview {
    ChatView()
}
