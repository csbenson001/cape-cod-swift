import Foundation
import SwiftUI
import CoreLocation

// MARK: - Tour Integration ViewModel

/// Ties together all tour sub-features -- achievements, Q&A, story chapters,
/// persona-narrated stories -- with the guided tour flow.
///
/// Owns the tour lifecycle from `startTour` through `completeTour` and
/// exposes computed properties that drive the active-tour UI.
@preconcurrency @MainActor
@Observable
final class TourIntegrationViewModel {

    // MARK: - Tour State

    var currentTour: GuidedTour?
    var currentStopIndex: Int = 0
    var completedStops: Set<Int> = []
    var tourStartTime: Date?
    var tourEndTime: Date?

    // MARK: - Sub-Feature Sheet / Overlay States

    var showQA: Bool = false
    var showInfoCard: Bool = false
    var showAchievements: Bool = false
    var showChapters: Bool = false
    var showStoryPicker: Bool = false

    // MARK: - Story Player Integration

    var storyPlayer: StoryPlayerViewModel?
    var storyChapters: [StoryChapter] = []
    var selectedPersona: StoryPersona?

    // MARK: - Achievement Tracking

    private(set) var tourAchievements: TourAchievementService
    private(set) var newlyUnlockedAchievements: [TourAchievement] = []
    var storiesListenedCount: Int = 0
    var questionsAskedCount: Int = 0

    // MARK: - Tour Statistics

    var totalDistanceTraveled: Double = 0

    /// Average time the user spends at each completed stop.
    var averageTimePerStop: TimeInterval {
        guard !completedStops.isEmpty, let start = tourStartTime else { return 0 }
        let elapsed = (tourEndTime ?? Date()).timeIntervalSince(start)
        return elapsed / Double(completedStops.count)
    }

    // MARK: - Resolved Stops Cache

    private var resolvedStops: [PointOfInterest] = []

    // MARK: - Init

    init(achievementService: TourAchievementService = .shared) {
        self.tourAchievements = achievementService
    }

    // MARK: - Computed Properties

    /// The current stop's `PointOfInterest`, if the tour is active.
    var currentStop: PointOfInterest? {
        guard currentStopIndex >= 0, currentStopIndex < resolvedStops.count else { return nil }
        return resolvedStops[currentStopIndex]
    }

    /// All resolved stops in tour order.
    var stops: [PointOfInterest] {
        resolvedStops
    }

    /// Whether the user is on the final stop.
    var isLastStop: Bool {
        guard !resolvedStops.isEmpty else { return false }
        return currentStopIndex >= resolvedStops.count - 1
    }

    /// Whether the tour has been completed.
    var isTourComplete: Bool {
        tourEndTime != nil
    }

    /// Wall-clock duration of the tour so far (or total if complete).
    var tourDuration: TimeInterval {
        guard let start = tourStartTime else { return 0 }
        return (tourEndTime ?? Date()).timeIntervalSince(start)
    }

    /// Fraction of stops completed, 0.0 ... 1.0.
    var progressPercentage: Double {
        guard !resolvedStops.isEmpty else { return 0 }
        return Double(completedStops.count) / Double(resolvedStops.count)
    }

    // MARK: - Tour Lifecycle

    /// Begin a guided tour. Resolves stop IDs to POIs, records the start
    /// with the achievement service, and triggers a haptic.
    func startTour(_ tour: GuidedTour) {
        currentTour = tour
        resolvedStops = tour.resolvedStops(from: BundledContent.allPOIs)
        currentStopIndex = 0
        completedStops = []
        tourStartTime = Date()
        tourEndTime = nil
        storiesListenedCount = 0
        questionsAskedCount = 0
        totalDistanceTraveled = 0
        newlyUnlockedAchievements = []
        storyChapters = []
        storyPlayer = nil
        selectedPersona = nil

        // Let the achievement service know a tour has started
        tourAchievements.recordTourStarted()

        CodHaptic.success()
    }

    /// Mark a stop as visited and advance the stop index.
    func markStopVisited(_ index: Int) {
        guard index >= 0, index < resolvedStops.count else { return }

        completedStops.insert(index)

        let poi = resolvedStops[index]
        tourAchievements.recordPOIVisit(
            poiId: poi.id,
            category: poi.category,
            region: poi.town.region
        )

        // Advance to next unvisited stop if current stop was just completed
        if index == currentStopIndex, !isLastStop {
            withAnimation(CodAnimation.spring) {
                currentStopIndex = index + 1
            }
        }

        CodHaptic.tap()
        checkAchievements()
    }

    /// Finish the tour, record it with achievements, and fire haptics.
    func completeTour() {
        guard let tour = currentTour else { return }

        tourEndTime = Date()
        tourAchievements.recordTourCompleted(tourCategory: tour.category)

        CodHaptic.success()
        checkAchievements()
    }

    // MARK: - Story Playback

    /// Play the first matching story at the current stop.
    /// Generates chapters from the script and wires up the player.
    func playStoryAtCurrentStop() {
        guard let stop = currentStop,
              let story = resolvedStory(for: stop) else { return }

        let player = StoryPlayerViewModel()
        player.loadAndPlay(poi: stop, story: story)
        storyPlayer = player

        // Generate chapters for the chaptered progress bar / list
        storyChapters = StoryChapterService.generateChapters(
            from: story.script,
            storyTitle: story.title
        )

        storiesListenedCount += 1
        tourAchievements.recordStoryPlayed()

        CodHaptic.selection()
        checkAchievements()
    }

    // MARK: - Q&A / Info

    /// Show the Q&A sheet for the current stop.
    func openQAForCurrentStop() {
        guard currentStop != nil else { return }
        questionsAskedCount += 1
        withAnimation(CodAnimation.spring) {
            showQA = true
        }
        CodHaptic.selection()
    }

    /// Show the info card for the current stop.
    func openInfoForCurrentStop() {
        guard currentStop != nil else { return }
        withAnimation(CodAnimation.spring) {
            showInfoCard = true
        }
        CodHaptic.selection()
    }

    // MARK: - Persona Selection

    /// Select a narrator persona. If a stop is loaded, regenerates the
    /// story chapters preview with the persona's voice description.
    func selectPersona(_ persona: StoryPersona) {
        selectedPersona = persona

        withAnimation(CodAnimation.quick) {
            showStoryPicker = false
        }

        CodHaptic.tap()
    }

    // MARK: - Achievement Checking

    /// Evaluate whether any new achievements should unlock based on
    /// current tour statistics. Newly unlocked items are appended to
    /// `newlyUnlockedAchievements` so the UI can present a celebration.
    func checkAchievements() {
        let previouslyUnlocked = tourAchievements.unlockedAchievements

        tourAchievements.checkAchievements()

        // Determine which achievements were just unlocked
        let freshUnlocks = tourAchievements.unlockedAchievements
            .subtracting(previouslyUnlocked)

        let newAchievements = TourAchievement.allCases.filter {
            freshUnlocks.contains($0.id)
        }

        if !newAchievements.isEmpty {
            newlyUnlockedAchievements.append(contentsOf: newAchievements)
            CodHaptic.success()

            // Briefly show the achievements overlay
            withAnimation(CodAnimation.spring) {
                showAchievements = true
            }
        }
    }

    /// Dismiss the most recent achievement notification.
    func dismissAchievementBanner() {
        if !newlyUnlockedAchievements.isEmpty {
            withAnimation(CodAnimation.quick) {
                newlyUnlockedAchievements.removeFirst()
                if newlyUnlockedAchievements.isEmpty {
                    showAchievements = false
                }
            }
        }
    }

    // MARK: - Navigation Helpers

    /// Jump to a specific stop index without marking intermediate stops.
    func navigateToStop(_ index: Int) {
        guard index >= 0, index < resolvedStops.count else { return }

        withAnimation(CodAnimation.spring) {
            currentStopIndex = index
        }

        // Recalculate chapters for the new stop if a story is available
        if let stop = resolvedStops[safe: index],
           let story = resolvedStory(for: stop) {
            storyChapters = StoryChapterService.generateChapters(
                from: story.script,
                storyTitle: story.title
            )
        } else {
            storyChapters = []
        }

        CodHaptic.selection()
    }

    /// Reset the view model to its idle state (no active tour).
    func resetTour() {
        currentTour = nil
        resolvedStops = []
        currentStopIndex = 0
        completedStops = []
        tourStartTime = nil
        tourEndTime = nil
        storyPlayer = nil
        storyChapters = []
        selectedPersona = nil
        storiesListenedCount = 0
        questionsAskedCount = 0
        totalDistanceTraveled = 0
        newlyUnlockedAchievements = []
        showQA = false
        showInfoCard = false
        showAchievements = false
        showChapters = false
        showStoryPicker = false
    }

    // MARK: - Private Helpers

    /// Pick the best story variant for the current experience mode.
    private func resolvedStory(for poi: PointOfInterest) -> StoryVariant? {
        guard !poi.stories.isEmpty else { return nil }

        // If a persona is selected, find a matching story or fall back to first
        if let persona = selectedPersona {
            let personaTitle = persona.displayName.lowercased()
            if let match = poi.stories.first(where: {
                $0.title.lowercased().contains(personaTitle)
            }) {
                return match
            }
        }

        // Fall back to first available story
        return poi.stories.first
    }
}

// MARK: - Collection Safe Subscript

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
