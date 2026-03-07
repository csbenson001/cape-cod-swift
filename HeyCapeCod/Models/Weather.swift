import Foundation

struct WeatherData: Codable, Equatable {
    var current: CurrentWeather
    var hourly: [HourlyForecast]
    var daily: [DailyForecast]
    var alerts: [WeatherAlert]
    let fetchedAt: Date

    var isStale: Bool {
        Date.now.timeIntervalSince(fetchedAt) > 1800 // 30 minutes
    }
}

struct CurrentWeather: Codable, Equatable {
    var temperature: Double
    var feelsLike: Double
    var condition: WeatherConditionType
    var humidity: Int
    var windSpeed: Double
    var windDirection: String
    var uvIndex: Int
    var visibility: Double
    var pressure: Double
    var dewPoint: Double

    var temperatureFormatted: String {
        "\(Int(temperature.rounded()))°"
    }

    var isBeachWeather: Bool {
        temperature >= 72 && windSpeed < 15 &&
        [.clear, .partlyCloudy].contains(condition)
    }
}

struct HourlyForecast: Identifiable, Codable, Equatable {
    var id: Date { time }
    let time: Date
    var temperature: Double
    var condition: WeatherConditionType
    var precipChance: Int
    var windSpeed: Double
}

struct DailyForecast: Identifiable, Codable, Equatable {
    var id: Date { date }
    let date: Date
    var high: Double
    var low: Double
    var condition: WeatherConditionType
    var precipChance: Int
    var sunrise: Date
    var sunset: Date
    var uvIndex: Int
}

struct WeatherAlert: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var severity: AlertSeverity
    var startTime: Date
    var endTime: Date

    enum AlertSeverity: String, Codable, Equatable {
        case advisory, watch, warning
    }
}

enum WeatherConditionType: String, Codable, Equatable, CaseIterable {
    case clear
    case partlyCloudy
    case cloudy
    case rain
    case thunderstorm
    case snow
    case fog
    case windy

    var displayName: String {
        switch self {
        case .clear: "Clear"
        case .partlyCloudy: "Partly Cloudy"
        case .cloudy: "Cloudy"
        case .rain: "Rain"
        case .thunderstorm: "Thunderstorm"
        case .snow: "Snow"
        case .fog: "Fog"
        case .windy: "Windy"
        }
    }

    var icon: String {
        switch self {
        case .clear: "sun.max.fill"
        case .partlyCloudy: "cloud.sun.fill"
        case .cloudy: "cloud.fill"
        case .rain: "cloud.rain.fill"
        case .thunderstorm: "cloud.bolt.rain.fill"
        case .snow: "cloud.snow.fill"
        case .fog: "cloud.fog.fill"
        case .windy: "wind"
        }
    }
}
