import Foundation
import CoreLocation

@preconcurrency @MainActor
@Observable
final class HomeViewModel {
    var weather: WeatherData?
    var tideData: TideData?
    var bridgeStatus: BridgeStatus?
    var nearbyLocations: [CodLocation] = []
    var recentConversations: [Conversation] = []
    var featuredStories: [Story] = []
    var isLoading = false
    var error: Error?

    private let weatherService: WeatherService
    private let tideService: TideService
    private let trafficService: TrafficService
    private let locationService: LocationService

    init(
        weatherService: WeatherService = WeatherService(),
        tideService: TideService = TideService(),
        trafficService: TrafficService = TrafficService(),
        locationService: LocationService = LocationService()
    ) {
        self.weatherService = weatherService
        self.tideService = tideService
        self.trafficService = trafficService
        self.locationService = locationService
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }

    var temperatureString: String {
        weather?.current.temperatureFormatted ?? "--°"
    }

    var conditionIcon: String {
        weather?.current.condition.icon ?? "cloud.fill"
    }

    var nextTideString: String {
        guard let next = tideData?.nextTide else { return "Loading..." }
        return "\(next.type.displayName) at \(next.timeFormatted)"
    }

    var bridgeSummary: String {
        guard let status = bridgeStatus else { return "Loading..." }
        let bourne = status.bourneBridge
        let sagamore = status.sagamoreBridge
        if bourne.status == .open && sagamore.status == .open && bourne.delayMinutes == 0 && sagamore.delayMinutes == 0 {
            return "Both bridges clear"
        }
        var parts: [String] = []
        if bourne.delayMinutes > 0 {
            parts.append("Bourne: \(bourne.delayMinutes)min delay")
        }
        if sagamore.delayMinutes > 0 {
            parts.append("Sagamore: \(sagamore.delayMinutes)min delay")
        }
        return parts.isEmpty ? "Bridges open" : parts.joined(separator: " | ")
    }

    func loadDashboard() async {
        isLoading = true
        defer { isLoading = false }

        let coordinate = locationService.currentLocation?.coordinate ?? WeatherService.capeCodCenter

        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor [self] in
                do { weather = try await weatherService.fetchWeather(for: coordinate) }
                catch { self.error = error }
            }
            group.addTask { @MainActor [self] in
                do { tideData = try await tideService.fetchTides(station: .hyannis) }
                catch { self.error = error }
            }
            group.addTask { @MainActor [self] in
                do { bridgeStatus = try await trafficService.fetchBridgeStatus() }
                catch { self.error = error }
            }
        }
    }

    func refresh() async {
        await loadDashboard()
    }
}
