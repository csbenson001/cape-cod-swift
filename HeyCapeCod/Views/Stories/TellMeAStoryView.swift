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

    // Legends & Haunted
    case ladyOfTheDunes
    case mooncussers
    case widowsWalkGhosts
    case mariaHallett
    case hauntedInns
    case ghostShips
    case deadMansHollow

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
        case .hauntedInns: "Haunted Inns & Taverns"
        case .ghostShips: "Ghost Ships in the Fog"
        case .deadMansHollow: "Dead Man's Hollow"
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
        case .whales: "binoculars.fill"
        case .seals: "pawprint.fill"
        case .greatWhiteSharks: "bolt.trianglebadge.exclamationmark.fill"
        case .pipingPlovers: "bird.fill"
        case .saltMarshes: "humidity.fill"
        case .pirates: "flag.2.crossed.fill"
        case .shipwrecks: "exclamationmark.triangle.fill"
        case .lifesavers: "lifepreserver.fill"
        case .fishingBoats: "ferry.fill"
        case .harborPilots: "helm.fill"
        case .ladyOfTheDunes: "questionmark.circle.fill"
        case .mooncussers: "moon.stars.fill"
        case .widowsWalkGhosts: "house.fill"
        case .mariaHallett: "wind"
        case .hauntedInns: "building.2.fill"
        case .ghostShips: "cloud.fog.fill"
        case .deadMansHollow: "eye.trianglebadge.exclamationmark.fill"
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
        case .hauntedInns: "Restless spirits roam Cape Cod's oldest inns and taverns after dark."
        case .ghostShips: "Phantom vessels that appear in the fog, crewed by the long-dead."
        case .deadMansHollow: "A lonely stretch of road where shadows move and voices whisper."
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
        case .ladyOfTheDunes, .mooncussers, .widowsWalkGhosts, .mariaHallett, .hauntedInns, .ghostShips, .deadMansHollow:
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
            // Backend unavailable — use a pre-written fallback story
            print("⚠️ AI backend unavailable (\(error.localizedDescription)), using fallback story")
            let fallback = Self.fallbackStory(for: topic, mode: mode)
            generationState = .complete(fallback)

            recentStories.insert(fallback, at: 0)
            if recentStories.count > 20 {
                recentStories = Array(recentStories.prefix(20))
            }
            persistStories()
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

    // MARK: - Fallback Stories

    /// Pre-written stories for when the AI backend is unavailable.
    static func fallbackStory(for topic: CapeCodStoryTopic, mode: ExperienceMode) -> GeneratedStory {
        let (title, content, funFacts) = fallbackContent(for: topic)
        let wordCount = content.split(separator: " ").count
        let relatedTopics = CapeCodStoryTopic.allCases
            .filter { $0.storyCategory == topic.storyCategory && $0 != topic }
            .shuffled()
            .prefix(3)

        return GeneratedStory(
            title: title,
            content: content,
            readingTime: max(1, wordCount / 200),
            topic: topic,
            mode: mode,
            relatedTopics: Array(relatedTopics),
            funFacts: funFacts
        )
    }

    private static func fallbackContent(for topic: CapeCodStoryTopic) -> (title: String, content: String, funFacts: [String]) {
        switch topic {
        case .revolution:
            return (
                "When Cape Cod Defied a King",
                """
                Long before the famous shots at Lexington and Concord, the people of Cape Cod were already stirring with the spirit of independence. In the salt-weathered towns along the narrow peninsula, fishermen and farmers quietly debated the future of the colonies in their gray-shingled meetinghouses.

                In December 1773, when the news of the Boston Tea Party reached the Cape, the towns erupted in celebration. But Cape Codders had their own tea party to remember. In Provincetown, a cargo of British tea aboard the ship was seized and destroyed by local patriots who refused to let the Crown profit from their harbor.

                Barnstable, the Cape's largest town, became a hotbed of revolutionary activity. The county courthouse saw heated debates between Loyalists and Patriots, with families sometimes divided against each other. James Otis Jr., born in West Barnstable, had already lit the fuse of revolution with his famous speech against the Writs of Assistance in 1761, declaring "a man's house is his castle."

                The Cape's strategic position made it a target throughout the war. British warships patrolled the waters, raiding coastal towns for supplies and intimidating the population. In 1779, the British attacked Falmouth (now part of Bourne), burning boats and stealing livestock. The town militia fought back with what little they had, firing muskets from behind stone walls and sand dunes.

                Perhaps the most dramatic Cape Cod moment came when the British frigate HMS Somerset ran aground off Provincetown during a fierce nor'easter in November 1778. The mighty warship, which had guarded the British fleet at Bunker Hill, was now at the mercy of the Cape's treacherous shoals. Local militia captured the crew of over 400 sailors, marching them inland as prisoners of war. The wreck of the Somerset still occasionally reveals itself in the shifting sands of the Outer Cape.

                The women of Cape Cod played vital roles during the war years. With their husbands away fighting or at sea, they managed farms, ran businesses, and organized supplies for the Continental Army. They melted pewter spoons into musket balls and knitted stockings for soldiers enduring bitter winters.

                By war's end, Cape Cod had given much to the cause of independence. Its harbors had sheltered privateers who harassed British shipping, its sons had fought in battles from Bunker Hill to Yorktown, and its communities had endured years of hardship and sacrifice. The spirit of independence that began in those salt-air meetinghouses had helped forge a new nation.
                """,
                [
                    "James Otis Jr. of West Barnstable is considered one of the earliest advocates for American independence.",
                    "The HMS Somerset, a 64-gun warship, wrecked off Provincetown in 1778 and its timbers still emerge from the sand.",
                    "Cape Cod privateers captured over 30 British vessels during the Revolutionary War."
                ]
            )

        case .pilgrims:
            return (
                "First Steps on a Sandy Shore",
                """
                The story most Americans know begins at Plymouth Rock, but the real first chapter of the Pilgrim saga unfolded on the windswept tip of Cape Cod. On November 11, 1620, after 66 grueling days at sea, the Mayflower dropped anchor in what is now Provincetown Harbor.

                The Pilgrims were exhausted, seasick, and far north of their intended destination in Virginia. But as they gazed at the curving arm of Cape Cod embracing the harbor, they must have felt a surge of relief. Here was shelter from the open Atlantic, a protected anchorage, and land — even if it was nothing like the gentle English countryside they'd left behind.

                Before anyone set foot ashore, the passengers gathered in the ship's cramped quarters to sign the Mayflower Compact, a remarkable document that established self-governance by consent of the governed. It was, in many ways, the seed from which American democracy would grow.

                The women waded ashore first — not for ceremony, but for laundry. Weeks of accumulated dirty clothes needed washing, and the fresh water they found near the shore was a blessing. Meanwhile, the men explored the dunes and scrubby forests of the Outer Cape, discovering buried caches of corn that the Wampanoag people had stored for winter.

                For five weeks, the Pilgrims explored Cape Cod, sending out scouting parties by shallop along the coast. They encountered the Nauset people near present-day Eastham, a meeting that ended in a brief skirmish known as the "First Encounter." The beach where this happened is still called First Encounter Beach today.

                Eventually, the Pilgrims decided that Provincetown's sandy soil couldn't sustain a farming colony, and they sailed across the bay to Plymouth. But Cape Cod had given them their first American home, their first taste of freedom, and the foundation of self-governance that would shape a nation.
                """,
                [
                    "The Pilgrims spent five weeks on Cape Cod before settling in Plymouth.",
                    "The Mayflower Compact was signed in Provincetown Harbor on November 11, 1620.",
                    "First Encounter Beach in Eastham marks the site of the Pilgrims' first encounter with the Nauset people."
                ]
            )

        case .saltMarshes:
            return (
                "The Living Marshes of Cape Cod",
                """
                At the edges of Cape Cod's harbors and inlets, where the land meets the sea in a gentle, blurred boundary, lie the salt marshes — one of the most productive ecosystems on Earth. These vast meadows of cordgrass and salt hay may look like simple fields of waving green, but they are teeming with life and vital to the Cape's ecology.

                Walk along the marsh at low tide and you'll see the intricate network of tidal creeks that wind through the grass like veins through a leaf. These channels carry the ocean's nutrients deep into the marsh with each tide, feeding an explosion of microscopic life that forms the base of the entire coastal food web.

                The Wampanoag people knew the marshes intimately. They harvested shellfish from the muddy creek beds, hunted waterfowl that nested in the tall grass, and gathered salt hay for insulation and animal feed. The marshes were a supermarket of the natural world.

                Early Cape Cod settlers quickly recognized the value of salt marsh hay. Unlike upland grass, it didn't need to be planted or tended — the tides did all the work. Farmers would row out to the marsh islands at low tide, cut the hay with scythes, and stack it on wooden staddles to keep it above the high water. Salt hay was so valuable that marsh rights were carefully recorded in town deeds, sometimes causing disputes that lasted generations.

                Today, scientists understand that salt marshes are among the most important habitats on the Cape. They act as natural storm buffers, absorbing wave energy that would otherwise erode the shoreline. They filter pollutants from runoff before it reaches the harbor. They serve as nurseries for fish, crabs, and shrimp — the young of countless species spend their earliest days hiding among the grass stems.

                The marshes also store enormous amounts of carbon, making them crucial allies in the fight against climate change. Acre for acre, salt marshes sequester more carbon than tropical rainforests. When we lose a marsh to development or sea-level rise, all that stored carbon returns to the atmosphere.

                Stand at the edge of a Cape Cod salt marsh at sunset, when the golden light turns the cordgrass to amber and a great blue heron stalks through the shallows, and you're witnessing a scene that has played out for thousands of years. The marsh doesn't hurry. It breathes with the tides, grows with the seasons, and endures.
                """,
                [
                    "Salt marshes can store up to ten times more carbon per acre than tropical forests.",
                    "A single acre of salt marsh can produce up to ten tons of organic matter per year.",
                    "Cape Cod's salt marshes provide nursery habitat for over 75% of the region's commercial fish species."
                ]
            )

        case .whales:
            return (
                "Giants of Stellwagen Bank",
                """
                Every spring, one of nature's greatest spectacles begins just a few miles off the tip of Cape Cod. Humpback whales, some weighing up to 40 tons, arrive at Stellwagen Bank after a journey of more than a thousand miles from their winter breeding grounds in the Caribbean.

                Stellwagen Bank is an underwater plateau about six miles north of Provincetown, stretching roughly 19 miles between Cape Cod and Cape Ann. This submerged mesa rises from the surrounding seafloor, forcing cold, nutrient-rich water upward in a process called upwelling. The result is an explosion of plankton, which attracts vast schools of sand lance, herring, and mackerel — a feast that draws whales from across the Atlantic.

                Humpback whales are the stars of Cape Cod's whale watching industry, and for good reason. They are acrobats of the ocean, breaching clear of the water in spectacular displays that send spray flying thirty feet into the air. They slap their massive tail flukes on the surface, a behavior called lobtailing, and they spy-hop — rising vertically to peer above the waves with one curious eye.

                Perhaps most remarkable is their feeding technique called bubble-net feeding. A group of humpbacks will dive beneath a school of fish and swim in tightening circles, blowing streams of bubbles that form a cylindrical net. The terrified fish pack tighter and tighter as the bubble wall closes in. Then, on some unseen signal, the whales surge upward through the center with their mouths wide open, engulfing thousands of fish in a single gulp.

                But the whales of Stellwagen Bank have not always had such a welcoming reception. For over a century, Provincetown and other Cape Cod towns were centers of the whaling industry. The Wampanoag people were the first whale hunters here, harvesting whales that drifted ashore or became stranded in shallow waters. European settlers expanded the practice into an industrial enterprise, building try-works on the beaches to render whale blubber into oil.

                Today, the relationship has completely reversed. The whale watching boats that depart daily from Provincetown and Barnstable Harbor carry researchers and tourists instead of harpoons. Scientists have identified individual whales by the unique patterns on their tail flukes, tracking families across decades. Some of these whales, like Salt, a humpback first identified in 1976, became beloved celebrities.

                The recovery of whale populations off Cape Cod is one of conservation's great success stories. Where once the waters ran red with the whaling industry's harvest, now they echo with the songs and breaths of these magnificent creatures, returned to a place they have called home for millennia.
                """,
                [
                    "Stellwagen Bank was designated a National Marine Sanctuary in 1992.",
                    "Humpback whales can consume up to 3,000 pounds of food per day during feeding season.",
                    "The humpback whale named Salt has been returning to Stellwagen Bank since 1976 and has had over 15 calves."
                ]
            )

        case .pirates:
            return (
                "Black Sam Bellamy and the Pirate Prince of Cape Cod",
                """
                In the spring of 1717, the most successful pirate in recorded history sailed toward Cape Cod with a fortune in stolen treasure. His name was Samuel "Black Sam" Bellamy, and his story is one of love, ambition, and tragedy that still haunts the shores of the Outer Cape.

                Bellamy arrived on Cape Cod around 1715, not as a pirate but as a young English sailor looking to salvage treasure from a Spanish fleet that had wrecked off the coast of Florida. He was handsome, charismatic, and broke. In Eastham, he met Maria Hallett, a young woman from a respectable family. They fell in love, but Maria's family disapproved — Bellamy had no money and no prospects.

                Determined to return wealthy enough to win Maria's hand, Bellamy sailed south to hunt for Spanish gold. When the salvage operation failed, he turned to piracy. In just over a year, Bellamy and his crew captured more than fifty ships, amassing a fortune worth an estimated $120 million in today's currency.

                Bellamy was unusual among pirates. He called himself the "Robin Hood of the Sea" and was known for his eloquent speeches about the injustice of the wealthy. He treated captives well, often releasing them unharmed. His crew operated as a democracy, voting on major decisions and sharing plunder equally regardless of rank or race — a radical notion in the 18th century.

                In April 1717, Bellamy captured his greatest prize: the Whydah, a fully armed slave ship loaded with ivory, indigo, and precious metals. He made the Whydah his flagship and turned north, sailing toward Cape Cod and his beloved Maria.

                He never made it. On the night of April 26, a ferocious nor'easter struck as the Whydah approached the Outer Cape. The storm drove the ship onto a sandbar off what is now Marconi Beach in Wellfleet. The Whydah broke apart in the violent surf, spilling her cargo of treasure and her crew of 146 men into the churning sea. Only two survived.

                Bellamy's body was never identified among the dead. Legend says Maria Hallett watched the wreck from the cliffs, her lantern visible through the rain.

                In 1984, underwater explorer Barry Clifford discovered the wreck of the Whydah, confirming a legend that many had dismissed as myth. The ship's bell, inscribed "THE WHYDAH GALLY 1716," proved the identity beyond doubt. The artifacts recovered — gold coins, weaponry, jewelry, and personal items — now fill the Whydah Pirate Museum in West Yarmouth, telling the story of a pirate who sailed for love and found only the bottom of the sea.
                """,
                [
                    "The Whydah is the only authenticated pirate shipwreck ever discovered.",
                    "Black Sam Bellamy captured over 50 ships in just 18 months, making him history's wealthiest pirate.",
                    "The Whydah Pirate Museum in West Yarmouth houses over 200,000 artifacts from the wreck."
                ]
            )

        case .cranberryBogs:
            return (
                "Ruby Red: The Cranberry Story",
                """
                Every autumn, Cape Cod puts on one of its most spectacular shows — not on a stage, but in the bogs. As the harvest season arrives, the cranberry bogs flood with water, and millions of berries float to the surface, turning entire fields into seas of brilliant ruby red.

                The cranberry is one of only three commercially grown fruits native to North America, and it has deep roots on Cape Cod. The Wampanoag people called it "sassamanesh" and used the tart berries for food, medicine, and dye. They mixed crushed cranberries with dried deer meat and fat to make pemmican, a high-energy food that could last through the long winters.

                European settlers learned about cranberries from the Wampanoag and quickly adopted them. Cape Cod's unique geography turned out to be perfect for the fruit: the acidic, sandy soil; the abundant freshwater; and the cool maritime climate created ideal growing conditions.

                The modern cranberry industry began in 1816 when Captain Henry Hall of Dennis noticed that cranberries growing near the beach produced more fruit when sand blew over them. He began deliberately spreading sand on his cranberry vines, a technique still used today called "sanding." His discovery transformed cranberries from a wild-harvested fruit into a cultivated crop.

                By the mid-1800s, Cape Cod was the cranberry capital of the world. Bogs were carved out of wetlands across the peninsula, and the harvest became the economic engine that drove Cape communities through the lean winter months. Workers came from across the region to pick cranberries by hand, using wooden scoops with tines that combed through the vines.

                Today's harvest is a marvel of agricultural engineering. In the wet harvest method used for most commercial cranberries, the bogs are flooded with about 18 inches of water. Then special machines called beaters drive through the flooded bog, gently dislodging the berries from the vines. Because cranberries have four air chambers inside them, they float to the surface, creating that iconic carpet of red.

                Workers in hip waders then corral the floating berries into a corner of the bog using floating booms, where they're pumped into trucks for processing. A single acre of cranberry bog can produce about 150 barrels of berries — roughly 15,000 pounds.

                The cranberry harvest is more than agriculture on Cape Cod — it's a cultural event. Festivals celebrate the harvest in towns across the Cape. Visitors line up along bog roads to photograph the stunning red fields. And in kitchens from Sandwich to Provincetown, the season brings cranberry sauce, cranberry bread, cranberry pie, and that most Cape Cod of cocktails — the Cape Codder, made with cranberry juice and vodka.
                """,
                [
                    "Cranberries have four air chambers inside, which is why they float and bounce.",
                    "Massachusetts produces about 25% of all cranberries grown in the United States.",
                    "Captain Henry Hall of Dennis is credited with starting commercial cranberry cultivation in 1816."
                ]
            )

        case .shipwrecks:
            return (
                "The Graveyard of the Atlantic",
                """
                Cape Cod's outer shore has earned a grim nickname: the Graveyard of the Atlantic. Over the centuries, more than 3,000 shipwrecks have occurred along this treacherous stretch of coast, where shifting sandbars, fierce currents, and legendary nor'easters have claimed vessels of every size and era.

                The danger begins with geography. Cape Cod juts 40 miles into the Atlantic like a bent arm, creating a natural trap for ships sailing along the coast. The outer beach drops off steeply, but just offshore, sandbars lurk beneath the waves, invisible until a ship's hull strikes them with a sickening crunch. Add fog so thick you can taste the salt in it, and currents that can push a vessel miles off course in an hour, and you have a recipe for maritime disaster.

                The most dangerous stretch runs from Chatham to Provincetown, where the Peaked Hill Bars have swallowed ships whole. These underwater sand ridges shift constantly with the tides and storms, making charts obsolete almost as soon as they're drawn. Sailors who survived groundings here described the bars as a living thing, grabbing hold of a ship and refusing to let go while waves pounded the vessel to pieces.

                The tales are harrowing. In 1802, a British warship ran aground off Truro, and the townsfolk watched helplessly as sailors clung to the rigging while the ship broke apart. In 1898, the steamer Portland vanished in a terrible November gale with all 192 passengers and crew, a disaster so catastrophic that the storm itself became known as the Portland Gale.

                The constant toll of shipwrecks led to the creation of the U.S. Life-Saving Service, the forerunner of the Coast Guard. Starting in 1872, a series of life-saving stations were built along the Outer Cape, each staffed by a keeper and a crew of surfmen who patrolled the beach in all weather, watching for ships in distress.

                These surfmen were extraordinary. In freezing gales and blinding snow, they would launch their surfboats through murderous breakers to reach a wreck. They fired Lyle guns — small cannons that shot a weighted line to a stranded ship so passengers could be hauled to shore in a breeches buoy. Their motto was simple and absolute: "You have to go out, but you don't have to come back."

                Today, the wrecks lie scattered along the Cape's outer shore, most buried beneath the sand. After major storms, the timbers of old ships sometimes emerge from the beach, dark wooden ribs reaching up from the sand like the fingers of the drowned. Divers explore wrecks in deeper water, finding anchors, cannons, and sometimes the personal belongings of those who perished — buttons, coins, and clay pipes that tell stories the sea tried to silence.
                """,
                [
                    "More than 3,000 shipwrecks have occurred along Cape Cod's outer shore.",
                    "The U.S. Life-Saving Service, precursor to the Coast Guard, was established largely because of Cape Cod's deadly waters.",
                    "The wreck of the Sparrowhawk, which sank in 1626, was uncovered by a storm in 1863 and is now in Pilgrim Hall Museum."
                ]
            )

        case .lightkeepers:
            return (
                "Keepers of the Light",
                """
                On stormy nights along Cape Cod's coast, when the fog rolls in thick as wool and the waves crash against the shore, the lighthouses still stand — sentinels of safety that have guided mariners home for centuries. Behind each beam of light lies a story of dedication, isolation, and quiet heroism.

                Cape Cod is home to some of the most iconic lighthouses in America. Highland Light in Truro, established in 1797, was the first lighthouse on Cape Cod and stands on the highest point of the Outer Cape. Its powerful beam could be seen 20 miles out to sea, a vital guide for ships navigating the treacherous waters off the Peaked Hill Bars.

                The keepers who tended these lights lived lives of extraordinary discipline. Every day, they climbed the spiral stairs to polish the enormous Fresnel lenses that focused the light into a beam visible for miles. They trimmed the wicks, filled the oil reservoirs, and wound the clockwork mechanisms that rotated the lenses. At night, they kept watch, ready to sound the fog signal — sometimes a steam-powered horn, sometimes a cannon — when visibility dropped.

                The isolation could be crushing. Many lighthouses stood on remote points of land, accessible only by sand roads that washed out in storms. Keepers and their families went weeks without visitors. Children attended one-room schoolhouses, if any existed nearby. The keeper's wife was often an unofficial assistant, climbing the tower to tend the light when her husband was ill or away.

                Some keepers became legends. At Nauset Light, Keeper Collins kept the light burning through a hurricane that tore the roof from his dwelling. He lashed himself to the tower railing and hand-cranked the lens mechanism when the clockwork failed, keeping the beacon sweeping through the wildest night any sailor on those waters had ever seen.

                The Fresnel lenses themselves were works of art — intricate assemblies of hand-ground glass prisms that could take a single flame and project it into a beam visible at the horizon. Each lens had a unique signature: some flashed, some rotated, some showed different colors at different angles, so that mariners could identify which lighthouse they were seeing and fix their position.

                Today, Cape Cod's lighthouses are automated, their keepers replaced by electric bulbs and computer controls. But the towers remain, painted in their distinctive patterns — Highland's white cylinder, Nauset's red and white bands, Chatham's white tower. They are monuments to the men and women who spent their lives on the edge of the continent, keeping the lights burning so that others might find their way home.
                """,
                [
                    "Highland Light in Truro was moved back 450 feet from the eroding cliff in 1996.",
                    "The Fresnel lens at Highland Light contained over 1,000 hand-ground glass prisms.",
                    "Cape Cod has 10 historic lighthouses still standing, from Nobska in Falmouth to Race Point in Provincetown."
                ]
            )

        // MARK: Haunted & Legend Stories

        case .widowsWalkGhosts:
            return (
                "The Watchers on the Widow's Walk",
                """
                On the rooftops of Cape Cod's oldest sea captains' homes, you'll find narrow platforms ringed with iron railings, perched high above the shingled roofs. They're called widow's walks, and their name tells you everything about the sorrow they've witnessed.

                In the 18th and 19th centuries, when Cape Cod's economy ran on the sea, these rooftop platforms served a practical purpose. Wives, mothers, and daughters would climb up to scan the horizon for returning ships. A sail on the horizon meant their husbands and fathers were coming home. But too often, the ships never came.

                The whaling voyages lasted years. A captain might leave Barnstable or Yarmouth and not return for three or four years — if he returned at all. The sea was merciless. Ships foundered in storms, were crushed by ice, or simply vanished without a trace. The women who paced those rooftop walkways knew that every sunset without a sail could mean they'd become the widows the walkways were named for.

                Local legend says that some of those women never stopped watching. In Barnstable Village, residents of the old Crocker Tavern have reported seeing a woman in a long dress standing on the widow's walk at midnight, her hair blowing in a wind that no one else can feel. She appears only when fog rolls in from the harbor, and she always faces the sea.

                On Route 6A in Yarmouth Port, the Captain Bangs Hallet House has its own spectral watcher. Visitors have photographed what appears to be a figure at the widow's walk railing — a translucent form that doesn't appear to the naked eye but shows up in images as a pale blur. The historical society that manages the house doesn't deny the reports. They simply say the captain's wife, Anna, loved the house very much.

                In Dennis, a bed-and-breakfast in a former captain's home reports that guests in the top-floor room sometimes hear footsteps on the roof — a slow, rhythmic pacing back and forth. When the innkeeper checks, the widow's walk is empty, but the iron railing is ice-cold to the touch, even in August.

                The most chilling account comes from Truro. A woman renting a summer cottage near a derelict captain's house woke at 3 AM to see a light on the abandoned building's widow's walk. Through binoculars, she saw what appeared to be a woman holding a lantern, slowly turning in a circle as if scanning the sea. The house had been empty for decades. It had no electricity.

                Whether these stories are born from imagination, grief, or something that defies explanation, the widow's walks remain — silent, weathered platforms where love and loss once stood together, watching the waves for a sail that might never appear.
                """,
                [
                    "Widow's walks were also called 'captain's walks' and served as roof-access points for chimney fire buckets.",
                    "Some historians believe widow's walks were primarily decorative, inspired by Italian Renaissance architecture.",
                    "Cape Cod has more surviving widow's walks per square mile than any other region in the United States."
                ]
            )

        case .mariaHallett:
            return (
                "The Sea Witch of Wellfleet",
                """
                In the windswept dunes of Wellfleet, where the Atlantic crashes against the Outer Cape with relentless fury, there once lived a young woman whose story would become Cape Cod's most enduring and tragic legend. Her name was Maria Hallett, and they called her the Sea Witch.

                Maria was barely fifteen when she met Samuel Bellamy, a penniless but handsome English sailor who arrived on Cape Cod around 1715. He was charming, ambitious, and full of promises. They fell in love in the meadows above the cliffs, meeting secretly because Maria's respectable family would never approve of a man with empty pockets and wandering eyes.

                Bellamy swore he would return wealthy enough to marry her. He sailed south to salvage treasure from Spanish wrecks off Florida. When that failed, he turned pirate, and within eighteen months became the richest buccaneer in history. But Maria didn't know any of this. All she knew was that he was gone.

                What happened next depends on which version of the legend you believe. In most tellings, Maria bore Bellamy's child in secret, and the baby died. The Puritanical townsfolk, horrified by the scandal, imprisoned her in the Eastham jail. Some say she went mad with grief. Others say she was never mad at all — just broken-hearted and abandoned by a community that should have shown compassion.

                Released from jail, Maria retreated to a crude hut in the dunes near Wellfleet, living as an outcast. The townspeople whispered that she had made a pact with the devil, that she could control the weather, that she lured ships to their doom on the offshore bars. They called her a witch.

                Then came the night of April 26, 1717. A monstrous nor'easter bore down on Cape Cod, and through the howling wind and rain, the Whydah — Bellamy's treasure-laden flagship — was driven onto the sandbars off Wellfleet. The ship broke apart, killing 144 of the 146 men aboard. Bellamy's body was never found.

                Legend says Maria watched the wreck from the cliffs, her lantern a tiny flame against the vast darkness of the storm. Did she weep? Did she rage? Did she summon the storm herself, as the townsfolk believed, finally punishing the man who had abandoned her?

                For years afterward, people reported seeing a light moving through the dunes near the wreck site — Maria's lantern, still searching for her lost pirate. Fishermen claimed to hear a woman's voice singing over the waves on stormy nights, a melody so beautiful and so sad that it could pull a man's heart from his chest.

                Maria Hallett may have been a real person or a composite of several women's stories woven together over centuries. But her legend endures because it speaks to something timeless — love, betrayal, survival, and the terrible power of a woman scorned by both her lover and her community.
                """,
                [
                    "The Whydah wreck site lies in about 30 feet of water off Marconi Beach in Wellfleet.",
                    "Maria Hallett's legend has been retold in novels, plays, and songs for over 300 years.",
                    "Some historians believe Maria Hallett was a real person from Eastham, though records are scarce."
                ]
            )

        case .ladyOfTheDunes:
            return (
                "The Lady of the Dunes: Cape Cod's Deepest Mystery",
                """
                On July 26, 1974, a young girl walking her dog through the dunes of the Cape Cod National Seashore in Provincetown made a discovery that would haunt investigators for decades. There, in a shallow depression among the scrub pines, lay the body of a woman. She had been murdered, and no one knew who she was.

                The woman was young — estimated to be between 25 and 40 years old. She had auburn hair, stood about five feet six inches tall, and had expensive dental work that suggested she came from a family of means. She was lying on a beach towel, and nearby was a pair of Wrangler jeans. But she carried no identification, and her hands had been removed — presumably to prevent fingerprint identification.

                The case became known as "The Lady of the Dunes," and it consumed generations of investigators. The Massachusetts State Police, the FBI, and countless amateur detectives pored over every detail. Who was she? Where had she come from? And who had killed her in this remote, beautiful place?

                Over the years, theories multiplied. Some investigators noted her dental work was unusually sophisticated for the era, suggesting she might have been from overseas. Others focused on the fact that the movie "Jaws" had been filming in nearby Martha's Vineyard in the summer of 1974, and speculated a connection to the film crew. A woman matching her general description had reportedly been seen as an extra in the movie.

                The case took a dramatic turn in 2022 when the FBI announced they had identified the woman using advanced DNA analysis and genealogical research. Her name was Ruth Marie Terry, and she had been from Tennessee. The identification, nearly fifty years after her death, was a testament to advances in forensic science — but it also opened new questions about how she came to be in Provincetown and who was responsible for her death.

                Today, visitors to the dunes near Race Point still pause at the approximate location where the Lady was found. The National Seashore has reclaimed the spot — sand and scrub pine have shifted over the decades, erasing any physical trace. But the story lingers like fog over the dunes, a reminder that even in a place as familiar and beloved as Cape Cod, darkness can hide in the most beautiful landscapes.
                """,
                [
                    "The Lady of the Dunes was identified in 2022 as Ruth Marie Terry, nearly 50 years after her death.",
                    "The case inspired numerous books, podcasts, and TV documentaries.",
                    "Advanced DNA genealogy techniques were used to finally identify the victim."
                ]
            )

        case .mooncussers:
            return (
                "The Mooncussers: Wreckers of the Cape",
                """
                On the darkest nights along Cape Cod's outer shore, when clouds smothered the moon and the sea turned black as ink, a different kind of predator stalked the beaches. They were called mooncussers — men who cursed the moon because its light could ruin their deadly trade.

                The mooncussers were wreckers, shore pirates who deliberately lured ships onto the sandbars and shoals that lined the coast. Their method was diabolically simple. On moonless nights, they would walk a horse or mule along the beach with a lantern tied to its neck. From out at sea, the bobbing light looked like a ship riding safely at anchor in a harbor. A captain, exhausted and lost in the fog, would steer toward the light, believing he was following another vessel into safe waters. Instead, his ship would strike the hidden sandbars with a grinding crash.

                Once a ship ran aground, the mooncussers would wait for the waves to do their work. The pounding surf would break the vessel apart, scattering its cargo along the beach. Under cover of darkness, the wreckers would strip the wreckage of everything valuable — barrels of rum, bolts of cloth, crates of tea, tools, rope, and hardware. If survivors staggered ashore, the mooncussers sometimes helped them. Other times, the stories suggest, they did not.

                The practice was most common in the 17th and 18th centuries, when Cape Cod's outer shore was remote, lawless, and desperately poor. The sandy soil couldn't support much farming, and the fishing was dangerous and unpredictable. A single shipwreck could provide a community with supplies worth a year's wages. The temptation was enormous.

                Not all wrecking was criminal. Cape Codders had legal "wreck rights" — the custom that whatever the sea deposited on your stretch of beach was yours to keep. This made a certain moral gray area. Was it wrong to profit from a wreck you didn't cause? What about a wreck you merely... didn't prevent? What about one you encouraged with a well-placed lantern?

                The mooncussers eventually disappeared, driven out by the construction of lighthouses, the establishment of the Life-Saving Service, and the slow improvement of navigation technology. But their legacy lives on in Cape Cod's architecture. Many of the old houses in Truro, Wellfleet, and Eastham were built with salvaged ship timbers. Look closely at the beams in some of these homes and you can still see the marks of shipwrights — evidence that the wood was shaped for a hull, not a house.

                The name "mooncusser" itself has become part of the Cape's vocabulary, a word that captures both the resourcefulness and the ruthlessness of life on this narrow, storm-battered peninsula. On clear nights, when the moon hangs full and bright over the Atlantic, you might imagine the old wreckers scowling at the sky, cursing the light that kept the ships safe and their pockets empty.
                """,
                [
                    "The term 'mooncusser' comes from the wreckers' frustration with bright moonlit nights that kept ships safe.",
                    "Many Cape Cod homes built before 1800 contain timbers salvaged from shipwrecks.",
                    "The U.S. Life-Saving Service was established partly to combat the wrecking trade on the Outer Cape."
                ]
            )

        case .hauntedInns:
            return (
                "Behind Closed Doors: The Haunted Inns of Cape Cod",
                """
                Cape Cod's inns and taverns have been welcoming travelers for over three hundred years. But some guests, it seems, have never checked out.

                The Dan'l Webster Inn in Sandwich, one of the Cape's most elegant establishments, sits on a site with a history stretching back to 1692. The original tavern was a gathering place for patriots during the Revolution and later served as a stop on the stagecoach route. Staff members have reported encounters they can't explain — doors that open and close on their own, the scent of perfume in empty hallways, and a woman in period dress who appears in the upstairs corridor and vanishes when approached.

                Room 4 is considered the most active. Guests have reported waking to find the rocking chair in the corner moving on its own, and the temperature dropping so sharply that their breath turns to fog, even in summer. The inn doesn't shy away from its reputation. They consider their ghosts part of the charm.

                In Orleans, the Orleans Inn overlooks Town Cove from a building dating to 1875. The inn's most famous spectral resident is believed to be Hannah, a former owner who died in the building. She's said to favor the third floor, where lights flicker without explanation and objects rearrange themselves overnight. One guest reported waking to find all her shoes lined up neatly by the door — a service she hadn't requested and no staff member claimed.

                The Captain Bangs Hallet House in Yarmouth Port, now a museum, was built in 1840 for a prosperous sea captain. Docents have reported hearing heavy footsteps on the upper floor when the building is empty, and several have described feeling a hand on their shoulder in the captain's study — a firm but gentle pressure, as if someone were trying to get their attention.

                Barnstable is perhaps the most haunted town on the Cape. The Barnstable House, dating to the 1700s, has a long history of unexplained phenomena. Doors slam in rooms with no draft. Voices murmur behind walls that have no adjacent rooms. And on certain autumn evenings, a figure has been seen standing at the second-floor window, gazing toward the harbor with an expression that witnesses describe as infinite sadness.

                Down in Chatham, the Chatham Wayside Inn has reports going back generations of a sea captain who appears in the tavern on stormy nights, sitting alone at a corner table. He wears a heavy coat and stares at something only he can see. Bartenders have set drinks in front of the empty chair where he's been spotted, half-joking. In the morning, the glass is always empty.

                Whether you believe in ghosts or not, the haunted inns of Cape Cod offer something undeniable: a connection to the past so vivid that it feels alive. These old buildings hold centuries of human experience within their walls — love, loss, laughter, and grief — and sometimes, on quiet nights when the wind dies down and the fire burns low, that experience seems to reach across time and tap you on the shoulder.
                """,
                [
                    "The Dan'l Webster Inn in Sandwich has been operating on the same site since 1692.",
                    "Barnstable County has more reported hauntings per capita than any county in Massachusetts.",
                    "Many Cape Cod ghost sightings are associated with nor'easters and full moons."
                ]
            )

        case .ghostShips:
            return (
                "Phantom Vessels: Ghost Ships of Cape Cod",
                """
                Sailors are a superstitious lot, and the waters off Cape Cod have given them plenty of reason to be. For centuries, mariners have reported seeing ships that shouldn't be there — vessels from another era, sailing against the wind, crewed by figures that cast no shadow and make no sound.

                The most famous ghost ship of Cape Cod is the phantom of the Palatine, though it's more properly associated with Block Island to the south. But the Cape has its own spectral fleet. Fishermen working the waters off Truro have long reported a three-masted schooner that appears in the fog, running before a wind that blows in the wrong direction. She flies no flag, shows no lights, and when a boat approaches, she dissolves into the mist like smoke.

                Old-timers in Chatham tell of the Ghost of the Monomoy, a vessel that appears off the southern tip of Monomoy Island during the worst winter storms. She's described as a square-rigged ship, her sails torn and her rigging tangled, heeling hard in seas that would swallow a modern fishing boat. Some say she's the specter of one of the many ships that went down on Monomoy's treacherous shoals. Others say she appears as a warning — that any vessel foolish enough to round the point in such weather will join her on the bottom.

                In Provincetown Harbor, a ghost ship has been reported intermittently since the 1800s. She appears at dawn, anchored in the harbor among the modern boats, a wooden vessel from the age of sail. Her hull is dark and barnacled, her masts bare, and she rides low in the water as if heavily laden. Witnesses say she looks absolutely solid and real — until they look away and look back to find the spot empty, with not even a ripple where the hull had been.

                Some believe the Provincetown phantom is connected to the whaling industry. During the 19th century, Provincetown was one of New England's busiest whaling ports, and dozens of whale ships sailed from its harbor never to return. The ghost ship, they say, is one of those lost vessels, still trying to make port with her cargo of whale oil and bone.

                Perhaps the eeriest account comes from the crew of a fishing dragger working off Highland Light in the 1960s. In their captain's log, they recorded encountering a sailing vessel on a clear, calm night. The ship was close enough that they could see figures moving on deck. They hailed the vessel by radio and received no response. They altered course to approach, and as they drew near, the ship simply wasn't there. The radar showed nothing. The sea was empty. But every man on board had seen it, and the captain dutifully recorded the encounter, writing simply: "Vessel sighted and lost. No explanation."

                The ghost ships of Cape Cod may be tricks of light and fog, collective hallucinations born of exhaustion and isolation, or memories so powerful they've imprinted themselves on the waters where they were made. Whatever they are, they belong to the sea, and the sea keeps its own counsel.
                """,
                [
                    "Ghost ship sightings off Cape Cod have been documented since the early 1700s.",
                    "The phenomenon of 'Fata Morgana' — a complex mirage that can make distant objects appear elevated — may explain some sightings.",
                    "Over 3,000 ships have wrecked along the Cape's outer shore, providing ample source material for phantom vessel legends."
                ]
            )

        case .deadMansHollow:
            return (
                "Dead Man's Hollow: Where the Shadows Gather",
                """
                There are places on Cape Cod that the locals avoid after dark — not because of any rational danger, but because of something they can't quite name. A feeling. A wrongness in the air. Dead Man's Hollow is one of those places.

                The hollow sits in the woods between two Cape towns, a low depression where the trail dips into shadow even on the brightest days. The trees grow differently here — twisted pitch pines that lean away from the center as if trying to escape. The ground is covered with a thick mat of pine needles that muffles every footstep. In the hollow, sound behaves strangely. Your voice falls flat, as if the air itself is absorbing it.

                The name dates to the 1700s, when a traveling minister was found dead in the hollow with no mark on his body and an expression of absolute terror frozen on his face. The local magistrate ruled it a natural death — perhaps his heart had simply given out — but the townsfolk had other ideas. They whispered that the hollow was cursed, that the Wampanoag had avoided it long before the English arrived, that something old and hungry lived in the darkness beneath the pines.

                Over the centuries, the stories accumulated like fallen leaves. A farmer walking home through the hollow heard footsteps behind him — heavy, deliberate footsteps that matched his pace exactly. When he stopped, the footsteps stopped. When he ran, they ran. He burst out of the tree line at a dead sprint and never went back.

                In the 1800s, a schoolteacher reported seeing lights in the hollow on a November evening — cold, blue lights that drifted between the trees like lanterns carried by invisible hands. She watched from the road for several minutes before the lights converged in the center of the hollow and winked out simultaneously, leaving a darkness that seemed deeper than the surrounding night.

                Children dared each other to walk through the hollow alone. Most turned back. Those who made it through reported the same unsettling details: the feeling of being watched, the strange silence, and a smell they couldn't place — not decay exactly, but something old. Ancient. Like opening a door that has been closed for a very long time.

                Modern hikers sometimes stumble into the hollow without knowing its history. They report the same sensations the locals have described for three centuries: the muffled quality of sound, the feeling of heaviness, the inexplicable urge to leave quickly. Their dogs refuse to enter. Their phone compasses spin.

                Is Dead Man's Hollow haunted? The question misses the point. Cape Cod is a place where 20,000 years of geological history lie just beneath your feet, where the bones of ships and sailors rest in the sand, where entire communities have risen and been reclaimed by the sea. Some places simply carry the weight of time more heavily than others. Dead Man's Hollow is one of them, and it asks nothing of visitors except that they keep walking and not look back.
                """,
                [
                    "Cape Cod has dozens of local 'haunted hollows' and 'devil's dens' documented in town histories.",
                    "The Wampanoag people had their own traditions about places of spiritual power that should be avoided.",
                    "Pitch pine forests, common on the Cape, can create unusual acoustic effects that contribute to eerie atmospheres."
                ]
            )

        // MARK: Remaining Topic Stories

        case .wampanoag:
            return (
                "The People of the First Light",
                """
                Long before the Pilgrims, long before the Vikings, long before any European sail appeared on the horizon, the Wampanoag people lived on Cape Cod. They called themselves the People of the First Light, because their homeland on the easternmost edge of the continent was the first place in the land to be touched by the rising sun.

                For over 12,000 years, the Wampanoag thrived on this narrow peninsula. They were not the "primitive" people that later histories would portray. They were sophisticated stewards of a complex landscape, managing forests with controlled burns to encourage the growth of berry bushes and to create open meadows for deer. They cultivated corn, beans, and squash — the Three Sisters — in cleared fields along the coast.

                Their relationship with the sea was deep and practical. They harvested quahogs, oysters, and scallops from the tidal flats, built fish weirs in the rivers, and hunted whales that stranded on the beaches. Wampanoag whalers were so skilled that English colonists later hired them as crew on their own whale ships.

                The Wampanoag lived in wetus — dome-shaped homes framed with bent saplings and covered with bark or woven mats. A typical village might contain several dozen wetus, a council house, and storage pits for preserved food. The villages moved seasonally: inland in winter for protection from storms, back to the coast in summer for fishing and shellfish harvesting.

                When the Pilgrims arrived in 1620, it was the Wampanoag sachem Massasoit who chose diplomacy over conflict, forming an alliance that sustained the struggling colony through its first years. Tisquantum, known to history as Squanto, taught the Pilgrims to plant corn with fish as fertilizer, to tap maple trees, and to navigate the Cape's waterways.

                But the alliance came at a terrible cost. European diseases had already devastated the Wampanoag population before the Pilgrims arrived, killing as many as 90% of the people in some villages. The epidemic of 1616-1619 left entire communities empty, their cornfields returning to forest, their fish weirs crumbling in the rivers.

                Today, the Mashpee Wampanoag Tribe maintains its presence on Cape Cod, with tribal lands in Mashpee and Taunton. They are the living descendants of the People of the First Light, and their history on this land is not a relic of the past but a continuing story — one that stretches from the last Ice Age to this morning's sunrise.
                """,
                [
                    "The Wampanoag have lived on Cape Cod for over 12,000 years, since the retreat of the glaciers.",
                    "The Mashpee Wampanoag Tribe received federal recognition in 2007.",
                    "The word 'Wampanoag' means 'People of the First Light' or 'People of the Eastern Dawn.'"
                ]
            )

        case .capeCodCanal:
            return (
                "The Big Ditch: How the Canal Changed Everything",
                """
                The idea was simple, even obvious: cut a canal across the base of Cape Cod to save ships the dangerous voyage around the Outer Cape. Simple to imagine, but it took over 300 years to accomplish.

                The first person to suggest a Cape Cod canal was Myles Standish, the Pilgrims' military leader, who proposed it in 1623. He could see that a shortcut between Buzzards Bay and Cape Cod Bay would save ships from navigating the treacherous shoals of the Outer Cape, where storms and sandbars had already begun claiming victims.

                For the next 280 years, engineers, politicians, and dreamers talked about the canal. George Washington ordered a survey of the route in 1776, believing it would be strategically valuable during the Revolution. The idea resurfaced repeatedly through the 1800s, but the cost and engineering challenges kept it in the realm of fantasy.

                Finally, in 1909, a New York financier named August Belmont Jr. decided to build it himself. Using a combination of steam shovels, dredges, and thousands of workers — many of them Italian and Portuguese immigrants — Belmont carved a channel through the sandy isthmus connecting Cape Cod to the mainland.

                The canal opened on July 29, 1914, just days before World War I erupted in Europe. It was 13 miles long but dangerously narrow, and the tidal currents that surged through it were vicious. Ships were sometimes swept sideways, crashing into the canal walls. Belmont, who had hoped to profit from tolls, went bankrupt.

                The federal government took over in 1928, and the Army Corps of Engineers widened the canal to 480 feet and deepened it to 32 feet. They built the two iconic bridges — the Bourne Bridge and the Sagamore Bridge — that still carry traffic over the canal today. A railroad bridge was added as well, a vertical-lift design that rises 135 feet to let ships pass beneath.

                The canal transformed Cape Cod. It technically made the Cape an island, separated from the mainland by a man-made waterway. It became a beloved recreation area — the service roads along both banks now form a popular 14-mile bike path. And every summer, the bridges become the most famous bottleneck in Massachusetts, as millions of visitors funnel onto the Cape through just two chokepoints.
                """,
                [
                    "The Cape Cod Canal is the widest sea-level canal in the world at 480 feet.",
                    "August Belmont Jr. spent $16 million of his own money to build the canal and ultimately went bankrupt.",
                    "The Bourne and Sagamore bridges, built in 1935, are being replaced with a new single bridge currently under construction."
                ]
            )

        case .whaling:
            return (
                "The Whale Oil Kings",
                """
                Before petroleum, before electricity, the world ran on whale oil. And Cape Cod was at the heart of an industry that lit the lamps of civilization while driving the great whales to the brink of extinction.

                The Wampanoag were the original Cape Cod whalers, harvesting whales that stranded on the beaches or came close to shore. They used every part of the animal — blubber for oil, meat for food, bones for tools. When English settlers arrived, they quickly recognized the value of this coastal bounty and began organizing shore-based whaling operations.

                By the mid-1700s, Cape Cod towns were launching deep-water whaling voyages that ranged across the Atlantic and eventually around the world. Provincetown, Wellfleet, Truro, and Dennis sent ships that might be gone for three or four years at a time, hunting sperm whales in the Pacific and right whales in the South Atlantic.

                The life of a whaler was brutal. The work was dangerous beyond modern comprehension. Men in small open boats rowed up to animals the size of school buses, drove harpoons into their flesh, and then held on as the wounded whale dragged them on what they called a "Nantucket sleigh ride" — a terrifying sprint through open ocean that could last hours.

                Once the whale was killed, the real work began. The carcass was lashed alongside the ship, and the crew used long-handled cutting spades to strip the blubber in a spiral pattern, like peeling an orange. The blubber was hauled aboard, cut into small pieces called "bible leaves," and rendered in try-pots — massive iron cauldrons set in brick furnaces on the deck. The fire was fueled by the scraps of previously rendered blubber, meaning the whale literally cooked itself.

                The smell was indescribable. Whalers said you could detect a whale ship from five miles downwind. The greasy black smoke from the try-works coated everything and everyone aboard. Yet the product was liquid gold — sperm whale oil burned cleaner and brighter than any other fuel available, and it commanded premium prices in the markets of Boston, New York, and London.

                The industry peaked in the 1840s and declined rapidly after petroleum was discovered in Pennsylvania in 1859. Kerosene was cheaper and didn't require three-year voyages to obtain. By the 1870s, the Cape's whaling fleet was gone, and the captains' mansions along Route 6A stood as monuments to an era when the world's economy floated on a sea of whale oil.
                """,
                [
                    "At its peak, the American whaling industry employed over 70,000 people.",
                    "Sperm whale oil was so valuable it was called 'liquid gold' — a single large whale could yield 100 barrels worth thousands of dollars.",
                    "Cape Cod whaling ships sometimes stayed at sea for 3-4 years before returning home."
                ]
            )

        case .portugueseFishing:
            return (
                "From the Azores to the Cape: The Portuguese Fishing Heritage",
                """
                Walk through Provincetown today and you'll notice something that sets it apart from the rest of Cape Cod. The names on the fishing boats — Mello, Santos, Costa, Silva. The restaurants serving caldo verde and linguica. The Blessing of the Fleet each June, when the bishop walks the wharf and sprinkles holy water on the bows of the fishing boats. This is the legacy of the Portuguese, whose story on Cape Cod is one of courage, hardship, and enduring community.

                They began arriving in the early 1800s, mostly from the Azores, a chain of volcanic islands in the mid-Atlantic that belonged to Portugal. Many came as crew on American whaling ships that stopped in the Azores to resupply and recruit sailors. The Azorean men were already expert fishermen and fearless in small boats, making them ideal whalers.

                When the whaling industry declined, the Portuguese stayed. They settled in Provincetown, where they turned their maritime skills to the Grand Banks fishing fleet. They built the sturdy fishing schooners that became icons of the Provincetown waterfront, and they perfected the art of trap fishing — setting long nets from shore to intercept migrating fish.

                Life was hard. The men went to sea in all weather, hauling nets and traps in freezing spray. The women ran the households, tended gardens, and processed fish for market. Everyone spoke Portuguese at home, even as the children learned English in the public schools. The community was tight-knit, centered on the Catholic church and the fishermen's mutual aid societies.

                The Portuguese transformed Provincetown's culture. They brought their festivals, their food, and their faith. The Blessing of the Fleet, held annually since the early 1900s, became the town's most important celebration. They introduced sweet bread, a rich egg bread that Cape Codders now consider a local staple. Their cooking — kale soup, marinated pork, grilled sardines — became part of the Cape's culinary identity.

                Today, the Portuguese fishing heritage lives on in Provincetown and across the Lower Cape, even as the fishing industry itself has declined. The descendants of those Azorean sailors serve on town boards, run businesses, and maintain the traditions their grandparents brought across the Atlantic. Their story is Cape Cod's story — a tale of people who came from across the sea, put down roots in sandy soil, and made this windswept peninsula their home.
                """,
                [
                    "By 1900, over half of Provincetown's population was of Portuguese descent.",
                    "The Blessing of the Fleet ceremony in Provincetown dates back to the early 1900s.",
                    "Portuguese sweet bread (massa sovada) is now a staple at bakeries across Cape Cod."
                ]
            )

        case .artColonies:
            return (
                "Provincetown: America's Oldest Art Colony",
                """
                At the very tip of Cape Cod, where the land curls back on itself like a closing fist, lies a town that changed American art. Provincetown has been drawing painters, writers, and dreamers since the 1890s, making it the oldest continuous art colony in the United States.

                The light brought them first. Artists talk about light the way musicians talk about acoustics, and the light in Provincetown is extraordinary. The town is nearly surrounded by water, and sunlight bouncing off the harbor, the bay, and the open Atlantic creates a luminous quality that makes colors vibrate. The painter Charles Hawthorne, who founded the Cape Cod School of Art in Provincetown in 1899, told his students to "go out and paint the light."

                Hawthorne's school attracted painters from across the country, and a community began to form. Studios opened in converted fishing shacks along the waterfront. Artists rented cheap rooms in Portuguese boarding houses. The town's natural beauty, its isolation, and its tolerant, working-class culture made it an ideal refuge for creative spirits who didn't fit in elsewhere.

                Then came the writers. In 1915, a group of young bohemians from Greenwich Village established the Provincetown Players, a theater company that performed in a fish house on a wharf. Among them was a young, unknown playwright named Eugene O'Neill, whose one-act plays about the sea — written in Provincetown and inspired by its people — would eventually win him the Nobel Prize in Literature.

                The Provincetown Players revolutionized American theater, introducing realism and psychological depth to a stage that had been dominated by melodrama. O'Neill's "Bound East for Cardiff," performed on that Provincetown wharf with the sound of real waves beneath the floorboards, is considered the birth of modern American drama.

                Through the decades that followed, Provincetown continued to attract luminaries. Edward Hopper painted his iconic Cape Cod landscapes from a cottage in Truro. Jackson Pollock, Robert Motherwell, and other Abstract Expressionists worked in Provincetown studios. Norman Mailer wrote several of his novels there. Tennessee Williams found inspiration in the town's dramatic beauty.

                Today, Provincetown has over 60 galleries and remains one of the most vibrant art communities in America. The Provincetown Art Association and Museum, founded in 1914, houses a permanent collection spanning a century of Cape Cod art. Every summer, the town fills with painters, sculptors, and performers carrying on a tradition that began with Charles Hawthorne and a canvas set up on the harbor beach, chasing the light.
                """,
                [
                    "Eugene O'Neill's first plays were performed in a converted fish house on a Provincetown wharf in 1916.",
                    "The Provincetown Art Association and Museum has been in continuous operation since 1914.",
                    "Edward Hopper's painting 'Nighthawks' was inspired by a diner in Greenwich Village, but his Cape Cod paintings of sunlit houses are among his most beloved works."
                ]
            )

        case .clamShacks:
            return (
                "Clam Shack Culture: A Cape Cod Love Story",
                """
                There is a particular kind of happiness that only a Cape Cod clam shack can provide. It involves a paper boat overflowing with golden fried clams, a plastic cup of tartar sauce, a view of the harbor, and absolutely no pretension whatsoever.

                Clam shacks are as essential to Cape Cod as lighthouses and beach roses. These no-frills restaurants — often little more than a kitchen window and some picnic tables — have been feeding hungry beachgoers since the early 1900s. They represent a culinary tradition that is democratic, delicious, and deeply connected to the Cape's working waterfront.

                The star of every clam shack menu is the fried clam. Cape Cod's version typically features soft-shell clams — known locally as steamers — dipped in evaporated milk, dredged in a mixture of flour and cornmeal, and fried in hot oil until they achieve a shattering golden crust. The result is a miracle of texture and flavor: crispy outside, tender inside, with the sweet brine of the sea in every bite.

                The great fried clam debate on Cape Cod centers on "bellies" versus "strips." Clam bellies include the whole clam — the soft, plump belly along with the strip of muscle — while strips are just the chewy neck portion. True Cape Codders will tell you that bellies are the only way to go, and that ordering strips is a mark of the tourist. This is said affectionately. Everyone was a tourist once.

                Beyond fried clams, clam shacks serve the full canon of Cape Cod seafood: lobster rolls (hot with butter or cold with mayo, another fierce local debate), fish and chips, clam chowder (always New England style, never Manhattan), fried scallops, and onion rings. Some shacks have expanded into stuffed quahogs, crab cakes, and even sushi, but the classics endure.

                What makes a great clam shack isn't just the food — it's the experience. Eating outdoors at a picnic table sticky with salt air, watching the boats come in while seagulls patrol overhead, sharing a pile of fried clams with your family while the sun drops toward the harbor. It's uncomplicated joy, and Cape Cod has been serving it up for over a century.
                """,
                [
                    "The fried clam was reportedly invented in Essex, Massachusetts in 1916, and quickly spread to Cape Cod.",
                    "Cape Cod's soft-shell clam harvest is valued at over $2 million annually.",
                    "The proper Cape Cod term for a large hard-shell clam is 'quahog' (pronounced 'ko-hog'), from the Wampanoag word."
                ]
            )

        case .seals:
            return (
                "The Return of the Seals",
                """
                Walk along the beaches of Chatham or Monomoy on a winter morning and you might think you've stumbled onto another planet. Hundreds — sometimes thousands — of gray seals haul out on the sandbars, their sleek bodies packed together like sardines, their doglike faces turned toward the sun. It's one of Cape Cod's most spectacular wildlife scenes, and it's remarkably recent.

                A century ago, seals were rare on Cape Cod. Fishermen had hunted them relentlessly, viewing them as competitors for the same fish. Massachusetts even offered bounties for seal kills well into the 20th century. By the 1960s, seals had been nearly eliminated from the Cape's waters.

                The Marine Mammal Protection Act of 1972 changed everything. Protected from hunting, seal populations began to recover. Gray seals, which breed on the remote beaches of Muskeget Island and Monomoy, were the first to return in significant numbers. Harbor seals followed, hauling out on rocks and sandbars throughout the Cape's harbors and bays.

                Today, the seal population off Cape Cod is estimated at over 50,000 — a conservation success story that has also created unexpected consequences. The seals' return has attracted their primary predator: the great white shark. Since the 2000s, white sharks have become regular summer visitors to the Cape's outer beaches, fundamentally changing the relationship between beachgoers and the ocean.

                Despite the shark concern, the seals are beloved by visitors. Seal watching tours depart from Chatham and other harbors, offering close encounters with these charismatic animals. The seals are curious and playful, often approaching kayakers and swimmers with what appears to be genuine interest. Their large, dark eyes and whiskered faces make them irresistibly photogenic.

                The gray seals of Cape Cod are now the largest colony in the United States. They're a reminder that nature, given protection and time, has an extraordinary capacity to heal — even if the healing comes with complications that no one quite expected.
                """,
                [
                    "Cape Cod's gray seal population has grown from near zero in the 1960s to over 50,000 today.",
                    "Gray seals can dive to depths of over 1,500 feet and hold their breath for up to an hour.",
                    "Massachusetts paid bounties for seal kills until 1962."
                ]
            )

        case .greatWhiteSharks:
            return (
                "Jaws Next Door: Great Whites of Cape Cod",
                """
                Every summer, one of the ocean's most formidable predators arrives off the shores of Cape Cod, drawn by the thousands of seals that now congregate on the Outer Cape's beaches. The great white shark has returned to waters where it hasn't been seen in living memory, and it's changed everything about how Cape Codders think about the sea.

                The sharks began appearing in significant numbers around 2009, following the explosive growth of the gray seal population. For great whites, the seal colonies off Chatham, Monomoy, and the outer beaches are an irresistible buffet. Researchers with the Atlantic White Shark Conservancy have tagged and identified over 400 individual sharks in Cape Cod waters, and the true number is certainly higher.

                The sharks are impressive animals. Adults typically measure 12 to 16 feet long and weigh over a ton. They cruise the shallow waters just offshore, sometimes in water barely deep enough to cover their dorsal fins. Beachgoers have spotted them from shore, dark shapes moving parallel to the beach just beyond the breakers.

                The presence of great whites has transformed beach culture on Cape Cod. Towns now post shark warning signs, employ spotter planes, and close beaches when sharks are detected. The Sharktivity app, developed by the Atlantic White Shark Conservancy, sends real-time alerts when sharks are spotted. Lifeguards carry tourniquets. The easygoing, carefree beach day now comes with a new awareness.

                There have been encounters. In 2018, a boogie boarder was bitten off Newcomb Hollow Beach in Wellfleet — the first fatal shark attack in Massachusetts since 1936. The incident sobered the Cape and sparked debates about shark management, seal population control, and the balance between conservation and public safety.

                Yet most Cape Codders have come to accept the sharks with a mix of respect and pragmatism. The sharks were here first — fossil evidence shows great whites have patrolled these waters for millions of years. Their return, driven by the recovery of seal populations, is a sign that the marine ecosystem is functioning as nature intended.

                The great whites of Cape Cod are a reminder that the ocean is not a swimming pool. It is a wild place, home to wild creatures, and sharing it requires awareness, respect, and a healthy measure of humility.
                """,
                [
                    "Over 400 individual great white sharks have been identified and cataloged in Cape Cod waters.",
                    "The Atlantic White Shark Conservancy's Sharktivity app provides real-time shark detection alerts.",
                    "Great whites can detect a single drop of blood in 25 gallons of water."
                ]
            )

        case .pipingPlovers:
            return (
                "Tiny Guardians: The Piping Plovers of Cape Cod",
                """
                They weigh barely two ounces — about as much as a handful of sand. They stand six inches tall. And every spring, they bring the full might of the federal government to Cape Cod's beaches, because piping plovers are among the most endangered shorebirds in North America.

                These tiny, sand-colored birds nest directly on the open beach, scraping shallow depressions in the sand and laying four speckled eggs that are nearly invisible to the untrained eye. It's an adaptation that served them well for millennia, when their only threats were foxes, hawks, and the occasional storm surge. But when humans discovered that beaches were good for sunbathing, volleyball, and driving, the plovers ran into trouble.

                By 1986, the piping plover population on the Atlantic coast had dropped to fewer than 800 pairs. The species was listed as threatened under the Endangered Species Act, and Cape Cod became ground zero for the recovery effort. Towns were required to fence off nesting areas, restrict beach vehicle access, and post monitors during nesting season — measures that sometimes put plover protection in direct conflict with beachgoers who had used those beaches for generations.

                The conflicts became legendary. Beach drivers fumed at closures. Dog walkers protested leash requirements. The piping plover became, for a time, the most controversial bird in Massachusetts.

                But the protections worked. Cape Cod's plover population slowly increased, and the species became a symbol of conservation success — and of the ongoing negotiation between human recreation and wildlife needs. Today, volunteer plover monitors patrol the beaches from April through August, marking nests and educating visitors about their tiny, determined neighbors.

                Watch a piping plover on the beach and you'll understand why people fall in love with them. They sprint across the sand on legs that move so fast they blur, stopping abruptly to tilt their heads and listen for invertebrates beneath the surface. Their call is a clear, sweet whistle that carries over the sound of the surf. They are fierce parents, feigning broken wings to lure predators away from their nests.

                The piping plovers of Cape Cod ask very little: a few feet of undisturbed sand, a summer to raise their young, and the chance to do what they've done on these beaches since long before humans arrived. In return, they remind us that sharing the coast means making room for all its inhabitants, even the smallest ones.
                """,
                [
                    "Piping plover eggs are so well camouflaged that even experienced researchers sometimes struggle to find them.",
                    "Cape Cod hosts about 150 nesting pairs of piping plovers each year — roughly 10% of the Atlantic population.",
                    "Piping plover chicks can run and feed themselves within hours of hatching."
                ]
            )

        case .lifesavers:
            return (
                "You Have to Go Out: The Surfmen of Cape Cod",
                """
                Their motto was simple and terrifying: "You have to go out, but you don't have to come back." The men of the United States Life-Saving Service who patrolled Cape Cod's outer beaches were among the bravest souls in American history, and their story is one of duty, sacrifice, and extraordinary courage.

                The Life-Saving Service was established in 1872 in response to the appalling number of shipwrecks along the Atlantic coast. Cape Cod, with its treacherous sandbars and violent storms, was the epicenter of the crisis. Between 1843 and 1903, over 500 vessels wrecked on the Outer Cape alone.

                The Service built a chain of life-saving stations along the coast, each staffed by a keeper and six to eight surfmen. The stations were spaced about five miles apart, and every night, in every kind of weather, the surfmen walked their patrols — trudging along the beach in darkness, watching for ships in distress. They carried Coston flares to signal warnings and each other.

                When a ship was spotted on the bars, the surfmen sprang into action. They hauled their surfboat — a heavy, double-ended wooden craft — across the beach on a cart and launched it into the breakers. In seas that could reach twenty feet, in blinding snow, in temperatures well below freezing, they rowed out to the wreck, navigating by instinct and experience through waves that would swallow a modern rescue boat.

                If the surf was too violent for the boat, they used the Lyle gun — a small brass cannon that fired a weighted line to the stranded ship. Once the line was secured, they rigged a breeches buoy — essentially a pair of canvas pants attached to a ring buoy on a pulley — and hauled survivors to shore one at a time, through the crashing surf, in a contraption that looked like something from a nightmare but saved thousands of lives.

                The surfmen were local men — fishermen, farmers, and laborers who knew the Cape's waters intimately. They trained constantly, drilling with their boats and equipment until every maneuver was automatic. They had to be. In the chaos of a rescue, with a ship breaking apart and people dying in the water, there was no time to think. Only to act.

                The Life-Saving Service merged into the U.S. Coast Guard in 1915, but its legacy lives on in the old station buildings that dot the Cape's coastline. Some have been converted to homes or museums. The Old Harbor Life-Saving Station, moved to Race Point in Provincetown, offers demonstrations of the breeches buoy rescue technique — a vivid reminder of what these men did, night after night, storm after storm, because that was the job, and somebody had to do it.
                """,
                [
                    "Cape Cod's life-saving stations rescued over 4,000 people between 1872 and 1915.",
                    "The Life-Saving Service motto 'You have to go out, but you don't have to come back' was unofficial but universally observed.",
                    "The Old Harbor Life-Saving Station in Provincetown was moved from Chatham to its current location in 1977."
                ]
            )

        case .fishingBoats:
            return (
                "The Fleet: Fishing Boats of Chatham",
                """
                Every morning before dawn, the fishing boats of Chatham head out through the break in the barrier beach, their running lights cutting through the darkness as they motor toward the open Atlantic. It's a scene that has played out in this harbor for over three centuries, and it remains one of the most authentic working waterfront experiences on Cape Cod.

                Chatham's fishing fleet is the last significant commercial fleet on the Outer Cape. While other harbors have been taken over by pleasure boats and tourist vessels, Chatham's Fish Pier remains a working pier where real fishermen unload real catches — cod, haddock, flounder, sea bass, and the prized Chatham day-boat scallops that command premium prices in Boston restaurants.

                The Chatham fleet is a day-boat fleet, meaning the boats go out in the morning and return the same day with their catch. This distinguishes Chatham fish from the product of larger offshore vessels that stay at sea for days, packing their catch in ice. Day-boat fish is fresher, and Chatham fishermen have built a reputation — and a brand — around that freshness.

                Watching the fleet return to the Fish Pier in the afternoon is a Cape Cod ritual. The boats motor up to the pier, and the fishermen unload their catch into bins that are weighed, tagged, and sold. Seals bob in the harbor waiting for scraps. Seagulls wheel overhead. Tourists press against the railing of the observation deck, cameras clicking, watching a tradition that predates the founding of the republic.

                The fishing life has never been easy, and it's harder now than ever. Regulations, quotas, and rising costs have squeezed the fleet. The number of active boats has declined steadily over the decades. Young people look at the economics — the cost of a boat, the price of fuel, the uncertainty of the catch — and choose other careers.

                But the fleet endures, sustained by families who have fished these waters for generations and by a community that understands the value of a working waterfront. Chatham's fish pier isn't a museum or a tourist attraction. It's a place where people work, where the sea provides, and where the bond between a town and its ocean remains unbroken.
                """,
                [
                    "Chatham's Fish Pier handles over 4 million pounds of fish annually.",
                    "Chatham day-boat scallops are so prized they're served at some of Boston's finest restaurants.",
                    "The Chatham fishing fleet has been in continuous operation for over 300 years."
                ]
            )

        case .harborPilots:
            return (
                "Navigating the Narrows: Cape Cod's Harbor Pilots",
                """
                The Cape Cod Canal looks deceptively simple from the bike path that runs along its banks — a wide channel of water connecting two bays. But for the captains of the massive ships that transit the canal, it's one of the most challenging passages on the East Coast, and they don't do it alone. They rely on harbor pilots — expert navigators who know every current, every shoal, and every trick of this tricky waterway.

                Harbor pilots are among the most skilled mariners in the world. They board incoming vessels at sea, climb rope ladders up the towering hulls of container ships and tankers, and take the helm for the transit through confined or hazardous waters. On the Cape Cod Canal, the challenges are formidable: the canal is only 480 feet wide, the currents can run at 5 knots, and the traffic includes everything from tugboat-barge combinations to 900-foot tankers.

                The tradition of pilotage on Cape Cod goes back to the earliest days of European settlement. As commerce grew and ships got larger, local mariners who knew the harbors, channels, and hidden hazards became invaluable. They would row out to approaching vessels in small boats, offer their services, and guide the ships safely to their berths.

                Today's pilots use GPS, radar, and electronic charts, but the fundamental skill remains the same: an intimate knowledge of local waters that no instrument can fully replace. A pilot knows that the current at the east end of the canal runs differently than at the west end, that the wind funnels through the canal in ways that can push a ship sideways, and that a submerged rock just south of the channel has caught the unwary for generations.

                The job requires years of training and apprenticeship. A pilot candidate starts as a mate, then serves as a deputy pilot for years before qualifying for a full pilot's license. The learning never stops — every transit teaches something new about how wind, current, and vessel handling interact in these confined waters.

                The harbor pilots of Cape Cod work in obscurity. Tourists crossing the canal bridges rarely notice the small pilot boat racing out to meet an incoming vessel. But every ship that passes safely through the canal, every tanker that reaches its berth without incident, is a testament to the skill of the pilot at the helm — a modern heir to the Cape Cod mariners who have been guiding ships through dangerous waters since the days of sail.
                """,
                [
                    "The Cape Cod Canal handles approximately 14,000 vessel transits per year.",
                    "Currents in the Cape Cod Canal can exceed 5 knots, making it one of the most challenging waterways on the East Coast.",
                    "Harbor pilots typically board vessels via rope ladder, sometimes climbing 30 feet or more up the side of a ship."
                ]
            )

        case .fourthOfJulyParades:
            return (
                "Sparklers and Sand: Fourth of July on Cape Cod",
                """
                There is no Fourth of July quite like a Cape Cod Fourth of July. In a nation of spectacular Independence Day celebrations, the Cape's version is deliberately, defiantly small-town — and that's exactly what makes it magical.

                Every town on the Cape has its own parade, and the friendly rivalry between them is part of the fun. Chatham's parade features antique cars and the Chatham Band, which has been performing since 1932. Orleans runs a pancake breakfast before its parade. Provincetown's celebration is famously eccentric, with floats that range from the patriotic to the surreal.

                But the heart of Cape Cod's Fourth is the family experience. It starts early — kids decorating their bikes with red, white, and blue streamers in the driveway. Then the walk to Main Street, staking out a spot on the curb with lawn chairs and blankets. The parade itself is a procession of fire trucks, Scout troops, Little League teams, and local politicians waving from convertibles. It's not the Macy's parade, and it doesn't want to be.

                After the parade, the Cape shifts into beach mode. Families pack coolers with hot dogs and watermelon and head for their favorite beach. The Fourth falls near the peak of the summer season, and the beaches are crowded with a mix of year-rounders and summer visitors, all claiming their patch of sand with umbrellas and towels.

                As evening falls, the fireworks begin. Nearly every harbor town launches its own display — Falmouth over the harbor, Chatham over Oyster Pond, Hyannis over Lewis Bay. Families spread blankets on the beach and watch the explosions of color reflected in the dark water. The smell of gunpowder mixes with salt air. Children wave sparklers, writing their names in light against the darkening sky.

                The Cape Cod Fourth of July is a celebration of the simple and the local. It's about community more than spectacle. It's about the kid on the decorated bicycle, the volunteer firefighter driving the antique pumper, the grandmother watching from her lawn chair as the parade passes her house for the fiftieth year in a row. It's America at its most intimate, and it happens every year on this narrow strip of sand reaching into the Atlantic.
                """,
                [
                    "The Chatham Band, featured in the town's July 4th parade, has been performing continuously since 1932.",
                    "Cape Cod's population can triple during the Fourth of July week, from about 215,000 to over 600,000.",
                    "Many Cape towns hold their fireworks over harbors so the colors reflect off the water."
                ]
            )

        case .blessingOfTheFleet:
            return (
                "Blessing of the Fleet: A Sacred Tradition",
                """
                Every June in Provincetown, the fishing boats dress in their finest. Flags and pennants stream from their rigging, flowers adorn their bows, and their hulls gleam with fresh paint. It's the Blessing of the Fleet, a ceremony that honors the fishermen who risk their lives on the sea and asks for divine protection in the season ahead.

                The tradition came to Cape Cod with the Portuguese fishing families who settled in Provincetown in the 19th century. In the Azores and mainland Portugal, the blessing of fishing boats before the season was an ancient custom, rooted in the Catholic faith and the practical reality that the sea was dangerous and unpredictable. A blessing couldn't guarantee safety, but it offered comfort — a sense that the fishermen were not alone on the water.

                The ceremony centers on the bishop's procession along MacMillan Wharf. As each decorated boat passes, the bishop sprinkles holy water on the bow and offers a prayer for the safety of the crew. The fleet processes slowly through the harbor, their engines rumbling, their flags snapping in the breeze. It's a solemn and beautiful spectacle that draws thousands of visitors.

                But the Blessing of the Fleet is more than a religious ceremony. It's a community celebration that marks the beginning of summer and honors Provincetown's maritime heritage. The weekend includes a parade, a carnival, Portuguese cultural events, and enough food to feed an army — linguica sandwiches, kale soup, malassadas (Portuguese fried dough), and fresh seafood of every kind.

                For the fishing families, the blessing carries real emotional weight. These are people who know the sea's capacity for violence. They've lost friends and family members to storms, equipment failures, and the simple bad luck that comes with working on open water. The blessing acknowledges that danger and meets it with faith, community, and the stubborn determination to go out again tomorrow.

                The Blessing of the Fleet is one of Cape Cod's most moving traditions — a moment when a community pauses to honor the people who feed it, to remember those who didn't come home, and to send its fleet out into the unknown with hope, prayer, and a spray of holy water gleaming on the bow.
                """,
                [
                    "Provincetown's Blessing of the Fleet has been held annually since the early 1900s.",
                    "The tradition originated in Mediterranean fishing communities and was brought to Cape Cod by Portuguese immigrants.",
                    "The ceremony typically takes place on the last Sunday in June."
                ]
            )

        case .cranberryHarvest:
            return (
                "When the Bogs Turn Red",
                """
                Every October, something extraordinary happens on Cape Cod. The cranberry bogs, which have spent the summer as unremarkable fields of low green vines, flood with water and transform into lakes of brilliant crimson. It's the wet harvest, and it's one of the most visually stunning agricultural events in America.

                The process begins when the grower floods the bog with about 18 inches of water from an adjacent reservoir. Then specialized machines called water reels — they look like oversized lawn mowers — drive through the flooded bog, gently dislodging the berries from the vines. Because cranberries have four internal air chambers, they float to the surface, creating a carpet of red that stretches to the horizon.

                Workers in hip waders then corral the floating berries using flexible booms, guiding them toward a corner of the bog where they're pumped into trucks for processing. A single acre can produce 150 to 200 barrels of berries — that's roughly 15,000 to 20,000 pounds of cranberries from a field the size of a football field.

                The harvest is a sensory experience. The bogs smell of earth and fruit and cold water. The berries make a soft rushing sound as they're pushed together by the booms. The workers move with practiced efficiency, their waders splashing, their breath visible in the cool morning air. It's backbreaking work, but there's a quiet satisfaction in it — the annual reward for a year of tending, sanding, and pest management.

                Cape Cod's cranberry harvest has become a tourist attraction in its own right. Visitors line up along the roads that border the bogs, cameras and phones held high, capturing the otherworldly beauty of those red fields. Some farms offer guided tours, letting visitors walk the bog dikes and even wade into the berries for photos.

                The timing of the harvest coincides with Cape Cod's most beautiful season. The salt marshes have turned gold, the oak forests are ablaze with color, and the summer crowds have departed, leaving the Cape to the year-rounders and the lucky few who know that autumn is the best-kept secret of this sandy peninsula.
                """,
                [
                    "Massachusetts is the second-largest cranberry-producing state, after Wisconsin.",
                    "A cranberry that bounces is a fresh cranberry — the air chambers that make them float also make them bounce.",
                    "The wet harvest method accounts for about 90% of all cranberries harvested commercially."
                ]
            )

        case .summerTheater:
            return (
                "The Show Must Go On: Summer Theater on the Cape",
                """
                Every summer, as the beaches fill and the ice cream shops open, another Cape Cod tradition comes alive: the summer theaters. From Falmouth to Provincetown, stages light up with productions that range from Broadway tryouts to experimental one-person shows, continuing a theatrical tradition that helped define American drama.

                It all began in Provincetown in 1915, when a group of writers and artists vacationing at the tip of the Cape decided to put on plays in a fish house on a wharf. They called themselves the Provincetown Players, and among their members was a brooding young man from New York named Eugene O'Neill. The plays O'Neill wrote and staged in that fish house — raw, realistic dramas about working people and the sea — would eventually win him the Nobel Prize and change American theater forever.

                The Provincetown Players proved that great theater could happen anywhere — even in a building that smelled like mackerel. Their success inspired a wave of summer theaters across Cape Cod. The Cape Playhouse in Dennis, opened in 1927, became known as the "Birthplace of the Stars." Its stage launched the careers of Bette Davis, Henry Fonda, Humphrey Bogart, and countless others who used summer stock as a stepping stone to Broadway and Hollywood.

                The Cape Cod tradition of summer theater endures because it offers something that Broadway cannot: intimacy. In a 200-seat theater in Wellfleet or a converted church in Chatham, you sit close enough to see the actors' expressions, to hear their breathing, to feel the energy of live performance in a way that vast commercial theaters can't replicate.

                For the actors, summer stock on the Cape is a rite of passage. Young performers share cramped houses, rehearse all day, perform at night, and tear down one set to build another in the hours between. It's exhausting, exhilarating, and formative. Many of today's Broadway and Hollywood stars spent their early summers on a Cape Cod stage.

                The summer theaters also serve the community. They bring cultural richness to small towns, provide employment, and create gathering places where residents and visitors share the experience of live storytelling. On a warm Cape Cod evening, sitting in a darkened theater as a story unfolds on stage, you're participating in a tradition that stretches back over a century to a fish house on a wharf in Provincetown, where it all began.
                """,
                [
                    "The Cape Playhouse in Dennis has been in continuous operation since 1927.",
                    "Bette Davis got her start as an usher at the Cape Playhouse before being cast in productions.",
                    "Eugene O'Neill wrote over 20 plays while living on Cape Cod."
                ]
            )

        default:
            // Generic fallback for any future topics without a specific story
            let categoryStories: [String: (String, String, [String])] = [
                "History": (
                    "Echoes of Cape Cod's Past",
                    """
                    Cape Cod's history stretches back thousands of years, long before European explorers first spotted its sandy shores from the decks of their sailing ships. The Wampanoag people had lived on the Cape for over 10,000 years, fishing its waters, hunting in its forests, and gathering shellfish from its tidal flats.

                    When the Pilgrims arrived in 1620, they found a land shaped by both nature and human hands. The Wampanoag had cleared forests for farming, maintained trails between villages, and developed sophisticated techniques for harvesting the sea's bounty. Their knowledge of the land would prove essential to the survival of the early European settlers.

                    Through the centuries that followed, Cape Cod evolved from a farming and fishing community into one of America's most beloved destinations. Its towns preserve layers of history in their architecture — from the oldest house in Sandwich, built in 1637, to the grand sea captains' homes that line the streets of Yarmouth and Dennis, each one a testament to the fortunes made in the China trade.

                    The Cape's history is written in its landscape: in the cranberry bogs carved from wetlands, in the harbors dredged for fishing fleets, in the salt works that once lined every bay, and in the stone walls that snake through forests that were once open pasture. Every path, every beach, every weathered shingle tells a story of the people who came here, stayed, and made this narrow peninsula their home.
                    """,
                    [
                        "The Wampanoag people have lived on Cape Cod for over 10,000 years.",
                        "Cape Cod was named by English explorer Bartholomew Gosnold in 1602.",
                        "The Cape Cod Canal, completed in 1914, technically makes Cape Cod an island."
                    ]
                ),
                "Nature": (
                    "The Wild Heart of Cape Cod",
                    """
                    Cape Cod is a place shaped by elemental forces — ice, wind, water, and time. Twenty thousand years ago, a glacier a mile thick crept southward across New England, bulldozing rock and sediment before it. When the ice finally retreated, it left behind a curving arm of sand and gravel extending into the Atlantic: Cape Cod.

                    The Cape is still changing, still being sculpted by the sea. The outer shore loses an average of three feet per year to erosion, its sandy cliffs crumbling into the waves. But what the ocean takes from one side, it deposits on the other — the long sandbars of Provincetown are built from sand carried north by longshore currents, grain by grain.

                    This dynamic landscape supports an astonishing variety of life. The Cape's forests shelter white-tailed deer, red foxes, and coyotes that crossed the Cape Cod Canal bridge and established thriving populations. Its ponds — called kettle ponds because they formed in depressions left by melting blocks of glacial ice — harbor rare species of fish and turtles found nowhere else.

                    The coastline is a ribbon of distinct habitats: sandy beaches where piping plovers nest, rocky shores where tide pools teem with sea stars and crabs, salt marshes where herons stalk through the cordgrass, and eelgrass meadows where bay scallops find shelter. Each habitat supports its own community of creatures, all connected in an intricate web of life that has been evolving since the glacier departed.
                    """,
                    [
                        "Cape Cod was formed by the Laurentide Ice Sheet approximately 20,000 years ago.",
                        "The Cape's outer beach erodes an average of 3 feet per year.",
                        "Kettle ponds on Cape Cod formed from melting blocks of glacial ice and have no inlet or outlet streams."
                    ]
                )
            ]

            let categoryKey = topic.storyCategory.rawValue.capitalized
            if let specific = categoryStories[categoryKey] {
                return specific
            }

            return (
                "A Cape Cod Tale: \(topic.displayName)",
                """
                Cape Cod has always been a place of stories. From the Wampanoag legends passed down through generations to the yarns spun by old salts in waterfront taverns, this narrow peninsula reaching into the Atlantic has inspired storytellers for millennia.

                \(topic.displayName) is woven into the very fabric of Cape Cod life. Walk through any of the Cape's fifteen towns and you'll find traces of this heritage — in the architecture, in the place names, in the way people talk about their home with a mix of pride and salt-air practicality.

                The story of \(topic.displayName) on Cape Cod is really a story about the relationship between people and place. It's about how a community shaped by wind, water, and isolation developed its own distinctive character — tough, resourceful, and deeply connected to the natural world that sustains it.

                Today, as Cape Cod faces new challenges from climate change to development pressures, the stories of its past offer both guidance and inspiration. They remind us that this place has always been changing, always adapting, and that the spirit of the people who call it home is as enduring as the tides that shaped its shores.
                """,
                [
                    "Cape Cod's unique geography was created by glacial activity over 20,000 years ago.",
                    "The Cape Cod National Seashore, established in 1961, protects 40 miles of coastline.",
                    "Cape Cod has 15 towns, from Bourne at the canal to Provincetown at the tip."
                ]
            )
        }
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
                Image(systemName: "book.closed.fill")
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

    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.capeCod.deepNavy.ignoresSafeArea()

            VStack(spacing: CodSpacing.xl) {
                Spacer()

                if let errorMessage {
                    // Error state
                    VStack(spacing: CodSpacing.lg) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(Color.capeCod.sunsetOrange)

                        Text("Couldn't generate story")
                            .codTextStyle(.sectionTitle)
                            .foregroundStyle(.white)

                        Text(errorMessage)
                            .codTextStyle(.body)
                            .foregroundStyle(.white.opacity(0.6))
                            .multilineTextAlignment(.center)

                        // Retry with fallback
                        Button {
                            self.errorMessage = nil
                            useFallbackStory()
                        } label: {
                            HStack(spacing: CodSpacing.sm) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 14))
                                Text("Read a Cape Cod Story Instead")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, CodSpacing.lg)
                            .padding(.vertical, CodSpacing.md)
                            .background(Color.capeCod.oceanGradient)
                            .clipShape(Capsule())
                        }
                        .padding(.top, CodSpacing.sm)
                    }
                    .padding(.horizontal, CodSpacing.xl)
                } else {
                    // Loading state
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

                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.capeCod.seafoam))
                        .scaleEffect(1.2)
                }

                Spacer()

                if errorMessage == nil {
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
                }

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
            case .error(let message):
                CodHaptic.error()
                withAnimation(CodAnimation.gentle) {
                    errorMessage = message
                }
            default:
                break
            }
        }
    }

    private func useFallbackStory() {
        let story = StoryGeneratorService.fallbackStory(for: topic, mode: mode)
        storyService.generationState = .complete(story)
        storyService.recentStories.insert(story, at: 0)
        CodHaptic.success()
        onStoryReady(story)
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
