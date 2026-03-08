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
    case pirate
    case haunted
    case maritime
    case art
    case romantic
    case photography
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lighthouses: "Lighthouses"
        case .history: "History"
        case .nature: "Nature"
        case .family: "Family Fun"
        case .foodAndCulture: "Food & Culture"
        case .adventure: "Adventure"
        case .pirate: "Pirates"
        case .haunted: "Haunted"
        case .maritime: "Maritime"
        case .art: "Art & Culture"
        case .romantic: "Romantic"
        case .photography: "Photo Spots"
        case .custom: "Custom"
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
        case .pirate: "flag.filled.and.flag.crossed"
        case .haunted: "moon.stars.fill"
        case .maritime: "sailboat.fill"
        case .art: "paintpalette.fill"
        case .romantic: "heart.fill"
        case .photography: "camera.fill"
        case .custom: "sparkles"
        }
    }

    var themeColor: String {
        switch self {
        case .lighthouses: "sandbarYellow"
        case .history: "sunsetOrange"
        case .nature: "duneGrass"
        case .family: "oceanBlue"
        case .foodAndCulture: "cranberry"
        case .adventure: "sunsetOrange"
        case .pirate: "lobsterRed"
        case .haunted: "deepNavy"
        case .maritime: "oceanBlue"
        case .art: "seafoam"
        case .romantic: "cranberry"
        case .photography: "sandbarYellow"
        case .custom: "oceanBlue"
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
        hauntedCapeCod,
        maritimeHeritage,
        artAndCultureTrail,
        romanticGetaway,
        photoTour,
        foodieCrawl,
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
        category: .pirate,
        estimatedDuration: "4-5 hours",
        distance: "35 miles",
        difficulty: .easy,
        stopIDs: ["whydah-museum", "marconi-beach", "wellfleet-drive-in"],
        region: nil
    )

    static let hauntedCapeCod = GuidedTour(
        id: "tour-haunted",
        name: "Haunted Cape Cod",
        subtitle: "Ghosts, shipwrecks, and eerie legends",
        description: "As night falls on the Cape, the stories come alive. Visit the sites of ghostly sightings, tragic shipwrecks, and unexplained phenomena. From the Lady in Black of Highland Light to the phantom sailors of Marconi Beach, Cape Cod has no shortage of spine-tingling tales.",
        icon: "moon.stars.fill",
        category: .haunted,
        estimatedDuration: "3-4 hours",
        distance: "40 miles",
        difficulty: .easy,
        stopIDs: ["highland-light", "marconi-beach", "wellfleet-drive-in", "whydah-museum"],
        region: nil
    )

    static let maritimeHeritage = GuidedTour(
        id: "tour-maritime",
        name: "Maritime Heritage Trail",
        subtitle: "Fishing, sailing, and seafaring tradition",
        description: "Cape Cod was built on the sea. Follow the maritime heritage from the working waterfront of Chatham Fish Pier to the historic Cape Cod Canal, lighthouses that guided ships for centuries, and the beaches where lifesaving crews risked everything.",
        icon: "sailboat.fill",
        category: .maritime,
        estimatedDuration: "5-6 hours",
        distance: "55 miles",
        difficulty: .moderate,
        stopIDs: ["chatham-fish-pier", "nobska-light", "canal-bike-path", "highland-light"],
        region: nil
    )

    static let artAndCultureTrail = GuidedTour(
        id: "tour-art-culture",
        name: "Art & Culture Trail",
        subtitle: "Galleries, theater, and creative Cape Cod",
        description: "Cape Cod has inspired artists for centuries. From the Provincetown art colony that launched American modernism to the galleries of Wellfleet and the heritage museums of Sandwich, discover the Cape's creative soul.",
        icon: "paintpalette.fill",
        category: .art,
        estimatedDuration: "4-5 hours",
        distance: "60 miles",
        difficulty: .easy,
        stopIDs: ["pilgrim-monument", "wellfleet-drive-in", "heritage-museums", "jfk-museum"],
        region: nil
    )

    static let romanticGetaway = GuidedTour(
        id: "tour-romantic",
        name: "Romantic Cape Cod",
        subtitle: "Sunsets, lighthouses, and seaside charm",
        description: "The perfect couples' tour: watch the sunset from Nobska Light, stroll the inscribed planks of Sandwich Boardwalk, and end the evening at the Wellfleet Drive-In under the stars. Cape Cod at its most enchanting.",
        icon: "heart.fill",
        category: .romantic,
        estimatedDuration: "4-5 hours",
        distance: "50 miles",
        difficulty: .easy,
        stopIDs: ["nobska-light", "sandwich-boardwalk", "race-point-beach", "wellfleet-drive-in"],
        region: nil
    )

    static let photoTour = GuidedTour(
        id: "tour-photo",
        name: "Cape Cod Photo Tour",
        subtitle: "The most Instagrammable spots",
        description: "Hit every iconic photo opportunity on the Cape — from the candy-striped Nauset Light to the dramatic cliffs of Marconi Beach, the boardwalk of a thousand messages, and the wild beauty of Race Point at golden hour.",
        icon: "camera.fill",
        category: .photography,
        estimatedDuration: "Full day",
        distance: "70 miles",
        difficulty: .moderate,
        stopIDs: ["nauset-light", "marconi-beach", "sandwich-boardwalk", "highland-light", "race-point-beach"],
        region: nil
    )

    static let foodieCrawl = GuidedTour(
        id: "tour-foodie",
        name: "Cape Cod Foodie Crawl",
        subtitle: "Seafood shacks, local fare, and sweet treats",
        description: "Taste your way across the Cape — from the freshest catch at Chatham Fish Pier to Provincetown's world-class dining scene, with stops at Wellfleet's legendary oyster beds and the ice cream shops of Main Street Hyannis.",
        icon: "fork.knife",
        category: .foodAndCulture,
        estimatedDuration: "Full day",
        distance: "65 miles",
        difficulty: .easy,
        stopIDs: ["chatham-fish-pier", "jfk-museum", "pilgrim-monument"],
        region: nil
    )
}
