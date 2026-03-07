import Foundation
import CoreLocation

@Observable
final class WeatherViewModel {
    var weather: WeatherData?
    var tideData: TideData?
    var selectedStation: TideStation = .hyannis
    var isLoading = false
    var error: Error?

    // Buoy / ocean data
    var waterTemperature: Double?
    var waveHeight: Double?
    var wavePeriod: Double?

    // Beach recommendation
    var beachRecommendation: BeachRecommendation?

    private let weatherService: WeatherService
    private let tideService: TideService

    init(
        weatherService: WeatherService = WeatherService(),
        tideService: TideService = TideService()
    ) {
        self.weatherService = weatherService
        self.tideService = tideService
    }

    // MARK: - Computed Properties

    var currentTemperature: String {
        weather?.current.temperatureFormatted ?? "--°"
    }

    var feelsLikeTemperature: String {
        guard let fl = weather?.current.feelsLike else { return "--°" }
        return "\(Int(fl.rounded()))°"
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

    var uvIndex: Int {
        weather?.current.uvIndex ?? 0
    }

    var uvDescription: String {
        switch uvIndex {
        case 0...2: return "Low"
        case 3...5: return "Moderate"
        case 6...7: return "High"
        case 8...10: return "Very High"
        default: return "Extreme"
        }
    }

    var waterTempFormatted: String? {
        guard let temp = waterTemperature else { return nil }
        return "\(Int(temp.rounded()))°F"
    }

    var waveHeightFormatted: String? {
        guard let height = waveHeight else { return nil }
        return String(format: "%.1f ft", height)
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
        tideData?.predictions ?? weatherService.tides
    }

    var nextTide: TidePrediction? {
        tidePredictions.first { $0.time > .now }
    }

    var tideStatus: TideStatus {
        guard let next = nextTide else { return .unknown }
        return next.type == .high ? .rising : .falling
    }

    var tideStations: [TideStation] { TideStation.allCases }

    var timeUntilNextTide: String? {
        guard let next = nextTide else { return nil }
        let interval = next.time.timeIntervalSince(.now)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }

    // MARK: - Tide Tips (context-aware)

    var tideTip: String? {
        guard let next = nextTide else { return nil }
        let minutesUntil = Int(next.time.timeIntervalSince(.now)) / 60

        if tideStatus == .falling && minutesUntil < 180 {
            return "Low tide coming in \(minutesUntil / 60)h \(minutesUntil % 60)m — great for tide pools at Skaket Beach!"
        }
        if tideStatus == .rising && next.type == .high {
            return "High tide at \(next.timeFormatted) — less sand, but better swimming conditions."
        }
        if tideStatus == .falling {
            return "Tide is going out — more beach to explore! Perfect for beachcombing."
        }
        return "Tide is coming in — keep an eye on your beach setup."
    }

    // MARK: - Loading

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
            group.addTask { [self] in
                await weatherService.fetchBuoyData()
            }
            group.addTask { [self] in
                await weatherService.fetchTides(station: WeatherService.defaultTideStation, days: 3)
            }
        }

        // Copy buoy data
        waterTemperature = weatherService.waterTemperature
        waveHeight = weatherService.waveHeight
        wavePeriod = weatherService.wavePeriod

        // Generate recommendation
        if let weather {
            beachRecommendation = BeachRecommendationEngine.recommend(
                weather: weather,
                waterTemp: waterTemperature,
                waveHeight: waveHeight,
                tideStatus: tideStatus,
                nextTide: nextTide
            )
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
