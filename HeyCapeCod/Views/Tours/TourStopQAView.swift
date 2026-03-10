import SwiftUI

// MARK: - QA Message Model

struct QAMessage: Identifiable, Equatable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date

    init(id: UUID = UUID(), content: String, isUser: Bool, timestamp: Date = .now) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

// MARK: - Tour Stop Q&A ViewModel

@preconcurrency @MainActor
@Observable
final class TourStopQAViewModel {

    // MARK: - State

    private(set) var messages: [QAMessage] = []
    var inputText: String = ""
    private(set) var isLoading: Bool = false
    let poi: PointOfInterest

    // MARK: - Init

    init(poi: PointOfInterest) {
        self.poi = poi
        let welcome = QAMessage(
            content: "Ask me anything about \(poi.name)! I know all about this spot.",
            isUser: false
        )
        messages.append(welcome)
    }

    // MARK: - Computed

    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }

    var suggestedQuestions: [String] {
        var questions: [String] = []

        switch poi.category {
        case .beach:
            questions.append("Is this beach good for swimming?")
            questions.append("What's the best time to visit?")
            questions.append("Is there parking nearby?")
            questions.append("Are dogs allowed here?")
        case .restaurant:
            questions.append("What's the must-try dish here?")
            questions.append("Do I need a reservation?")
            questions.append("Is it family-friendly?")
            questions.append("What are the hours?")
        case .historic:
            questions.append("What happened here historically?")
            questions.append("How old is this site?")
            questions.append("Are there guided tours available?")
            questions.append("What's the most surprising fact?")
        case .lighthouse:
            questions.append("Can I climb to the top?")
            questions.append("When was this lighthouse built?")
            questions.append("What's the best photo angle?")
            questions.append("Is it still operational?")
        case .museum:
            questions.append("What's the main exhibit?")
            questions.append("How long should I plan to spend here?")
            questions.append("Is it good for kids?")
            questions.append("What are the admission prices?")
        case .nature:
            questions.append("What wildlife might I see?")
            questions.append("How long is the main trail?")
            questions.append("What's the best season to visit?")
            questions.append("Are there any guided walks?")
        case .marina:
            questions.append("Are there boat tours available?")
            questions.append("Can I rent a kayak here?")
            questions.append("What's the fishing like?")
            questions.append("Is there a good seafood shack nearby?")
        case .entertainment:
            questions.append("What shows are playing?")
            questions.append("Is it good for families?")
            questions.append("How do I get tickets?")
            questions.append("What's the vibe like?")
        case .shopping:
            questions.append("What's unique to shop for here?")
            questions.append("Are there local artisan goods?")
            questions.append("What are the store hours?")
            questions.append("Any must-visit shops?")
        case .lodging:
            questions.append("What's the history of this place?")
            questions.append("What should I not miss here?")
            questions.append("Any local insider tips?")
            questions.append("What's nearby worth visiting?")
        }

        // Enrich with POI-specific questions based on facts/tips
        if !poi.facts.isEmpty {
            questions.insert("Tell me a fun fact about \(poi.name)", at: 1)
        }

        return Array(questions.prefix(4))
    }

    // MARK: - Send Question

    func sendQuestion() async {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMessage = QAMessage(content: trimmed, isUser: true)
        messages.append(userMessage)
        inputText = ""
        isLoading = true

        defer { isLoading = false }

        // Build context-rich prompt
        let mode = UserProfileManager.shared.currentProfile?.experienceMode ?? .adult
        let contextParts = buildContextParts()
        let systemContext = "You are a knowledgeable Cape Cod guide. Answer questions about \(poi.name) in \(poi.town.displayName). Keep answers concise (2-3 sentences). Be warm and engaging."
        let fullPrompt = "\(systemContext)\n\nContext about this location:\n\(contextParts)\n\nUser question: \(trimmed)"

        // Build history for API
        let historyArray: [[String: String]] = messages.dropLast().map { msg in
            ["role": msg.isUser ? "user" : "assistant", "content": msg.content]
        }

        do {
            let url = APIClient.shared.baseURL.appendingPathComponent("chat")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = APIClient.shared.authToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            let body: [String: Any] = [
                "message": fullPrompt,
                "mode": mode.rawValue,
                "history": historyArray
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
            }

            let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
            let aiMessage = QAMessage(content: decoded.response, isUser: false)
            messages.append(aiMessage)
            CodHaptic.success()
        } catch {
            let errorMessage = QAMessage(
                content: "I'm having trouble connecting right now. Try again in a moment — the Cape Cod breeze must be interfering with the signal!",
                isUser: false
            )
            messages.append(errorMessage)
        }
    }

    // MARK: - Helpers

    private func buildContextParts() -> String {
        var parts: [String] = []

        parts.append("Name: \(poi.name)")
        parts.append("Town: \(poi.town.displayName)")
        parts.append("Category: \(poi.category.displayName)")

        if !poi.description.isEmpty {
            parts.append("Description: \(poi.description)")
        }

        if !poi.facts.isEmpty {
            parts.append("Facts: \(poi.facts.joined(separator: "; "))")
        }

        if !poi.tips.isEmpty {
            parts.append("Tips: \(poi.tips.joined(separator: "; "))")
        }

        return parts.joined(separator: "\n")
    }
}

// MARK: - Tour Stop Q&A View

struct TourStopQAView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: TourStopQAViewModel
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Color.capeCod.background
                .ignoresSafeArea()
                .overlay(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                Divider()
                    .foregroundStyle(Color.capeCod.driftwood.opacity(0.2))
                messageList
                suggestedQuestionsBar
                inputBar
            }
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        ZStack {
            // Dark navy background
            LinearGradient(
                colors: [Color.capeCod.deepNavy, Color(hex: 0x162233)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)

            HStack {
                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    Text(viewModel.poi.name)
                        .codTextStyle(.cardTitle)
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text("Ask a Question")
                        .codTextStyle(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Button {
                    CodHaptic.light()
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(width: 44, height: 44)
                }
                .codAccessibleButton("Close Q&A")
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.vertical, CodSpacing.md)
        }
        .frame(minHeight: 64)
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: CodSpacing.sm) {
                    // Top breathing room
                    Color.clear.frame(height: CodSpacing.sm)

                    ForEach(viewModel.messages) { message in
                        QABubble(message: message)
                            .id(message.id)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }

                    // Typing indicator
                    if viewModel.isLoading {
                        HStack {
                            TypingIndicator()
                            Spacer(minLength: 60)
                        }
                        .padding(.horizontal, CodSpacing.screenEdge)
                        .transition(.codScale)
                        .id("loading_indicator")
                    }

                    // Bottom anchor
                    Color.clear
                        .frame(height: 1)
                        .id("qa_bottom_anchor")
                }
                .padding(.bottom, CodSpacing.sm)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.count) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.isLoading) {
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(CodAnimation.spring) {
            if viewModel.isLoading {
                proxy.scrollTo("loading_indicator", anchor: .bottom)
            } else if let last = viewModel.messages.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            } else {
                proxy.scrollTo("qa_bottom_anchor", anchor: .bottom)
            }
        }
    }

    // MARK: - Suggested Questions

    private var suggestedQuestionsBar: some View {
        Group {
            if !viewModel.suggestedQuestions.isEmpty && viewModel.messages.count <= 2 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: CodSpacing.sm) {
                        ForEach(viewModel.suggestedQuestions, id: \.self) { question in
                            Button {
                                CodHaptic.light()
                                viewModel.inputText = question
                                Task { await viewModel.sendQuestion() }
                            } label: {
                                Text(question)
                                    .codTextStyle(.caption)
                                    .foregroundStyle(Color.capeCod.oceanBlue)
                                    .padding(.horizontal, CodSpacing.md)
                                    .padding(.vertical, CodSpacing.sm)
                                    .background(Color.capeCod.oceanBlue.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                            .codAccessibleButton(question, hint: "Tap to ask this question")
                        }
                    }
                    .padding(.horizontal, CodSpacing.screenEdge)
                }
                .padding(.vertical, CodSpacing.sm)
                .transition(.codSlideUp)
            }
        }
        .animation(CodAnimation.spring, value: viewModel.messages.count)
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundStyle(Color.capeCod.driftwood.opacity(0.2))

            HStack(alignment: .bottom, spacing: CodSpacing.sm) {
                // Text field
                TextField(
                    "Ask about \(viewModel.poi.name)...",
                    text: $viewModel.inputText,
                    axis: .vertical
                )
                .textFieldStyle(.plain)
                .codTextStyle(.body)
                .lineLimit(1...4)
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
                .onSubmit {
                    guard viewModel.canSend else { return }
                    CodHaptic.tap()
                    Task { await viewModel.sendQuestion() }
                }

                // Send button
                Button {
                    CodHaptic.tap()
                    Task { await viewModel.sendQuestion() }
                } label: {
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(Color.capeCod.oceanBlue)
                                .frame(width: 32, height: 32)
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(
                                    viewModel.canSend
                                        ? Color.capeCod.oceanBlue
                                        : Color.capeCod.driftwood.opacity(0.3)
                                )
                        }
                    }
                    .animation(CodAnimation.quick, value: viewModel.canSend)
                    .animation(CodAnimation.quick, value: viewModel.isLoading)
                }
                .disabled(!viewModel.canSend)
                .codAccessibleButton(
                    "Send question",
                    hint: viewModel.canSend ? "Send your question" : "Type a question first"
                )
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.vertical, CodSpacing.sm + 2)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Q&A Chat Bubble

private struct QABubble: View {
    let message: QAMessage

    private var isUser: Bool { message.isUser }

    var body: some View {
        HStack(alignment: .bottom, spacing: CodSpacing.xs) {
            if isUser { Spacer(minLength: 48) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: CodSpacing.xs) {
                Text(message.content)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(isUser ? Color.white : Color.capeCod.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

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
            .background(
                isUser
                    ? Color.capeCod.oceanBlue
                    : Color.capeCod.cardBackground
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: CodRadius.card,
                    style: .continuous
                )
            )

            if !isUser { Spacer(minLength: 48) }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }
}

// MARK: - Preview

#Preview {
    TourStopQAView(
        viewModel: TourStopQAViewModel(
            poi: PointOfInterest(
                id: "preview-poi",
                name: "Nauset Light",
                coordinate: .init(latitude: 41.8583, longitude: -69.9522),
                geofenceRadius: 200,
                category: .lighthouse,
                town: .eastham,
                description: "One of the most photographed lighthouses on Cape Cod.",
                stories: [],
                facts: [
                    "Built in 1877, originally in Chatham",
                    "Moved to its current location in 1996 to save it from erosion",
                    "The red and white tower is 48 feet tall"
                ],
                tips: [
                    "Visit at sunset for the best photos",
                    "The adjacent Three Sisters lighthouses are a short walk away"
                ],
                imageSystemName: "light.beacon.max.fill"
            )
        )
    )
}
