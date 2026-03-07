import Foundation

/// Weather response from the backend API (/api/weather).
struct WeatherAPIData: Codable {
    let temperature: Double
    let feelsLike: Double?
    let description: String
    let humidity: Int
    let windSpeed: Double
    let windDirection: String
    let uvIndex: Int
    let icon: String

    /// Convert to the existing WeatherData model
    func toWeatherData() -> WeatherData {
        let condition = mapCondition(icon)
        let current = CurrentWeather(
            temperature: temperature,
            feelsLike: feelsLike ?? temperature,
            condition: condition,
            humidity: humidity,
            windSpeed: windSpeed,
            windDirection: windDirection,
            uvIndex: uvIndex,
            visibility: 10,
            pressure: 30.0,
            dewPoint: 0
        )
        return WeatherData(
            current: current,
            hourly: [],
            daily: [],
            alerts: [],
            fetchedAt: .now
        )
    }

    private func mapCondition(_ icon: String) -> WeatherConditionType {
        let lower = icon.lowercased()
        if lower.contains("thunder") { return .thunderstorm }
        if lower.contains("rain") || lower.contains("shower") { return .rain }
        if lower.contains("snow") { return .snow }
        if lower.contains("fog") || lower.contains("mist") { return .fog }
        if lower.contains("wind") { return .windy }
        if lower.contains("cloud") || lower.contains("overcast") { return .cloudy }
        if lower.contains("partly") { return .partlyCloudy }
        return .clear
    }
}
