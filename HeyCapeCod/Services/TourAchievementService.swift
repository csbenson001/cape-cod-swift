import Foundation

// MARK: - Achievement Category

enum AchievementCategory: String, CaseIterable, Identifiable {
    case exploration
    case learning
    case social
    case timing

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .exploration: "Exploration"
        case .learning: "Learning"
        case .social: "Social"
        case .timing: "Timing"
        }
    }

    var icon: String {
        switch self {
        case .exploration: "map"
        case .learning: "book"
        case .social: "person.2"
        case .timing: "clock"
        }
    }
}

// MARK: - Tour Achievement

enum TourAchievement: String, CaseIterable, Identifiable {
    case firstStep
    case storyteller
    case explorer
    case lighthouseKeeper
    case historyBuff
    case beachcomber
    case tourPro
    case capeComplete
    case nightOwl
    case earlyBird
    case socialButterfly
    case masterExplorer

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .firstStep: "First Step"
        case .storyteller: "Storyteller"
        case .explorer: "Cape Explorer"
        case .lighthouseKeeper: "Lighthouse Keeper"
        case .historyBuff: "History Buff"
        case .beachcomber: "Beachcomber"
        case .tourPro: "Tour Pro"
        case .capeComplete: "Cape Completionist"
        case .nightOwl: "Night Owl"
        case .earlyBird: "Early Bird"
        case .socialButterfly: "Social Butterfly"
        case .masterExplorer: "Master Explorer"
        }
    }

    var description: String {
        switch self {
        case .firstStep: "Visit your very first point of interest on Cape Cod."
        case .storyteller: "Listen to 5 audio stories about Cape Cod's rich history."
        case .explorer: "Discover 10 different points of interest across the Cape."
        case .lighthouseKeeper: "Visit every lighthouse on Cape Cod."
        case .historyBuff: "Complete a history-themed guided tour."
        case .beachcomber: "Set foot on 5 different Cape Cod beaches."
        case .tourPro: "Complete 3 guided tours of the Cape."
        case .capeComplete: "Visit points of interest in all 4 Cape Cod regions."
        case .nightOwl: "Start a guided tour after 6 PM."
        case .earlyBird: "Start a guided tour before 8 AM."
        case .socialButterfly: "Share a tour with a friend."
        case .masterExplorer: "Visit 20 or more points of interest."
        }
    }

    var icon: String {
        switch self {
        case .firstStep: "figure.walk"
        case .storyteller: "headphones"
        case .explorer: "map"
        case .lighthouseKeeper: "light.beacon.max.fill"
        case .historyBuff: "building.columns"
        case .beachcomber: "beach.umbrella"
        case .tourPro: "star.fill"
        case .capeComplete: "checkmark.seal.fill"
        case .nightOwl: "moon.stars.fill"
        case .earlyBird: "sunrise.fill"
        case .socialButterfly: "square.and.arrow.up"
        case .masterExplorer: "crown.fill"
        }
    }

    var requirement: String {
        switch self {
        case .firstStep: "Visit 1 POI"
        case .storyteller: "Listen to 5 stories"
        case .explorer: "Visit 10 POIs"
        case .lighthouseKeeper: "Visit all lighthouses"
        case .historyBuff: "Complete 1 history tour"
        case .beachcomber: "Visit 5 beaches"
        case .tourPro: "Complete 3 tours"
        case .capeComplete: "Visit all 4 regions"
        case .nightOwl: "Start a tour after 6 PM"
        case .earlyBird: "Start a tour before 8 AM"
        case .socialButterfly: "Share 1 tour"
        case .masterExplorer: "Visit 20 POIs"
        }
    }

    var category: AchievementCategory {
        switch self {
        case .firstStep, .explorer, .lighthouseKeeper, .beachcomber, .capeComplete, .masterExplorer:
            .exploration
        case .storyteller, .historyBuff, .tourPro:
            .learning
        case .socialButterfly:
            .social
        case .nightOwl, .earlyBird:
            .timing
        }
    }

    /// The target count used for progress calculation where applicable.
    var targetCount: Int {
        switch self {
        case .firstStep: 1
        case .storyteller: 5
        case .explorer: 10
        case .lighthouseKeeper: 5 // approximate total lighthouses
        case .historyBuff: 1
        case .beachcomber: 5
        case .tourPro: 3
        case .capeComplete: 4
        case .nightOwl: 1
        case .earlyBird: 1
        case .socialButterfly: 1
        case .masterExplorer: 20
        }
    }
}

// MARK: - Tour Achievement Service

@preconcurrency @MainActor
@Observable
final class TourAchievementService {
    static let shared = TourAchievementService()

    // MARK: - Published State

    private(set) var unlockedAchievements: Set<String> = []
    var recentUnlock: TourAchievement?

    var totalPOIsVisited: Int { visitedPOIIds.count }
    private(set) var totalStoriesPlayed: Int = 0
    private(set) var totalToursCompleted: Int = 0
    private(set) var regionsVisited: Set<String> = []
    private(set) var categoriesVisited: Set<String> = []
    private(set) var totalShares: Int = 0
    private(set) var hasStartedTourAtNight: Bool = false
    private(set) var hasStartedTourEarly: Bool = false
    private(set) var hasCompletedHistoryTour: Bool = false
    private(set) var visitedPOIIds: Set<String> = []
    private(set) var beachesVisited: Int = 0
    private(set) var lighthousesVisited: Int = 0

    // MARK: - Persistence Keys

    private enum Keys {
        static let unlocked = "tour_achievements_unlocked"
        static let storiesPlayed = "tour_achievements_stories_played"
        static let toursCompleted = "tour_achievements_tours_completed"
        static let regions = "tour_achievements_regions"
        static let categories = "tour_achievements_categories"
        static let shares = "tour_achievements_shares"
        static let nightTour = "tour_achievements_night_tour"
        static let earlyTour = "tour_achievements_early_tour"
        static let historyTour = "tour_achievements_history_tour"
        static let visitedIds = "tour_achievements_visited_ids"
        static let beaches = "tour_achievements_beaches"
        static let lighthouses = "tour_achievements_lighthouses"
    }

    // MARK: - Init

    private init() {
        loadFromDefaults()
    }

    // MARK: - Persistence

    private func loadFromDefaults() {
        let defaults = UserDefaults.standard
        if let saved = defaults.stringArray(forKey: Keys.unlocked) {
            unlockedAchievements = Set(saved)
        }
        totalStoriesPlayed = defaults.integer(forKey: Keys.storiesPlayed)
        totalToursCompleted = defaults.integer(forKey: Keys.toursCompleted)
        if let savedRegions = defaults.stringArray(forKey: Keys.regions) {
            regionsVisited = Set(savedRegions)
        }
        if let savedCategories = defaults.stringArray(forKey: Keys.categories) {
            categoriesVisited = Set(savedCategories)
        }
        totalShares = defaults.integer(forKey: Keys.shares)
        hasStartedTourAtNight = defaults.bool(forKey: Keys.nightTour)
        hasStartedTourEarly = defaults.bool(forKey: Keys.earlyTour)
        hasCompletedHistoryTour = defaults.bool(forKey: Keys.historyTour)
        if let savedIds = defaults.stringArray(forKey: Keys.visitedIds) {
            visitedPOIIds = Set(savedIds)
        }
        beachesVisited = defaults.integer(forKey: Keys.beaches)
        lighthousesVisited = defaults.integer(forKey: Keys.lighthouses)
    }

    private func saveToDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(Array(unlockedAchievements), forKey: Keys.unlocked)
        defaults.set(totalStoriesPlayed, forKey: Keys.storiesPlayed)
        defaults.set(totalToursCompleted, forKey: Keys.toursCompleted)
        defaults.set(Array(regionsVisited), forKey: Keys.regions)
        defaults.set(Array(categoriesVisited), forKey: Keys.categories)
        defaults.set(totalShares, forKey: Keys.shares)
        defaults.set(hasStartedTourAtNight, forKey: Keys.nightTour)
        defaults.set(hasStartedTourEarly, forKey: Keys.earlyTour)
        defaults.set(hasCompletedHistoryTour, forKey: Keys.historyTour)
        defaults.set(Array(visitedPOIIds), forKey: Keys.visitedIds)
        defaults.set(beachesVisited, forKey: Keys.beaches)
        defaults.set(lighthousesVisited, forKey: Keys.lighthouses)

        syncToBackend()
    }

    // MARK: - Backend Sync

    /// Sync achievements to the backend (fire-and-forget).
    private func syncToBackend() {
        Task {
            do {
                let payload = AchievementSyncPayload(
                    unlocked: Array(unlockedAchievements),
                    metrics: AchievementMetrics(
                        totalPOIsVisited: totalPOIsVisited,
                        totalStoriesPlayed: totalStoriesPlayed,
                        totalToursCompleted: totalToursCompleted,
                        regionsVisited: Array(regionsVisited),
                        categoriesVisited: Array(categoriesVisited),
                        beachesVisited: beachesVisited,
                        lighthousesVisited: lighthousesVisited,
                        totalShares: totalShares,
                        hasStartedTourAtNight: hasStartedTourAtNight,
                        hasStartedTourEarly: hasStartedTourEarly,
                        hasCompletedHistoryTour: hasCompletedHistoryTour,
                        visitedPOIIds: Array(visitedPOIIds)
                    )
                )
                let _: AchievementSyncResponse = try await APIClient.shared.put("achievements", body: payload)
                print("✅ Achievements synced to backend")
            } catch {
                print("⚠️ Achievement sync failed (will retry next save): \(error.localizedDescription)")
            }
        }
    }

    /// Pull achievements from backend and merge with local state.
    func syncFromBackend() async {
        do {
            let response: AchievementFetchResponse = try await APIClient.shared.get("achievements")
            let remote = response.achievements

            // Merge: take the union of unlocked achievements
            let mergedUnlocked = unlockedAchievements.union(Set(remote.unlocked))
            if mergedUnlocked.count > unlockedAchievements.count {
                unlockedAchievements = mergedUnlocked
            }

            // Take the max of each metric
            totalStoriesPlayed = max(totalStoriesPlayed, remote.metrics.totalStoriesPlayed)
            totalToursCompleted = max(totalToursCompleted, remote.metrics.totalToursCompleted)
            regionsVisited = regionsVisited.union(Set(remote.metrics.regionsVisited))
            categoriesVisited = categoriesVisited.union(Set(remote.metrics.categoriesVisited))
            beachesVisited = max(beachesVisited, remote.metrics.beachesVisited)
            lighthousesVisited = max(lighthousesVisited, remote.metrics.lighthousesVisited)
            totalShares = max(totalShares, remote.metrics.totalShares)
            visitedPOIIds = visitedPOIIds.union(Set(remote.metrics.visitedPOIIds))
            hasStartedTourAtNight = hasStartedTourAtNight || remote.metrics.hasStartedTourAtNight
            hasStartedTourEarly = hasStartedTourEarly || remote.metrics.hasStartedTourEarly
            hasCompletedHistoryTour = hasCompletedHistoryTour || remote.metrics.hasCompletedHistoryTour

            // Persist merged state locally
            let defaults = UserDefaults.standard
            defaults.set(Array(unlockedAchievements), forKey: Keys.unlocked)
            defaults.set(totalStoriesPlayed, forKey: Keys.storiesPlayed)
            defaults.set(totalToursCompleted, forKey: Keys.toursCompleted)
            defaults.set(Array(regionsVisited), forKey: Keys.regions)
            defaults.set(Array(categoriesVisited), forKey: Keys.categories)
            defaults.set(totalShares, forKey: Keys.shares)
            defaults.set(hasStartedTourAtNight, forKey: Keys.nightTour)
            defaults.set(hasStartedTourEarly, forKey: Keys.earlyTour)
            defaults.set(hasCompletedHistoryTour, forKey: Keys.historyTour)
            defaults.set(Array(visitedPOIIds), forKey: Keys.visitedIds)
            defaults.set(beachesVisited, forKey: Keys.beaches)
            defaults.set(lighthousesVisited, forKey: Keys.lighthouses)

            print("✅ Achievements synced from backend")
        } catch {
            print("⚠️ Achievement fetch failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Recording Events

    func recordPOIVisit(poiId: String, category: LocationCategory, region: CapeRegion) {
        guard !visitedPOIIds.contains(poiId) else { return }

        visitedPOIIds.insert(poiId)
        regionsVisited.insert(region.rawValue)
        categoriesVisited.insert(category.rawValue)

        if category == .beach {
            beachesVisited += 1
        }
        if category == .lighthouse {
            lighthousesVisited += 1
        }

        saveToDefaults()
        checkAchievements()
    }

    func recordStoryPlayed() {
        totalStoriesPlayed += 1
        saveToDefaults()
        checkAchievements()
    }

    func recordTourCompleted(tourCategory: TourCategory) {
        totalToursCompleted += 1
        if tourCategory == .history {
            hasCompletedHistoryTour = true
        }
        saveToDefaults()
        checkAchievements()
    }

    func recordTourStarted() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 18 {
            hasStartedTourAtNight = true
        }
        if hour < 8 {
            hasStartedTourEarly = true
        }
        saveToDefaults()
        checkAchievements()
    }

    func recordShare() {
        totalShares += 1
        saveToDefaults()
        checkAchievements()
    }

    // MARK: - Achievement Evaluation

    func checkAchievements() {
        for achievement in TourAchievement.allCases {
            guard !unlockedAchievements.contains(achievement.id) else { continue }

            let shouldUnlock: Bool
            switch achievement {
            case .firstStep:
                shouldUnlock = totalPOIsVisited >= 1
            case .storyteller:
                shouldUnlock = totalStoriesPlayed >= 5
            case .explorer:
                shouldUnlock = totalPOIsVisited >= 10
            case .lighthouseKeeper:
                shouldUnlock = lighthousesVisited >= 5
            case .historyBuff:
                shouldUnlock = hasCompletedHistoryTour
            case .beachcomber:
                shouldUnlock = beachesVisited >= 5
            case .tourPro:
                shouldUnlock = totalToursCompleted >= 3
            case .capeComplete:
                shouldUnlock = regionsVisited.count >= 4
            case .nightOwl:
                shouldUnlock = hasStartedTourAtNight
            case .earlyBird:
                shouldUnlock = hasStartedTourEarly
            case .socialButterfly:
                shouldUnlock = totalShares >= 1
            case .masterExplorer:
                shouldUnlock = totalPOIsVisited >= 20
            }

            if shouldUnlock {
                unlockAchievement(achievement)
            }
        }
    }

    func progress(for achievement: TourAchievement) -> Double {
        if unlockedAchievements.contains(achievement.id) {
            return 1.0
        }

        let current: Double
        let target = Double(achievement.targetCount)

        switch achievement {
        case .firstStep, .explorer, .masterExplorer:
            current = Double(totalPOIsVisited)
        case .storyteller:
            current = Double(totalStoriesPlayed)
        case .lighthouseKeeper:
            current = Double(lighthousesVisited)
        case .historyBuff:
            current = hasCompletedHistoryTour ? 1.0 : 0.0
        case .beachcomber:
            current = Double(beachesVisited)
        case .tourPro:
            current = Double(totalToursCompleted)
        case .capeComplete:
            current = Double(regionsVisited.count)
        case .nightOwl:
            current = hasStartedTourAtNight ? 1.0 : 0.0
        case .earlyBird:
            current = hasStartedTourEarly ? 1.0 : 0.0
        case .socialButterfly:
            current = Double(totalShares)
        }

        return min(current / target, 1.0)
    }

    func unlockAchievement(_ achievement: TourAchievement) {
        unlockedAchievements.insert(achievement.id)
        recentUnlock = achievement
        saveToDefaults()
        CodHaptic.success()
    }

    // MARK: - Computed Helpers

    var unlockedCount: Int {
        unlockedAchievements.count
    }

    static let totalAchievements: Int = TourAchievement.allCases.count

    var overallProgress: Double {
        guard Self.totalAchievements > 0 else { return 0 }
        return Double(unlockedCount) / Double(Self.totalAchievements)
    }

    func isUnlocked(_ achievement: TourAchievement) -> Bool {
        unlockedAchievements.contains(achievement.id)
    }
}

// MARK: - Backend Sync Models

private struct AchievementSyncPayload: Encodable {
    let unlocked: [String]
    let metrics: AchievementMetrics
}

private struct AchievementSyncResponse: Decodable {
    let success: Bool
}

private struct AchievementFetchResponse: Decodable {
    let achievements: AchievementData
}

private struct AchievementData: Decodable {
    let unlocked: [String]
    let metrics: AchievementMetrics
}

struct AchievementMetrics: Codable {
    let totalPOIsVisited: Int
    let totalStoriesPlayed: Int
    let totalToursCompleted: Int
    let regionsVisited: [String]
    let categoriesVisited: [String]
    let beachesVisited: Int
    let lighthousesVisited: Int
    let totalShares: Int
    let hasStartedTourAtNight: Bool
    let hasStartedTourEarly: Bool
    let hasCompletedHistoryTour: Bool
    let visitedPOIIds: [String]
}
