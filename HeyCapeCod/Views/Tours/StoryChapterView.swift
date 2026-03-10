import SwiftUI
import CoreLocation

// MARK: - StoryChapter Model

/// Represents a single chapter within a story, with progress boundaries for seeking.
struct StoryChapter: Identifiable {
    let id: Int
    let title: String
    let content: String
    let startProgress: Double
    let endProgress: Double
    let highlight: String?

    /// Estimated duration based on proportion of total story duration.
    func estimatedDuration(totalDuration: TimeInterval) -> TimeInterval {
        (endProgress - startProgress) * totalDuration
    }

    /// Whether the given progress value falls within this chapter.
    func contains(progress: Double) -> Bool {
        progress >= startProgress && progress < endProgress
    }
}

// MARK: - StoryChapterService

/// Utility that splits a story script into chapters with progress boundaries.
enum StoryChapterService {

    // MARK: - Chapter Title Templates

    private static let chapterTitles: [[String]] = [
        ["Introduction", "The Story Begins", "Setting the Scene"],
        ["The History", "Origins", "How It Began"],
        ["The Heart of It", "The Journey", "Deeper In"],
        ["Turning Point", "What Changed", "Discoveries"],
        ["Legacy", "The Impact", "What Remains"],
    ]

    // MARK: - Public API

    /// Generate chapters from a story script, targeting 3-5 chapters.
    static func generateChapters(from script: String, storyTitle: String) -> [StoryChapter] {
        guard !script.isEmpty else { return [] }

        let paragraphs = splitIntoParagraphs(script)
        let grouped = groupParagraphs(paragraphs, targetChapters: clamp(paragraphs.count, min: 3, max: 5))

        let totalWords = Double(script.split(separator: " ").count)
        guard totalWords > 0 else { return [] }

        var chapters: [StoryChapter] = []
        var cumulativeWords: Double = 0

        for (index, group) in grouped.enumerated() {
            let content = group.joined(separator: "\n\n")
            let wordCount = Double(content.split(separator: " ").count)
            let startProgress = cumulativeWords / totalWords
            cumulativeWords += wordCount
            let endProgress = min(1.0, cumulativeWords / totalWords)

            let title = chapterTitle(for: index, total: grouped.count)
            let highlight = extractHighlight(from: content)

            chapters.append(StoryChapter(
                id: index,
                title: title,
                content: content,
                startProgress: startProgress,
                endProgress: endProgress,
                highlight: highlight
            ))
        }

        // Ensure the last chapter's endProgress is exactly 1.0
        if let last = chapters.last {
            chapters[chapters.count - 1] = StoryChapter(
                id: last.id,
                title: last.title,
                content: last.content,
                startProgress: last.startProgress,
                endProgress: 1.0,
                highlight: last.highlight
            )
        }

        return chapters
    }

    // MARK: - Private Helpers

    private static func splitIntoParagraphs(_ script: String) -> [String] {
        // Try splitting on double newlines first
        let doubleNewlineSplit = script
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if doubleNewlineSplit.count >= 3 {
            return doubleNewlineSplit
        }

        // Fall back to splitting by sentences, grouping into logical blocks
        let sentences = splitIntoSentences(script)
        guard sentences.count >= 3 else {
            return [script]
        }

        let targetParagraphs = min(5, max(3, sentences.count / 3))
        let sentencesPerParagraph = max(1, sentences.count / targetParagraphs)

        var paragraphs: [String] = []
        var current: [String] = []

        for sentence in sentences {
            current.append(sentence)
            if current.count >= sentencesPerParagraph && paragraphs.count < targetParagraphs - 1 {
                paragraphs.append(current.joined(separator: " "))
                current = []
            }
        }

        if !current.isEmpty {
            paragraphs.append(current.joined(separator: " "))
        }

        return paragraphs
    }

    private static func splitIntoSentences(_ text: String) -> [String] {
        var sentences: [String] = []
        text.enumerateSubstrings(in: text.startIndex..., options: .bySentences) { substring, _, _, _ in
            if let s = substring?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty {
                sentences.append(s)
            }
        }
        return sentences.isEmpty ? [text] : sentences
    }

    private static func groupParagraphs(_ paragraphs: [String], targetChapters: Int) -> [[String]] {
        guard paragraphs.count > targetChapters else {
            return paragraphs.map { [$0] }
        }

        let paragraphsPerChapter = max(1, paragraphs.count / targetChapters)
        var groups: [[String]] = []
        var current: [String] = []

        for paragraph in paragraphs {
            current.append(paragraph)
            if current.count >= paragraphsPerChapter && groups.count < targetChapters - 1 {
                groups.append(current)
                current = []
            }
        }

        if !current.isEmpty {
            groups.append(current)
        }

        return groups
    }

    private static func chapterTitle(for index: Int, total: Int) -> String {
        // Use predefined titles, cycling through variants
        let safeIndex = min(index, chapterTitles.count - 1)
        let variants = chapterTitles[safeIndex]
        return variants[index % variants.count]
    }

    private static func extractHighlight(from content: String) -> String? {
        let sentences = splitIntoSentences(content)
        guard !sentences.isEmpty else { return nil }

        // Prefer a sentence with interesting keywords, otherwise take the first
        let interestingKeywords = ["famous", "remarkable", "unique", "only", "first", "oldest",
                                   "largest", "tallest", "discovered", "historic", "legend",
                                   "secret", "treasure", "amazing", "incredible"]

        for sentence in sentences {
            let lower = sentence.lowercased()
            if interestingKeywords.contains(where: { lower.contains($0) }) {
                return sentence
            }
        }

        return sentences.first
    }

    private static func clamp(_ value: Int, min minVal: Int, max maxVal: Int) -> Int {
        max(minVal, min(maxVal, value))
    }
}

// MARK: - ChapterProgressBar

/// A segmented progress bar showing chapter boundaries with a position indicator.
/// Designed for reuse outside the story player.
struct ChapterProgressBar: View {
    @Binding var progress: Double
    let chapters: [StoryChapter]
    var onSeek: ((Double) -> Void)?

    @State private var isDragging = false
    @State private var barWidth: CGFloat = 0

    /// Color shades for alternating chapter segments
    private let segmentColors: [Color] = [
        Color.capeCod.oceanBlue.opacity(0.5),
        Color.capeCod.oceanBlue.opacity(0.35),
        Color.capeCod.seafoam.opacity(0.4),
        Color.capeCod.seafoam.opacity(0.3),
        Color.capeCod.oceanBlue.opacity(0.45),
    ]

    var body: some View {
        VStack(spacing: CodSpacing.xs) {
            progressBar
            chapterLabels
        }
        .codAccessibleGroup(label: currentChapterLabel)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            let width = geo.size.width

            ZStack(alignment: .leading) {
                // Chapter segments background
                HStack(spacing: 1) {
                    ForEach(chapters) { chapter in
                        let segmentWidth = (chapter.endProgress - chapter.startProgress) * width - (chapters.count > 1 ? 1 : 0)

                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(segmentColors[chapter.id % segmentColors.count])
                            .frame(width: max(0, segmentWidth))
                            .onTapGesture {
                                CodHaptic.light()
                                withAnimation(CodAnimation.quick) {
                                    progress = chapter.startProgress
                                }
                                onSeek?(chapter.startProgress)
                            }
                    }
                }

                // Filled progress overlay
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color.capeCod.seafoam)
                    .frame(width: max(0, progress * width))

                // Chapter boundary separators
                ForEach(chapters.dropFirst()) { chapter in
                    let xPosition = chapter.startProgress * width
                    Rectangle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 2, height: 12)
                        .position(x: xPosition, y: 6)
                }

                // Position indicator
                Circle()
                    .fill(.white)
                    .frame(width: isDragging ? 16 : 12, height: isDragging ? 16 : 12)
                    .shadow(color: Color.capeCod.oceanBlue.opacity(0.4), radius: 4)
                    .position(x: max(6, min(width - 6, progress * width)), y: 6)
                    .animation(CodAnimation.quick, value: isDragging)
            }
            .onAppear { barWidth = width }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let clamped = max(0, min(1, value.location.x / width))
                        progress = clamped
                    }
                    .onEnded { value in
                        isDragging = false
                        let clamped = max(0, min(1, value.location.x / width))
                        progress = clamped
                        CodHaptic.light()
                        onSeek?(clamped)
                    }
            )
        }
        .frame(height: 12)
    }

    // MARK: - Chapter Labels

    private var chapterLabels: some View {
        GeometryReader { geo in
            let width = geo.size.width

            ForEach(chapters) { chapter in
                let centerX = ((chapter.startProgress + chapter.endProgress) / 2) * width

                Text(shortLabel(for: chapter))
                    .codTextStyle(.label)
                    .foregroundStyle(.white.opacity(currentChapter?.id == chapter.id ? 0.7 : 0.3))
                    .lineLimit(1)
                    .frame(width: max(30, (chapter.endProgress - chapter.startProgress) * width - 4))
                    .position(x: centerX, y: 6)
            }
        }
        .frame(height: 14)
    }

    // MARK: - Helpers

    private var currentChapter: StoryChapter? {
        chapters.first { $0.contains(progress: progress) } ?? chapters.last
    }

    private var currentChapterLabel: String {
        guard let chapter = currentChapter else { return "Progress" }
        return "Chapter \(chapter.id + 1): \(chapter.title)"
    }

    private func shortLabel(for chapter: StoryChapter) -> String {
        "Ch.\(chapter.id + 1)"
    }
}

// MARK: - StoryChapterListView

/// A vertical list of chapter cards for navigation within a story.
/// Designed to appear as a sheet or inline section.
struct StoryChapterListView: View {
    @Bindable var viewModel: StoryPlayerViewModel
    let chapters: [StoryChapter]
    var onSelectChapter: ((StoryChapter) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                LazyVStack(spacing: CodSpacing.sm) {
                    ForEach(chapters) { chapter in
                        chapterCard(chapter)
                            .staggered(index: chapter.id)
                    }
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.top, CodSpacing.sm)
                .padding(.bottom, CodSpacing.lg)
            }
        }
        .background(Color.capeCod.deepNavy.ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                Text("Chapters")
                    .codTextStyle(.sectionTitle)
                    .foregroundStyle(.white)

                if let story = viewModel.currentStory {
                    Text(story.title)
                        .codTextStyle(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            Spacer()

            Text("\(chapters.count) chapters")
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.seafoam)
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.vertical, CodSpacing.md)
    }

    // MARK: - Chapter Card

    private func chapterCard(_ chapter: StoryChapter) -> some View {
        let isActive = chapter.contains(progress: viewModel.progress)

        return Button {
            CodHaptic.tap()
            viewModel.progress = chapter.startProgress
            viewModel.seekToProgress()
            onSelectChapter?(chapter)
        } label: {
            HStack(spacing: CodSpacing.md) {
                // Chapter number badge
                ZStack {
                    Circle()
                        .fill(isActive ? Color.capeCod.seafoam : .white.opacity(0.1))
                        .frame(width: 36, height: 36)

                    Text("\(chapter.id + 1)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(isActive ? Color.capeCod.deepNavy : .white.opacity(0.6))
                }

                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    Text(chapter.title)
                        .codTextStyle(.cardTitle)
                        .foregroundStyle(isActive ? Color.capeCod.seafoam : .white)

                    Text(previewText(chapter.content))
                        .codTextStyle(.caption)
                        .foregroundStyle(.white.opacity(0.45))
                        .lineLimit(1)

                    Text(formattedDuration(chapter.estimatedDuration(totalDuration: viewModel.duration)))
                        .codTextStyle(.label)
                        .foregroundStyle(.white.opacity(0.3))
                }

                Spacer()

                // Playing indicator
                if isActive && viewModel.isPlaying {
                    playingIndicator
                } else if isActive {
                    Image(systemName: "pause.circle.fill")
                        .foregroundStyle(Color.capeCod.seafoam)
                        .font(.system(size: 20))
                }
            }
            .padding(CodSpacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                    .fill(isActive ? .white.opacity(0.08) : .white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                            .strokeBorder(
                                isActive ? Color.capeCod.seafoam.opacity(0.3) : .clear,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .codAccessibleCard(
            label: "Chapter \(chapter.id + 1): \(chapter.title)",
            hint: isActive ? "Currently playing" : "Tap to jump to this chapter"
        )
    }

    // MARK: - Playing Indicator

    private var playingIndicator: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.capeCod.seafoam)
                    .frame(width: 3, height: 12)
                    .scaleEffect(y: 0.5, anchor: .bottom)
                    .animation(
                        .easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.15),
                        value: viewModel.isPlaying
                    )
            }
        }
        .frame(width: 20)
    }

    // MARK: - Helpers

    private func previewText(_ content: String) -> String {
        let trimmed = content.prefix(50)
        return trimmed.count < content.count ? "\(trimmed)..." : String(trimmed)
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - StoryHighlightsView

/// Displays key highlights and takeaways from the story in an elegant card layout.
/// Shown after story completion or accessible via a dedicated button.
struct StoryHighlightsView: View {
    let chapters: [StoryChapter]
    let poi: PointOfInterest?

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                LazyVStack(spacing: CodSpacing.md) {
                    ForEach(chapters.filter { $0.highlight != nil }) { chapter in
                        highlightCard(chapter: chapter)
                            .staggered(index: chapter.id)
                    }

                    relatedFactsSection
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.top, CodSpacing.sm)
                .padding(.bottom, CodSpacing.xl)
            }
        }
        .background(Color.capeCod.deepNavy.ignoresSafeArea())
        .onAppear {
            withAnimation(CodAnimation.spring) {
                appeared = true
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 20))
                .foregroundStyle(Color.capeCod.sandbarYellow)

            Text("Key Highlights")
                .codTextStyle(.sectionTitle)
                .foregroundStyle(.white)

            Spacer()

            if let poi = poi {
                Text(poi.name)
                    .codTextStyle(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.vertical, CodSpacing.md)
        .codAccessibleHeader("Key Highlights")
    }

    // MARK: - Highlight Card

    private func highlightCard(chapter: StoryChapter) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            // Chapter reference
            HStack(spacing: CodSpacing.xs) {
                Circle()
                    .fill(Color.capeCod.oceanBlue.opacity(0.4))
                    .frame(width: 6, height: 6)

                Text("Chapter \(chapter.id + 1): \(chapter.title)")
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.seafoam.opacity(0.7))
            }

            // Quote-style highlight
            HStack(alignment: .top, spacing: CodSpacing.sm) {
                Rectangle()
                    .fill(Color.capeCod.sunsetOrange)
                    .frame(width: 3)
                    .clipShape(Capsule())

                Text(chapter.highlight ?? "")
                    .codTextStyle(.storyBody)
                    .foregroundStyle(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Related POI fact if matching
            if let matchingFact = findRelatedFact(for: chapter) {
                HStack(alignment: .top, spacing: CodSpacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.capeCod.sandbarYellow)

                    Text(matchingFact)
                        .codTextStyle(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, CodSpacing.xs)
            }

            // Share button
            HStack {
                Spacer()
                ShareLink(item: chapter.highlight ?? "") {
                    HStack(spacing: CodSpacing.xs) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 12))
                        Text("Share")
                            .codTextStyle(.label)
                    }
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.horizontal, CodSpacing.sm)
                    .padding(.vertical, CodSpacing.xs)
                    .background(.white.opacity(0.06))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    // MARK: - Related Facts

    @ViewBuilder
    private var relatedFactsSection: some View {
        if let facts = poi?.facts, !facts.isEmpty {
            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: "text.book.closed.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.capeCod.duneGrass)

                    Text("Related Facts")
                        .codTextStyle(.cardTitle)
                        .foregroundStyle(.white)
                }

                ForEach(Array(facts.prefix(4).enumerated()), id: \.offset) { index, fact in
                    HStack(alignment: .top, spacing: CodSpacing.sm) {
                        Text("\(index + 1).")
                            .codTextStyle(.caption)
                            .foregroundStyle(Color.capeCod.duneGrass.opacity(0.7))
                            .frame(width: 20, alignment: .trailing)

                        Text(fact)
                            .codTextStyle(.body)
                            .foregroundStyle(.white.opacity(0.65))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(CodSpacing.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                    .fill(Color.capeCod.duneGrass.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                            .strokeBorder(Color.capeCod.duneGrass.opacity(0.15), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Helpers

    private func findRelatedFact(for chapter: StoryChapter) -> String? {
        guard let facts = poi?.facts, let highlight = chapter.highlight else { return nil }

        let highlightWords = Set(
            highlight.lowercased()
                .components(separatedBy: .alphanumerics.inverted)
                .filter { $0.count > 4 }
        )

        for fact in facts {
            let factWords = Set(
                fact.lowercased()
                    .components(separatedBy: .alphanumerics.inverted)
                    .filter { $0.count > 4 }
            )
            if !highlightWords.intersection(factWords).isEmpty {
                return fact
            }
        }

        return nil
    }
}

// MARK: - StoryTranscriptView

/// Enhanced chaptered transcript with progress highlighting, tap-to-seek, and search.
struct StoryTranscriptView: View {
    @Bindable var viewModel: StoryPlayerViewModel
    let chapters: [StoryChapter]

    @State private var searchText = ""
    @State private var scrollProxy: ScrollViewProxy?

    var body: some View {
        VStack(spacing: 0) {
            transcriptHeader
            searchBar
            transcriptContent
        }
        .background(Color.capeCod.deepNavy.ignoresSafeArea())
    }

    // MARK: - Header

    private var transcriptHeader: some View {
        HStack {
            Image(systemName: "text.alignleft")
                .font(.system(size: 16))
                .foregroundStyle(Color.capeCod.seafoam)

            Text("Transcript")
                .codTextStyle(.sectionTitle)
                .foregroundStyle(.white)

            Spacer()

            if let story = viewModel.currentStory {
                let wordCount = story.script.split(separator: " ").count
                Text("\(wordCount) words")
                    .codTextStyle(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.vertical, CodSpacing.md)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.4))

            TextField("Search transcript...", text: $searchText)
                .codTextStyle(.body)
                .foregroundStyle(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Button {
                    withAnimation(CodAnimation.quick) {
                        searchText = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .codAccessibleButton("Clear search")
            }
        }
        .padding(.horizontal, CodSpacing.md)
        .padding(.vertical, CodSpacing.sm + 2)
        .background(
            RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous)
                .fill(.white.opacity(0.06))
        )
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.bottom, CodSpacing.sm)
    }

    // MARK: - Transcript Content

    private var transcriptContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: CodSpacing.lg) {
                    ForEach(chapters) { chapter in
                        chapterTranscriptSection(chapter)
                    }
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.xl)
            }
            .onAppear {
                scrollProxy = proxy
            }
            .onChange(of: viewModel.progress) { _, newProgress in
                scrollToCurrentParagraph(proxy: proxy, progress: newProgress)
            }
        }
    }

    // MARK: - Chapter Section

    private func chapterTranscriptSection(_ chapter: StoryChapter) -> some View {
        let isCurrentChapter = chapter.contains(progress: viewModel.progress)

        return VStack(alignment: .leading, spacing: CodSpacing.sm) {
            // Chapter header
            HStack(spacing: CodSpacing.sm) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(isCurrentChapter ? Color.capeCod.seafoam : .white.opacity(0.15))
                    .frame(width: 3, height: 16)

                Text("Chapter \(chapter.id + 1): \(chapter.title)")
                    .codTextStyle(.cardTitle)
                    .foregroundStyle(isCurrentChapter ? Color.capeCod.seafoam : .white.opacity(0.6))
            }
            .id("chapter-header-\(chapter.id)")

            // Paragraphs
            let paragraphs = splitParagraphs(chapter.content)

            ForEach(Array(paragraphs.enumerated()), id: \.offset) { paraIndex, paragraph in
                let paragraphProgress = estimateParagraphProgress(
                    chapterIndex: chapter.id,
                    paragraphIndex: paraIndex,
                    totalParagraphs: paragraphs.count,
                    chapter: chapter
                )
                let isCurrentParagraph = isCurrentChapter &&
                    isParagraphCurrent(progress: viewModel.progress, paragraphProgress: paragraphProgress, chapter: chapter, paragraphCount: paragraphs.count)

                paragraphView(
                    text: paragraph,
                    isActive: isCurrentParagraph,
                    progress: paragraphProgress
                )
                .id("paragraph-\(chapter.id)-\(paraIndex)")
            }
        }
    }

    // MARK: - Paragraph View

    private func paragraphView(text: String, isActive: Bool, progress: Double) -> some View {
        Button {
            CodHaptic.light()
            withAnimation(CodAnimation.quick) {
                viewModel.progress = progress
                viewModel.seekToProgress()
            }
        } label: {
            HStack(alignment: .top, spacing: CodSpacing.sm) {
                // Active indicator
                if isActive {
                    Circle()
                        .fill(Color.capeCod.seafoam)
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)
                } else {
                    Color.clear
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)
                }

                highlightedText(text, isActive: isActive)
            }
        }
        .buttonStyle(.plain)
        .codAccessibleButton("Seek to this paragraph")
    }

    // MARK: - Highlighted Text

    @ViewBuilder
    private func highlightedText(_ text: String, isActive: Bool) -> some View {
        if searchText.isEmpty {
            Text(text)
                .codTextStyle(.storyBody)
                .foregroundStyle(isActive ? .white : .white.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)
                .animation(CodAnimation.quick, value: isActive)
        } else {
            buildSearchHighlightedText(text)
                .codTextStyle(.storyBody)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func buildSearchHighlightedText(_ text: String) -> Text {
        guard !searchText.isEmpty else {
            return Text(text).foregroundColor(.white.opacity(0.55))
        }

        let lowercasedText = text.lowercased()
        let lowercasedSearch = searchText.lowercased()
        var result = Text("")
        var currentIndex = lowercasedText.startIndex

        while let range = lowercasedText[currentIndex...].range(of: lowercasedSearch) {
            // Text before match
            let beforeRange = currentIndex..<range.lowerBound
            let originalBefore = text[beforeRange]
            result = result + Text(originalBefore).foregroundColor(.white.opacity(0.55))

            // Matched text
            let originalMatch = text[range]
            result = result + Text(originalMatch)
                .foregroundColor(Color.capeCod.sandbarYellow)
                .bold()

            currentIndex = range.upperBound
        }

        // Remaining text
        let remaining = text[currentIndex...]
        result = result + Text(remaining).foregroundColor(.white.opacity(0.55))

        return result
    }

    // MARK: - Paragraph Parsing

    private func splitParagraphs(_ content: String) -> [String] {
        content
            .components(separatedBy: "\n\n")
            .flatMap { $0.components(separatedBy: "\n") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    // MARK: - Progress Estimation

    private func estimateParagraphProgress(
        chapterIndex: Int,
        paragraphIndex: Int,
        totalParagraphs: Int,
        chapter: StoryChapter
    ) -> Double {
        guard totalParagraphs > 0 else { return chapter.startProgress }
        let chapterSpan = chapter.endProgress - chapter.startProgress
        let fraction = Double(paragraphIndex) / Double(totalParagraphs)
        return chapter.startProgress + (fraction * chapterSpan)
    }

    private func isParagraphCurrent(
        progress: Double,
        paragraphProgress: Double,
        chapter: StoryChapter,
        paragraphCount: Int
    ) -> Bool {
        guard paragraphCount > 0 else { return false }
        let step = (chapter.endProgress - chapter.startProgress) / Double(paragraphCount)
        return progress >= paragraphProgress && progress < paragraphProgress + step
    }

    private func scrollToCurrentParagraph(proxy: ScrollViewProxy, progress: Double) {
        guard let chapter = chapters.first(where: { $0.contains(progress: progress) }) else { return }

        let paragraphs = splitParagraphs(chapter.content)

        let chapterSpan = chapter.endProgress - chapter.startProgress
        guard chapterSpan > 0 else { return }
        let relativeProgress = (progress - chapter.startProgress) / chapterSpan
        let paragraphIndex = min(paragraphs.count - 1, Int(relativeProgress * Double(paragraphs.count)))

        withAnimation(CodAnimation.spring) {
            proxy.scrollTo("paragraph-\(chapter.id)-\(paragraphIndex)", anchor: .center)
        }
    }
}

// MARK: - Preview Data

extension StoryChapter {
    static let previewChapters: [StoryChapter] = StoryChapterService.generateChapters(
        from: previewScript,
        storyTitle: "Black Sam Bellamy and the Whydah"
    )

    static let previewScript = """
    In 1717, the pirate ship Whydah went down in a fierce nor'easter off Wellfleet. Its captain, 'Black Sam' Bellamy, was just 28 years old and already the wealthiest pirate in recorded history.

    Bellamy was no ordinary buccaneer. Born in Devon, England, he came to Cape Cod seeking fortune and fell in love with a local girl named Maria Hallett. When her family rejected the penniless sailor, Bellamy turned to piracy, vowing to return rich enough to claim her hand.

    In just over a year, he captured more than 50 ships. The Whydah itself was a slave ship he seized off the coast of Cuba, converting it into his flagship.

    On April 26, 1717, Bellamy was sailing north to reunite with Maria when a violent storm drove the Whydah onto a sandbar. Of the 146 men aboard, only two survived.

    The wreck lay undiscovered for over 260 years until Barry Clifford found it in 1984. Today, artifacts from the Whydah are displayed in the museum, telling the remarkable story of the prince of pirates and his fateful voyage home.
    """
}

extension PointOfInterest {
    static let preview = PointOfInterest(
        id: "whydah-museum",
        name: "Whydah Pirate Museum",
        coordinate: CLLocationCoordinate2D(latitude: 41.7585, longitude: -70.0637),
        geofenceRadius: 200,
        category: .museum,
        town: .yarmouth,
        description: "Home to the only authenticated pirate shipwreck ever discovered.",
        stories: [
            StoryVariant(
                title: "Black Sam Bellamy and the Whydah",
                mode: .adult,
                script: StoryChapter.previewScript
            )
        ],
        facts: [
            "The Whydah is the only authenticated pirate shipwreck ever discovered",
            "Over 200,000 artifacts have been recovered since 1984",
            "Captain Sam Bellamy captured 53 ships in just over one year",
            "The ship's bell confirmed the wreck's identity"
        ],
        tips: [
            "Visit on a weekday morning to avoid crowds",
            "The gift shop has great pirate costumes for kids"
        ],
        imageSystemName: "flag.filled.and.flag.crossed"
    )
}

// MARK: - Previews

#Preview("Chapter Progress Bar") {
    @Previewable @State var progress = 0.35

    ZStack {
        Color.capeCod.deepNavy.ignoresSafeArea()

        VStack(spacing: CodSpacing.xl) {
            ChapterProgressBar(
                progress: $progress,
                chapters: StoryChapter.previewChapters
            )
            .padding(.horizontal, CodSpacing.screenEdge)

            Text("Progress: \(Int(progress * 100))%")
                .codTextStyle(.body)
                .foregroundStyle(.white)

            Slider(value: $progress, in: 0...1)
                .tint(Color.capeCod.seafoam)
                .padding(.horizontal, CodSpacing.screenEdge)
        }
    }
}

#Preview("Chapter List") {
    StoryChapterListView(
        viewModel: {
            let vm = StoryPlayerViewModel()
            vm.loadAndPlay(
                poi: .preview,
                story: PointOfInterest.preview.stories[0]
            )
            return vm
        }(),
        chapters: StoryChapter.previewChapters
    )
}

#Preview("Highlights") {
    StoryHighlightsView(
        chapters: StoryChapter.previewChapters,
        poi: .preview
    )
}

#Preview("Transcript") {
    StoryTranscriptView(
        viewModel: {
            let vm = StoryPlayerViewModel()
            vm.loadAndPlay(
                poi: .preview,
                story: PointOfInterest.preview.stories[0]
            )
            return vm
        }(),
        chapters: StoryChapter.previewChapters
    )
}
