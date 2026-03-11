import Foundation

/// Smart beach recommendation engine.
/// Factors: wind direction (windward = choppier), tide (low = more sand),
/// crowds (weekday vs weekend), user mode (kids = calm water), water temp, UV.
struct BeachRecommendation {
    let beachName: String
    let rating: BeachRating
    let summary: String
    let details: String
    let factors: [RecommendationFactor]

    enum BeachRating: String {
        case great = "Great day for the beach!"
        case good = "Good beach conditions"
        case caution = "Use caution"
        case notRecommended = "Best for a beach walk"

        var color: String {
            switch self {
            case .great: return "duneGrass"
            case .good: return "oceanBlue"
            case .caution: return "sandbarYellow"
            case .notRecommended: return "cranberry"
            }
        }

        var icon: String {
            switch self {
            case .great: return "checkmark.circle.fill"
            case .good: return "hand.thumbsup.fill"
            case .caution: return "exclamationmark.triangle.fill"
            case .notRecommended: return "figure.walk.circle.fill"
            }
        }
    }

    struct RecommendationFactor {
        let icon: String
        let label: String
        let value: String
        let isPositive: Bool
    }
}

/// Cape Cod beach profiles for smart recommendations.
struct CapeCodBeach: Identifiable {
    let id: String
    let name: String
    let town: String
    let side: BeachSide
    let isKidFriendly: Bool
    let hasTidePools: Bool
    let hasLifeguards: Bool // seasonal
    let bestWindDirection: String // winds FROM this direction make it calmer
    let description: String

    enum BeachSide: String {
        case bayside  // calmer, warmer water, better for kids
        case oceanside // bigger waves, cooler water
        case sound    // Nantucket Sound — moderate
    }
}

enum BeachRecommendationEngine {

    // MARK: - Beach Database

    static let beaches: [CapeCodBeach] = [
        CapeCodBeach(id: "skaket", name: "Skaket Beach", town: "Orleans",
            side: .bayside, isKidFriendly: true, hasTidePools: true, hasLifeguards: true,
            bestWindDirection: "S", description: "Huge tidal flats at low tide, warm shallow water, amazing sunsets"),
        CapeCodBeach(id: "nauset", name: "Nauset Beach", town: "Orleans",
            side: .oceanside, isKidFriendly: false, hasTidePools: false, hasLifeguards: true,
            bestWindDirection: "W", description: "Long barrier beach with big surf, great for experienced swimmers"),
        CapeCodBeach(id: "coast-guard", name: "Coast Guard Beach", town: "Eastham",
            side: .oceanside, isKidFriendly: false, hasTidePools: false, hasLifeguards: true,
            bestWindDirection: "W", description: "National Seashore gem, shuttle access in summer"),
        CapeCodBeach(id: "marconi", name: "Marconi Beach", town: "Wellfleet",
            side: .oceanside, isKidFriendly: false, hasTidePools: false, hasLifeguards: true,
            bestWindDirection: "W", description: "Dramatic cliffs, where the first transatlantic wireless signal was sent"),
        CapeCodBeach(id: "mayflower", name: "Mayflower Beach", town: "Dennis",
            side: .bayside, isKidFriendly: true, hasTidePools: true, hasLifeguards: true,
            bestWindDirection: "S", description: "Wide sandy flats at low tide, warm bay water, family favorite"),
        CapeCodBeach(id: "chapin", name: "Chapin Memorial Beach", town: "Dennis",
            side: .bayside, isKidFriendly: true, hasTidePools: false, hasLifeguards: false,
            bestWindDirection: "S", description: "Drive-on beach, great for families with gear"),
        CapeCodBeach(id: "race-point", name: "Race Point Beach", town: "Provincetown",
            side: .oceanside, isKidFriendly: false, hasTidePools: false, hasLifeguards: true,
            bestWindDirection: "S", description: "Wild and remote, whale watching from shore, spectacular dunes"),
        CapeCodBeach(id: "herring-cove", name: "Herring Cove Beach", town: "Provincetown",
            side: .bayside, isKidFriendly: true, hasTidePools: false, hasLifeguards: true,
            bestWindDirection: "E", description: "Calmer water, famous sunsets, accessible"),
        CapeCodBeach(id: "old-silver", name: "Old Silver Beach", town: "Falmouth",
            side: .sound, isKidFriendly: true, hasTidePools: false, hasLifeguards: true,
            bestWindDirection: "N", description: "Warm Buzzards Bay water, gentle waves, popular family beach"),
        CapeCodBeach(id: "sandy-neck", name: "Sandy Neck Beach", town: "Barnstable",
            side: .bayside, isKidFriendly: true, hasTidePools: false, hasLifeguards: false,
            bestWindDirection: "S", description: "6-mile barrier beach, off-road vehicle access, piping plover habitat"),
        CapeCodBeach(id: "town-neck", name: "Town Neck Beach", town: "Sandwich",
            side: .bayside, isKidFriendly: true, hasTidePools: false, hasLifeguards: false,
            bestWindDirection: "S", description: "Views of Cape Cod Canal, boardwalk access, family friendly"),
        CapeCodBeach(id: "craigville", name: "Craigville Beach", town: "Barnstable",
            side: .sound, isKidFriendly: true, hasTidePools: false, hasLifeguards: true,
            bestWindDirection: "N", description: "Warm Nantucket Sound water, classic Cape beach"),
    ]

    // MARK: - Recommendation Engine

    static func recommend(
        weather: WeatherData,
        waterTemp: Double?,
        waveHeight: Double?,
        tideStatus: TideStatus,
        nextTide: TidePrediction?,
        mode: GeofenceManager.StoryMode = .adult
    ) -> BeachRecommendation {
        let current = weather.current
        let windDir = current.windDirection

        // Score each beach
        var bestBeach = beaches[0]
        var bestScore = -999.0

        for beach in beaches {
            var score = 0.0

            // Wind factor: beaches sheltered from current wind score higher
            if isWindSheltered(beach: beach, windDirection: windDir) {
                score += 20
            } else {
                score -= 10
            }

            // Kids mode: strongly prefer bayside/calm beaches
            if mode == .kids || mode == .family {
                if beach.isKidFriendly { score += 25 }
                if beach.side == .bayside { score += 15 }
                if beach.side == .oceanside { score -= 20 }
            }

            // Tide factor: low tide = more sand, better for bayside
            if tideStatus == .falling && beach.side == .bayside {
                score += 15
                if beach.hasTidePools { score += 10 }
            }

            // Wave factor: high waves bad for kids, good for surfers
            if let waves = waveHeight {
                if waves > 4 && beach.side == .oceanside {
                    if mode == .kids || mode == .family { score -= 20 }
                    else { score += 5 }
                }
                if waves < 2 && beach.side == .bayside { score += 5 }
            }

            // Weekend crowd avoidance: less popular beaches score slightly higher
            let isWeekend = Calendar.current.isDateInWeekend(.now)
            if isWeekend && !beach.hasLifeguards {
                score += 5 // less crowded
            }

            // Lifeguard bonus for families
            if (mode == .kids || mode == .family) && beach.hasLifeguards {
                score += 10
            }

            if score > bestScore {
                bestScore = score
                bestBeach = beach
            }
        }

        // Overall rating
        let rating = overallRating(weather: current, waveHeight: waveHeight)

        // Build factors
        var factors: [BeachRecommendation.RecommendationFactor] = []

        factors.append(.init(
            icon: "thermometer", label: "Air Temp",
            value: current.temperatureFormatted,
            isPositive: current.temperature >= 70
        ))

        if let waterTemp {
            factors.append(.init(
                icon: "water.waves", label: "Water Temp",
                value: "\(Int(waterTemp))°F",
                isPositive: waterTemp >= 60
            ))
        }

        if let waves = waveHeight {
            factors.append(.init(
                icon: "wind", label: "Waves",
                value: String(format: "%.1f ft", waves),
                isPositive: waves < 4
            ))
        }

        factors.append(.init(
            icon: "sun.max.fill", label: "UV Index",
            value: "\(current.uvIndex)",
            isPositive: current.uvIndex <= 5
        ))

        if let next = nextTide {
            factors.append(.init(
                icon: next.type.icon, label: next.type.displayName,
                value: next.timeFormatted,
                isPositive: true
            ))
        }

        // Build detail text
        let windDetail = isWindSheltered(beach: bestBeach, windDirection: windDir)
            ? "sheltered from today's \(windDir) wind"
            : "facing today's \(windDir) wind — expect some chop"
        let tideDetail = tideStatus == .falling
            ? "tide is going out — more sand to explore"
            : "tide is coming in — set up above the high water line"

        let summary: String
        if rating == .notRecommended {
            summary = "\(bestBeach.name) is the best spot for a beach walk today — \(bestBeach.description.lowercased()). Bundle up and enjoy the off-season beauty!"
        } else {
            summary = "\(bestBeach.name) is your best bet right now — \(bestBeach.description.lowercased())."
        }

        return BeachRecommendation(
            beachName: bestBeach.name,
            rating: rating,
            summary: summary,
            details: "It's \(windDetail), and the \(tideDetail).",
            factors: factors
        )
    }

    // MARK: - Helpers

    private static func overallRating(weather: CurrentWeather, waveHeight: Double?) -> BeachRecommendation.BeachRating {
        // Not recommended
        if weather.condition == .thunderstorm || weather.condition == .rain { return .notRecommended }
        if weather.windSpeed > 30 { return .notRecommended }
        if weather.temperature < 55 { return .notRecommended }

        // Caution
        if weather.windSpeed > 20 { return .caution }
        if let waves = waveHeight, waves > 6 { return .caution }
        if weather.uvIndex >= 9 { return .caution }
        if weather.condition == .fog { return .caution }

        // Great
        if weather.temperature >= 72 && weather.windSpeed < 15 &&
           [.clear, .partlyCloudy].contains(weather.condition) {
            return .great
        }

        return .good
    }

    private static func isWindSheltered(beach: CapeCodBeach, windDirection: String) -> Bool {
        // A beach is "sheltered" if the wind blows FROM the same direction
        // as the beach's best wind direction
        let windDeg = degreesFromCompass(windDirection)
        let bestDeg = degreesFromCompass(beach.bestWindDirection)
        let diff = abs(windDeg - bestDeg)
        return diff < 90 || diff > 270
    }

    private static func degreesFromCompass(_ dir: String) -> Double {
        let map: [String: Double] = [
            "N": 0, "NNE": 22.5, "NE": 45, "ENE": 67.5,
            "E": 90, "ESE": 112.5, "SE": 135, "SSE": 157.5,
            "S": 180, "SSW": 202.5, "SW": 225, "WSW": 247.5,
            "W": 270, "WNW": 292.5, "NW": 315, "NNW": 337.5,
        ]
        return map[dir] ?? 0
    }
}
