import Foundation
import CoreLocation

/// AI-powered tour generator that creates personalized tours based on user interests,
/// location, available time, and preferences.
@preconcurrency @MainActor
@Observable
final class TourGeneratorService {
    static let shared = TourGeneratorService()

    private(set) var isGenerating = false
    private(set) var generatedTour: GuidedTour?
    private(set) var error: String?

    private init() {}

    /// Generate a custom tour using AI based on user preferences.
    func generateTour(request: TourRequest) async -> GuidedTour? {
        isGenerating = true
        error = nil
        defer { isGenerating = false }

        do {
            let prompt = buildPrompt(from: request)
            let response = try await callAIForTour(prompt: prompt, request: request)
            generatedTour = response
            return response
        } catch {
            self.error = error.localizedDescription
            // Fall back to best-match curated tour
            let fallback = bestMatchCuratedTour(for: request)
            generatedTour = fallback
            return fallback
        }
    }

    /// Build a tour from specific interest keywords (quick generation).
    func quickGenerate(theme: TourTheme, duration: TourDuration, region: CapeRegion?) -> GuidedTour {
        let matchingPOIs = selectPOIsForTheme(theme, duration: duration, region: region)
        let stopIDs = matchingPOIs.map(\.id)

        return GuidedTour(
            id: "custom-\(theme.rawValue)-\(UUID().uuidString.prefix(6))",
            name: theme.tourName,
            subtitle: theme.subtitle,
            description: theme.description,
            icon: theme.icon,
            category: theme.tourCategory,
            estimatedDuration: duration.displayName,
            distance: estimateDistance(for: matchingPOIs),
            difficulty: .easy,
            stopIDs: stopIDs,
            region: region
        )
    }

    // MARK: - Private

    private func buildPrompt(from request: TourRequest) -> String {
        var parts: [String] = [
            "Create a personalized Cape Cod tour with these preferences:"
        ]

        if let theme = request.theme {
            parts.append("Theme: \(theme.displayName)")
        }
        if !request.interests.isEmpty {
            parts.append("Interests: \(request.interests.joined(separator: ", "))")
        }
        parts.append("Duration: \(request.duration.displayName)")
        if let region = request.region {
            parts.append("Region: \(region.rawValue)")
        }
        if let mode = request.experienceMode {
            parts.append("Experience mode: \(mode.rawValue)")
        }
        if request.includeFood {
            parts.append("Include restaurant stops")
        }
        if let avoidCrowds = request.avoidCrowds, avoidCrowds {
            parts.append("Prefer less crowded spots")
        }

        parts.append("\nAvailable POIs: \(BundledContent.allPOIs.map { "\($0.id): \($0.name) (\($0.category.displayName), \($0.town.displayName))" }.joined(separator: "; "))")
        parts.append("\nReturn a JSON object with: name, subtitle, description, stopIDs (array of POI IDs from the list above), estimatedDuration, difficulty (easy/moderate/challenging)")

        return parts.joined(separator: "\n")
    }

    private func callAIForTour(prompt: String, request: TourRequest) async throws -> GuidedTour {
        let aiRequest = try buildBackendRequest(prompt)
        let (data, response) = try await URLSession.shared.data(for: aiRequest)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw TourGeneratorError.apiError
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let message = json["message"] as? String else {
            throw TourGeneratorError.parseError
        }

        // Try to extract JSON from the AI response
        return parseTourFromAIResponse(message, request: request)
    }

    private func buildBackendRequest(_ prompt: String) throws -> URLRequest {
        let baseURL = APIClient.shared.baseURL
        let url = baseURL.appendingPathComponent("chat")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = APIClient.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "message": prompt,
            "mode": "adult",
            "history": []
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func parseTourFromAIResponse(_ response: String, request: TourRequest) -> GuidedTour {
        // Extract JSON from AI response (may be wrapped in markdown code blocks)
        var jsonString = response
        if let jsonStart = response.range(of: "{"),
           let jsonEnd = response.range(of: "}", options: .backwards) {
            jsonString = String(response[jsonStart.lowerBound...jsonEnd.upperBound])
        }

        // Try to parse structured response
        if let data = jsonString.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

            let name = json["name"] as? String ?? request.theme?.tourName ?? "Custom Tour"
            let subtitle = json["subtitle"] as? String ?? "A personalized Cape Cod experience"
            let description = json["description"] as? String ?? "An AI-curated tour tailored to your interests."
            let stopIDs = json["stopIDs"] as? [String] ?? json["stop_ids"] as? [String] ?? []
            let duration = json["estimatedDuration"] as? String ?? request.duration.displayName
            let difficultyStr = json["difficulty"] as? String ?? "easy"
            let difficulty = TourDifficulty(rawValue: difficultyStr) ?? .easy

            let validStopIDs = stopIDs.filter { stopID in
                BundledContent.allPOIs.contains { $0.id == stopID }
            }

            if !validStopIDs.isEmpty {
                return GuidedTour(
                    id: "ai-\(UUID().uuidString.prefix(8))",
                    name: name,
                    subtitle: subtitle,
                    description: description,
                    icon: request.theme?.icon ?? "sparkles",
                    category: request.theme?.tourCategory ?? .custom,
                    estimatedDuration: duration,
                    distance: estimateDistance(for: validStopIDs.compactMap { id in BundledContent.allPOIs.first { $0.id == id } }),
                    difficulty: difficulty,
                    stopIDs: validStopIDs,
                    region: request.region
                )
            }
        }

        // Fallback: use theme-based selection
        return quickGenerate(theme: request.theme ?? .explore, duration: request.duration, region: request.region)
    }

    private func selectPOIsForTheme(_ theme: TourTheme, duration: TourDuration, region: CapeRegion?) -> [PointOfInterest] {
        var candidates = BundledContent.allPOIs

        if let region {
            candidates = candidates.filter { $0.town.region == region }
        }

        // Score POIs by theme relevance
        let scored = candidates.map { poi -> (PointOfInterest, Int) in
            var score = 0
            for category in theme.relevantCategories {
                if poi.category == category { score += 10 }
            }
            for keyword in theme.keywords {
                if poi.name.localizedCaseInsensitiveContains(keyword) { score += 5 }
                if poi.description.localizedCaseInsensitiveContains(keyword) { score += 3 }
                for fact in poi.facts {
                    if fact.localizedCaseInsensitiveContains(keyword) { score += 2 }
                }
            }
            return (poi, score)
        }
        .filter { $0.1 > 0 }
        .sorted { $0.1 > $1.1 }

        let maxStops = duration.maxStops
        let selected = Array(scored.prefix(maxStops)).map(\.0)

        // If we don't have enough theme-specific POIs, add popular ones
        if selected.count < 2 {
            let fallback = candidates.prefix(maxStops)
            return Array(fallback)
        }

        return selected
    }

    private func bestMatchCuratedTour(for request: TourRequest) -> GuidedTour {
        if let theme = request.theme {
            let category = theme.tourCategory
            if let match = CuratedTours.all.first(where: { $0.category == category }) {
                return match
            }
        }
        return CuratedTours.all.first ?? CuratedTours.lighthouseTrail
    }

    private func estimateDistance(for pois: [PointOfInterest]) -> String {
        guard pois.count > 1 else { return "< 5 miles" }

        var totalMeters: Double = 0
        for i in 0..<pois.count - 1 {
            let from = CLLocation(latitude: pois[i].coordinate.latitude, longitude: pois[i].coordinate.longitude)
            let to = CLLocation(latitude: pois[i + 1].coordinate.latitude, longitude: pois[i + 1].coordinate.longitude)
            totalMeters += from.distance(from: to)
        }
        let miles = totalMeters / 1609.34
        return "\(Int(miles.rounded())) miles"
    }
}

// MARK: - Tour Request

struct TourRequest {
    var theme: TourTheme?
    var interests: [String] = []
    var duration: TourDuration = .halfDay
    var region: CapeRegion?
    var experienceMode: ExperienceMode?
    var includeFood: Bool = false
    var avoidCrowds: Bool? = nil
}

// MARK: - Tour Theme

enum TourTheme: String, CaseIterable, Identifiable {
    case pirate
    case haunted
    case maritime
    case foodie
    case romantic
    case nature
    case history
    case photography
    case family
    case art
    case adventure
    case explore

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pirate: "Pirate Adventure"
        case .haunted: "Haunted Cape Cod"
        case .maritime: "Maritime Heritage"
        case .foodie: "Foodie Crawl"
        case .romantic: "Romantic Getaway"
        case .nature: "Nature Explorer"
        case .history: "History Trail"
        case .photography: "Photo Tour"
        case .family: "Family Fun"
        case .art: "Art & Culture"
        case .adventure: "Outdoor Adventure"
        case .explore: "Best of Cape Cod"
        }
    }

    var tourName: String {
        switch self {
        case .pirate: "Pirate Adventure Tour"
        case .haunted: "Haunted Cape Cod After Dark"
        case .maritime: "Maritime Heritage Trail"
        case .foodie: "Cape Cod Foodie Crawl"
        case .romantic: "Romantic Cape Cod"
        case .nature: "Nature Explorer"
        case .history: "Cape Cod History Trail"
        case .photography: "Cape Cod Photo Tour"
        case .family: "Family Fun Day"
        case .art: "Art & Culture Trail"
        case .adventure: "Cape Cod Adventure"
        case .explore: "Best of Cape Cod"
        }
    }

    var subtitle: String {
        switch self {
        case .pirate: "Treasure, shipwrecks, and swashbuckling tales"
        case .haunted: "Ghosts, legends, and spine-tingling stories"
        case .maritime: "Fishing, sailing, and seafaring tradition"
        case .foodie: "Seafood shacks, oysters, and local fare"
        case .romantic: "Sunsets, strolls, and seaside charm"
        case .nature: "Forests, ponds, and coastal beauty"
        case .history: "From Pilgrims to presidents"
        case .photography: "The most stunning photo spots"
        case .family: "Kid-friendly Cape Cod highlights"
        case .art: "Galleries, studios, and creative Cape Cod"
        case .adventure: "Biking, kayaking, and outdoor thrills"
        case .explore: "A curated Cape Cod highlights tour"
        }
    }

    var description: String {
        "An AI-curated \(displayName.lowercased()) tailored to your preferences."
    }

    var icon: String {
        switch self {
        case .pirate: "flag.filled.and.flag.crossed"
        case .haunted: "moon.stars.fill"
        case .maritime: "sailboat.fill"
        case .foodie: "fork.knife"
        case .romantic: "heart.fill"
        case .nature: "leaf.fill"
        case .history: "building.columns.fill"
        case .photography: "camera.fill"
        case .family: "figure.2.and.child.holdinghands"
        case .art: "paintpalette.fill"
        case .adventure: "figure.hiking"
        case .explore: "sparkles"
        }
    }

    var tourCategory: TourCategory {
        switch self {
        case .pirate: .pirate
        case .haunted: .haunted
        case .maritime: .maritime
        case .foodie: .foodAndCulture
        case .romantic: .romantic
        case .nature: .nature
        case .history: .history
        case .photography: .photography
        case .family: .family
        case .art: .art
        case .adventure: .adventure
        case .explore: .custom
        }
    }

    var relevantCategories: [LocationCategory] {
        switch self {
        case .pirate: [.museum, .historic]
        case .haunted: [.lighthouse, .historic, .entertainment]
        case .maritime: [.marina, .lighthouse, .historic]
        case .foodie: [.restaurant]
        case .romantic: [.lighthouse, .beach, .nature]
        case .nature: [.nature, .beach]
        case .history: [.historic, .museum]
        case .photography: [.lighthouse, .beach, .nature, .historic]
        case .family: [.museum, .entertainment, .beach, .nature]
        case .art: [.museum, .entertainment, .historic]
        case .adventure: [.nature, .beach]
        case .explore: LocationCategory.allCases
        }
    }

    var keywords: [String] {
        switch self {
        case .pirate: ["pirate", "shipwreck", "treasure", "Whydah", "Bellamy"]
        case .haunted: ["ghost", "haunted", "eerie", "legend", "storm", "shipwreck", "night"]
        case .maritime: ["fish", "sail", "boat", "marine", "harbor", "lighthouse", "whaling"]
        case .foodie: ["food", "restaurant", "seafood", "oyster", "lobster", "clam", "dining"]
        case .romantic: ["sunset", "scenic", "view", "romantic", "stroll", "boardwalk"]
        case .nature: ["nature", "forest", "pond", "trail", "bird", "wildlife", "beach"]
        case .history: ["history", "historic", "pilgrims", "colonial", "president", "Kennedy"]
        case .photography: ["view", "scenic", "iconic", "photographed", "cliff", "sunset"]
        case .family: ["family", "kids", "fun", "interactive", "carousel", "swim"]
        case .art: ["art", "gallery", "museum", "culture", "theater", "Provincetown"]
        case .adventure: ["bike", "kayak", "hike", "surf", "adventure", "trail"]
        case .explore: ["popular", "famous", "iconic", "must-see"]
        }
    }
}

// MARK: - Tour Duration

enum TourDuration: String, CaseIterable, Identifiable {
    case quick      // 1-2 hours, 2-3 stops
    case halfDay    // 3-4 hours, 3-4 stops
    case fullDay    // 6-8 hours, 5-7 stops
    case multiDay   // 2+ days

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .quick: "1-2 hours"
        case .halfDay: "3-4 hours"
        case .fullDay: "Full day"
        case .multiDay: "Multi-day"
        }
    }

    var maxStops: Int {
        switch self {
        case .quick: 3
        case .halfDay: 4
        case .fullDay: 6
        case .multiDay: 10
        }
    }
}

// MARK: - Errors

enum TourGeneratorError: LocalizedError {
    case apiError
    case parseError
    case noStopsFound

    var errorDescription: String? {
        switch self {
        case .apiError: "Could not reach the tour generator. Using curated tours instead."
        case .parseError: "Could not parse the tour. Using curated tours instead."
        case .noStopsFound: "No matching stops found for your preferences."
        }
    }
}
