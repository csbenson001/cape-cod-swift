import Foundation
import CoreLocation
import WeatherKit

protocol WeatherServiceProtocol: Sendable {
    func fetchWeather(for coordinate: CLLocationCoordinate2D) async throws -> WeatherData
}

/// Unified weather service using WeatherKit (primary) with NOAA fallback.
/// Also fetches:
/// - Water temperature from NOAA Buoy 44018 (Cape Cod area)
/// - Tide predictions from NOAA CO-OPS stations
/// - Buoy wave data for beach conditions
@Observable
final class WeatherService: WeatherServiceProtocol, @unchecked Sendable {
    private var cachedWeather: WeatherData?
    private(set) var currentWeather: WeatherAPIData?
    private(set) var tides: [TidePrediction] = []
    private(set) var waterTemperature: Double?
    private(set) var waveHeight: Double?
    private(set) var wavePeriod: Double?
    private(set) var buoyWindSpeed: Double?
    private(set) var buoyWindDirection: String?
    private(set) var lastUpdated: Date?

    private let session: URLSession
    private let weatherKitService = WeatherKit.WeatherService.shared

    // Cape Cod center coordinates (Barnstable)
    static let capeCodCenter = CLLocationCoordinate2D(latitude: 41.7003, longitude: -70.3002)

    // NOAA Buoy for Cape Cod waters
    static let capeCodBuoyStation = "44018"
    // Primary tide station: Woods Hole
    static let defaultTideStation = "8447930"

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: config)
    }

    // MARK: - Full Weather Fetch

    func fetchWeather(for coordinate: CLLocationCoordinate2D) async throws -> WeatherData {
        if let cached = cachedWeather, !cached.isStale {
            return cached
        }

        // Try WeatherKit first, fall back to backend, then NOAA
        do {
            let weather = try await fetchFromWeatherKit(coordinate)
            cachedWeather = weather
            lastUpdated = .now
            print("✅ Loaded weather from WeatherKit")
            return weather
        } catch {
            print("❌ WeatherKit failed: \(error.localizedDescription), trying backend...")
            do {
                let weather = try await fetchFromBackend(coordinate)
                cachedWeather = weather
                lastUpdated = .now
                return weather
            } catch {
                print("❌ Backend failed, falling back to NOAA: \(error.localizedDescription)")
                let weather = try await fetchDirectFromNOAA(coordinate)
                cachedWeather = weather
                lastUpdated = .now
                return weather
            }
        }
    }

    // MARK: - WeatherKit

    private func fetchFromWeatherKit(_ coordinate: CLLocationCoordinate2D) async throws -> WeatherData {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let weather = try await weatherKitService.weather(for: location)

        let current = CurrentWeather(
            temperature: weather.currentWeather.temperature.converted(to: .fahrenheit).value,
            feelsLike: weather.currentWeather.apparentTemperature.converted(to: .fahrenheit).value,
            condition: mapWeatherKitCondition(weather.currentWeather.condition),
            humidity: Int(weather.currentWeather.humidity * 100),
            windSpeed: weather.currentWeather.wind.speed.converted(to: .milesPerHour).value,
            windDirection: compassDirection(from: weather.currentWeather.wind.direction.converted(to: .degrees).value),
            uvIndex: weather.currentWeather.uvIndex.value,
            visibility: weather.currentWeather.visibility.converted(to: .miles).value,
            pressure: weather.currentWeather.pressure.converted(to: .inchesOfMercury).value,
            dewPoint: weather.currentWeather.dewPoint.converted(to: .fahrenheit).value
        )

        let hourly = weather.hourlyForecast.prefix(24).map { hour in
            HourlyForecast(
                time: hour.date,
                temperature: hour.temperature.converted(to: .fahrenheit).value,
                condition: mapWeatherKitCondition(hour.condition),
                precipChance: Int(hour.precipitationChance * 100),
                windSpeed: hour.wind.speed.converted(to: .milesPerHour).value
            )
        }

        let daily = weather.dailyForecast.prefix(7).map { day in
            DailyForecast(
                date: day.date,
                high: day.highTemperature.converted(to: .fahrenheit).value,
                low: day.lowTemperature.converted(to: .fahrenheit).value,
                condition: mapWeatherKitCondition(day.condition),
                precipChance: Int(day.precipitationChance * 100),
                sunrise: day.sun.sunrise ?? day.date,
                sunset: day.sun.sunset ?? day.date,
                uvIndex: day.uvIndex.value
            )
        }

        let alerts = weather.weatherAlerts?.map { alert in
            WeatherAlert(
                id: UUID(),
                title: alert.summary,
                description: alert.detailsURL.absoluteString,
                severity: mapAlertSeverity(alert.severity),
                startTime: alert.metadata.date,
                endTime: alert.metadata.expirationDate
            )
        } ?? []

        return WeatherData(
            current: current,
            hourly: Array(hourly),
            daily: Array(daily),
            alerts: alerts,
            fetchedAt: .now
        )
    }

    private func mapWeatherKitCondition(_ condition: WeatherKit.WeatherCondition) -> WeatherConditionType {
        switch condition {
        case .clear, .hot: return .clear
        case .mostlyClear, .partlyCloudy: return .partlyCloudy
        case .mostlyCloudy, .cloudy: return .cloudy
        case .rain, .heavyRain, .drizzle, .freezingRain, .freezingDrizzle: return .rain
        case .thunderstorms, .strongStorms, .isolatedThunderstorms, .scatteredThunderstorms: return .thunderstorm
        case .snow, .heavySnow, .flurries, .blizzard, .sleet, .blowingSnow: return .snow
        case .haze, .foggy, .smoky: return .fog
        case .windy, .breezy: return .windy
        @unknown default: return .cloudy
        }
    }

    private func mapAlertSeverity(_ severity: WeatherKit.WeatherSeverity) -> WeatherAlert.AlertSeverity {
        switch severity {
        case .minor, .moderate: return .advisory
        case .severe: return .watch
        case .extreme: return .warning
        @unknown default: return .advisory
        }
    }

    private func compassDirection(from degrees: Double) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                          "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((degrees + 11.25) / 22.5) % 16
        return directions[index]
    }

    // MARK: - Tides (NOAA CO-OPS)

    func fetchTides(station: String = "8447930", days: Int = 3) async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let begin = formatter.string(from: .now)
        let end = formatter.string(from: Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .now)

        guard let url = URL(string: "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?begin_date=\(begin)&end_date=\(end)&station=\(station)&product=predictions&datum=MLLW&time_zone=lst_ldt&interval=hilo&units=english&application=HeyCapeCod&format=json") else { return }

        do {
            let (data, _) = try await session.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let predictions = json["predictions"] as? [[String: String]] else { return }

            let dateParser = DateFormatter()
            dateParser.dateFormat = "yyyy-MM-dd HH:mm"
            dateParser.timeZone = TimeZone(identifier: "America/New_York")

            tides = predictions.compactMap { entry in
                guard let timeStr = entry["t"],
                      let heightStr = entry["v"],
                      let typeStr = entry["type"],
                      let time = dateParser.date(from: timeStr),
                      let height = Double(heightStr),
                      let type = TideType(rawValue: typeStr) else { return nil }
                return TidePrediction(time: time, height: height, type: type)
            }
            print("✅ Loaded \(tides.count) tide predictions for station \(station)")
        } catch {
            print("❌ Tide fetch error: \(error.localizedDescription)")
        }
    }

    // MARK: - Water Temperature & Buoy Data (NOAA NDBC)

    func fetchBuoyData(station: String = "44018") async {
        guard let url = URL(string: "https://www.ndbc.noaa.gov/data/realtime2/\(station).txt") else { return }

        do {
            var request = URLRequest(url: url)
            request.setValue("HeyCapeCod/1.0", forHTTPHeaderField: "User-Agent")
            let (data, _) = try await session.data(for: request)
            guard let text = String(data: data, encoding: .utf8) else { return }

            let lines = text.components(separatedBy: "\n")
            // Lines: #YY MM DD hh mm WDIR WSPD GST WVHT DPD APD MWD PRES ATMP WTMP DEWP VIS PTDY TIDE
            // Skip first 2 header lines, grab first data line
            guard lines.count > 2 else { return }
            let dataLine = lines[2]
            let cols = dataLine.split(whereSeparator: { $0.isWhitespace }).map(String.init)
            guard cols.count >= 15 else { return }

            // WTMP is column index 14 (water temp in Celsius)
            if let wtmpC = Double(cols[14]), wtmpC < 99 {
                waterTemperature = wtmpC * 9.0 / 5.0 + 32.0
            }
            // WVHT is column index 8 (wave height in meters)
            if let wvhtM = Double(cols[8]), wvhtM < 99 {
                waveHeight = wvhtM * 3.28084
            }
            // DPD is column index 9 (dominant wave period in seconds)
            if let dpd = Double(cols[9]), dpd < 99 {
                wavePeriod = dpd
            }
            // WSPD is column index 6 (wind speed in m/s)
            if let wspdMs = Double(cols[6]), wspdMs < 99 {
                buoyWindSpeed = wspdMs * 2.237
            }
            // WDIR is column index 5 (wind direction in degrees)
            if let wdir = Double(cols[5]), wdir < 999 {
                buoyWindDirection = compassDirection(from: wdir)
            }

            print("✅ Buoy data: water=\(waterTemperature.map { String(format: "%.0f", $0) } ?? "N/A")°F, waves=\(waveHeight.map { String(format: "%.1f", $0) } ?? "N/A")ft")
        } catch {
            print("❌ Buoy data error: \(error.localizedDescription)")
        }
    }

    // MARK: - Backend API

    private func fetchFromBackend(_ coordinate: CLLocationCoordinate2D) async throws -> WeatherData {
        let response: WeatherAPIData = try await APIClient.shared.get("/weather", queryItems: [
            URLQueryItem(name: "lat", value: String(coordinate.latitude)),
            URLQueryItem(name: "lng", value: String(coordinate.longitude)),
        ])
        currentWeather = response
        print("✅ Loaded weather from backend: \(response.description)")
        return response.toWeatherData()
    }

    // MARK: - Direct NOAA Fallback

    private func fetchDirectFromNOAA(_ coordinate: CLLocationCoordinate2D) async throws -> WeatherData {
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

        async let dailyData = fetchJSON(from: forecastURLString)
        async let hourlyData = fetchJSON(from: forecastHourlyURLString)

        let (daily, hourly) = try await (dailyData, hourlyData)

        return try parseWeatherData(daily: daily, hourly: hourly)
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
        guard let hourlyProps = hourly["properties"] as? [String: Any],
              let hourlyPeriods = hourlyProps["periods"] as? [[String: Any]],
              let current = hourlyPeriods.first else {
            throw WeatherServiceError.invalidResponse
        }

        let currentWeather = CurrentWeather(
            temperature: (current["temperature"] as? NSNumber)?.doubleValue ?? 0,
            feelsLike: (current["temperature"] as? NSNumber)?.doubleValue ?? 0,
            condition: mapNOAACondition(current["shortForecast"] as? String ?? ""),
            humidity: parseHumidity(current["relativeHumidity"] as? [String: Any]),
            windSpeed: parseWindSpeed(current["windSpeed"] as? String ?? ""),
            windDirection: (current["windDirection"] as? String) ?? "N",
            uvIndex: 0, visibility: 10, pressure: 30.0, dewPoint: 0
        )

        let hourlyForecasts = hourlyPeriods.prefix(24).map { period -> HourlyForecast in
            HourlyForecast(
                time: parseISO8601(period["startTime"] as? String ?? "") ?? .now,
                temperature: (period["temperature"] as? NSNumber)?.doubleValue ?? 0,
                condition: mapNOAACondition(period["shortForecast"] as? String ?? ""),
                precipChance: (period["probabilityOfPrecipitation"] as? [String: Any])?["value"] as? Int ?? 0,
                windSpeed: parseWindSpeed(period["windSpeed"] as? String ?? "")
            )
        }

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
                high: (day["temperature"] as? NSNumber)?.doubleValue ?? 0,
                low: (night["temperature"] as? NSNumber)?.doubleValue ?? 0,
                condition: mapNOAACondition(day["shortForecast"] as? String ?? ""),
                precipChance: (day["probabilityOfPrecipitation"] as? [String: Any])?["value"] as? Int ?? 0,
                sunrise: .now, sunset: .now, uvIndex: 0
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

    private func mapNOAACondition(_ forecast: String) -> WeatherConditionType {
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
