import Foundation
import CoreLocation

protocol WeatherServiceProtocol: Sendable {
    func fetchWeather(for coordinate: CLLocationCoordinate2D) async throws -> WeatherData
}

@Observable
final class WeatherService: WeatherServiceProtocol {
    private let session: URLSession
    private var cachedWeather: WeatherData?

    // Cape Cod center coordinates (Barnstable)
    static let capeCodCenter = CLLocationCoordinate2D(latitude: 41.7003, longitude: -70.3002)

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: config)
    }

    func fetchWeather(for coordinate: CLLocationCoordinate2D) async throws -> WeatherData {
        if let cached = cachedWeather, !cached.isStale {
            return cached
        }

        // Step 1: Get the forecast endpoint from NWS points API
        let pointURL = URL(string: "https://api.weather.gov/points/\(coordinate.latitude),\(coordinate.longitude)")!
        var pointRequest = URLRequest(url: pointURL)
        pointRequest.setValue("HeyCapeCod/1.0", forHTTPHeaderField: "User-Agent")

        let (pointData, _) = try await session.data(for: pointRequest)
        guard let pointJSON = try JSONSerialization.jsonObject(with: pointData) as? [String: Any],
              let properties = pointJSON["properties"] as? [String: Any],
              let forecastURLString = properties["forecast"] as? String,
              let forecastHourlyURLString = properties["forecastHourly"] as? String else {
            throw WeatherServiceError.invalidResponse
        }

        // Step 2: Fetch daily and hourly forecasts in parallel
        async let dailyData = fetchJSON(from: forecastURLString)
        async let hourlyData = fetchJSON(from: forecastHourlyURLString)

        let (daily, hourly) = try await (dailyData, hourlyData)

        let weather = try parseWeatherData(daily: daily, hourly: hourly)
        cachedWeather = weather
        return weather
    }

    private func fetchJSON(from urlString: String) async throws -> [String: Any] {
        guard let url = URL(string: urlString) else { throw WeatherServiceError.invalidURL }
        var request = URLRequest(url: url)
        request.setValue("HeyCapeCod/1.0", forHTTPHeaderField: "User-Agent")
        let (data, _) = try await session.data(for: request)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw WeatherServiceError.invalidResponse
        }
        return json
    }

    private func parseWeatherData(daily: [String: Any], hourly: [String: Any]) throws -> WeatherData {
        // Parse current conditions from first hourly period
        guard let hourlyProps = hourly["properties"] as? [String: Any],
              let hourlyPeriods = hourlyProps["periods"] as? [[String: Any]],
              let current = hourlyPeriods.first else {
            throw WeatherServiceError.invalidResponse
        }

        let currentWeather = CurrentWeather(
            temperature: (current["temperature"] as? Double) ?? 0,
            feelsLike: (current["temperature"] as? Double) ?? 0,
            condition: mapCondition(current["shortForecast"] as? String ?? ""),
            humidity: parseHumidity(current["relativeHumidity"] as? [String: Any]),
            windSpeed: parseWindSpeed(current["windSpeed"] as? String ?? ""),
            windDirection: (current["windDirection"] as? String) ?? "N",
            uvIndex: 0,
            visibility: 10,
            pressure: 30.0,
            dewPoint: 0
        )

        // Parse hourly forecasts
        let hourlyForecasts = hourlyPeriods.prefix(24).map { period -> HourlyForecast in
            HourlyForecast(
                time: parseISO8601(period["startTime"] as? String ?? "") ?? .now,
                temperature: (period["temperature"] as? Double) ?? 0,
                condition: mapCondition(period["shortForecast"] as? String ?? ""),
                precipChance: (period["probabilityOfPrecipitation"] as? [String: Any])?["value"] as? Int ?? 0,
                windSpeed: parseWindSpeed(period["windSpeed"] as? String ?? "")
            )
        }

        // Parse daily forecasts
        guard let dailyProps = daily["properties"] as? [String: Any],
              let dailyPeriods = dailyProps["periods"] as? [[String: Any]] else {
            throw WeatherServiceError.invalidResponse
        }

        var dailyForecasts: [DailyForecast] = []
        var i = 0
        while i < dailyPeriods.count - 1 {
            let day = dailyPeriods[i]
            let night = dailyPeriods[i + 1]
            dailyForecasts.append(DailyForecast(
                date: parseISO8601(day["startTime"] as? String ?? "") ?? .now,
                high: (day["temperature"] as? Double) ?? 0,
                low: (night["temperature"] as? Double) ?? 0,
                condition: mapCondition(day["shortForecast"] as? String ?? ""),
                precipChance: (day["probabilityOfPrecipitation"] as? [String: Any])?["value"] as? Int ?? 0,
                sunrise: .now,
                sunset: .now,
                uvIndex: 0
            ))
            i += 2
        }

        return WeatherData(
            current: currentWeather,
            hourly: Array(hourlyForecasts),
            daily: dailyForecasts,
            alerts: [],
            fetchedAt: .now
        )
    }

    private func mapCondition(_ forecast: String) -> WeatherConditionType {
        let lower = forecast.lowercased()
        if lower.contains("thunder") { return .thunderstorm }
        if lower.contains("rain") || lower.contains("shower") { return .rain }
        if lower.contains("snow") { return .snow }
        if lower.contains("fog") || lower.contains("mist") { return .fog }
        if lower.contains("wind") { return .windy }
        if lower.contains("cloud") || lower.contains("overcast") { return .cloudy }
        if lower.contains("partly") { return .partlyCloudy }
        return .clear
    }

    private func parseWindSpeed(_ speed: String) -> Double {
        Double(speed.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
    }

    private func parseHumidity(_ humidity: [String: Any]?) -> Int {
        (humidity?["value"] as? Int) ?? 0
    }

    private func parseISO8601(_ string: String) -> Date? {
        ISO8601DateFormatter().date(from: string)
    }
}

enum WeatherServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid weather service URL."
        case .invalidResponse: "Could not parse weather data."
        case .networkError: "Unable to connect to weather service."
        }
    }
}
