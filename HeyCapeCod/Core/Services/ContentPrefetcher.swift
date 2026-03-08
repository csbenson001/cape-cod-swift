import Foundation
import CoreLocation

/// Pre-fetches and caches content for nearby POIs, weather data, and
/// pre-connects WebSocket when the voice tab is selected.
///
/// Performance targets:
/// - Audio latency: < 200ms round trip
/// - GPS battery: < 5% per hour in background
/// - App launch: < 2 seconds
@preconcurrency @MainActor
@Observable
final class ContentPrefetcher {
    static let shared = ContentPrefetcher()

    private(set) var isPrefetching = false
    private(set) var prefetchedPOICount = 0

    private var prefetchTask: Task<Void, Never>?

    private init() {}

    // MARK: - Nearby POI Prefetch

    /// Preload content for POIs within a radius when user location changes.
    /// Called by LocationManager on significant location change.
    func prefetchNearbyContent(around location: CLLocation) {
        prefetchTask?.cancel()
        prefetchTask = Task { [weak self] in
            guard let self, !Task.isCancelled else { return }
            isPrefetching = true
            defer { isPrefetching = false }

            // Fetch nearby POIs (this also caches them via SwiftData)
            let pois = await POIService.shared.fetchNearbyPOIsList(
                lat: location.coordinate.latitude,
                lng: location.coordinate.longitude,
                radius: 10000 // 10km radius
            )
            prefetchedPOICount = pois.count
            print("📦 Prefetched \(pois.count) nearby POIs")
        }
    }

    // MARK: - Weather Cache

    /// Aggressively cache weather data with 15-minute TTL.
    /// Called on app launch and every 15 minutes.
    func prefetchWeather() {
        Task {
            let weatherService = WeatherService()
            let coordinate = WeatherService.capeCodCenter
            _ = try? await weatherService.fetchWeather(for: coordinate)
            await weatherService.fetchTides()
            await weatherService.fetchBuoyData()
            print("📦 Weather data prefetched")
        }
    }

    // MARK: - WebSocket Pre-Connect

    /// Pre-connect WebSocket when voice tab is selected to reduce latency.
    func preConnectWebSocket() {
        Task {
            let ws = WebSocketManager.shared
            guard !ws.isConnected else { return }
            ws.connect()
            print("📦 WebSocket pre-connected for voice")
        }
    }

    /// Disconnect WebSocket when leaving voice context to save resources.
    func disconnectWebSocketIfIdle() {
        let ws = WebSocketManager.shared
        guard ws.isConnected else { return }
        ws.disconnect()
    }

    // MARK: - Launch Optimization

    /// Warm up critical paths on app launch.
    /// Target: complete within 500ms to stay under 2s launch time.
    func warmUpOnLaunch() {
        Task.detached(priority: .userInitiated) {
            // Load cached POIs from SwiftData (instant)
            _ = await POIService.shared.fetchAllPOIs()

            // Start weather prefetch in background
            await ContentPrefetcher.shared.prefetchWeather()
        }
    }
}

// MARK: - Cache TTL Configuration

enum CacheTTL {
    static let weather: TimeInterval = 900  // 15 minutes
    static let traffic: TimeInterval = 300  // 5 minutes
    static let tides: TimeInterval = 3600   // 1 hour
    static let poi: TimeInterval = 86400    // 24 hours
    static let buoy: TimeInterval = 1800    // 30 minutes
}
