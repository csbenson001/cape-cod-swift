import Foundation
import CoreLocation

@Observable
final class WeatherViewModel {
    var weather: WeatherData?
    var tideData: TideData?
    var selectedStation: TideStation = .hyannis
    var isLoading = false
    var error: Error?

    private let weatherService: WeatherService
    private let tideService: TideService

    init(
        weatherService: WeatherService = WeatherService(),
        tideService: TideService = TideService()
    ) {
        self.weatherService = weatherService
        self.tideService = tideService
    }

    var currentTemperature: String {
        weather?.current.temperatureFormatted ?? "--°"
    }

    var conditionName: String {
        weather?.current.condition.displayName ?? "Loading"
    }

    var conditionIcon: String {
        weather?.current.condition.icon ?? "cloud.fill"
    }

    var isBeachDay: Bool {
        weather?.current.isBeachWeather ?? false
    }

    var windSummary: String {
        guard let current = weather?.current else { return "--" }
        return "\(current.windDirection) \(Int(current.windSpeed)) mph"
    }

    var humiditySummary: String {
        guard let current = weather?.current else { return "--" }
        return "\(current.humidity)%"
    }

    var hourlyForecast: [HourlyForecast] {
        weather?.hourly ?? []
    }

    var dailyForecast: [DailyForecast] {
        weather?.daily ?? []
    }

    var alerts: [WeatherAlert] {
        weather?.alerts ?? []
    }

    var tidePredictions: [TidePrediction] {
        tideData?.predictions ?? []
    }

    var nextTide: TidePrediction? {
        tideData?.nextTide
    }

    var tideStatus: TideStatus {
        tideData?.currentTideStatus ?? .unknown
    }

    var tideStations: [TideStation] { TideStation.allCases }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        await withTaskGroup(of: Void.self) { group in
            group.addTask { [self] in
                do { weather = try await weatherService.fetchWeather(for: WeatherService.capeCodCenter) }
                catch { self.error = error }
            }
            group.addTask { [self] in
                do { tideData = try await tideService.fetchTides(station: selectedStation) }
                catch { self.error = error }
            }
        }
    }

    func selectStation(_ station: TideStation) async {
        selectedStation = station
        do { tideData = try await tideService.fetchTides(station: station) }
        catch { error = error }
    }

    func refresh() async {
        await load()
    }
}
