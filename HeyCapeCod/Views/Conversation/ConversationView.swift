import SwiftUI

struct ConversationView: View {
    @State private var viewModel = ConversationViewModel()
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages
                messageList

                // Input Bar
                inputBar
            }
            .background(Color.capeCod.background)
            .navigationTitle("Ask Cape Cod")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Messages

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: CodSpacing.md) {
                    if viewModel.messages.isEmpty {
                        emptyState
                    }

                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.vertical, CodSpacing.md)
            }
            .onChange(of: viewModel.messages.count) {
                if let last = viewModel.messages.last {
                    withAnimation(CodAnimation.spring) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: CodSpacing.lg) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.capeCod.oceanBlue.opacity(0.3))
                .codAccessibleHidden()

            Text("Ask me anything about Cape Cod")
                .codTextStyle(.subtitle)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                SuggestionChip(text: "Best beaches for families?") {
                    viewModel.inputText = "What are the best beaches for families on Cape Cod?"
                }
                SuggestionChip(text: "Where to eat in Provincetown?") {
                    viewModel.inputText = "Where are the best restaurants in Provincetown?"
                }
                SuggestionChip(text: "Whale watching recommendations") {
                    viewModel.inputText = "Tell me about whale watching on Cape Cod"
                }
            }
        }
        .padding(.top, CodSpacing.xxl)
    }

    // MARK: - Input

    private var inputBar: some View {
        HStack(spacing: CodSpacing.sm) {
            // Microphone
            Button {
                Task { await viewModel.toggleListening() }
            } label: {
                Image(systemName: viewModel.isListening ? "mic.fill" : "mic")
                    .font(.title3)
                    .foregroundStyle(viewModel.isListening ? Color.capeCod.cranberry : Color.capeCod.driftwood)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .codAccessibleButton(
                viewModel.isListening ? "Stop listening" : "Start voice input",
                hint: viewModel.isListening ? "Tap to stop recording" : "Tap to dictate your question"
            )

            // Text field
            TextField("Ask about Cape Cod...", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .codTextStyle(.body)
                .lineLimit(1...5)
                .focused($isInputFocused)

            // Send
            Button {
                Task { await viewModel.sendMessage() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(viewModel.canSend ? Color.capeCod.oceanBlue : Color.capeCod.driftwood.opacity(0.3))
                    .frame(minWidth: 44, minHeight: 44)
            }
            .disabled(!viewModel.canSend)
            .codAccessibleButton("Send message", hint: viewModel.canSend ? "Send your question" : "Type a message first")
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.vertical, CodSpacing.sm)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: Message
    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: CodSpacing.xs) {
                Text(message.content)
                    .codTextStyle(.body)
                    .foregroundStyle(isUser ? .white : Color.capeCod.primaryText)

                if message.isStreaming {
                    ProgressView()
                        .tint(Color.capeCod.driftwood)
                }
            }
            .padding(.horizontal, CodSpacing.md)
            .padding(.vertical, CodSpacing.sm + 2)
            .background(isUser ? Color.capeCod.oceanBlue : Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))

            if !isUser { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Suggestion Chip

private struct SuggestionChip: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .codTextStyle(.caption)
                .padding(.horizontal, CodSpacing.md)
                .padding(.vertical, CodSpacing.sm)
                .background(Color.capeCod.oceanBlue.opacity(0.08))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .codAccessibleButton(text, hint: "Tap to ask this question")
    }
}

#Preview {
    ConversationView()
}
