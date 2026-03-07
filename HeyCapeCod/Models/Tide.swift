import Foundation

struct TideData: Codable, Equatable {
    let stationID: String
    let stationName: String
    var predictions: [TidePrediction]
    let fetchedAt: Date

    var nextTide: TidePrediction? {
        predictions.first { $0.time > .now }
    }

    var currentTideStatus: TideStatus {
        guard let next = nextTide else { return .unknown }
        return next.type == .high ? .rising : .falling
    }

    var isStale: Bool {
        Date.now.timeIntervalSince(fetchedAt) > 3600 // 1 hour
    }
}

struct TidePrediction: Identifiable, Codable, Equatable {
    var id: Date { time }
    let time: Date
    let height: Double
    let type: TideType

    var heightFormatted: String {
        String(format: "%.1f ft", height)
    }

    var timeFormatted: String {
        time.formatted(date: .omitted, time: .shortened)
    }
}

enum TideType: String, Codable, Equatable {
    case high = "H"
    case low = "L"

    var displayName: String {
        switch self {
        case .high: "High Tide"
        case .low: "Low Tide"
        }
    }

    var icon: String {
        switch self {
        case .high: "arrow.up.to.line"
        case .low: "arrow.down.to.line"
        }
    }
}

enum TideStatus: String {
    case rising, falling, unknown

    var displayName: String {
        switch self {
        case .rising: "Rising"
        case .falling: "Falling"
        case .unknown: "Unknown"
        }
    }

    var icon: String {
        switch self {
        case .rising: "arrow.up"
        case .falling: "arrow.down"
        case .unknown: "questionmark"
        }
    }
}

// MARK: - NOAA Tide Stations on Cape Cod

enum TideStation: String, CaseIterable, Identifiable {
    case provincetown = "8446493"
    case wellfleet = "8446613"
    case chatham = "8447241"
    case hyannis = "8447173"
    case falmouth = "8447685"
    case sandwichCanal = "8447386"
    case woodsHole = "8447930"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .provincetown: "Provincetown"
        case .wellfleet: "Wellfleet Harbor"
        case .chatham: "Chatham"
        case .hyannis: "Hyannis"
        case .falmouth: "Falmouth Heights"
        case .sandwichCanal: "Cape Cod Canal (Sandwich)"
        case .woodsHole: "Woods Hole"
        }
    }
}
