import SwiftUI
import AVFoundation

// MARK: - CapeCodStoryTopic

/// Cape Cod story topics organized by category, each with a display name,
/// SF Symbol icon, teaser blurb, and associated StoryCategory.
enum CapeCodStoryTopic: String, CaseIterable, Identifiable, Codable {
    // History
    case pilgrims
    case wampanoag
    case capeCodCanal
    case whaling
    case revolution

    // Culture
    case cranberryBogs
    case portugueseFishing
    case artColonies
    case lightkeepers
    case clamShacks

    // Nature
    case whales
    case seals
    case greatWhiteSharks
    case pipingPlovers
    case saltMarshes

    // Maritime
    case pirates
    case shipwrecks
    case lifesavers
    case fishingBoats
    case harborPilots

    // Legends
    case ladyOfTheDunes
    case mooncussers
    case widowsWalkGhosts
    case mariaHallett

    // Seasonal Events
    case fourthOfJulyParades
    case blessingOfTheFleet
    case cranberryHarvest
    case summerTheater

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pilgrims: "The Pilgrims' Landing"
        case .wampanoag: "The Wampanoag People"
        case .capeCodCanal: "The Cape Cod Canal"
        case .whaling: "Whaling Days"
        case .revolution: "Revolution on the Cape"
        case .cranberryBogs: "Cranberry Bogs"
        case .portugueseFishing: "Portuguese Fishing Heritage"
        case .artColonies: "Art Colonies of Provincetown"
        case .lightkeepers: "The Lightkeepers"
        case .clamShacks: "Clam Shack Culture"
        case .whales: "Humpback Whales"
        case .seals: "The Seals of Chatham"
        case .greatWhiteSharks: "Great White Sharks"
        case .pipingPlovers: "Piping Plovers"
        case .saltMarshes: "The Salt Marshes"
        case .pirates: "Pirates of the Cape"
        case .shipwrecks: "Shipwrecks & the Graveyard of the Atlantic"
        case .lifesavers: "The Lifesavers"
        case .fishingBoats: "Fishing Boats of Chatham"
        case .harborPilots: "Harbor Pilots"
        case .ladyOfTheDunes: "The Lady of the Dunes"
        case .mooncussers: "The Mooncussers"
        case .widowsWalkGhosts: "Widow's Walk Ghosts"
        case .mariaHallett: "Maria Hallett, the Sea Witch"
        case .fourthOfJulyParades: "4th of July Parades"
        case .blessingOfTheFleet: "Blessing of the Fleet"
        case .cranberryHarvest: "Cranberry Harvest"
        case .summerTheater: "Summer Theater on the Cape"
        }
    }

    var icon: String {
        switch self {
        case .pilgrims: "sailboat.fill"
        case .wampanoag: "leaf.circle.fill"
        case .capeCodCanal: "water.waves"
        case .whaling: "fish.fill"
        case .revolution: "flag.fill"
        case .cranberryBogs: "leaf.fill"
        case .portugueseFishing: "ferry.fill"
        case .artColonies: "paintpalette.fill"
        case .lightkeepers: "light.beacon.max.fill"
        case .clamShacks: "fork.knife"
        case .whales: "whale.fill"
        case .seals: "pawprint.fill"
        case .greatWhiteSharks: "bolt.trianglebadge.exclamationmark.fill"
        case .pipingPlovers: "bird.fill"
        case .saltMarshes: "humidity.fill"
        case .pirates: "flag.2.crossed.fill"
        case .shipwrecks: "anchor.circle.fill"
        case .lifesavers: "lifepreserver.fill"
        case .fishingBoats: "ferry.fill"
        case .harborPilots: "helm.fill"
        case .ladyOfTheDunes: "questionmark.circle.fill"
        case .mooncussers: "moon.stars.fill"
        case .widowsWalkGhosts: "house.fill"
        case .mariaHallett: "wind"
        case .fourthOfJulyParades: "fireworks"
        case .blessingOfTheFleet: "hands.sparkles.fill"
        case .cranberryHarvest: "basket.fill"
        case .summerTheater: "theatermasks.fill"
        }
    }

    var teaser: String {
        switch self {
        case .pilgrims: "Before Plymouth Rock, the Pilgrims first landed on Cape Cod..."
        case .wampanoag: "The People of the First Light have called this land home for 12,000 years."
        case .capeCodCanal: "How a massive ditch changed Cape Cod forever."
        case .whaling: "When Nantucket Sound echoed with the call of the whale hunt."
        case .revolution: "Cape Cod's fiery role in the fight for independence."
        case .cranberryBogs: "The ruby-red fruit that shaped Cape Cod's landscape and economy."
        case .portugueseFishing: "Brave fishermen who crossed the Atlantic and built a community."
        case .artColonies: "How Provincetown became America's oldest art colony."
        case .lightkeepers: "Lonely guardians of the coast, tending flames through storms."
        case .clamShacks: "From quahogs to bellies, the delicious story of Cape Cod's clam shacks."
        case .whales: "Majestic giants breach and feed in the rich waters off Provincetown."
        case .seals: "Thousands of gray seals now call the Outer Cape home."
        case .greatWhiteSharks: "Apex predators patrol the shores, drawn by the seal buffet."
        case .pipingPlovers: "Tiny, endangered shorebirds that nest on Cape Cod beaches."
        case .saltMarshes: "Hidden ecosystems teeming with life between land and sea."
        case .pirates: "Black Sam Bellamy and the treasure of the Whydah."
        case .shipwrecks: "Over 3,000 vessels lost along these treacherous shores."
        case .lifesavers: "Heroic surfmen who risked everything to save sailors from the sea."
        case .fishingBoats: "The iconic fleet that still brings the catch of the day."
        case .harborPilots: "Expert navigators guiding ships through the Cape's tricky waters."
        case .ladyOfTheDunes: "An unsolved mystery in the dunes of Provincetown."
        case .mooncussers: "Wreckers who lured ships to their doom with false lights."
        case .widowsWalkGhosts: "Spectral wives still pace rooftop walkways, watching the sea."
        case .mariaHallett: "A love story, a pirate, and a curse on the shores of Wellfleet."
        case .fourthOfJulyParades: "Small-town celebrations that define Cape Cod summers."
        case .blessingOfTheFleet: "A sacred tradition honoring fishermen and the sea."
        case .cranberryHarvest: "When the bogs turn crimson and the harvest begins."
        case .summerTheater: "Eugene O'Neill, Tennessee Williams, and the stages of the Cape."
        }
    }

    var storyCategory: StoryCategory {
        switch self {
        case .pilgrims, .wampanoag, .capeCodCanal, .whaling, .revolution:
            .history
        case .cranberryBogs, .portugueseFishing, .artColonies, .lightkeepers, .clamShacks:
            .culture
        case .whales, .seals, .greatWhiteSharks, .pipingPlovers, .saltMarshes:
            .nature
        case .pirates, .shipwrecks, .lifesavers, .fishingBoats, .harborPilots:
            .maritime
        case .ladyOfTheDunes, .mooncussers, .widowsWalkGhosts, .mariaHallett:
            .legend
        case .fourthOfJulyParades, .blessingOfTheFleet, .cranberryHarvest, .summerTheater:
            .food // Seasonal events mapped to food as the closest available category
        }
    }

    var categoryColor: Color {
        switch storyCategory {
        case .history: Color.capeCod.sunsetOrange
        case .nature: Color.capeCod.duneGrass
        case .maritime: Color.capeCod.oceanBlue
        case .legend: Color.capeCod.cranberry
        case .culture: Color.capeCod.seafoam
        case .food: Color.capeCod.sandbarYellow
        }
    }

    var categoryLabel: String {
        switch self {
        case .fourthOfJulyParades, .blessingOfTheFleet, .cranberryHarvest, .summerTheater:
            "Seasonal"
        default:
            storyCategory.displayName
        }
    }

    static func topicsFor(category: StoryCategory) -> [CapeCodStoryTopic] {
        allCases.filter { $0.storyCategory == category }
    }
}

// MARK: - GeneratedStory

/// A story generated by the AI, including parsed metadata.
struct GeneratedStory: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let content: String
    let readingTime: Int // minutes
    let topic: CapeCodStoryTopic
    let mode: ExperienceMode
    let relatedTopics: [CapeCodStoryTopic]
    let funFacts: [String]
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        readingTime: Int,
        topic: CapeCodStoryTopic,
        mode: ExperienceMode,
        relatedTopics: [CapeCodStoryTopic] = [],
        funFacts: [String] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.readingTime = readingTime
        self.topic = topic
        self.mode = mode
        self.relatedTopics = relatedTopics
        self.funFacts = funFacts
        self.createdAt = createdAt
    }
}

// MARK: - StoryGenerationState

enum StoryGenerationState: Equatable {
    case idle
    case generating
    case complete(GeneratedStory)
    case error(String)
}

// MARK: - StoryGeneratorService

/// Observable service that uses the app's AIService to generate Cape Cod stories.
@preconcurrency @MainActor
@Observable
final class StoryGeneratorService {

    var generationState: StoryGenerationState = .idle
    var recentStories: [GeneratedStory] = []
    var favoriteStories: [GeneratedStory] = []

    private let aiService: AIService

    private static let recentStoriesKey = "StoryGenerator.recentStories"
    private static let favoriteStoriesKey = "StoryGenerator.favoriteStories"

    init(aiService: AIService = AIService()) {
        self.aiService = aiService
        loadPersistedStories()
    }

    // MARK: - Generate Story

    func generateStory(topic: CapeCodStoryTopic, mode: ExperienceMode) async {
        generationState = .generating

        let systemPrompt = buildSystemPrompt(mode: mode)
        let userPrompt = "Tell me a story about \(topic.displayName) on Cape Cod."

        let history: [Message] = [
            .system(systemPrompt)
        ]

        let context = ChatContext(
            experienceMode: mode,
            visitType: "storytelling",
            interests: [topic.storyCategory.rawValue]
        )

        do {
            let response = try await aiService.sendMessage(userPrompt, history: history, context: context)
            let story = parseResponse(response, topic: topic, mode: mode)
            generationState = .complete(story)

            recentStories.insert(story, at: 0)
            if recentStories.count > 20 {
                recentStories = Array(recentStories.prefix(20))
            }
            persistStories()
        } catch {
            generationState = .error(error.localizedDescription)
        }
    }

    // MARK: - Favorites

    func toggleFavorite(_ story: GeneratedStory) {
        if let index = favoriteStories.firstIndex(where: { $0.id == story.id }) {
            favoriteStories.remove(at: index)
        } else {
            favoriteStories.insert(story, at: 0)
        }
        persistStories()
    }

    func isFavorite(_ story: GeneratedStory) -> Bool {
        favoriteStories.contains(where: { $0.id == story.id })
    }

    func reset() {
        generationState = .idle
    }

    // MARK: - Private Helpers

    private func buildSystemPrompt(mode: ExperienceMode) -> String {
        let modeInstructions: String
        switch mode {
        case .kids:
            modeInstructions = """
            Write for children ages 6-10. Use simple, fun language. Include silly details \
            and exciting moments. Keep the story to about 3-5 minutes of reading time \
            (roughly 400-600 words). Make it educational but entertaining. Use short paragraphs.
            """
        case .teen:
            modeInstructions = """
            Write for teenagers. Use engaging, slightly edgy language with historical depth. \
            Include surprising facts and dramatic moments. Keep the story to about 5-8 minutes \
            of reading time (roughly 700-1000 words). Be authentic, not condescending.
            """
        case .adult:
            modeInstructions = """
            Write for adults with literary quality. Use rich, evocative prose with detailed \
            historical context. Include nuanced perspectives and atmospheric descriptions. \
            Keep the story to about 8-12 minutes of reading time (roughly 1200-1800 words).
            """
        case .family:
            modeInstructions = """
            Write for a family audience, engaging for both kids and adults. Balance fun and \
            education. Include moments that spark conversation between generations. Keep the \
            story to about 5-8 minutes of reading time (roughly 700-1000 words).
            """
        }

        return """
        You are a master storyteller for the Hey Cape Cod app. You tell captivating, \
        historically-grounded stories about Cape Cod, Massachusetts.

        \(modeInstructions)

        FORMAT YOUR RESPONSE EXACTLY LIKE THIS:
        - First line: The story title (no quotes, no prefix)
        - Then a blank line
        - Then the story content with paragraph breaks
        - Then a blank line
        - Then 2-4 lines starting with "Fun Fact:" followed by an interesting related fact

        Make the story vivid, accurate, and deeply connected to Cape Cod's real places, \
        people, and history. Mention specific towns, landmarks, and sensory details \
        (the salt air, the sound of waves, the gray-shingled cottages).
        """
    }

    private func parseResponse(
        _ response: String,
        topic: CapeCodStoryTopic,
        mode: ExperienceMode
    ) -> GeneratedStory {
        let lines = response.components(separatedBy: "\n")

        // Title: first non-empty line
        let title = lines.first(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty })
            ?? topic.displayName

        // Fun facts: lines starting with "Fun Fact:"
        let funFacts = lines
            .filter { $0.trimmingCharacters(in: .whitespaces).hasPrefix("Fun Fact:") }
            .map { $0.replacingOccurrences(of: "Fun Fact:", with: "").trimmingCharacters(in: .whitespaces) }

        // Content: everything between title and fun facts
        let funFactStartIndex = lines.firstIndex(where: {
            $0.trimmingCharacters(in: .whitespaces).hasPrefix("Fun Fact:")
        }) ?? lines.endIndex

        let titleEndIndex = lines.firstIndex(where: {
            !$0.trimmingCharacters(in: .whitespaces).isEmpty
        }).map { $0 + 1 } ?? 1

        let contentLines = lines[titleEndIndex..<funFactStartIndex]
        let content = contentLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)

        // Estimate reading time: ~200 words per minute
        let wordCount = content.split(separator: " ").count
        let readingTime = max(1, wordCount / 200)

        // Pick 2-3 related topics from the same category
        let relatedTopics = CapeCodStoryTopic.allCases
            .filter { $0.storyCategory == topic.storyCategory && $0 != topic }
            .shuffled()
            .prefix(3)

        return GeneratedStory(
            title: title,
            content: content,
            readingTime: readingTime,
            topic: topic,
            mode: mode,
            relatedTopics: Array(relatedTopics),
            funFacts: funFacts
        )
    }

    // MARK: - Persistence

    private func persistStories() {
        let encoder = JSONEncoder()
        if let recentData = try? encoder.encode(recentStories) {
            UserDefaults.standard.set(recentData, forKey: Self.recentStoriesKey)
        }
        if let favData = try? encoder.encode(favoriteStories) {
            UserDefaults.standard.set(favData, forKey: Self.favoriteStoriesKey)
        }
    }

    private func loadPersistedStories() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: Self.recentStoriesKey),
           let stories = try? decoder.decode([GeneratedStory].self, from: data) {
            recentStories = stories
        }
        if let data = UserDefaults.standard.data(forKey: Self.favoriteStoriesKey),
           let stories = try? decoder.decode([GeneratedStory].self, from: data) {
            favoriteStories = stories
        }
    }
}

// MARK: - TellMeAStoryView

/// Main view for the "Tell Me a Story About..." feature.
/// Presents a grid of Cape Cod topics organized by category, with experience mode
/// selection, search filtering, recent stories, and favorites.
struct TellMeAStoryView: View {
    @State private var storyService = StoryGeneratorService()
    @State private var selectedMode: ExperienceMode = UserProfileManager.shared.currentProfile?.experienceMode ?? .family
    @State private var searchText = ""
    @State private var selectedStory: GeneratedStory?
    @State private var showLoadingView = false
    @State private var pendingTopic: CapeCodStoryTopic?
    @State private var headerAnimated = false

    @Environment(\.dismiss) private var dismiss

    private var filteredTopics: [CapeCodStoryTopic] {
        if searchText.isEmpty {
            return CapeCodStoryTopic.allCases
        }
        let query = searchText.lowercased()
        return CapeCodStoryTopic.allCases.filter {
            $0.displayName.lowercased().contains(query)
            || $0.teaser.lowercased().contains(query)
            || $0.categoryLabel.lowercased().contains(query)
        }
    }

    private var groupedTopics: [(String, [CapeCodStoryTopic])] {
        let grouped = Dictionary(grouping: filteredTopics, by: { $0.categoryLabel })
        let order = ["History", "Nature", "Maritime", "Legend", "Culture", "Seasonal"]
        return order.compactMap { key in
            guard let topics = grouped[key], !topics.isEmpty else { return nil }
            return (key, topics)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                headerSection
                modeSelector
                searchBar

                if !storyService.recentStories.isEmpty {
                    recentStoriesSection
                }

                if !storyService.favoriteStories.isEmpty {
                    favoritesSection
                }

                surpriseMeButton

                topicGridSections

                Spacer(minLength: CodSpacing.tabBarClearance)
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
        .background(Color.capeCod.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedStory) { story in
            StoryReadingView(
                story: story,
                storyService: storyService
            )
        }
        .sheet(isPresented: $showLoadingView) {
            if let topic = pendingTopic {
                StoryLoadingView(
                    topic: topic,
                    mode: selectedMode,
                    storyService: storyService,
                    onStoryReady: { story in
                        showLoadingView = false
                        pendingTopic = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            selectedStory = story
                        }
                    },
                    onCancel: {
                        showLoadingView = false
                        pendingTopic = nil
                        storyService.reset()
                    }
                )
                .interactiveDismissDisabled()
            }
        }
        .onAppear {
            withAnimation(CodAnimation.gentle) {
                headerAnimated = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CodSpacing.md) {
            ZStack {
                Image(systemName: "book.and.wreath.fill")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(Color.capeCod.oceanGradient)
                    .scaleEffect(headerAnimated ? 1.0 : 0.8)
                    .opacity(headerAnimated ? 1.0 : 0)

                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.capeCod.sunsetOrange)
                    .offset(x: 32, y: -24)
                    .scaleEffect(headerAnimated ? 1.0 : 0.0)
                    .opacity(headerAnimated ? 1.0 : 0)
            }
            .codAccessibleHidden()

            Text("Tell Me a Story About...")
                .codTextStyle(.heroTitle)
                .multilineTextAlignment(.center)
                .codAccessibleHeader("Tell Me a Story About")

            Text("Pick a Cape Cod topic and let AI craft a story just for you")
                .codTextStyle(.subtitle)
                .multilineTextAlignment(.center)
        }
        .padding(.top, CodSpacing.lg)
    }

    // MARK: - Mode Selector

    private var modeSelector: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("WHO'S LISTENING?")
                .codTextStyle(.label)

            HStack(spacing: CodSpacing.sm) {
                ForEach(ExperienceMode.allCases) { mode in
                    modePill(mode)
                }
            }
        }
        .codAccessible(label: "Experience mode selector", hint: "Choose who the story is for")
    }

    private func modePill(_ mode: ExperienceMode) -> some View {
        Button {
            withAnimation(CodAnimation.quick) {
                selectedMode = mode
            }
            CodHaptic.selection()
        } label: {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: modeIcon(mode))
                    .font(.system(size: 12))
                Text(mode.displayName)
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(.horizontal, CodSpacing.md)
            .padding(.vertical, CodSpacing.sm + 2)
            .foregroundStyle(selectedMode == mode ? .white : Color.capeCod.textPrimary)
            .background(
                selectedMode == mode
                    ? AnyShapeStyle(Color.capeCod.oceanGradient)
                    : AnyShapeStyle(Color.capeCod.surface)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleButton(
            "\(mode.displayName) mode",
            hint: selectedMode == mode ? "Currently selected" : "Tap to select"
        )
    }

    private func modeIcon(_ mode: ExperienceMode) -> String {
        switch mode {
        case .kids: "face.smiling"
        case .teen: "person.fill"
        case .adult: "eyeglasses"
        case .family: "figure.2.and.child.holdinghands"
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.capeCod.textSecondary)
                .font(.system(size: 15))

            TextField("Search topics...", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(Color.capeCod.textPrimary)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.capeCod.textSecondary)
                }
                .codAccessibleButton("Clear search")
            }
        }
        .padding(.horizontal, CodSpacing.md)
        .padding(.vertical, CodSpacing.sm + 2)
        .background(Color.capeCod.surface)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
        .codAccessible(label: "Search topics", hint: "Type to filter story topics")
    }

    // MARK: - Surprise Me

    private var surpriseMeButton: some View {
        CodButton(
            "Surprise Me!",
            variant: .accent,
            icon: "dice.fill",
            isFullWidth: true
        ) {
            guard let randomTopic = CapeCodStoryTopic.allCases.randomElement() else { return }
            CodHaptic.tap()
            startStoryGeneration(topic: randomTopic)
        }
        .codAccessibleButton("Surprise Me", hint: "Generate a story about a random Cape Cod topic")
    }

    // MARK: - Recent Stories Section

    private var recentStoriesSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Recent Stories")
                .codTextStyle(.sectionTitle)
                .codAccessibleHeader("Recent Stories")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.md) {
                    ForEach(Array(storyService.recentStories.prefix(8).enumerated()), id: \.element.id) { index, story in
                        recentStoryCard(story)
                            .staggered(index: index)
                    }
                }
            }
        }
    }

    private func recentStoryCard(_ story: GeneratedStory) -> some View {
        Button {
            CodHaptic.light()
            selectedStory = story
        } label: {
            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                HStack(spacing: CodSpacing.xs) {
                    Image(systemName: story.topic.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(story.topic.categoryColor)
                    Text(story.topic.categoryLabel)
                        .codTextStyle(.label)
                        .foregroundStyle(story.topic.categoryColor)
                }

                Text(story.title)
                    .codTextStyle(.cardTitle)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: CodSpacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text("\(story.readingTime) min")
                        .font(.system(size: 11))
                }
                .foregroundStyle(Color.capeCod.textSecondary)
            }
            .padding(CodSpacing.cardPadding)
            .frame(width: 180, alignment: .leading)
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleCard(label: story.title, hint: "Tap to read this story")
    }

    // MARK: - Favorites Section

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack {
                Text("Favorites")
                    .codTextStyle(.sectionTitle)
                    .codAccessibleHeader("Favorites")
                Spacer()
                Image(systemName: "heart.fill")
                    .foregroundStyle(Color.capeCod.cranberry)
                    .codAccessibleHidden()
            }

            ForEach(Array(storyService.favoriteStories.prefix(5).enumerated()), id: \.element.id) { index, story in
                Button {
                    CodHaptic.light()
                    selectedStory = story
                } label: {
                    HStack(spacing: CodSpacing.md) {
                        Image(systemName: story.topic.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(story.topic.categoryColor)
                            .frame(width: 40, height: 40)
                            .background(story.topic.categoryColor.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))

                        VStack(alignment: .leading, spacing: CodSpacing.xs) {
                            Text(story.title)
                                .codTextStyle(.cardTitle)
                                .lineLimit(1)
                            Text(story.mode.displayName + " \u{2022} \(story.readingTime) min read")
                                .codTextStyle(.caption)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.capeCod.textSecondary)
                    }
                    .padding(CodSpacing.cardPadding)
                    .background(Color.capeCod.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
                    .adaptiveCardStyle()
                }
                .buttonStyle(CodButtonPressStyle(variant: .ghost))
                .staggered(index: index)
                .codAccessibleCard(label: story.title, hint: "Tap to read this favorite story")
            }
        }
    }

    // MARK: - Topic Grid Sections

    private var topicGridSections: some View {
        VStack(spacing: CodSpacing.sectionSpacing) {
            ForEach(groupedTopics, id: \.0) { categoryName, topics in
                VStack(alignment: .leading, spacing: CodSpacing.md) {
                    HStack(spacing: CodSpacing.sm) {
                        if let first = topics.first {
                            Image(systemName: first.storyCategory.icon)
                                .foregroundStyle(first.categoryColor)
                        }
                        Text(categoryName)
                            .codTextStyle(.sectionTitle)
                            .codAccessibleHeader(categoryName)
                    }

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: CodSpacing.md),
                            GridItem(.flexible(), spacing: CodSpacing.md)
                        ],
                        spacing: CodSpacing.md
                    ) {
                        ForEach(Array(topics.enumerated()), id: \.element.id) { index, topic in
                            StoryTopicCard(topic: topic) {
                                startStoryGeneration(topic: topic)
                            }
                            .staggered(index: index)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func startStoryGeneration(topic: CapeCodStoryTopic) {
        pendingTopic = topic
        showLoadingView = true
    }
}

// MARK: - StoryTopicCard

/// A tappable card for a single story topic, with category-colored accent,
/// icon, title, and teaser text.
struct StoryTopicCard: View {
    let topic: CapeCodStoryTopic
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            CodHaptic.light()
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: topic.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(topic.categoryColor)

                    Spacer()

                    Text(topic.categoryLabel)
                        .font(.system(size: 10, weight: .semibold))
                        .textCase(.uppercase)
                        .tracking(0.8)
                        .foregroundStyle(topic.categoryColor)
                        .padding(.horizontal, CodSpacing.sm)
                        .padding(.vertical, CodSpacing.xs)
                        .background(topic.categoryColor.opacity(0.12))
                        .clipShape(Capsule())
                }

                Text(topic.displayName)
                    .codTextStyle(.cardTitle)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(topic.teaser)
                    .codTextStyle(.caption)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(CodSpacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(topic.categoryColor)
                    .frame(width: 3)
                    .padding(.vertical, CodSpacing.sm)
            }
            .adaptiveCardStyle()
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleCard(
            label: "\(topic.displayName). \(topic.categoryLabel) story.",
            hint: "Tap to generate a story about \(topic.displayName)"
        )
    }
}

// MARK: - StoryLoadingView

/// Shown while AI generates a story. Displays animated book icon,
/// rotating Cape Cod fun facts, and a cancel button.
struct StoryLoadingView: View {
    let topic: CapeCodStoryTopic
    let mode: ExperienceMode
    let storyService: StoryGeneratorService
    let onStoryReady: (GeneratedStory) -> Void
    let onCancel: () -> Void

    @State private var factIndex = 0
    @State private var bookPulse = false
    @State private var sparkleRotation: Double = 0

    @Environment(\.dismiss) private var dismiss

    private let funFacts: [String] = [
        "Cape Cod was formed by glaciers over 20,000 years ago.",
        "The Cape Cod Canal is the widest sea-level canal in the world.",
        "Provincetown was the Pilgrims' first landing place in 1620.",
        "Cape Cod has over 130 named beaches.",
        "The pirate ship Whydah sank off Wellfleet in 1717.",
        "Chatham's seal population grew from hundreds to thousands since the 1990s.",
        "Marconi sent the first transatlantic wireless message from Wellfleet in 1903.",
        "Cape Cod produces about 2 million barrels of cranberries each year.",
        "The Cape has 10 historic lighthouses still standing.",
        "Henry David Thoreau walked the entire length of Cape Cod in the 1850s.",
        "The Kennedy Compound in Hyannis Port has been in the family since 1928.",
        "Cape Cod's official fish is the Atlantic cod, which gave the Cape its name.",
    ]

    var body: some View {
        ZStack {
            Color.capeCod.deepNavy.ignoresSafeArea()

            VStack(spacing: CodSpacing.xl) {
                Spacer()

                // Animated book icon
                ZStack {
                    Circle()
                        .fill(Color.capeCod.oceanBlue.opacity(0.15))
                        .frame(width: 160, height: 160)
                        .scaleEffect(bookPulse ? 1.15 : 0.95)

                    Circle()
                        .fill(Color.capeCod.oceanBlue.opacity(0.08))
                        .frame(width: 200, height: 200)
                        .scaleEffect(bookPulse ? 1.1 : 0.9)

                    Image(systemName: "book.fill")
                        .font(.system(size: 52, weight: .light))
                        .foregroundStyle(.white)
                        .scaleEffect(bookPulse ? 1.05 : 0.95)

                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.capeCod.sunsetOrange)
                        .offset(x: 40, y: -35)
                        .rotationEffect(.degrees(sparkleRotation))
                }
                .codAccessibleHidden()

                VStack(spacing: CodSpacing.md) {
                    Text("Crafting your story...")
                        .codTextStyle(.sectionTitle)
                        .foregroundStyle(.white)

                    Text("about \(topic.displayName)")
                        .codTextStyle(.subtitle)
                        .foregroundStyle(.white.opacity(0.6))
                }

                // Progress indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.capeCod.seafoam))
                    .scaleEffect(1.2)

                Spacer()

                // Rotating fun facts
                VStack(spacing: CodSpacing.sm) {
                    Text("DID YOU KNOW?")
                        .codTextStyle(.label)
                        .foregroundStyle(Color.capeCod.seafoam)

                    Text(funFacts[factIndex])
                        .codTextStyle(.body)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .frame(minHeight: 44)
                        .id(factIndex)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .animation(CodAnimation.spring, value: factIndex)
                }
                .padding(.horizontal, CodSpacing.xl)

                Spacer()

                // Cancel button
                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.vertical, CodSpacing.md)
                        .frame(maxWidth: .infinity)
                }
                .codAccessibleButton("Cancel story generation")
                .padding(.bottom, CodSpacing.lg)
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
        .onAppear {
            withAnimation(CodAnimation.pulse) {
                bookPulse = true
            }
            withAnimation(CodAnimation.orbit) {
                sparkleRotation = 360
            }
            startFactRotation()
            startGeneration()
        }
    }

    private func startFactRotation() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { timer in
            Task { @MainActor in
                guard storyService.generationState == .generating else {
                    timer.invalidate()
                    return
                }
                withAnimation {
                    factIndex = (factIndex + 1) % funFacts.count
                }
            }
        }
    }

    private func startGeneration() {
        Task {
            await storyService.generateStory(topic: topic, mode: mode)

            switch storyService.generationState {
            case .complete(let story):
                CodHaptic.success()
                onStoryReady(story)
            case .error:
                CodHaptic.error()
                // Stay on screen; user can see the cancel button
            default:
                break
            }
        }
    }
}

// MARK: - StoryReadingView

/// Full-screen reading experience for a generated story.
/// Features typewriter text reveal, reading progress, fun facts,
/// related stories, share, favorite, read aloud, and adjustable text size.
struct StoryReadingView: View {
    let story: GeneratedStory
    let storyService: StoryGeneratorService

    @Environment(\.dismiss) private var dismiss

    @State private var revealedWordCount = 0
    @State private var readingProgress: CGFloat = 0
    @State private var showFunFacts = false
    @State private var isFavorite: Bool
    @State private var isReadingAloud = false
    @State private var textSizeIndex = 1 // 0=small, 1=medium, 2=large
    @State private var showShareSheet = false

    private let synthesizer = AVSpeechSynthesizer()
    private let words: [String]
    private let totalWords: Int

    private var textSizeMultiplier: CGFloat {
        switch textSizeIndex {
        case 0: 0.85
        case 2: 1.2
        default: 1.0
        }
    }

    private var textSizeLabel: String {
        switch textSizeIndex {
        case 0: "Small"
        case 2: "Large"
        default: "Medium"
        }
    }

    init(story: GeneratedStory, storyService: StoryGeneratorService) {
        self.story = story
        self.storyService = storyService
        self.words = story.content.components(separatedBy: .whitespaces)
        self.totalWords = story.content.components(separatedBy: .whitespaces).count
        self._isFavorite = State(initialValue: storyService.isFavorite(story))
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Color.capeCod.deepNavy.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.capeCod.oceanGradient)
                        .frame(width: geo.size.width * readingProgress, height: 3)
                }
                .frame(height: 3)
                .codAccessible(label: "Reading progress: \(Int(readingProgress * 100)) percent")

                // Top bar
                topBar

                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: CodSpacing.lg) {
                        storyHeader
                        storyContent
                        if !story.funFacts.isEmpty { funFactsSection }
                        if !story.relatedTopics.isEmpty { relatedTopicsSection }
                        Spacer(minLength: CodSpacing.xxl)
                    }
                    .padding(.horizontal, CodSpacing.screenEdge)
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: ScrollOffsetKey.self,
                                value: geo.frame(in: .named("storyScroll")).minY
                            )
                        }
                    )
                }
                .coordinateSpace(name: "storyScroll")
                .onPreferenceChange(ScrollOffsetKey.self) { offset in
                    // Estimate progress based on scroll position
                    let totalHeight = CGFloat(totalWords) * 2.0 // rough estimate
                    let scrolled = -offset
                    readingProgress = min(1.0, max(0, scrolled / max(totalHeight, 1)))
                }
            }
        }
        .onAppear {
            startTypewriterEffect()
        }
        .onDisappear {
            synthesizer.stopSpeaking(at: .immediate)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetWrapper(items: ["\(story.title)\n\n\(story.content)"])
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .codAccessibleButton("Close")

            Spacer()

            // Text size control
            Menu {
                ForEach(0..<3, id: \.self) { index in
                    Button {
                        withAnimation(CodAnimation.quick) { textSizeIndex = index }
                    } label: {
                        HStack {
                            Text(["Small", "Medium", "Large"][index])
                            if textSizeIndex == index {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "textformat.size")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .codAccessibleButton("Text size: \(textSizeLabel)")

            // Share button
            Button {
                showShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .codAccessibleButton("Share story")

            // Favorite toggle
            Button {
                withAnimation(CodAnimation.bouncy) {
                    isFavorite.toggle()
                }
                storyService.toggleFavorite(story)
                CodHaptic.tap()
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isFavorite ? Color.capeCod.cranberry : .white.opacity(0.5))
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .codAccessibleButton(isFavorite ? "Remove from favorites" : "Add to favorites")
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.vertical, CodSpacing.sm)
    }

    // MARK: - Story Header

    private var storyHeader: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: story.topic.icon)
                    .font(.system(size: 12))
                    .foregroundStyle(story.topic.categoryColor)
                Text(story.topic.categoryLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundStyle(story.topic.categoryColor)

                Spacer()

                HStack(spacing: CodSpacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text("\(story.readingTime) min read")
                        .font(.system(size: 11))
                }
                .foregroundStyle(.white.opacity(0.4))
            }

            Text(story.title)
                .font(.system(size: 28 * textSizeMultiplier, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .lineSpacing(4)

            HStack(spacing: CodSpacing.sm) {
                Text(story.mode.displayName + " Edition")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.horizontal, CodSpacing.sm)
                    .padding(.vertical, CodSpacing.xs)
                    .background(.white.opacity(0.08))
                    .clipShape(Capsule())

                // Read aloud button
                Button {
                    toggleReadAloud()
                } label: {
                    HStack(spacing: CodSpacing.xs) {
                        Image(systemName: isReadingAloud ? "stop.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 11))
                        Text(isReadingAloud ? "Stop" : "Read Aloud")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(isReadingAloud ? Color.capeCod.sunsetOrange : .white.opacity(0.5))
                    .padding(.horizontal, CodSpacing.sm)
                    .padding(.vertical, CodSpacing.xs)
                    .background(
                        isReadingAloud
                            ? Color.capeCod.sunsetOrange.opacity(0.15)
                            : .white.opacity(0.08)
                    )
                    .clipShape(Capsule())
                }
                .codAccessibleButton(isReadingAloud ? "Stop reading aloud" : "Read story aloud")
            }

            Divider()
                .background(.white.opacity(0.1))
        }
        .padding(.top, CodSpacing.md)
    }

    // MARK: - Story Content (Typewriter Effect)

    private var storyContent: some View {
        let visibleText: String = {
            if revealedWordCount >= totalWords {
                return story.content
            }
            return words.prefix(revealedWordCount).joined(separator: " ")
        }()

        return Text(visibleText)
            .font(.system(size: 17 * textSizeMultiplier, weight: .regular, design: .serif))
            .lineSpacing(17 * textSizeMultiplier * 0.5)
            .foregroundStyle(Color(hex: 0xF0EDE8))
            .codAccessible(label: "Story content", hint: "")
    }

    // MARK: - Fun Facts

    private var funFactsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Button {
                withAnimation(CodAnimation.spring) {
                    showFunFacts.toggle()
                }
                CodHaptic.selection()
            } label: {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(Color.capeCod.sandbarYellow)
                    Text("Fun Facts")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: showFunFacts ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(CodSpacing.cardPadding)
                .background(.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            }
            .codAccessibleButton(
                "Fun Facts",
                hint: showFunFacts ? "Tap to collapse" : "Tap to expand"
            )

            if showFunFacts {
                VStack(alignment: .leading, spacing: CodSpacing.md) {
                    ForEach(Array(story.funFacts.enumerated()), id: \.offset) { index, fact in
                        HStack(alignment: .top, spacing: CodSpacing.sm) {
                            Text("\(index + 1).")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.capeCod.sandbarYellow)
                                .frame(width: 20, alignment: .trailing)

                            Text(fact)
                                .font(.system(size: 14 * textSizeMultiplier, weight: .regular))
                                .foregroundStyle(.white.opacity(0.75))
                                .lineSpacing(4)
                        }
                        .staggered(index: index)
                    }
                }
                .padding(.horizontal, CodSpacing.sm)
                .transition(.codSlideUp)
            }
        }
        .padding(.top, CodSpacing.lg)
    }

    // MARK: - Related Topics

    private var relatedTopicsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("CONTINUE EXPLORING")
                .codTextStyle(.label)
                .foregroundStyle(.white.opacity(0.4))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.sm) {
                    ForEach(story.relatedTopics) { relatedTopic in
                        Button {
                            CodHaptic.light()
                            dismiss()
                        } label: {
                            HStack(spacing: CodSpacing.sm) {
                                Image(systemName: relatedTopic.icon)
                                    .font(.system(size: 14))
                                    .foregroundStyle(relatedTopic.categoryColor)
                                Text(relatedTopic.displayName)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, CodSpacing.md)
                            .padding(.vertical, CodSpacing.sm + 2)
                            .background(.white.opacity(0.08))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(CodButtonPressStyle(variant: .ghost))
                        .codAccessibleButton(relatedTopic.displayName, hint: "Story about \(relatedTopic.displayName)")
                    }
                }
            }
        }
        .padding(.top, CodSpacing.md)
    }

    // MARK: - Typewriter Effect

    private func startTypewriterEffect() {
        let interval: TimeInterval = 0.02
        var count = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            Task { @MainActor in
                count += 1
                revealedWordCount = count
                if count >= totalWords {
                    timer.invalidate()
                }
            }
        }
    }

    // MARK: - Read Aloud (AVSpeechSynthesizer)

    private func toggleReadAloud() {
        if isReadingAloud {
            synthesizer.stopSpeaking(at: .immediate)
            isReadingAloud = false
        } else {
            let utterance = AVSpeechUtterance(string: story.content)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            utterance.pitchMultiplier = 1.0
            utterance.preUtteranceDelay = 0.3
            synthesizer.speak(utterance)
            isReadingAloud = true
        }
        CodHaptic.tap()
    }
}

// MARK: - ScrollOffsetKey

private struct ScrollOffsetKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - ShareSheetWrapper

/// UIKit share sheet wrapped for SwiftUI presentation.
private struct ShareSheetWrapper: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Previews

#Preview("Tell Me a Story") {
    NavigationStack {
        TellMeAStoryView()
    }
}

#Preview("Story Topic Card") {
    VStack(spacing: CodSpacing.md) {
        StoryTopicCard(topic: .pirates) {}
        StoryTopicCard(topic: .whales) {}
        StoryTopicCard(topic: .cranberryBogs) {}
    }
    .padding(CodSpacing.screenEdge)
    .background(Color.capeCod.background)
}

#Preview("Story Reading View") {
    StoryReadingView(
        story: GeneratedStory(
            title: "The Pirates of Cape Cod",
            content: """
            The year was 1717, and the waters off Cape Cod were about to witness one of the most \
            dramatic chapters in pirate history. Samuel "Black Sam" Bellamy, the youngest and most \
            daring pirate captain of his era, was sailing northward aboard the Whydah Gally, \
            a captured slave ship he had converted into his fearsome flagship.

            The Whydah was loaded with treasure from over fifty captured vessels -- gold, silver, \
            indigo, and ivory worth millions in today's currency. Bellamy commanded a crew of 146 \
            men, a diverse group that included former slaves, Native Americans, and European sailors \
            who had chosen the pirate's democratic way of life over the rigid hierarchies of the \
            Royal Navy.

            As a nor'easter bore down on the Cape, Bellamy pressed on. Some say he was driven by \
            love -- that he was racing to see Maria Hallett, the young woman from Wellfleet who \
            had stolen his heart. Others say it was simply the arrogance of a man who believed \
            himself invincible on the sea.

            The storm struck with devastating fury. The Whydah, heavy with plunder, was caught \
            in mountainous waves off what is now Marconi Beach in Wellfleet. At around midnight \
            on April 26, 1717, the ship capsized and broke apart. Of the 146 men aboard, only \
            two survived -- Thomas Davis, a Welsh carpenter, and John Julian, a Miskito Indian \
            who had been Bellamy's pilot.

            For nearly three centuries, the Whydah lay buried beneath the shifting sands of \
            Cape Cod. Then, in 1984, underwater explorer Barry Clifford discovered the wreck. \
            It was the first authenticated pirate shipwreck ever found, and the artifacts \
            recovered -- now displayed at the Whydah Pirate Museum in Yarmouth -- tell the \
            remarkable story of life aboard a pirate ship.
            """,
            readingTime: 5,
            topic: .pirates,
            mode: .adult,
            relatedTopics: [.shipwrecks, .mariaHallett, .lifesavers],
            funFacts: [
                "The Whydah carried over 4.5 tons of gold and silver when it sank.",
                "Black Sam Bellamy was only 28 years old when he died in the shipwreck.",
                "The Whydah was originally a slave ship captured by Bellamy near Cuba.",
            ]
        ),
        storyService: StoryGeneratorService()
    )
}

#Preview("Story Loading View") {
    StoryLoadingView(
        topic: .pirates,
        mode: .family,
        storyService: StoryGeneratorService(),
        onStoryReady: { _ in },
        onCancel: {}
    )
}
