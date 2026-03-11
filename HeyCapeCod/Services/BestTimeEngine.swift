import Foundation

// MARK: - Beach Profile Data

enum BeachFacing: String, Sendable {
    case east, west, north, south
}

enum ParkingSize: String, Sendable {
    case small, medium, large, shuttle
}

enum CrowdLevel: String, Sendable {
    case low = "Low"
    case moderate = "Moderate"
    case busy = "Busy"
    case packed = "Packed"

    var icon: String {
        switch self {
        case .low: return "person"
        case .moderate: return "person.2"
        case .busy: return "person.3.sequence"
        case .packed: return "person.3.sequence.fill"
        }
    }
}

struct BeachProfile: Identifiable, Sendable {
    let id: String
    let name: String
    let town: String
    let facing: BeachFacing
    let tideDependent: Bool
    let bestAtLowTide: Bool
    let hasParking: Bool
    let parkingCapacity: ParkingSize
    let popularityLevel: Int // 1-5
    let kidFriendly: Bool
    let hasLifeguards: Bool
    let hasRestrooms: Bool
}

struct BestTimeRecommendation: Identifiable, Sendable {
    let id = UUID()
    let beach: BeachProfile
    let optimalStart: Date
    let optimalEnd: Date
    let rating: Int // 1-5
    let reasons: [String]
    let crowdLevel: CrowdLevel
    let tideInfo: String
    let parkingTip: String
    let quickTip: String

    var optimalWindow: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        return "\(fmt.string(from: optimalStart)) – \(fmt.string(from: optimalEnd))"
    }
}

struct BeachRanking: Identifiable, Sendable {
    let id = UUID()
    let recommendation: BestTimeRecommendation
    let overallScore: Double
}

struct HourlyScore: Identifiable, Sendable {
    let id = UUID()
    let hour: Int
    let score: Double // 0-100
    let label: String
}

// MARK: - Best Time Engine

@MainActor
@Observable
final class BestTimeEngine {

    static let shared = BestTimeEngine()

    let beaches: [BeachProfile] = BeachProfile.allBeaches

    // MARK: - Public API

    func bestTimeToVisit(beach: BeachProfile, date: Date = .now) -> BestTimeRecommendation {
        let cal = Calendar.current
        let dayOfWeek = cal.component(.weekday, from: date)
        let isWeekend = dayOfWeek == 1 || dayOfWeek == 7
        let month = cal.component(.month, from: date)
        let isSummer = (6...8).contains(month)

        let tideState = simulatedTideState(for: date)
        let (optStart, optEnd) = computeOptimalWindow(
            beach: beach, date: date,
            tideState: tideState, isWeekend: isWeekend
        )
        let crowd = estimateCrowds(
            popularity: beach.popularityLevel,
            isWeekend: isWeekend, isSummer: isSummer
        )
        let rating = computeRating(
            beach: beach, tideState: tideState,
            crowd: crowd, isWeekend: isWeekend, isSummer: isSummer
        )
        let reasons = buildReasons(
            beach: beach, tideState: tideState,
            crowd: crowd, isSummer: isSummer
        )
        let tideInfo = tideDescription(beach: beach, tideState: tideState)
        let parkingTip = parkingAdvice(
            capacity: beach.parkingCapacity,
            crowd: crowd, isWeekend: isWeekend, isSummer: isSummer
        )
        let quickTip = generateQuickTip(
            beach: beach, tideState: tideState, crowd: crowd
        )

        return BestTimeRecommendation(
            beach: beach, optimalStart: optStart, optimalEnd: optEnd,
            rating: rating, reasons: reasons, crowdLevel: crowd,
            tideInfo: tideInfo, parkingTip: parkingTip, quickTip: quickTip
        )
    }

    func rankBeachesForToday() -> [BeachRanking] {
        let date = Date.now
        return beaches
            .map { beach in
                let rec = bestTimeToVisit(beach: beach, date: date)
                let score = Double(rec.rating) * 20.0
                    + (rec.crowdLevel == .low ? 10 : 0)
                    + (beach.kidFriendly ? 5 : 0)
                return BeachRanking(recommendation: rec, overallScore: score)
            }
            .sorted { $0.overallScore > $1.overallScore }
    }

    func hourlyScores(beach: BeachProfile, date: Date = .now) -> [HourlyScore] {
        let cal = Calendar.current
        let dayOfWeek = cal.component(.weekday, from: date)
        let isWeekend = dayOfWeek == 1 || dayOfWeek == 7

        return (6...20).map { hour in
            let score = hourScore(
                beach: beach, hour: hour,
                date: date, isWeekend: isWeekend
            )
            let fmt = DateFormatter()
            fmt.dateFormat = "ha"
            var comps = cal.dateComponents([.year, .month, .day], from: date)
            comps.hour = hour
            let d = cal.date(from: comps) ?? date
            return HourlyScore(hour: hour, score: score, label: fmt.string(from: d))
        }
    }
}

// MARK: - Computation Helpers

private extension BestTimeEngine {

    struct TideState {
        let lowTideHour: Int   // hour of low tide (0-23)
        let highTideHour: Int  // hour of high tide
    }

    func simulatedTideState(for date: Date) -> TideState {
        // Simulate tide cycle: shifts ~50 min/day
        let cal = Calendar.current
        let dayOfYear = cal.ordinality(of: .day, in: .year, for: date) ?? 1
        let baseHour = (dayOfYear * 50 / 60) % 12
        let lowTideHour = 6 + baseHour % 12
        let highTideHour = (lowTideHour + 6) % 24
        return TideState(lowTideHour: lowTideHour, highTideHour: highTideHour)
    }

    func computeOptimalWindow(
        beach: BeachProfile, date: Date, tideState: TideState, isWeekend: Bool
    ) -> (Date, Date) {
        let cal = Calendar.current
        var startHour: Int
        if beach.tideDependent && beach.bestAtLowTide {
            startHour = max(7, tideState.lowTideHour - 1)
        } else if beach.tideDependent {
            startHour = max(7, tideState.highTideHour - 1)
        } else {
            startHour = isWeekend ? 8 : 10
        }
        switch beach.facing {
        case .east: startHour = min(startHour, 10)
        case .west: startHour = max(startHour, 14)
        case .north, .south: break
        }
        startHour = min(startHour, 16)
        let endHour = min(startHour + 3, 19)
        var startComps = cal.dateComponents([.year, .month, .day], from: date)
        startComps.hour = startHour; startComps.minute = 0
        var endComps = startComps
        endComps.hour = endHour; endComps.minute = 30
        return (cal.date(from: startComps) ?? date, cal.date(from: endComps) ?? date)
    }

    func estimateCrowds(popularity: Int, isWeekend: Bool, isSummer: Bool) -> CrowdLevel {
        let score = popularity + (isWeekend ? 2 : 0) + (isSummer ? 2 : 0)
        switch score {
        case ...3: return .low
        case 4...5: return .moderate
        case 6...7: return .busy
        default: return .packed
        }
    }

    func computeRating(
        beach: BeachProfile, tideState: TideState, crowd: CrowdLevel, isWeekend: Bool, isSummer: Bool
    ) -> Int {
        var rating = 3
        if crowd == .low || crowd == .moderate { rating += 1 }
        if crowd == .packed { rating -= 1 }
        if beach.tideDependent && beach.bestAtLowTide {
            rating += (8...16).contains(tideState.lowTideHour) ? 1 : -1
        }
        return max(1, min(5, rating))
    }

    func buildReasons(
        beach: BeachProfile, tideState: TideState,
        crowd: CrowdLevel, isSummer: Bool
    ) -> [String] {
        var reasons: [String] = []
        if beach.tideDependent && beach.bestAtLowTide {
            reasons.append("Low tide exposes flats for exploring")
        }
        if crowd == .low {
            reasons.append("Expected low crowds today")
        } else if crowd == .packed {
            reasons.append("Expect heavy crowds — arrive early")
        }
        if beach.kidFriendly {
            reasons.append("Great for families with kids")
        }
        if beach.hasLifeguards && isSummer {
            reasons.append("Lifeguards on duty")
        }
        if beach.facing == .west {
            reasons.append("Beautiful sunset views in the evening")
        }
        if reasons.isEmpty {
            reasons.append("Solid beach day conditions")
        }
        return reasons
    }

    func tideDescription(beach: BeachProfile, tideState: TideState) -> String {
        let lowFmt = formatHour(tideState.lowTideHour)
        let highFmt = formatHour(tideState.highTideHour)
        if beach.tideDependent && beach.bestAtLowTide {
            return "Low tide at \(lowFmt) — best for flats walking"
        } else if beach.tideDependent {
            return "High tide at \(highFmt) — ideal for swimming"
        }
        return "Low \(lowFmt) · High \(highFmt)"
    }

    func parkingAdvice(
        capacity: ParkingSize, crowd: CrowdLevel,
        isWeekend: Bool, isSummer: Bool
    ) -> String {
        switch capacity {
        case .shuttle:
            return "Take the shuttle — no beach parking available"
        case .small where isWeekend && isSummer:
            return "Lot fills by 9 AM on summer weekends — go early!"
        case .small:
            return "Small lot — arrive before 10 AM"
        case .medium where crowd == .packed:
            return "Parking fills by 10 AM — consider arriving by 9"
        case .medium:
            return "Moderate parking — should find a spot before noon"
        case .large:
            return "Large lot — parking usually available"
        }
    }

    func generateQuickTip(
        beach: BeachProfile, tideState: TideState, crowd: CrowdLevel
    ) -> String {
        if beach.tideDependent && beach.bestAtLowTide {
            return "Flats will be exposed — perfect for tide pooling!"
        }
        if beach.facing == .west {
            return "Stick around for a stunning Cape Cod sunset."
        }
        if crowd == .low {
            return "Quiet day ahead — bring a book and relax."
        }
        if beach.hasLifeguards {
            return "Lifeguard-protected swim area available."
        }
        return "Great conditions for a day at the beach!"
    }

    func hourScore(
        beach: BeachProfile, hour: Int,
        date: Date, isWeekend: Bool
    ) -> Double {
        var score: Double = 50

        // Sun quality: best 9AM-4PM
        if (9...16).contains(hour) { score += 20 }
        else if (7...8).contains(hour) || (17...18).contains(hour) { score += 10 }

        // Crowd penalty at peak (11-2)
        if (11...14).contains(hour) {
            score -= isWeekend ? 20 : 10
        }

        // Tide bonus
        let tide = simulatedTideState(for: date)
        if beach.tideDependent && beach.bestAtLowTide {
            let dist = abs(hour - tide.lowTideHour)
            score += max(0, 25 - Double(dist * 8))
        }

        // Facing bonus
        switch beach.facing {
        case .east where hour < 12: score += 15
        case .west where hour >= 14: score += 15
        case .east where hour >= 14: score -= 5
        case .west where hour < 10: score -= 5
        default: break
        }

        return max(0, min(100, score))
    }

    func formatHour(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let ampm = hour < 12 ? "AM" : "PM"
        return "\(h):00 \(ampm)"
    }
}

// MARK: - Beach Database

extension BeachProfile {
    // swiftlint:disable:next function_body_length
    static let allBeaches: [BeachProfile] = [
        .init(id: "skaket", name: "Skaket Beach", town: "Orleans", facing: .west,
              tideDependent: true, bestAtLowTide: true, hasParking: true,
              parkingCapacity: .medium, popularityLevel: 4, kidFriendly: true, hasLifeguards: true, hasRestrooms: true),
        .init(id: "nauset", name: "Nauset Beach", town: "Orleans", facing: .east,
              tideDependent: false, bestAtLowTide: false, hasParking: true,
              parkingCapacity: .large, popularityLevel: 5, kidFriendly: false, hasLifeguards: true, hasRestrooms: true),
        .init(id: "coast_guard", name: "Coast Guard Beach", town: "Eastham", facing: .east,
              tideDependent: false, bestAtLowTide: false, hasParking: true,
              parkingCapacity: .shuttle, popularityLevel: 5, kidFriendly: false, hasLifeguards: true, hasRestrooms: true),
        .init(id: "first_encounter", name: "First Encounter Beach", town: "Eastham", facing: .west,
              tideDependent: true, bestAtLowTide: true, hasParking: true,
              parkingCapacity: .medium, popularityLevel: 3, kidFriendly: true, hasLifeguards: false, hasRestrooms: true),
        .init(id: "chapin", name: "Chapin Memorial Beach", town: "Dennis", facing: .north,
              tideDependent: true, bestAtLowTide: true, hasParking: true,
              parkingCapacity: .medium, popularityLevel: 3, kidFriendly: true, hasLifeguards: false, hasRestrooms: true),
        .init(id: "mayflower", name: "Mayflower Beach", town: "Dennis", facing: .north,
              tideDependent: true, bestAtLowTide: true, hasParking: true,
              parkingCapacity: .small, popularityLevel: 4, kidFriendly: true, hasLifeguards: true, hasRestrooms: true),
        .init(id: "corporation", name: "Corporation Beach", town: "Dennis", facing: .north,
              tideDependent: false, bestAtLowTide: false, hasParking: true,
              parkingCapacity: .medium, popularityLevel: 3, kidFriendly: true, hasLifeguards: true, hasRestrooms: true),
        .init(id: "marconi", name: "Marconi Beach", town: "Wellfleet", facing: .east,
              tideDependent: false, bestAtLowTide: false, hasParking: true,
              parkingCapacity: .large, popularityLevel: 4, kidFriendly: false, hasLifeguards: true, hasRestrooms: true),
        .init(id: "cahoon_hollow", name: "Cahoon Hollow", town: "Wellfleet", facing: .east,
              tideDependent: false, bestAtLowTide: false, hasParking: true,
              parkingCapacity: .medium, popularityLevel: 4, kidFriendly: false, hasLifeguards: false, hasRestrooms: false),
        .init(id: "race_point", name: "Race Point", town: "Provincetown", facing: .north,
              tideDependent: false, bestAtLowTide: false, hasParking: true,
              parkingCapacity: .large, popularityLevel: 4, kidFriendly: false, hasLifeguards: true, hasRestrooms: true),
        .init(id: "herring_cove", name: "Herring Cove", town: "Provincetown", facing: .west,
              tideDependent: false, bestAtLowTide: false, hasParking: true,
              parkingCapacity: .large, popularityLevel: 4, kidFriendly: true, hasLifeguards: true, hasRestrooms: true),
        .init(id: "sandy_neck", name: "Sandy Neck", town: "Barnstable", facing: .north,
              tideDependent: false, bestAtLowTide: false, hasParking: true,
              parkingCapacity: .large, popularityLevel: 3, kidFriendly: true, hasLifeguards: false, hasRestrooms: true),
    ]
}
