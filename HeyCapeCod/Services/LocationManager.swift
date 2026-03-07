import CoreLocation

/// Async/await wrapper around CLLocationManager.
///
/// Supports two permission levels:
/// - "When In Use" — continuous location for the map
/// - "Always" — background geofence triggers for GPS-triggered stories
@Observable
final class LocationManager: NSObject, @unchecked Sendable {

    // MARK: - Public State

    private(set) var currentLocation: CLLocation?
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private(set) var heading: CLHeading?
    private(set) var locationError: Error?

    var isAuthorized: Bool {
        [.authorizedWhenInUse, .authorizedAlways].contains(authorizationStatus)
    }

    var hasAlwaysPermission: Bool {
        authorizationStatus == .authorizedAlways
    }

    var isDenied: Bool {
        [.denied, .restricted].contains(authorizationStatus)
    }

    var permissionMessage: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Location access lets us trigger stories as you explore Cape Cod."
        case .restricted:
            return "Location access is restricted on this device. Check parental controls or device management settings."
        case .denied:
            return "Location access was denied. Open Settings to enable it for GPS-triggered stories."
        case .authorizedWhenInUse:
            return "For background story triggers, upgrade to \"Always\" in Settings."
        case .authorizedAlways:
            return "Full location access enabled."
        @unknown default:
            return "Unknown location permission state."
        }
    }

    // MARK: - Callbacks

    /// Called when user moves significantly (for geofence re-evaluation)
    var onSignificantLocationChange: ((CLLocation) -> Void)?

    /// Called when a monitored geofence region is entered
    var onRegionEntered: ((String) -> Void)?

    // MARK: - Private State

    private let manager = CLLocationManager()
    private var lastSignificantLocation: CLLocation?
    private static let significantDistanceThreshold: CLLocationDistance = 500

    // Authorization continuations
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    // MARK: - Init

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 20
        manager.allowsBackgroundLocationUpdates = false
        manager.pausesLocationUpdatesAutomatically = true
        authorizationStatus = manager.authorizationStatus
    }

    // MARK: - Permission Requests (async/await)

    /// Request "When In Use" permission. Returns the resulting authorization status.
    @discardableResult
    func requestWhenInUsePermission() async -> CLAuthorizationStatus {
        guard authorizationStatus == .notDetermined else { return authorizationStatus }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    /// Request "Always" permission (must have "When In Use" first on iOS).
    /// Returns the resulting authorization status.
    @discardableResult
    func requestAlwaysPermission() async -> CLAuthorizationStatus {
        // If not determined, get WhenInUse first
        if authorizationStatus == .notDetermined {
            await requestWhenInUsePermission()
        }

        guard authorizationStatus == .authorizedWhenInUse else {
            return authorizationStatus
        }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            manager.requestAlwaysAuthorization()
        }
    }

    // MARK: - One-Shot Location (async/await)

    /// Get a single location fix. Throws if location services are unavailable.
    func requestLocation() async throws -> CLLocation {
        guard isAuthorized else {
            throw LocationManagerError.notAuthorized
        }

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    // MARK: - Continuous Updates

    func startContinuousUpdates() {
        guard isAuthorized else { return }
        manager.startUpdatingLocation()
    }

    func stopContinuousUpdates() {
        manager.stopUpdatingLocation()
    }

    func startHeadingUpdates() {
        guard CLLocationManager.headingAvailable() else { return }
        manager.startUpdatingHeading()
    }

    func stopHeadingUpdates() {
        manager.stopUpdatingHeading()
    }

    // MARK: - Background Location (for geofences)

    func enableBackgroundUpdates() {
        guard hasAlwaysPermission else { return }
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
    }

    func disableBackgroundUpdates() {
        manager.allowsBackgroundLocationUpdates = false
        manager.showsBackgroundLocationIndicator = false
    }

    // MARK: - Geofence Region Monitoring

    /// Monitor a circular region. iOS limits to 20 simultaneous regions.
    func startMonitoring(regionID: String, center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }

        let clampedRadius = min(radius, manager.maximumRegionMonitoringDistance)
        let region = CLCircularRegion(center: center, radius: clampedRadius, identifier: regionID)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        manager.startMonitoring(for: region)
    }

    func stopMonitoring(regionID: String) {
        for region in manager.monitoredRegions {
            if region.identifier == regionID {
                manager.stopMonitoring(for: region)
                break
            }
        }
    }

    func stopAllMonitoring() {
        for region in manager.monitoredRegions {
            manager.stopMonitoring(for: region)
        }
    }

    var monitoredRegionCount: Int {
        manager.monitoredRegions.count
    }

    var monitoredRegionIDs: Set<String> {
        Set(manager.monitoredRegions.map(\.identifier))
    }

    // MARK: - Distance Helpers

    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
        currentLocation?.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }

    func formattedDistance(to coordinate: CLLocationCoordinate2D) -> String? {
        guard let meters = distance(to: coordinate) else { return nil }
        let miles = meters / 1609.34
        if miles < 0.1 {
            return "\(Int(meters * 3.28084)) ft"
        } else if miles < 10 {
            return String(format: "%.1f mi", miles)
        } else {
            return "\(Int(miles)) mi"
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if let continuation = authorizationContinuation {
            authorizationContinuation = nil
            continuation.resume(returning: authorizationStatus)
        }

        if isAuthorized {
            startContinuousUpdates()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location

        // Fulfill one-shot request
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(returning: location)
        }

        // Check for significant movement (500m) for geofence re-evaluation
        if let last = lastSignificantLocation {
            if location.distance(from: last) >= Self.significantDistanceThreshold {
                lastSignificantLocation = location
                onSignificantLocationChange?(location)
            }
        } else {
            lastSignificantLocation = location
            onSignificantLocationChange?(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error

        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(throwing: error)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        onRegionEntered?(region.identifier)
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        // Non-fatal — region monitoring may be temporarily unavailable
        print("[LocationManager] Monitoring failed for \(region?.identifier ?? "unknown"): \(error.localizedDescription)")
    }
}

// MARK: - Errors

enum LocationManagerError: LocalizedError {
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            "Location permission is required. Please enable it in Settings."
        }
    }
}
