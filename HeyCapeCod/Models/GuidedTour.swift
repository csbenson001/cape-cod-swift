import Foundation
import CoreLocation

/// A curated guided tour with an ordered list of POI stops.
struct GuidedTour: Identifiable, Hashable {
    let id: String
    let name: String
    let subtitle: String
    let description: String
    let icon: String
    let category: TourCategory
    let estimatedDuration: String
    let distance: String
    let difficulty: TourDifficulty
    let stopIDs: [String]
    let region: CapeRegion?

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: GuidedTour, rhs: GuidedTour) -> Bool { lhs.id == rhs.id }

    /// Resolve stop IDs to actual PointOfInterest objects from bundled content.
    func resolvedStops(from allPOIs: [PointOfInterest]) -> [PointOfInterest] {
        stopIDs.compactMap { stopID in
            allPOIs.first { $0.id == stopID }
        }
    }
}

enum TourCategory: String, CaseIterable, Identifiable {
    case lighthouses
    case history
    case nature
    case family
    case foodAndCulture
    case adventure

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lighthouses: "Lighthouses"
        case .history: "History"
        case .nature: "Nature"
        case .family: "Family Fun"
        case .foodAndCulture: "Food & Culture"
        case .adventure: "Adventure"
        }
    }

    var icon: String {
        switch self {
        case .lighthouses: "light.beacon.max.fill"
        case .history: "building.columns.fill"
        case .nature: "leaf.fill"
        case .family: "figure.2.and.child.holdinghands"
        case .foodAndCulture: "fork.knife"
        case .adventure: "figure.hiking"
        }
    }
}

enum TourDifficulty: String, Codable {
    case easy, moderate, challenging

    var displayName: String { rawValue.capitalized }

    var color: String {
        switch self {
        case .easy: "duneGrass"
        case .moderate: "sandbarYellow"
        case .challenging: "sunsetOrange"
        }
    }
}

// MARK: - Curated Tours

enum CuratedTours {

    static let all: [GuidedTour] = [
        lighthouseTrail,
        outerCapeHistory,
        familyAdventure,
        canalToSandwich,
        capeTipExplorer,
        piratesAndLegends,
    ]

    static let lighthouseTrail = GuidedTour(
        id: "tour-lighthouses",
        name: "Lighthouse Trail",
        subtitle: "Cape Cod's iconic beacons",
        description: "Visit three of Cape Cod's most famous lighthouses, each with a unique story of storms, rescues, and the relentless Atlantic. From the two-color beacon at Nobska to the chip-bag-famous Nauset Light and the lighthouse that walked at Highland.",
        icon: "light.beacon.max.fill",
        category: .lighthouses,
        estimatedDuration: "3-4 hours",
        distance: "65 miles",
        difficulty: .easy,
        stopIDs: ["nobska-light", "nauset-light", "highland-light"],
        region: nil
    )

    static let outerCapeHistory = GuidedTour(
        id: "tour-outer-cape-history",
        name: "Outer Cape History Trail",
        subtitle: "From Pilgrims to wireless radio",
        description: "Trace the stories that shaped America — from the Pilgrims' true first landing in Provincetown, to the spot where Marconi sent the first transatlantic wireless message, to the dramatic cliffs where Highland Light was moved to safety.",
        icon: "building.columns.fill",
        category: .history,
        estimatedDuration: "4-5 hours",
        distance: "30 miles",
        difficulty: .easy,
        stopIDs: ["pilgrim-monument", "marconi-beach", "highland-light", "race-point-beach"],
        region: .outerCape
    )

    static let familyAdventure = GuidedTour(
        id: "tour-family-fun",
        name: "Family Fun Day",
        subtitle: "Kid-friendly Cape Cod highlights",
        description: "A perfect family day hitting Cape Cod's most exciting spots for kids — real pirate treasure, seal watching, swimming in crystal-clear kettle ponds, and a drive-in movie to cap the night.",
        icon: "figure.2.and.child.holdinghands",
        category: .family,
        estimatedDuration: "Full day",
        distance: "45 miles",
        difficulty: .easy,
        stopIDs: ["whydah-museum", "chatham-fish-pier", "nickerson-state-park", "wellfleet-drive-in"],
        region: nil
    )

    static let canalToSandwich = GuidedTour(
        id: "tour-canal-sandwich",
        name: "Canal & Sandwich",
        subtitle: "Upper Cape gems",
        description: "Explore the engineering marvel of the Cape Cod Canal by bike, walk the story-inscribed Sandwich Boardwalk, and wander through 100 acres of gardens and antique cars at Heritage Museums.",
        icon: "bicycle",
        category: .nature,
        estimatedDuration: "3-4 hours",
        distance: "10 miles",
        difficulty: .moderate,
        stopIDs: ["canal-bike-path", "sandwich-boardwalk", "heritage-museums"],
        region: .upperCape
    )

    static let capeTipExplorer = GuidedTour(
        id: "tour-cape-tip",
        name: "Cape Tip Explorer",
        subtitle: "Provincetown & the wild outer shore",
        description: "Journey to the very tip of Cape Cod where two oceans meet. Climb the Pilgrim Monument for panoramic views, then explore Race Point's wild beaches where whales feed just offshore.",
        icon: "water.waves",
        category: .adventure,
        estimatedDuration: "3-4 hours",
        distance: "5 miles",
        difficulty: .moderate,
        stopIDs: ["pilgrim-monument", "race-point-beach"],
        region: .outerCape
    )

    static let piratesAndLegends = GuidedTour(
        id: "tour-pirates",
        name: "Pirates & Legends",
        subtitle: "Shipwrecks, treasure, and tall tales",
        description: "Discover the swashbuckling history of Cape Cod — from Black Sam Bellamy's treasure at the Whydah Museum to the shipwreck-laden waters off Marconi Beach and the spooky drive-in at Wellfleet.",
        icon: "flag.filled.and.flag.crossed",
        category: .history,
        estimatedDuration: "4-5 hours",
        distance: "35 miles",
        difficulty: .easy,
        stopIDs: ["whydah-museum", "marconi-beach", "wellfleet-drive-in"],
        region: nil
    )
}
