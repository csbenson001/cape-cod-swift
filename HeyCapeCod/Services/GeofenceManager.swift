import Foundation
import CoreLocation

/// Manages the 20-geofence limit on iOS by monitoring the nearest POIs
/// to the user's current location.
///
/// Strategy:
/// - Fetch POIs from backend API, falling back to bundled content
/// - Re-evaluate which 20 POIs to monitor every time user moves 500+ meters
/// - On region entry: check cooldown, mode, queue, then trigger story
/// - 24-hour cooldown per POI stored in UserDefaults
@preconcurrency @MainActor
@Observable
final class GeofenceManager {

    // MARK: - Public State

    private(set) var activeGeofences: Set<String> = []
    private(set) var lastTriggeredPOI: String?
    private(set) var cachedPOIs: [PointOfInterest] = []

    /// Story mode filter — determines which story variant to play
    enum StoryMode: String, CaseIterable, Identifiable {
        case adult, kids, family
        var id: String { rawValue }
        var displayName: String { rawValue.capitalized }
    }

    var storyMode: StoryMode = .adult

    // MARK: - Configuration

    static let maxMonitoredRegions = 20
    private static let cooldownInterval: TimeInterval = 24 * 60 * 60 // 24 hours
    private static let cooldownKey = "geofenceCooldowns"

    // MARK: - Dependencies

    private let locationManager: LocationManager

    /// Called when a story should be triggered
    var onStoryTriggered: ((PointOfInterest, StoryVariant?) -> Void)?

    // MARK: - Private State

    /// Queue of triggered POIs waiting to play (if another story is active)
    private var storyQueue: [PointOfInterest] = []
    private(set) var isStoryPlaying = false

    // MARK: - Init

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        // Start with bundled content as immediate fallback
        self.cachedPOIs = BundledContent.allPOIs
        setupLocationCallbacks()
    }

    // MARK: - Setup

    private func setupLocationCallbacks() {
        // Re-evaluate geofences when user moves 500+ meters
        locationManager.onSignificantLocationChange = { [weak self] location in
            Task { @MainActor [weak self] in
                await self?.fetchAndReEvaluate(around: location)
            }
        }

        // Handle region entry
        locationManager.onRegionEntered = { [weak self] regionID in
            Task { @MainActor [weak self] in
                self?.handleRegionEntry(regionID: regionID)
            }
        }
    }

    // MARK: - API Integration

    /// Fetch POIs from API and re-evaluate geofences.
    /// Falls back to bundled/cached POIs if API is unavailable.
    private func fetchAndReEvaluate(around location: CLLocation) async {
        let nearbyAPIPOIs = await POIService.shared.fetchNearbyPOIsList(
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude,
            radius: 15000
        )

        if !nearbyAPIPOIs.isEmpty {
            // Sort by priority descending, take top 20
            let sorted = nearbyAPIPOIs
                .sorted { $0.priority > $1.priority }
                .prefix(Self.maxMonitoredRegions)
            cachedPOIs = sorted.map { $0.toPointOfInterest() }
            print("✅ GeofenceManager loaded \(cachedPOIs.count) POIs from API")
        } else {
            print("📦 GeofenceManager using \(cachedPOIs.count) cached/bundled POIs")
        }

        reEvaluateGeofences(around: location)
    }

    // MARK: - Geofence Management

    /// Evaluate which 20 POIs are nearest and set up geofences for them.
    func reEvaluateGeofences(around location: CLLocation) {
        let pois = cachedPOIs

        // Sort by distance from user
        let sorted = pois
            .map { poi in
                let dist = location.distance(from: CLLocation(
                    latitude: poi.coordinate.latitude,
                    longitude: poi.coordinate.longitude
                ))
                return (poi: poi, distance: dist)
            }
            .sorted { $0.distance < $1.distance }

        // Take nearest 20
        let nearest = Array(sorted.prefix(Self.maxMonitoredRegions))

        // Determine which regions to add/remove
        let desiredIDs = Set(nearest.map(\.poi.id))
        let currentIDs = locationManager.monitoredRegionIDs

        // Remove regions no longer in the nearest 20
        for id in currentIDs where !desiredIDs.contains(id) {
            locationManager.stopMonitoring(regionID: id)
        }

        // Add new regions
        for entry in nearest where !currentIDs.contains(entry.poi.id) {
            locationManager.startMonitoring(
                regionID: entry.poi.id,
                center: entry.poi.coordinate,
                radius: entry.poi.geofenceRadius
            )
        }

        activeGeofences = desiredIDs
    }

    /// Initial setup — call after location permission is granted
    func startMonitoring() {
        guard let location = locationManager.currentLocation else { return }
        Task {
            await fetchAndReEvaluate(around: location)
        }
    }

    func stopMonitoring() {
        locationManager.stopAllMonitoring()
        activeGeofences.removeAll()
        storyQueue.removeAll()
    }

    // MARK: - Region Entry Handling

    private func handleRegionEntry(regionID: String) {
        guard let poi = cachedPOIs.first(where: { $0.id == regionID }) else { return }

        // Check cooldown
        guard !isOnCooldown(poiID: poi.id) else { return }

        // Find story variant matching current mode
        let story = poi.stories.first { $0.mode == storyMode }
            ?? poi.stories.first // Fall back to any available story

        // Record trigger time for cooldown
        recordTrigger(poiID: poi.id)
        lastTriggeredPOI = poi.id

        // Queue or trigger immediately
        if isStoryPlaying {
            storyQueue.append(poi)
        } else {
            triggerStory(poi: poi, story: story)
        }
    }

    private func triggerStory(poi: PointOfInterest, story: StoryVariant?) {
        isStoryPlaying = true
        onStoryTriggered?(poi, story)
    }

    /// Call when the current story finishes playing
    func storyDidFinish() {
        isStoryPlaying = false

        // Play next queued story if available
        if let next = storyQueue.first {
            storyQueue.removeFirst()
            let story = next.stories.first { $0.mode == storyMode } ?? next.stories.first
            triggerStory(poi: next, story: story)
        }
    }

    // MARK: - Cooldown Management (UserDefaults)

    private func isOnCooldown(poiID: String) -> Bool {
        let cooldowns = loadCooldowns()
        guard let lastTrigger = cooldowns[poiID] else { return false }
        return Date().timeIntervalSince(lastTrigger) < Self.cooldownInterval
    }

    private func recordTrigger(poiID: String) {
        var cooldowns = loadCooldowns()
        cooldowns[poiID] = Date()
        saveCooldowns(cooldowns)
    }

    /// Clear cooldown for a specific POI (e.g., user manually wants to replay)
    func clearCooldown(poiID: String) {
        var cooldowns = loadCooldowns()
        cooldowns.removeValue(forKey: poiID)
        saveCooldowns(cooldowns)
    }

    /// Clear all cooldowns
    func clearAllCooldowns() {
        UserDefaults.standard.removeObject(forKey: Self.cooldownKey)
    }

    private func loadCooldowns() -> [String: Date] {
        guard let data = UserDefaults.standard.data(forKey: Self.cooldownKey),
              let cooldowns = try? JSONDecoder().decode([String: Date].self, from: data)
        else { return [:] }

        // Prune expired entries
        let now = Date()
        return cooldowns.filter { now.timeIntervalSince($0.value) < Self.cooldownInterval }
    }

    private func saveCooldowns(_ cooldowns: [String: Date]) {
        guard let data = try? JSONEncoder().encode(cooldowns) else { return }
        UserDefaults.standard.set(data, forKey: Self.cooldownKey)
    }

    // MARK: - Cooldown status for UI

    func cooldownRemaining(poiID: String) -> TimeInterval? {
        let cooldowns = loadCooldowns()
        guard let lastTrigger = cooldowns[poiID] else { return nil }
        let elapsed = Date().timeIntervalSince(lastTrigger)
        let remaining = Self.cooldownInterval - elapsed
        return remaining > 0 ? remaining : nil
    }
}

// MARK: - POI & Story Data Structures

/// A Point of Interest with geofence data and story variants.
struct PointOfInterest: Identifiable, Equatable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let geofenceRadius: CLLocationDistance
    let category: LocationCategory
    let town: CapeCodTown
    let description: String
    let stories: [StoryVariant]
    let facts: [String]
    let tips: [String]
    let imageSystemName: String?

    static func == (lhs: PointOfInterest, rhs: PointOfInterest) -> Bool {
        lhs.id == rhs.id
    }
}

/// A single story variant within a POI, keyed to a content mode.
struct StoryVariant: Identifiable, Equatable {
    let id: String
    let title: String
    let mode: GeofenceManager.StoryMode
    let script: String
    let duration: TimeInterval // estimated seconds

    init(
        title: String,
        mode: GeofenceManager.StoryMode,
        script: String,
        duration: TimeInterval = 0
    ) {
        self.id = "\(title)-\(mode.rawValue)"
        self.title = title
        self.mode = mode
        self.script = script
        // Rough estimate: ~150 words/minute for TTS
        self.duration = duration > 0 ? duration : Double(script.split(separator: " ").count) / 2.5
    }
}

// MARK: - API POI → PointOfInterest Conversion

extension POI {
    func toPointOfInterest() -> PointOfInterest {
        PointOfInterest(
            id: id,
            name: name,
            coordinate: coordinate,
            geofenceRadius: CLLocationDistance(radius),
            category: category.toLocationCategory ?? .nature,
            town: CapeCodTown(rawValue: town) ?? .barnstable,
            description: description,
            stories: [],
            facts: facts,
            tips: tips,
            imageSystemName: nil
        )
    }
}

// MARK: - PointOfInterest → POI Conversion (for BundledContent)

extension PointOfInterest {
    func toPOI() -> POI {
        POI(
            id: id,
            name: name,
            description: description,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            radius: Int(geofenceRadius),
            category: POICategory(rawValue: category.rawValue) ?? .nature,
            town: town.rawValue,
            facts: facts,
            tips: tips
        )
    }
}
