import CoreLocation

@preconcurrency @MainActor
@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var heading: CLHeading?
    var nearbyStoryTrigger: UUID?

    private let locationManager = CLLocationManager()
    private var monitoredStories: [UUID: CLCircularRegion] = [:]

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.allowsBackgroundLocationUpdates = false
    }

    // MARK: - Authorization

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    var isAuthorized: Bool {
        [.authorizedWhenInUse, .authorizedAlways].contains(authorizationStatus)
    }

    // MARK: - Location Updates

    func startUpdating() {
        guard isAuthorized else {
            requestAuthorization()
            return
        }
        locationManager.startUpdatingLocation()
    }

    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - Heading

    func startHeadingUpdates() {
        guard CLLocationManager.headingAvailable() else { return }
        locationManager.startUpdatingHeading()
    }

    // MARK: - Story Geofencing

    func monitorStory(_ story: Story) {
        guard let coordinate = story.triggerCoordinate,
              CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }

        let region = CLCircularRegion(
            center: coordinate,
            radius: story.triggerRadius,
            identifier: story.id.uuidString
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false

        monitoredStories[story.id] = region
        locationManager.startMonitoring(for: region)
    }

    func stopMonitoringStory(_ story: Story) {
        guard let region = monitoredStories.removeValue(forKey: story.id) else { return }
        locationManager.stopMonitoring(for: region)
    }

    func stopAllMonitoring() {
        for region in monitoredStories.values {
            locationManager.stopMonitoring(for: region)
        }
        monitoredStories.removeAll()
    }

    // MARK: - Distance Helpers

    func distance(to location: CodLocation) -> CLLocationDistance? {
        currentLocation?.distance(from: location.clLocation)
    }

    func formattedDistance(to location: CodLocation) -> String? {
        guard let meters = distance(to: location) else { return nil }
        let miles = meters / 1609.34
        if miles < 0.1 {
            return "\(Int(meters)) ft"
        } else if miles < 10 {
            return String(format: "%.1f mi", miles)
        } else {
            return "\(Int(miles)) mi"
        }
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            currentLocation = locations.last
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            authorizationStatus = status
            if isAuthorized {
                startUpdating()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        Task { @MainActor in
            heading = newHeading
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let identifier = region.identifier
        Task { @MainActor in
            guard let storyID = UUID(uuidString: identifier) else { return }
            nearbyStoryTrigger = storyID
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Location errors are non-fatal — GPS may be temporarily unavailable
    }
}
