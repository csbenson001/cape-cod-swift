import Testing
import Foundation
import CoreLocation
@testable import HeyCapeCod

// MARK: - Story Chapter Service Tests

@Suite("Story Chapter Service Tests")
struct StoryChapterServiceTests {

    // MARK: - Multi-Paragraph Script Fixture

    static let multiParagraphScript = """
    In 1717, the pirate ship Whydah went down in a fierce nor'easter off Wellfleet. \
    Its captain, 'Black Sam' Bellamy, was just 28 years old and already the wealthiest \
    pirate in recorded history.

    Bellamy was no ordinary buccaneer. Born in Devon, England, he came to Cape Cod \
    seeking fortune and fell in love with a local girl named Maria Hallett. When her \
    family rejected the penniless sailor, Bellamy turned to piracy, vowing to return \
    rich enough to claim her hand.

    In just over a year, he captured more than 50 ships. The Whydah itself was a slave \
    ship he seized off the coast of Cuba, converting it into his flagship. The vessel \
    carried treasure worth millions in today's currency.

    On April 26, 1717, Bellamy was sailing north to reunite with Maria when a violent \
    storm drove the Whydah onto a sandbar. Of the 146 men aboard, only two survived. \
    The storm was one of the worst in Cape Cod history.

    The wreck lay undiscovered for over 260 years until Barry Clifford found it in 1984. \
    Today, artifacts from the Whydah are displayed in the museum, telling the remarkable \
    story of the prince of pirates and his fateful voyage home.
    """

    @Test("Generates 3-5 chapters from multi-paragraph script")
    func testChapterGenerationCount() {
        let chapters = StoryChapterService.generateChapters(
            from: Self.multiParagraphScript,
            storyTitle: "Test Story"
        )
        #expect(chapters.count >= 3)
        #expect(chapters.count <= 5)
    }

    @Test("Chapter progress ranges are contiguous")
    func testChapterProgressContiguity() {
        let chapters = StoryChapterService.generateChapters(
            from: Self.multiParagraphScript,
            storyTitle: "Test Story"
        )

        #expect(!chapters.isEmpty)

        // First chapter starts at 0
        #expect(chapters.first!.startProgress == 0.0)

        // Last chapter ends at 1.0
        #expect(chapters.last!.endProgress == 1.0)

        // Each chapter's end equals the next chapter's start
        for i in 0..<(chapters.count - 1) {
            let gap = abs(chapters[i].endProgress - chapters[i + 1].startProgress)
            #expect(gap < 0.001, "Gap between chapter \(i) end and chapter \(i + 1) start: \(gap)")
        }
    }

    @Test("All chapters have non-empty titles")
    func testChaptersHaveTitles() {
        let chapters = StoryChapterService.generateChapters(
            from: Self.multiParagraphScript,
            storyTitle: "Test Story"
        )

        for chapter in chapters {
            #expect(!chapter.title.isEmpty, "Chapter \(chapter.id) has empty title")
        }
    }

    @Test("All chapters have non-empty content")
    func testChaptersHaveContent() {
        let chapters = StoryChapterService.generateChapters(
            from: Self.multiParagraphScript,
            storyTitle: "Test Story"
        )

        for chapter in chapters {
            #expect(!chapter.content.isEmpty, "Chapter \(chapter.id) has empty content")
        }
    }

    @Test("Empty script produces no chapters")
    func testEmptyScript() {
        let chapters = StoryChapterService.generateChapters(
            from: "",
            storyTitle: "Empty"
        )
        #expect(chapters.isEmpty)
    }

    @Test("Very short script (single paragraph) produces at least 1 chapter")
    func testShortScript() {
        let shortScript = "This is a single short paragraph about Cape Cod."
        let chapters = StoryChapterService.generateChapters(
            from: shortScript,
            storyTitle: "Short"
        )
        #expect(chapters.count >= 1)
        #expect(chapters.last?.endProgress == 1.0)
    }

    @Test("Chapter IDs are sequential starting from 0")
    func testChapterIDs() {
        let chapters = StoryChapterService.generateChapters(
            from: Self.multiParagraphScript,
            storyTitle: "Test"
        )

        for (index, chapter) in chapters.enumerated() {
            #expect(chapter.id == index)
        }
    }

    @Test("Chapter progress ranges do not overlap")
    func testNoOverlap() {
        let chapters = StoryChapterService.generateChapters(
            from: Self.multiParagraphScript,
            storyTitle: "Test"
        )

        for i in 0..<chapters.count {
            #expect(chapters[i].startProgress < chapters[i].endProgress,
                    "Chapter \(i) has invalid range")
            for j in (i + 1)..<chapters.count {
                #expect(chapters[i].endProgress <= chapters[j].startProgress + 0.001,
                        "Chapters \(i) and \(j) overlap")
            }
        }
    }
}

// MARK: - StoryChapter Model Tests

@Suite("Story Chapter Model Tests")
struct StoryChapterModelTests {

    @Test("contains(progress:) correctly identifies chapter boundaries")
    func testContainsProgress() {
        let chapter = StoryChapter(
            id: 0,
            title: "Intro",
            content: "Test content",
            startProgress: 0.0,
            endProgress: 0.33,
            highlight: nil
        )

        #expect(chapter.contains(progress: 0.0))
        #expect(chapter.contains(progress: 0.15))
        #expect(chapter.contains(progress: 0.32))
        #expect(!chapter.contains(progress: 0.33))  // endProgress is exclusive
        #expect(!chapter.contains(progress: 0.5))
        #expect(!chapter.contains(progress: -0.1))
    }

    @Test("estimatedDuration computes correct proportional duration")
    func testEstimatedDuration() {
        let chapter = StoryChapter(
            id: 0,
            title: "Test",
            content: "Content",
            startProgress: 0.25,
            endProgress: 0.75,
            highlight: nil
        )

        let totalDuration: TimeInterval = 120.0
        let estimated = chapter.estimatedDuration(totalDuration: totalDuration)
        #expect(abs(estimated - 60.0) < 0.01)
    }

    @Test("Chapter with zero-length range has zero duration")
    func testZeroLengthChapter() {
        let chapter = StoryChapter(
            id: 0,
            title: "Empty",
            content: "",
            startProgress: 0.5,
            endProgress: 0.5,
            highlight: nil
        )

        #expect(chapter.estimatedDuration(totalDuration: 100) == 0)
    }
}

// MARK: - Tour Achievement Service Tests

@Suite("Tour Achievement Service Tests")
struct TourAchievementServiceTests {

    @Test("All achievements exist in allCases")
    func testAllAchievementsEnumerated() {
        let allCases = TourAchievement.allCases
        #expect(allCases.count == 12)
        #expect(allCases.contains(.firstStep))
        #expect(allCases.contains(.masterExplorer))
    }

    @Test("Achievement categories are well-defined")
    func testAchievementCategories() {
        let explorationAchievements = TourAchievement.allCases.filter {
            $0.category == .exploration
        }
        let learningAchievements = TourAchievement.allCases.filter {
            $0.category == .learning
        }
        let socialAchievements = TourAchievement.allCases.filter {
            $0.category == .social
        }
        let timingAchievements = TourAchievement.allCases.filter {
            $0.category == .timing
        }

        #expect(explorationAchievements.count >= 3)
        #expect(learningAchievements.count >= 2)
        #expect(socialAchievements.count >= 1)
        #expect(timingAchievements.count >= 2)
    }

    @Test("Category display names are non-empty")
    func testCategoryDisplayNames() {
        for category in AchievementCategory.allCases {
            #expect(!category.displayName.isEmpty)
            #expect(!category.icon.isEmpty)
        }
    }

    @Test("Achievement display properties are non-empty")
    func testAchievementDisplayProperties() {
        for achievement in TourAchievement.allCases {
            #expect(!achievement.displayName.isEmpty)
            #expect(!achievement.description.isEmpty)
            #expect(!achievement.icon.isEmpty)
            #expect(!achievement.requirement.isEmpty)
            #expect(achievement.targetCount > 0)
        }
    }

    @Test("Achievement IDs are unique")
    func testUniqueIDs() {
        let ids = TourAchievement.allCases.map(\.id)
        let uniqueIDs = Set(ids)
        #expect(ids.count == uniqueIDs.count)
    }

    @Test("Progress for unlocked achievement is 1.0")
    func testProgressForUnlocked() {
        let service = TourAchievementService.shared
        // Manually unlock an achievement
        service.unlockAchievement(.firstStep)

        let progress = service.progress(for: .firstStep)
        #expect(progress == 1.0)
    }

    @Test("isUnlocked returns correct state")
    func testIsUnlocked() {
        let service = TourAchievementService.shared

        // Unlock firstStep
        service.unlockAchievement(.firstStep)
        #expect(service.isUnlocked(.firstStep))

        // Storyteller might not be unlocked yet
        // (depends on test ordering, but we verify the method works)
        let beforeUnlock = service.isUnlocked(.storyteller)
        service.unlockAchievement(.storyteller)
        #expect(service.isUnlocked(.storyteller))

        // If it was already unlocked, the count shouldn't change
        let countBefore = service.unlockedCount
        service.unlockAchievement(.storyteller)
        #expect(service.unlockedCount == countBefore)
    }

    @Test("Total achievements count matches allCases")
    func testTotalAchievements() {
        let service = TourAchievementService.shared
        #expect(TourAchievementService.totalAchievements == TourAchievement.allCases.count)
    }

    @Test("Overall progress is bounded 0..1")
    func testOverallProgressBounds() {
        let service = TourAchievementService.shared
        #expect(service.overallProgress >= 0.0)
        #expect(service.overallProgress <= 1.0)
    }

    @Test("Recording story play increments counter")
    func testRecordStoryPlayed() {
        let service = TourAchievementService.shared
        let before = service.totalStoriesPlayed
        service.recordStoryPlayed()
        #expect(service.totalStoriesPlayed == before + 1)
    }

    @Test("Recording share increments counter")
    func testRecordShare() {
        let service = TourAchievementService.shared
        let before = service.totalShares
        service.recordShare()
        #expect(service.totalShares == before + 1)
    }
}

// MARK: - Story Persona Service Tests

@Suite("Story Persona Service Tests")
struct StoryPersonaServiceTests {

    @Test("All personas are enumerated")
    func testPersonaCount() {
        #expect(StoryPersona.allCases.count == 6)
    }

    @Test("Each persona has unique display name")
    func testUniqueDisplayNames() {
        let names = StoryPersona.allCases.map(\.displayName)
        let unique = Set(names)
        #expect(names.count == unique.count)
    }

    @Test("Each persona has non-empty voice description")
    func testVoiceDescriptions() {
        for persona in StoryPersona.allCases {
            #expect(!persona.voiceDescription.isEmpty,
                    "\(persona.displayName) has empty voice description")
        }
    }

    @Test("Each persona has non-empty system prompt")
    func testSystemPrompts() {
        for persona in StoryPersona.allCases {
            #expect(!persona.systemPrompt.isEmpty,
                    "\(persona.displayName) has empty system prompt")
        }
    }

    @Test("Each persona has an icon")
    func testPersonaIcons() {
        for persona in StoryPersona.allCases {
            #expect(!persona.icon.isEmpty,
                    "\(persona.displayName) has empty icon")
        }
    }

    @Test("Persona IDs are unique")
    func testPersonaIDs() {
        let ids = StoryPersona.allCases.map(\.id)
        let unique = Set(ids)
        #expect(ids.count == unique.count)
    }

    @Test("suggestPersona returns captainSalty for lighthouse POI")
    func testSuggestPersonaLighthouse() {
        let service = StoryPersonaService()
        let poi = PointOfInterest(
            id: "test-lighthouse",
            name: "Highland Light",
            coordinate: CLLocationCoordinate2D(latitude: 42.0, longitude: -70.0),
            geofenceRadius: 200,
            category: .lighthouse,
            town: .truro,
            description: "A famous lighthouse on Cape Cod.",
            stories: [],
            facts: [],
            tips: [],
            imageSystemName: nil
        )
        let persona = service.suggestPersona(for: poi)
        #expect(persona == .captainSalty)
    }

    @Test("suggestPersona returns marineBiologist for nature POI")
    func testSuggestPersonaNature() {
        let service = StoryPersonaService()
        let poi = PointOfInterest(
            id: "test-nature",
            name: "Salt Marsh Trail",
            coordinate: CLLocationCoordinate2D(latitude: 42.0, longitude: -70.0),
            geofenceRadius: 200,
            category: .nature,
            town: .barnstable,
            description: "A scenic salt marsh ecosystem.",
            stories: [],
            facts: [],
            tips: [],
            imageSystemName: nil
        )
        let persona = service.suggestPersona(for: poi)
        #expect(persona == .marineBiologist)
    }

    @Test("suggestPersona returns ghostHunter for spooky keywords")
    func testSuggestPersonaGhostHunter() {
        let service = StoryPersonaService()
        let poi = PointOfInterest(
            id: "test-haunted",
            name: "The Haunted Inn",
            coordinate: CLLocationCoordinate2D(latitude: 42.0, longitude: -70.0),
            geofenceRadius: 200,
            category: .lodging,
            town: .barnstable,
            description: "A historic inn with ghost sightings.",
            stories: [],
            facts: [],
            tips: [],
            imageSystemName: nil
        )
        let persona = service.suggestPersona(for: poi)
        #expect(persona == .ghostHunter)
    }

    @Test("suggestPersona returns foodieCritic for restaurant POI")
    func testSuggestPersonaRestaurant() {
        let service = StoryPersonaService()
        let poi = PointOfInterest(
            id: "test-restaurant",
            name: "The Lobster Pot",
            coordinate: CLLocationCoordinate2D(latitude: 42.0, longitude: -70.0),
            geofenceRadius: 200,
            category: .restaurant,
            town: .provincetown,
            description: "A legendary seafood restaurant.",
            stories: [],
            facts: [],
            tips: [],
            imageSystemName: nil
        )
        let persona = service.suggestPersona(for: poi)
        #expect(persona == .foodieCritic)
    }

    @Test("suggestPersona returns adventureGuide for trail-related nature POI")
    func testSuggestPersonaAdventure() {
        let service = StoryPersonaService()
        let poi = PointOfInterest(
            id: "test-trail",
            name: "Great Island Trail",
            coordinate: CLLocationCoordinate2D(latitude: 42.0, longitude: -70.0),
            geofenceRadius: 200,
            category: .nature,
            town: .wellfleet,
            description: "A scenic hiking trail through the dunes.",
            stories: [],
            facts: [],
            tips: [],
            imageSystemName: nil
        )
        let persona = service.suggestPersona(for: poi)
        #expect(persona == .adventureGuide)
    }

    @Test("suggestPersona returns localHistorian for historic POI")
    func testSuggestPersonaHistoric() {
        let service = StoryPersonaService()
        let poi = PointOfInterest(
            id: "test-historic",
            name: "Pilgrim Monument",
            coordinate: CLLocationCoordinate2D(latitude: 42.0, longitude: -70.0),
            geofenceRadius: 200,
            category: .historic,
            town: .provincetown,
            description: "Commemorates the Mayflower Pilgrims.",
            stories: [],
            facts: [],
            tips: [],
            imageSystemName: nil
        )
        let persona = service.suggestPersona(for: poi)
        #expect(persona == .localHistorian)
    }
}

// MARK: - PointOfInterest Model Tests

@Suite("PointOfInterest Model Tests")
struct PointOfInterestModelTests {

    @Test("Equality is based on ID")
    func testEquality() {
        let poi1 = PointOfInterest(
            id: "test-id",
            name: "Place A",
            coordinate: CLLocationCoordinate2D(latitude: 42.0, longitude: -70.0),
            geofenceRadius: 200,
            category: .beach,
            town: .barnstable,
            description: "First description",
            stories: [],
            facts: ["Fact A"],
            tips: [],
            imageSystemName: nil
        )

        let poi2 = PointOfInterest(
            id: "test-id",
            name: "Place B (same ID)",
            coordinate: CLLocationCoordinate2D(latitude: 43.0, longitude: -71.0),
            geofenceRadius: 300,
            category: .nature,
            town: .truro,
            description: "Different description",
            stories: [],
            facts: ["Fact B"],
            tips: [],
            imageSystemName: nil
        )

        let poi3 = PointOfInterest(
            id: "different-id",
            name: "Place A",
            coordinate: CLLocationCoordinate2D(latitude: 42.0, longitude: -70.0),
            geofenceRadius: 200,
            category: .beach,
            town: .barnstable,
            description: "First description",
            stories: [],
            facts: ["Fact A"],
            tips: [],
            imageSystemName: nil
        )

        #expect(poi1 == poi2, "POIs with same ID should be equal")
        #expect(poi1 != poi3, "POIs with different IDs should not be equal")
    }

    @Test("StoryVariant ID is derived from title and mode")
    func testStoryVariantID() {
        let story = StoryVariant(
            title: "The Lighthouse",
            mode: .adult,
            script: "Once upon a time..."
        )
        #expect(story.id == "The Lighthouse-adult")
    }

    @Test("StoryVariant estimates duration from word count")
    func testStoryVariantDuration() {
        let words = Array(repeating: "word", count: 100).joined(separator: " ")
        let story = StoryVariant(
            title: "Test",
            mode: .adult,
            script: words
        )
        // 100 words / 2.5 = 40 seconds
        #expect(story.duration == 40.0)
    }

    @Test("StoryVariant uses explicit duration when provided")
    func testStoryVariantExplicitDuration() {
        let story = StoryVariant(
            title: "Test",
            mode: .adult,
            script: "Short",
            duration: 120.0
        )
        #expect(story.duration == 120.0)
    }
}

// MARK: - GuidedTour Tests

@Suite("Guided Tour Tests")
struct GuidedTourTests {

    @Test("resolvedStops returns POIs in stop ID order")
    func testResolvedStopsOrder() {
        let allPOIs = BundledContent.allPOIs
        guard allPOIs.count >= 3 else {
            Issue.record("Not enough bundled POIs for this test")
            return
        }

        let stopIDs = [allPOIs[2].id, allPOIs[0].id, allPOIs[1].id]
        let tour = GuidedTour(
            id: "test-tour",
            name: "Test Tour",
            subtitle: "A test tour",
            description: "Testing stop resolution",
            icon: "map",
            category: .history,
            estimatedDuration: "1 hour",
            distance: "5 miles",
            difficulty: .easy,
            stopIDs: stopIDs,
            region: nil
        )

        let resolved = tour.resolvedStops(from: allPOIs)

        #expect(resolved.count == 3)
        #expect(resolved[0].id == allPOIs[2].id)
        #expect(resolved[1].id == allPOIs[0].id)
        #expect(resolved[2].id == allPOIs[1].id)
    }

    @Test("resolvedStops skips unknown IDs")
    func testResolvedStopsSkipsUnknown() {
        let allPOIs = BundledContent.allPOIs
        guard let firstPOI = allPOIs.first else {
            Issue.record("No bundled POIs available")
            return
        }

        let tour = GuidedTour(
            id: "test-tour",
            name: "Test Tour",
            subtitle: "A test tour",
            description: "Testing unknown ID handling",
            icon: "map",
            category: .history,
            estimatedDuration: "30 min",
            distance: "2 miles",
            difficulty: .easy,
            stopIDs: [firstPOI.id, "nonexistent-poi-id", "also-fake"],
            region: nil
        )

        let resolved = tour.resolvedStops(from: allPOIs)
        #expect(resolved.count == 1)
        #expect(resolved[0].id == firstPOI.id)
    }

    @Test("GuidedTour equality is based on ID")
    func testTourEquality() {
        let tour1 = GuidedTour(
            id: "tour-1", name: "Tour A", subtitle: "", description: "",
            icon: "map", category: .history, estimatedDuration: "",
            distance: "", difficulty: .easy, stopIDs: [], region: nil
        )
        let tour2 = GuidedTour(
            id: "tour-1", name: "Tour B (same ID)", subtitle: "", description: "",
            icon: "star", category: .nature, estimatedDuration: "",
            distance: "", difficulty: .challenging, stopIDs: ["stop-1"], region: nil
        )

        #expect(tour1 == tour2)
    }
}

// MARK: - ExperienceMode Tests

@Suite("Experience Mode Tests")
struct ExperienceModeTests {

    @Test("All experience modes have raw values")
    func testAllModes() {
        let modes = ExperienceMode.allCases
        #expect(modes.count == 4)
        #expect(modes.contains(.kids))
        #expect(modes.contains(.teen))
        #expect(modes.contains(.adult))
        #expect(modes.contains(.family))
    }

    @Test("ExperienceMode round-trips through raw value")
    func testRawValueRoundTrip() {
        for mode in ExperienceMode.allCases {
            let raw = mode.rawValue
            let restored = ExperienceMode(rawValue: raw)
            #expect(restored == mode)
        }
    }
}

// MARK: - Location Category Tests

@Suite("Location Category Tests")
struct LocationCategoryTests {

    @Test("All categories have display names")
    func testDisplayNames() {
        for category in LocationCategory.allCases {
            #expect(!category.displayName.isEmpty)
        }
    }

    @Test("LocationCategory includes expected categories")
    func testExpectedCategories() {
        let all = LocationCategory.allCases
        #expect(all.contains(.beach))
        #expect(all.contains(.lighthouse))
        #expect(all.contains(.restaurant))
        #expect(all.contains(.historic))
        #expect(all.contains(.nature))
        #expect(all.contains(.museum))
    }
}

// MARK: - Cape Region Tests

@Suite("Cape Region Tests")
struct CapeRegionTests {

    @Test("All four Cape regions exist")
    func testAllRegions() {
        let regions = CapeRegion.allCases
        #expect(regions.count == 4)
        #expect(regions.contains(.upperCape))
        #expect(regions.contains(.midCape))
        #expect(regions.contains(.lowerCape))
        #expect(regions.contains(.outerCape))
    }
}

// MARK: - Achievement Category Tests

@Suite("Achievement Category Tests")
struct AchievementCategoryTests {

    @Test("All four categories exist")
    func testAllCategories() {
        let categories = AchievementCategory.allCases
        #expect(categories.count == 4)
        #expect(categories.contains(.exploration))
        #expect(categories.contains(.learning))
        #expect(categories.contains(.social))
        #expect(categories.contains(.timing))
    }

    @Test("Every achievement maps to a valid category")
    func testAchievementCategoryMapping() {
        let validCategories = Set(AchievementCategory.allCases)
        for achievement in TourAchievement.allCases {
            #expect(validCategories.contains(achievement.category),
                    "\(achievement.displayName) has invalid category")
        }
    }
}

// MARK: - POI Category Tests

@Suite("POI Category Tests")
struct POICategoryTests {

    @Test("POICategory has all expected values")
    func testAllPOICategories() {
        let all = POICategory.allCases
        #expect(all.count == 12)
        #expect(all.contains(.beach))
        #expect(all.contains(.lighthouse))
        #expect(all.contains(.museum))
    }

    @Test("POICategory display names are non-empty")
    func testPOICategoryDisplayNames() {
        for category in POICategory.allCases {
            #expect(!category.displayName.isEmpty)
            #expect(!category.icon.isEmpty)
        }
    }

    @Test("POICategory to LocationCategory mapping works for shared values")
    func testPOICategoryToLocationCategory() {
        // These categories share the same raw value
        let sharedCategories: [POICategory] = [.beach, .restaurant, .lighthouse, .museum, .nature]
        for poiCat in sharedCategories {
            #expect(poiCat.toLocationCategory != nil,
                    "\(poiCat.rawValue) should map to LocationCategory")
        }
    }
}

// MARK: - Bundled Content Tests

@Suite("Bundled Content Tests")
struct BundledContentTests {

    @Test("Bundled POIs are not empty")
    func testBundledPOIsExist() {
        #expect(!BundledContent.allPOIs.isEmpty)
    }

    @Test("All bundled POIs have unique IDs")
    func testBundledPOIUniqueIDs() {
        let ids = BundledContent.allPOIs.map(\.id)
        let unique = Set(ids)
        #expect(ids.count == unique.count, "Duplicate POI IDs found in bundled content")
    }

    @Test("All bundled POIs have names")
    func testBundledPOINames() {
        for poi in BundledContent.allPOIs {
            #expect(!poi.name.isEmpty, "POI \(poi.id) has empty name")
        }
    }

    @Test("Bundled POIs have valid coordinates on Cape Cod")
    func testBundledPOICoordinates() {
        for poi in BundledContent.allPOIs {
            // Cape Cod rough bounding box
            #expect(poi.coordinate.latitude > 41.0 && poi.coordinate.latitude < 43.0,
                    "\(poi.name) latitude \(poi.coordinate.latitude) is outside Cape Cod range")
            #expect(poi.coordinate.longitude > -71.0 && poi.coordinate.longitude < -69.5,
                    "\(poi.name) longitude \(poi.coordinate.longitude) is outside Cape Cod range")
        }
    }
}

// MARK: - StoryMode Tests

@Suite("Story Mode Tests")
struct StoryModeTests {

    @Test("All story modes are available")
    func testAllModes() {
        let modes = GeofenceManager.StoryMode.allCases
        #expect(modes.count == 3)
        #expect(modes.contains(.adult))
        #expect(modes.contains(.kids))
        #expect(modes.contains(.family))
    }

    @Test("Story mode display names are capitalized")
    func testDisplayNames() {
        for mode in GeofenceManager.StoryMode.allCases {
            #expect(!mode.displayName.isEmpty)
            #expect(mode.displayName == mode.rawValue.capitalized)
        }
    }
}
