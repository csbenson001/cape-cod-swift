import Foundation
import SwiftUI

// MARK: - Story Persona

/// Narrator personas that reinterpret POI stories through distinct character voices.
enum StoryPersona: String, CaseIterable, Identifiable {
    case captainSalty
    case marineBiologist
    case ghostHunter
    case localHistorian
    case foodieCritic
    case adventureGuide

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .captainSalty: "Captain Salty"
        case .marineBiologist: "Dr. Marina Shore"
        case .ghostHunter: "Vincent Graves"
        case .localHistorian: "Professor Eldridge"
        case .foodieCritic: "Chef Delphine"
        case .adventureGuide: "Ranger Kai"
        }
    }

    var icon: String {
        switch self {
        case .captainSalty: "sailboat.fill"
        case .marineBiologist: "fish.fill"
        case .ghostHunter: "moon.stars.fill"
        case .localHistorian: "book.fill"
        case .foodieCritic: "fork.knife"
        case .adventureGuide: "figure.hiking"
        }
    }

    var voiceDescription: String {
        switch self {
        case .captainSalty:
            "A weathered old sea captain with a gravelly voice, salty humor, and a nautical metaphor for every occasion. Speaks in colorful maritime slang and always ties things back to the sea."
        case .marineBiologist:
            "An enthusiastic marine biologist who sees the natural world in everything. Passionate about ecosystems, tidal patterns, and wildlife. Educational but never boring — full of wonder."
        case .ghostHunter:
            "A dramatic paranormal investigator who views every shadow as supernatural. Speaks in hushed, suspenseful tones and finds the eerie side of even the most cheerful locations."
        case .localHistorian:
            "A warm, academic historian with deep roots on the Cape. Connects every location to fascinating stories across centuries, from the Wampanoag to the Kennedys, with genuine affection."
        case .foodieCritic:
            "A passionate culinary storyteller who experiences the world through taste and aroma. Rich sensory descriptions, flavor metaphors, and an insatiable curiosity about local food culture."
        case .adventureGuide:
            "An energetic outdoor adventure guide who radiates positivity. Motivational, action-oriented, always pointing out the next trail, tide pool, or sunset spot. Makes everything feel like an expedition."
        }
    }

    var systemPrompt: String {
        switch self {
        case .captainSalty:
            """
            You are Captain Salty, a retired sea captain who has sailed the waters off Cape Cod for over 40 years. \
            You speak with a gravelly voice full of nautical metaphors and salty humor. You call the listener \
            "shipmate" or "sailor." You relate everything to the sea — weather is "readin' the sky," walking is \
            "makin' headway," and a good view is "a fine horizon." You pepper your stories with phrases like \
            "I'll tell ye," "mark my words," and "by the barnacles." You have a deep love for Cape Cod and its \
            maritime heritage, and you weave in tales of storms, whales, and old fishing days. Keep it colorful, \
            warm, and entertaining.
            """
        case .marineBiologist:
            """
            You are Dr. Marina Shore, a marine biologist who has studied Cape Cod's ecosystems for two decades. \
            You are passionate about the natural world and see ecological connections everywhere. You explain \
            things through the lens of science — tidal patterns, migration routes, dune ecology, salt marsh \
            cycles. You get visibly excited about wildlife sightings and seasonal changes. You use accessible \
            scientific language, always making concepts approachable. You love sharing surprising facts about \
            how nature shapes every part of Cape Cod, from the sand beneath your feet to the osprey overhead.
            """
        case .ghostHunter:
            """
            You are Vincent Graves, a paranormal investigator who has cataloged supernatural activity across \
            Cape Cod for years. You speak in dramatic, suspenseful tones and find the eerie side of every \
            location. Shipwrecks have restless crews, old inns have unexplained footsteps, and foggy beaches \
            hide spectral figures. You reference cold spots, EMF readings, and local legends of hauntings. \
            Even cheerful places get the spooky treatment — you might note an "unusual energy" at a lighthouse \
            or a "presence" near historic buildings. Keep it thrilling and atmospheric, never truly terrifying, \
            but always deliciously creepy.
            """
        case .localHistorian:
            """
            You are Professor Eldridge, a Cape Cod historian who grew up in Chatham and has spent a lifetime \
            studying the region's rich past. You are academic but warm, weaving connections across eras — from \
            the Wampanoag people to the Pilgrims, from whaling captains to artists' colonies, from the \
            railroad era to modern conservation. You love revealing how the past shaped the present: why a \
            street has its name, what a building used to be, how a storm changed the coastline. You speak with \
            genuine affection for the Cape and its resilient people, always finding the human story in history.
            """
        case .foodieCritic:
            """
            You are Chef Delphine, a culinary storyteller who experiences Cape Cod entirely through taste, \
            aroma, and food culture. You describe locations in sensory terms — the salt air that flavors \
            everything, the cranberry bogs that paint the landscape, the clam shacks that define summer. You \
            use flavor metaphors: a sunset is "honey-glazed," a beach is "salt-kissed," history is "layered \
            like a New England bouillabaisse." You know the food traditions behind every town — Portuguese \
            linguica in Provincetown, oysters in Wellfleet, cranberry everything in the bogs. You make the \
            listener hungry for both knowledge and a good meal.
            """
        case .adventureGuide:
            """
            You are Ranger Kai, an outdoor adventure guide who has led expeditions across every trail, beach, \
            and waterway on Cape Cod. You are energetic, motivational, and action-oriented. You speak with \
            infectious enthusiasm — every location is an opportunity for adventure. You point out kayak \
            launches, cycling routes, hiking trails, tide pools to explore, and the best spots for sunrise \
            or sunset. You use phrases like "let's go!", "check this out," and "you're gonna love this." \
            You encourage the listener to get out there, try something new, and experience Cape Cod actively \
            rather than passively. Keep the energy high and the tone uplifting.
            """
        }
    }

    var themeColor: Color {
        switch self {
        case .captainSalty: Color.capeCod.oceanBlue
        case .marineBiologist: Color.capeCod.seafoam
        case .ghostHunter: Color.capeCod.cranberry
        case .localHistorian: Color.capeCod.sunsetOrange
        case .foodieCritic: Color.capeCod.sandbarYellow
        case .adventureGuide: Color.capeCod.duneGrass
        }
    }
}

// MARK: - Story Persona Service

@preconcurrency @MainActor
@Observable
final class StoryPersonaService {

    // MARK: - Public State

    var selectedPersona: StoryPersona = .localHistorian
    private(set) var isGenerating: Bool = false
    private(set) var generatedScript: String?
    private(set) var error: String?

    // MARK: - Private

    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Generate Persona Story

    /// Generates a full narrated story for a POI in the selected persona's voice.
    /// Returns a `StoryVariant` with the generated script and estimated duration,
    /// or `nil` if generation fails.
    func generatePersonaStory(
        for poi: PointOfInterest,
        persona: StoryPersona,
        mode: ExperienceMode
    ) async -> StoryVariant? {
        isGenerating = true
        generatedScript = nil
        error = nil

        defer { isGenerating = false }

        let prompt = buildStoryPrompt(for: poi, persona: persona, mode: mode)

        do {
            let reply = try await sendChatRequest(message: prompt, mode: mode)

            generatedScript = reply

            let wordCount = reply.split(separator: " ").count
            let durationSeconds = Double(wordCount) / 150.0 * 60.0

            let storyMode: GeofenceManager.StoryMode = switch mode {
            case .kids: .kids
            case .family: .family
            case .adult, .teen: .adult
            }

            return StoryVariant(
                title: "\(persona.displayName): \(poi.name)",
                mode: storyMode,
                script: reply,
                duration: durationSeconds
            )
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }

    // MARK: - Suggest Persona

    /// Suggests the best-fitting persona for a given POI based on its category,
    /// name, and description.
    func suggestPersona(for poi: PointOfInterest) -> StoryPersona {
        let searchText = "\(poi.name) \(poi.description)".lowercased()

        // Check for spooky/supernatural keywords first (overrides category)
        let spookyKeywords = ["ghost", "pirate", "haunted", "shipwreck", "mystery", "legend", "supernatural", "cemetery"]
        if spookyKeywords.contains(where: { searchText.contains($0) }) {
            return .ghostHunter
        }

        // Category-based matching
        switch poi.category {
        case .lighthouse, .marina:
            return .captainSalty
        case .nature, .beach:
            // If trail-related, prefer adventure guide
            let trailKeywords = ["trail", "hike", "kayak", "bike", "path", "walk", "paddle"]
            if trailKeywords.contains(where: { searchText.contains($0) }) {
                return .adventureGuide
            }
            return .marineBiologist
        case .historic:
            return .localHistorian
        case .museum:
            // Museums with spooky themes already caught above
            return .localHistorian
        case .restaurant:
            return .foodieCritic
        case .entertainment, .shopping, .lodging:
            // Default to local historian for general interest categories
            return .localHistorian
        }
    }

    // MARK: - Generate Quick Facts

    /// Generates 3-4 fun facts about a POI in the persona's voice.
    func generateQuickFacts(
        for poi: PointOfInterest,
        persona: StoryPersona
    ) async -> [String]? {
        let prompt = """
            You are \(persona.displayName). \(persona.systemPrompt)

            Generate exactly 3 to 4 fun, surprising facts about \(poi.name) in \(poi.town.displayName), Cape Cod.
            Category: \(poi.category.displayName).
            Description: \(poi.description)
            \(poi.facts.isEmpty ? "" : "Known facts: \(poi.facts.joined(separator: "; "))")

            Stay fully in character. Each fact should be 1-2 sentences in your unique voice.
            Return ONLY the facts, one per line, prefixed with a number and period (e.g., "1. ...").
            Do not include any other text.
            """

        do {
            let reply = try await sendChatRequest(message: prompt, mode: .adult)

            let facts = reply
                .components(separatedBy: .newlines)
                .map { line in
                    // Strip leading number/period prefix like "1. " or "2. "
                    line.replacingOccurrences(
                        of: #"^\d+\.\s*"#,
                        with: "",
                        options: .regularExpression
                    )
                }
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

            return facts.isEmpty ? nil : facts
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }

    // MARK: - Private Helpers

    private func buildStoryPrompt(
        for poi: PointOfInterest,
        persona: StoryPersona,
        mode: ExperienceMode
    ) -> String {
        let modeGuidance: String = switch mode {
        case .kids:
            "This story is for CHILDREN (ages 5-10). Use simple words, short sentences, a playful tone, and age-appropriate content. Make it fun and engaging, like a storybook."
        case .family:
            "This story is for a FAMILY audience (mixed ages). Make it engaging for both adults and children — include wonder and humor alongside real information. Keep language accessible but not childish."
        case .teen:
            "This story is for TEENAGERS. Keep it interesting and a bit edgy — no talking down. Include cool details, surprising facts, and a conversational tone they would actually enjoy."
        case .adult:
            "This story is for ADULTS. Use rich vocabulary, nuanced storytelling, and deeper historical or cultural context. It is fine to include complexity and layered narratives."
        }

        var prompt = """
            You are \(persona.displayName). \(persona.systemPrompt)

            \(modeGuidance)

            Tell a compelling narrated story about the following Cape Cod location:

            Name: \(poi.name)
            Town: \(poi.town.displayName) (\(poi.town.region.rawValue))
            Category: \(poi.category.displayName)
            Description: \(poi.description)
            """

        if !poi.facts.isEmpty {
            prompt += "\nKey Facts: \(poi.facts.joined(separator: "; "))"
        }

        if !poi.tips.isEmpty {
            prompt += "\nVisitor Tips: \(poi.tips.joined(separator: "; "))"
        }

        prompt += """

            Write a narrated story of roughly 200-350 words, fully in character. \
            The story should feel like a guided audio tour segment — immersive, personal, \
            and rooted in this specific place. Do not break character. Return only the narration script.
            """

        return prompt
    }

    private func sendChatRequest(message: String, mode: ExperienceMode) async throws -> String {
        let baseURL = APIClient.shared.baseURL
        let url = baseURL.appendingPathComponent("chat")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = APIClient.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "message": message,
            "mode": mode.rawValue,
            "history": [] as [[String: String]]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.requestFailed
        }

        if httpResponse.statusCode == 429 {
            throw AIServiceError.rateLimited
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw AIServiceError.requestFailed
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let reply = json["message"] as? String else {
            throw AIServiceError.invalidResponse
        }

        return reply
    }
}
