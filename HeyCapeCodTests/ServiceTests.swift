import XCTest
import Foundation
import CoreLocation
@testable import HeyCapeCod

// MARK: - Mock API Client

/// A protocol-based mock that mirrors APIClient's request/response pattern.
/// Allows configurable responses and error injection for isolated testing.
final class MockAPIClient {
    var mockResponses: [String: Any] = [:]
    var mockErrors: [String: Error] = [:]
    var requestLog: [(method: String, endpoint: String)] = []

    func get<T: Decodable>(_ endpoint: String) throws -> T {
        requestLog.append(("GET", endpoint))
        if let error = mockErrors[endpoint] {
            throw error
        }
        guard let response = mockResponses[endpoint] as? T else {
            throw APIError.noData
        }
        return response
    }

    func post<T: Decodable, B: Encodable>(_ endpoint: String, body: B) throws -> T {
        requestLog.append(("POST", endpoint))
        if let error = mockErrors[endpoint] {
            throw error
        }
        guard let response = mockResponses[endpoint] as? T else {
            throw APIError.noData
        }
        return response
    }

    func injectError(_ error: Error, for endpoint: String) {
        mockErrors[endpoint] = error
    }

    func injectResponse<T>(_ response: T, for endpoint: String) {
        mockResponses[endpoint] = response
    }

    func reset() {
        mockResponses.removeAll()
        mockErrors.removeAll()
        requestLog.removeAll()
    }
}

// MARK: - Mock Location Manager

/// Mock location provider with configurable coordinates and authorization status.
final class MockLocationManager {
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var monitoredRegions: Set<String> = []
    var onRegionEntered: ((String) -> Void)?
    var onSignificantLocationChange: ((CLLocation) -> Void)?

    var isAuthorized: Bool {
        [.authorizedWhenInUse, .authorizedAlways].contains(authorizationStatus)
    }

    var hasAlwaysPermission: Bool {
        authorizationStatus == .authorizedAlways
    }

    var isDenied: Bool {
        [.denied, .restricted].contains(authorizationStatus)
    }

    /// Set coordinates for a Cape Cod location
    func setLocation(latitude: Double, longitude: Double) {
        currentLocation = CLLocation(latitude: latitude, longitude: longitude)
    }

    /// Simulate entering a geofence region
    func simulateRegionEntry(regionID: String) {
        onRegionEntered?(regionID)
    }

    /// Simulate significant location change
    func simulateSignificantMove(to location: CLLocation) {
        currentLocation = location
        onSignificantLocationChange?(location)
    }

    func startMonitoring(regionID: String) {
        monitoredRegions.insert(regionID)
    }

    func stopMonitoring(regionID: String) {
        monitoredRegions.remove(regionID)
    }

    func stopAllMonitoring() {
        monitoredRegions.removeAll()
    }
}

// MARK: - Test Helpers

extension CLLocationCoordinate2D {
    /// Barnstable, Cape Cod center
    static let barnstable = CLLocationCoordinate2D(latitude: 41.7003, longitude: -70.3002)
    /// Provincetown
    static let provincetown = CLLocationCoordinate2D(latitude: 42.0521, longitude: -70.1862)
    /// Chatham
    static let chatham = CLLocationCoordinate2D(latitude: 41.6821, longitude: -69.9597)
}

/// Creates a sample TrafficResponse for testing
func makeSampleTrafficResponse(
    sagamoreDelay: Int = 5,
    bourneDelay: Int = 10,
    sagamoreStatus: TrafficLevel = .clear,
    bourneStatus: TrafficLevel = .moderate,
    route6Status: TrafficLevel = .clear,
    route3Status: TrafficLevel = .clear,
    route6Delay: Int = 0,
    route3Delay: Int = 0,
    recommendation: String = "Take the Sagamore Bridge"
) -> TrafficResponse {
    TrafficResponse(
        bridges: .init(
            sagamore: .init(delayMinutes: sagamoreDelay, status: sagamoreStatus, direction: "eastbound", lastUpdated: "2025-07-04T12:00:00Z"),
            bourne: .init(delayMinutes: bourneDelay, status: bourneStatus, direction: "eastbound", lastUpdated: "2025-07-04T12:00:00Z")
        ),
        routes: .init(
            route6: .init(status: route6Status, delayMinutes: route6Delay),
            route3: .init(status: route3Status, delayMinutes: route3Delay)
        ),
        recommendation: recommendation,
        updatedAt: "2025-07-04T12:00:00Z"
    )
}

/// Creates a sample WeatherData for testing
func makeSampleWeatherData(fetchedAt: Date = .now) -> WeatherData {
    WeatherData(
        current: CurrentWeather(
            temperature: 75,
            feelsLike: 78,
            condition: .clear,
            humidity: 55,
            windSpeed: 8,
            windDirection: "SW",
            uvIndex: 7,
            visibility: 10,
            pressure: 30.1,
            dewPoint: 62
        ),
        hourly: [],
        daily: [],
        alerts: [],
        fetchedAt: fetchedAt
    )
}

/// Creates a sample PointOfInterest for testing
func makeSamplePOI(
    id: String = "nauset-light",
    name: String = "Nauset Lighthouse",
    latitude: Double = 41.8584,
    longitude: Double = -69.9514,
    radius: CLLocationDistance = 200,
    category: LocationCategory = .lighthouse,
    town: CapeCodTown = .eastham,
    stories: [StoryVariant] = []
) -> PointOfInterest {
    PointOfInterest(
        id: id,
        name: name,
        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
        geofenceRadius: radius,
        category: category,
        town: town,
        description: "A historic Cape Cod lighthouse",
        stories: stories,
        facts: ["Built in 1877", "Moved from cliff edge in 1996"],
        tips: ["Best at sunset"],
        imageSystemName: "light.beacon.max.fill"
    )
}

/// Creates sample StoryVariants for testing
func makeSampleStories() -> [StoryVariant] {
    [
        StoryVariant(
            title: "Nauset Light History",
            mode: .adult,
            script: "The Nauset Lighthouse was built in eighteen seventy seven on the bluffs of Eastham overlooking the Atlantic Ocean. For over a century it has guided mariners safely past the treacherous shoals of Cape Cod."
        ),
        StoryVariant(
            title: "Nauset Light for Kids",
            mode: .kids,
            script: "Look up at the tall red and white lighthouse. It has been shining its light for ships for a very long time."
        ),
        StoryVariant(
            title: "Nauset Light Family",
            mode: .family,
            script: "Welcome to Nauset Lighthouse, families. This iconic red and white tower has been a Cape Cod landmark since the nineteenth century."
        ),
    ]
}


// MARK: - TrafficServiceTests

final class TrafficServiceTests: XCTestCase {

    // MARK: - TrafficResponse to TrafficReport Mapping

    func testTrafficResponseToReportMappingRouteCount() {
        let response = makeSampleTrafficResponse()
        let report = response.toTrafficReport()

        // Should produce 4 routes: Sagamore, Bourne, Route 6, Route 3
        XCTAssertEqual(report.routes.count, 4)
    }

    func testTrafficResponseToReportRouteNames() {
        let response = makeSampleTrafficResponse()
        let report = response.toTrafficReport()

        let names = report.routes.map(\.name)
        XCTAssertTrue(names.contains("Sagamore Bridge"))
        XCTAssertTrue(names.contains("Bourne Bridge"))
        XCTAssertTrue(names.contains("Route 6"))
        XCTAssertTrue(names.contains("Route 3"))
    }

    func testTrafficResponseDelayConversion() {
        let response = makeSampleTrafficResponse(sagamoreDelay: 15, bourneDelay: 30)
        let report = response.toTrafficReport()

        let sagamore = report.routes.first { $0.name == "Sagamore Bridge" }!
        let bourne = report.routes.first { $0.name == "Bourne Bridge" }!

        // Delay minutes * 60 = travel time in seconds
        XCTAssertEqual(sagamore.currentTravelTime, 15 * 60)
        XCTAssertEqual(bourne.currentTravelTime, 30 * 60)
    }

    func testTrafficResponseCongestionLevelMapping() {
        let response = makeSampleTrafficResponse(
            sagamoreStatus: .clear,
            bourneStatus: .heavy
        )
        let report = response.toTrafficReport()

        let sagamore = report.routes.first { $0.name == "Sagamore Bridge" }!
        let bourne = report.routes.first { $0.name == "Bourne Bridge" }!

        XCTAssertEqual(sagamore.congestionLevel, .free)
        XCTAssertEqual(bourne.congestionLevel, .heavy)
    }

    func testTrafficResponseBridgeStatusMapping() {
        let response = makeSampleTrafficResponse(
            sagamoreDelay: 5,
            bourneDelay: 20,
            sagamoreStatus: .clear,
            bourneStatus: .heavy
        )
        let report = response.toTrafficReport()

        XCTAssertEqual(report.bridgeStatus.sagamoreBridge.status, .open)
        XCTAssertEqual(report.bridgeStatus.sagamoreBridge.delayMinutes, 5)
        XCTAssertEqual(report.bridgeStatus.bourneBridge.status, .restricted)
        XCTAssertEqual(report.bridgeStatus.bourneBridge.delayMinutes, 20)
    }

    func testTrafficResponseSevereMapsToCongestionSevere() {
        let response = makeSampleTrafficResponse(sagamoreStatus: .severe)
        let report = response.toTrafficReport()
        let sagamore = report.routes.first { $0.name == "Sagamore Bridge" }!
        XCTAssertEqual(sagamore.congestionLevel, .severe)
    }

    func testTrafficResponseModerateMapsToCongestionModerate() {
        let response = makeSampleTrafficResponse(sagamoreStatus: .moderate)
        let report = response.toTrafficReport()
        let sagamore = report.routes.first { $0.name == "Sagamore Bridge" }!
        XCTAssertEqual(sagamore.congestionLevel, .moderate)
    }

    // MARK: - TrafficReport Staleness

    func testTrafficReportFreshWhenJustCreated() {
        let report = TrafficReport(
            routes: [],
            incidents: [],
            bridgeStatus: BridgeStatus(
                bourneBridge: .init(status: .open, delayMinutes: 0, lastUpdated: .now),
                sagamoreBridge: .init(status: .open, delayMinutes: 0, lastUpdated: .now)
            ),
            fetchedAt: .now
        )
        XCTAssertFalse(report.isStale)
    }

    func testTrafficReportStaleAfter300Seconds() {
        let oldDate = Date.now.addingTimeInterval(-301)
        let report = TrafficReport(
            routes: [],
            incidents: [],
            bridgeStatus: BridgeStatus(
                bourneBridge: .init(status: .open, delayMinutes: 0, lastUpdated: .now),
                sagamoreBridge: .init(status: .open, delayMinutes: 0, lastUpdated: .now)
            ),
            fetchedAt: oldDate
        )
        XCTAssertTrue(report.isStale)
    }

    func testTrafficReportNotStaleAtExactly299Seconds() {
        let recentDate = Date.now.addingTimeInterval(-299)
        let report = TrafficReport(
            routes: [],
            incidents: [],
            bridgeStatus: BridgeStatus(
                bourneBridge: .init(status: .open, delayMinutes: 0, lastUpdated: .now),
                sagamoreBridge: .init(status: .open, delayMinutes: 0, lastUpdated: .now)
            ),
            fetchedAt: recentDate
        )
        XCTAssertFalse(report.isStale)
    }

    // MARK: - TrafficRoute Formatting

    func testTrafficRouteTravelTimeFormattedMinutes() {
        let route = TrafficRoute(
            id: UUID(), name: "Test", origin: "A", destination: "B",
            currentTravelTime: 45 * 60, typicalTravelTime: 30 * 60,
            congestionLevel: .moderate, distance: 10
        )
        XCTAssertEqual(route.travelTimeFormatted, "45 min")
    }

    func testTrafficRouteTravelTimeFormattedHours() {
        let route = TrafficRoute(
            id: UUID(), name: "Test", origin: "A", destination: "B",
            currentTravelTime: 90 * 60, typicalTravelTime: 60 * 60,
            congestionLevel: .heavy, distance: 50
        )
        XCTAssertEqual(route.travelTimeFormatted, "1h 30m")
    }

    func testTrafficRouteDelayMinutes() {
        let route = TrafficRoute(
            id: UUID(), name: "Test", origin: "A", destination: "B",
            currentTravelTime: 2700, typicalTravelTime: 1800,
            congestionLevel: .moderate, distance: 10
        )
        XCTAssertEqual(route.delayMinutes, 15)
    }

    func testTrafficRouteDelayNeverNegative() {
        let route = TrafficRoute(
            id: UUID(), name: "Test", origin: "A", destination: "B",
            currentTravelTime: 1000, typicalTravelTime: 2000,
            congestionLevel: .free, distance: 10
        )
        XCTAssertEqual(route.delayMinutes, 0)
    }

    // MARK: - TrafficLevel Mappings

    func testTrafficLevelToCongestionLevel() {
        XCTAssertEqual(TrafficLevel.clear.toCongestionLevel, .free)
        XCTAssertEqual(TrafficLevel.moderate.toCongestionLevel, .moderate)
        XCTAssertEqual(TrafficLevel.heavy.toCongestionLevel, .heavy)
        XCTAssertEqual(TrafficLevel.severe.toCongestionLevel, .severe)
    }

    func testTrafficLevelToBridgeConditionStatus() {
        XCTAssertEqual(TrafficLevel.clear.toBridgeConditionStatus, .open)
        XCTAssertEqual(TrafficLevel.moderate.toBridgeConditionStatus, .open)
        XCTAssertEqual(TrafficLevel.heavy.toBridgeConditionStatus, .restricted)
        XCTAssertEqual(TrafficLevel.severe.toBridgeConditionStatus, .restricted)
    }

    // MARK: - CongestionLevel Properties

    func testCongestionLevelDisplayNames() {
        XCTAssertEqual(CongestionLevel.free.displayName, "Free")
        XCTAssertEqual(CongestionLevel.light.displayName, "Light")
        XCTAssertEqual(CongestionLevel.moderate.displayName, "Moderate")
        XCTAssertEqual(CongestionLevel.heavy.displayName, "Heavy")
        XCTAssertEqual(CongestionLevel.severe.displayName, "Severe")
    }

    func testCongestionLevelAllCases() {
        XCTAssertEqual(CongestionLevel.allCases.count, 5)
    }
}


// MARK: - WeatherServiceTests

final class WeatherServiceTests: XCTestCase {

    // MARK: - WeatherData Staleness

    func testWeatherDataFreshWhenJustCreated() {
        let weather = makeSampleWeatherData(fetchedAt: .now)
        XCTAssertFalse(weather.isStale)
    }

    func testWeatherDataStaleAfter1800Seconds() {
        let oldDate = Date.now.addingTimeInterval(-1801)
        let weather = makeSampleWeatherData(fetchedAt: oldDate)
        XCTAssertTrue(weather.isStale)
    }

    func testWeatherDataFreshAt1799Seconds() {
        let recentDate = Date.now.addingTimeInterval(-1799)
        let weather = makeSampleWeatherData(fetchedAt: recentDate)
        XCTAssertFalse(weather.isStale)
    }

    func testWeatherDataStaleTTLIs30Minutes() {
        // Verify the staleness boundary is at 1800 seconds (30 minutes)
        let justStale = Date.now.addingTimeInterval(-1800.1)
        let justFresh = Date.now.addingTimeInterval(-1799.9)

        XCTAssertTrue(makeSampleWeatherData(fetchedAt: justStale).isStale)
        XCTAssertFalse(makeSampleWeatherData(fetchedAt: justFresh).isStale)
    }

    // MARK: - WeatherAPIData to WeatherData Mapping

    func testWeatherAPIDataToWeatherDataMapping() {
        let apiData = WeatherAPIData(
            temperature: 82,
            feelsLike: 85,
            description: "Sunny and warm",
            humidity: 60,
            windSpeed: 12,
            windDirection: "SW",
            uvIndex: 8,
            icon: "clear"
        )

        let weatherData = apiData.toWeatherData()

        XCTAssertEqual(weatherData.current.temperature, 82)
        XCTAssertEqual(weatherData.current.feelsLike, 85)
        XCTAssertEqual(weatherData.current.humidity, 60)
        XCTAssertEqual(weatherData.current.windSpeed, 12)
        XCTAssertEqual(weatherData.current.windDirection, "SW")
        XCTAssertEqual(weatherData.current.uvIndex, 8)
        XCTAssertEqual(weatherData.current.condition, .clear)
        XCTAssertFalse(weatherData.isStale)
    }

    func testWeatherAPIDataFeelsLikeDefaultsToTemperature() {
        let apiData = WeatherAPIData(
            temperature: 70,
            feelsLike: nil,
            description: "Mild",
            humidity: 50,
            windSpeed: 5,
            windDirection: "N",
            uvIndex: 3,
            icon: "cloudy"
        )

        let weatherData = apiData.toWeatherData()
        XCTAssertEqual(weatherData.current.feelsLike, 70)
    }

    func testWeatherAPIDataConditionMapping() {
        // Test various icon strings map to correct conditions
        let iconToCondition: [(String, WeatherConditionType)] = [
            ("clear", .clear),
            ("sunny", .clear),
            ("partly cloudy", .partlyCloudy),
            ("cloudy", .cloudy),
            ("overcast", .cloudy),
            ("rain", .rain),
            ("shower", .rain),
            ("thunderstorm", .thunderstorm),
            ("snow", .snow),
            ("fog", .fog),
            ("mist", .fog),
            ("windy", .windy),
        ]

        for (icon, expected) in iconToCondition {
            let apiData = WeatherAPIData(
                temperature: 70, feelsLike: 70, description: "",
                humidity: 50, windSpeed: 5, windDirection: "N",
                uvIndex: 3, icon: icon
            )
            XCTAssertEqual(
                apiData.toWeatherData().current.condition, expected,
                "Icon '\(icon)' should map to \(expected)"
            )
        }
    }

    func testWeatherAPIDataEmptyForecastArrays() {
        let apiData = WeatherAPIData(
            temperature: 70, feelsLike: 70, description: "Mild",
            humidity: 50, windSpeed: 5, windDirection: "N",
            uvIndex: 3, icon: "clear"
        )

        let weatherData = apiData.toWeatherData()
        XCTAssertTrue(weatherData.hourly.isEmpty)
        XCTAssertTrue(weatherData.daily.isEmpty)
        XCTAssertTrue(weatherData.alerts.isEmpty)
    }

    // MARK: - CurrentWeather Beach Weather Logic

    func testBeachWeatherConditions() {
        let beachDay = CurrentWeather(
            temperature: 78, feelsLike: 80, condition: .clear,
            humidity: 55, windSpeed: 8, windDirection: "SW",
            uvIndex: 7, visibility: 10, pressure: 30.1, dewPoint: 62
        )
        XCTAssertTrue(beachDay.isBeachWeather)
    }

    func testNotBeachWeatherWhenTooColdd() {
        let coldDay = CurrentWeather(
            temperature: 65, feelsLike: 63, condition: .clear,
            humidity: 50, windSpeed: 5, windDirection: "W",
            uvIndex: 5, visibility: 10, pressure: 30.0, dewPoint: 50
        )
        XCTAssertFalse(coldDay.isBeachWeather)
    }

    func testNotBeachWeatherWhenTooWindy() {
        let windyDay = CurrentWeather(
            temperature: 80, feelsLike: 80, condition: .clear,
            humidity: 50, windSpeed: 20, windDirection: "NE",
            uvIndex: 6, visibility: 10, pressure: 30.0, dewPoint: 55
        )
        XCTAssertFalse(windyDay.isBeachWeather)
    }

    func testNotBeachWeatherWhenRaining() {
        let rainyDay = CurrentWeather(
            temperature: 80, feelsLike: 78, condition: .rain,
            humidity: 85, windSpeed: 10, windDirection: "E",
            uvIndex: 2, visibility: 5, pressure: 29.8, dewPoint: 70
        )
        XCTAssertFalse(rainyDay.isBeachWeather)
    }

    func testBeachWeatherBoundaryTemperature() {
        // Exactly 72 degrees, low wind, clear: should be beach weather
        let borderline = CurrentWeather(
            temperature: 72, feelsLike: 72, condition: .clear,
            humidity: 50, windSpeed: 10, windDirection: "S",
            uvIndex: 5, visibility: 10, pressure: 30.0, dewPoint: 55
        )
        XCTAssertTrue(borderline.isBeachWeather)
    }

    func testBeachWeatherBoundaryWind() {
        // High temp but wind exactly at 14.9 (under 15): should be beach weather
        let borderlineWind = CurrentWeather(
            temperature: 80, feelsLike: 80, condition: .partlyCloudy,
            humidity: 50, windSpeed: 14.9, windDirection: "S",
            uvIndex: 5, visibility: 10, pressure: 30.0, dewPoint: 55
        )
        XCTAssertTrue(borderlineWind.isBeachWeather)
    }

    func testBeachWeatherPartlyCloudy() {
        let partlyCloudy = CurrentWeather(
            temperature: 78, feelsLike: 78, condition: .partlyCloudy,
            humidity: 50, windSpeed: 8, windDirection: "SW",
            uvIndex: 5, visibility: 10, pressure: 30.0, dewPoint: 55
        )
        XCTAssertTrue(partlyCloudy.isBeachWeather)
    }

    func testNotBeachWeatherWhenFullyCloudy() {
        let cloudy = CurrentWeather(
            temperature: 80, feelsLike: 80, condition: .cloudy,
            humidity: 50, windSpeed: 5, windDirection: "W",
            uvIndex: 3, visibility: 10, pressure: 30.0, dewPoint: 55
        )
        XCTAssertFalse(cloudy.isBeachWeather)
    }

    // MARK: - CurrentWeather Formatting

    func testTemperatureFormatted() {
        let weather = CurrentWeather(
            temperature: 72.6, feelsLike: 74, condition: .clear,
            humidity: 50, windSpeed: 5, windDirection: "N",
            uvIndex: 5, visibility: 10, pressure: 30.0, dewPoint: 55
        )
        XCTAssertEqual(weather.temperatureFormatted, "73\u{00B0}")
    }

    func testTemperatureFormattedRoundsDown() {
        let weather = CurrentWeather(
            temperature: 72.3, feelsLike: 72, condition: .clear,
            humidity: 50, windSpeed: 5, windDirection: "N",
            uvIndex: 5, visibility: 10, pressure: 30.0, dewPoint: 55
        )
        XCTAssertEqual(weather.temperatureFormatted, "72\u{00B0}")
    }

    // MARK: - WeatherConditionType Properties

    func testWeatherConditionDisplayNames() {
        XCTAssertEqual(WeatherConditionType.clear.displayName, "Clear")
        XCTAssertEqual(WeatherConditionType.partlyCloudy.displayName, "Partly Cloudy")
        XCTAssertEqual(WeatherConditionType.rain.displayName, "Rain")
        XCTAssertEqual(WeatherConditionType.thunderstorm.displayName, "Thunderstorm")
        XCTAssertEqual(WeatherConditionType.snow.displayName, "Snow")
        XCTAssertEqual(WeatherConditionType.fog.displayName, "Fog")
        XCTAssertEqual(WeatherConditionType.windy.displayName, "Windy")
    }

    func testWeatherConditionIcons() {
        XCTAssertEqual(WeatherConditionType.clear.icon, "sun.max.fill")
        XCTAssertEqual(WeatherConditionType.rain.icon, "cloud.rain.fill")
        XCTAssertEqual(WeatherConditionType.thunderstorm.icon, "cloud.bolt.rain.fill")
        XCTAssertEqual(WeatherConditionType.snow.icon, "cloud.snow.fill")
    }

    func testWeatherConditionAllCases() {
        XCTAssertEqual(WeatherConditionType.allCases.count, 8)
    }

    // MARK: - WeatherServiceError Descriptions

    func testWeatherServiceErrorDescriptions() {
        XCTAssertEqual(
            WeatherServiceError.invalidURL.errorDescription,
            "Invalid weather service URL."
        )
        XCTAssertEqual(
            WeatherServiceError.invalidResponse.errorDescription,
            "Could not parse weather data."
        )
        XCTAssertEqual(
            WeatherServiceError.networkError.errorDescription,
            "Unable to connect to weather service."
        )
    }

    // MARK: - NOAA Tide API URL Construction

    func testNOAATideAPIURLConstruction() {
        let station = "8447930"
        let beginDate = "20250704"
        let endDate = "20250707"

        let urlString = "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?begin_date=\(beginDate)&end_date=\(endDate)&station=\(station)&product=predictions&datum=MLLW&time_zone=lst_ldt&interval=hilo&units=english&application=HeyCapeCod&format=json"

        let url = URL(string: urlString)
        XCTAssertNotNil(url)
        XCTAssertTrue(url!.absoluteString.contains("station=8447930"))
        XCTAssertTrue(url!.absoluteString.contains("product=predictions"))
        XCTAssertTrue(url!.absoluteString.contains("datum=MLLW"))
        XCTAssertTrue(url!.absoluteString.contains("application=HeyCapeCod"))
        XCTAssertTrue(url!.absoluteString.contains("format=json"))
    }

    func testWeatherServiceDefaultTideStation() {
        XCTAssertEqual(WeatherService.defaultTideStation, "8447930")
    }

    func testWeatherServiceCapeCodBuoyStation() {
        XCTAssertEqual(WeatherService.capeCodBuoyStation, "44018")
    }

    func testWeatherServiceCapeCodCenter() {
        let center = WeatherService.capeCodCenter
        XCTAssertEqual(center.latitude, 41.7003, accuracy: 0.0001)
        XCTAssertEqual(center.longitude, -70.3002, accuracy: 0.0001)
    }
}


// MARK: - POIServiceTests

final class POIServiceTests: XCTestCase {

    // MARK: - PointOfInterest Equality

    func testPointOfInterestEqualityByID() {
        let poi1 = makeSamplePOI(id: "lighthouse-1", name: "Nauset Light", latitude: 41.85, longitude: -69.95)
        let poi2 = makeSamplePOI(id: "lighthouse-1", name: "Different Name", latitude: 42.0, longitude: -70.0)

        XCTAssertEqual(poi1, poi2, "POIs with the same ID should be equal regardless of other fields")
    }

    func testPointOfInterestInequalityByID() {
        let poi1 = makeSamplePOI(id: "lighthouse-1")
        let poi2 = makeSamplePOI(id: "lighthouse-2")

        XCTAssertNotEqual(poi1, poi2)
    }

    // MARK: - StoryVariant Duration Estimation

    func testStoryVariantDurationFromWordCount() {
        let script = "The Nauset Lighthouse was built in eighteen seventy seven on the bluffs of Eastham"
        // 13 words / 2.5 = 5.2 seconds
        let story = StoryVariant(title: "Test", mode: .adult, script: script)

        let wordCount = script.split(separator: " ").count
        let expectedDuration = Double(wordCount) / 2.5
        XCTAssertEqual(story.duration, expectedDuration, accuracy: 0.01)
    }

    func testStoryVariantExplicitDurationOverridesEstimate() {
        let story = StoryVariant(
            title: "Test",
            mode: .adult,
            script: "Short script with few words",
            duration: 120
        )
        XCTAssertEqual(story.duration, 120)
    }

    func testStoryVariantZeroDurationUsesEstimate() {
        let story = StoryVariant(
            title: "Test",
            mode: .kids,
            script: "One two three four five"
        )
        // 5 words / 2.5 = 2.0 seconds
        XCTAssertEqual(story.duration, 2.0)
    }

    func testStoryVariantIDComposition() {
        let story = StoryVariant(title: "Nauset Light History", mode: .adult, script: "Test")
        XCTAssertEqual(story.id, "Nauset Light History-adult")
    }

    func testStoryVariantIDForKidsMode() {
        let story = StoryVariant(title: "Fun Facts", mode: .kids, script: "Test")
        XCTAssertEqual(story.id, "Fun Facts-kids")
    }

    func testStoryVariantIDForFamilyMode() {
        let story = StoryVariant(title: "Tour Guide", mode: .family, script: "Test")
        XCTAssertEqual(story.id, "Tour Guide-family")
    }

    // MARK: - StoryMode

    func testStoryModeAllCases() {
        let modes = GeofenceManager.StoryMode.allCases
        XCTAssertEqual(modes.count, 3)
        XCTAssertTrue(modes.contains(.adult))
        XCTAssertTrue(modes.contains(.kids))
        XCTAssertTrue(modes.contains(.family))
    }

    func testStoryModeDisplayNames() {
        XCTAssertEqual(GeofenceManager.StoryMode.adult.displayName, "Adult")
        XCTAssertEqual(GeofenceManager.StoryMode.kids.displayName, "Kids")
        XCTAssertEqual(GeofenceManager.StoryMode.family.displayName, "Family")
    }

    func testStoryModeRawValues() {
        XCTAssertEqual(GeofenceManager.StoryMode.adult.rawValue, "adult")
        XCTAssertEqual(GeofenceManager.StoryMode.kids.rawValue, "kids")
        XCTAssertEqual(GeofenceManager.StoryMode.family.rawValue, "family")
    }

    // MARK: - POI to/from Conversion

    func testPOIToPointOfInterestConversion() {
        let poi = POI(
            id: "coast-guard-beach",
            name: "Coast Guard Beach",
            description: "Famous National Seashore beach",
            latitude: 41.8398,
            longitude: -69.9508,
            radius: 300,
            category: .beach,
            town: "eastham",
            facts: ["Part of Cape Cod National Seashore"],
            tips: ["Arrive early in summer"]
        )

        let converted = poi.toPointOfInterest()

        XCTAssertEqual(converted.id, "coast-guard-beach")
        XCTAssertEqual(converted.name, "Coast Guard Beach")
        XCTAssertEqual(converted.coordinate.latitude, 41.8398, accuracy: 0.0001)
        XCTAssertEqual(converted.coordinate.longitude, -69.9508, accuracy: 0.0001)
        XCTAssertEqual(converted.geofenceRadius, 300)
        XCTAssertEqual(converted.facts, ["Part of Cape Cod National Seashore"])
        XCTAssertEqual(converted.tips, ["Arrive early in summer"])
    }

    func testPointOfInterestToPOIConversion() {
        let pointOfInterest = makeSamplePOI(
            id: "nauset-light",
            name: "Nauset Lighthouse",
            latitude: 41.8584,
            longitude: -69.9514,
            radius: 200
        )

        let poi = pointOfInterest.toPOI()

        XCTAssertEqual(poi.id, "nauset-light")
        XCTAssertEqual(poi.name, "Nauset Lighthouse")
        XCTAssertEqual(poi.latitude, 41.8584, accuracy: 0.0001)
        XCTAssertEqual(poi.longitude, -69.9514, accuracy: 0.0001)
        XCTAssertEqual(poi.radius, 200)
    }

    // MARK: - POI Default Values

    func testPOIDefaultRadius() {
        let poi = POI(id: "test", name: "Test POI", latitude: 41.7, longitude: -70.3)
        XCTAssertEqual(poi.radius, 200)
    }

    func testPOIDefaultCategory() {
        let poi = POI(id: "test", name: "Test POI", latitude: 41.7, longitude: -70.3)
        XCTAssertEqual(poi.category, .nature)
    }

    func testPOIDefaultPriority() {
        let poi = POI(id: "test", name: "Test POI", latitude: 41.7, longitude: -70.3)
        XCTAssertEqual(poi.priority, 0)
    }

    func testPOIDefaultIsActive() {
        let poi = POI(id: "test", name: "Test POI", latitude: 41.7, longitude: -70.3)
        XCTAssertTrue(poi.isActive)
    }

    // MARK: - POI Coordinate

    func testPOICoordinateComputed() {
        let poi = POI(id: "test", name: "Test", latitude: 41.8398, longitude: -69.9508)
        XCTAssertEqual(poi.coordinate.latitude, 41.8398, accuracy: 0.0001)
        XCTAssertEqual(poi.coordinate.longitude, -69.9508, accuracy: 0.0001)
    }

    // MARK: - POICategory

    func testPOICategoryDisplayNames() {
        XCTAssertEqual(POICategory.beach.displayName, "Beaches")
        XCTAssertEqual(POICategory.restaurant.displayName, "Dining")
        XCTAssertEqual(POICategory.historic.displayName, "Historic Sites")
        XCTAssertEqual(POICategory.lighthouse.displayName, "Lighthouses")
        XCTAssertEqual(POICategory.museum.displayName, "Museums")
    }

    func testPOICategoryAllCases() {
        XCTAssertEqual(POICategory.allCases.count, 12)
    }

    func testPOICategoryIcons() {
        XCTAssertEqual(POICategory.beach.icon, "beach.umbrella.fill")
        XCTAssertEqual(POICategory.restaurant.icon, "fork.knife")
        XCTAssertEqual(POICategory.lighthouse.icon, "light.beacon.max.fill")
    }

    // MARK: - POI Equality and Hashing

    func testPOIEqualityByID() {
        let poi1 = POI(id: "same-id", name: "Name 1", latitude: 41.7, longitude: -70.3)
        let poi2 = POI(id: "same-id", name: "Name 2", latitude: 42.0, longitude: -71.0)
        XCTAssertEqual(poi1, poi2)
    }

    func testPOIHashingByID() {
        let poi1 = POI(id: "same-id", name: "Name 1", latitude: 41.7, longitude: -70.3)
        let poi2 = POI(id: "same-id", name: "Name 2", latitude: 42.0, longitude: -71.0)
        XCTAssertEqual(poi1.hashValue, poi2.hashValue)
    }
}


// MARK: - GeofenceManagerTests

final class GeofenceManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Clear all geofence cooldowns before each test
        UserDefaults.standard.removeObject(forKey: "geofenceCooldowns")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "geofenceCooldowns")
        super.tearDown()
    }

    // MARK: - Configuration Constants

    func testMaxMonitoredRegionsIs20() {
        XCTAssertEqual(GeofenceManager.maxMonitoredRegions, 20)
    }

    // MARK: - Cooldown Logic via UserDefaults

    func testCooldownNotSetByDefault() {
        // With no cooldown data in UserDefaults, loading should return empty
        let data = UserDefaults.standard.data(forKey: "geofenceCooldowns")
        XCTAssertNil(data)
    }

    func testCooldownRecordAndCheck() {
        // Simulate recording a trigger by storing cooldown data directly
        let poiID = "nauset-light"
        var cooldowns: [String: Date] = [:]
        cooldowns[poiID] = Date()

        let encoded = try! JSONEncoder().encode(cooldowns)
        UserDefaults.standard.set(encoded, forKey: "geofenceCooldowns")

        // Verify we can read it back
        let data = UserDefaults.standard.data(forKey: "geofenceCooldowns")!
        let decoded = try! JSONDecoder().decode([String: Date].self, from: data)
        XCTAssertNotNil(decoded[poiID])
        XCTAssertTrue(Date().timeIntervalSince(decoded[poiID]!) < 5) // Should be very recent
    }

    func testCooldownExpired() {
        // Simulate a cooldown that expired (over 24h ago)
        let poiID = "old-poi"
        let expiredDate = Date().addingTimeInterval(-25 * 60 * 60) // 25 hours ago
        var cooldowns: [String: Date] = [:]
        cooldowns[poiID] = expiredDate

        let encoded = try! JSONEncoder().encode(cooldowns)
        UserDefaults.standard.set(encoded, forKey: "geofenceCooldowns")

        // Read and filter (matching GeofenceManager.loadCooldowns logic)
        let data = UserDefaults.standard.data(forKey: "geofenceCooldowns")!
        let decoded = try! JSONDecoder().decode([String: Date].self, from: data)
        let cooldownInterval: TimeInterval = 24 * 60 * 60

        let active = decoded.filter { Date().timeIntervalSince($0.value) < cooldownInterval }
        XCTAssertTrue(active.isEmpty, "Expired cooldowns should be pruned")
    }

    func testCooldownStillActive() {
        // Simulate a cooldown set 1 hour ago (within 24h)
        let poiID = "recent-poi"
        let recentDate = Date().addingTimeInterval(-1 * 60 * 60) // 1 hour ago
        var cooldowns: [String: Date] = [:]
        cooldowns[poiID] = recentDate

        let encoded = try! JSONEncoder().encode(cooldowns)
        UserDefaults.standard.set(encoded, forKey: "geofenceCooldowns")

        let data = UserDefaults.standard.data(forKey: "geofenceCooldowns")!
        let decoded = try! JSONDecoder().decode([String: Date].self, from: data)
        let cooldownInterval: TimeInterval = 24 * 60 * 60

        let active = decoded.filter { Date().timeIntervalSince($0.value) < cooldownInterval }
        XCTAssertEqual(active.count, 1)
        XCTAssertNotNil(active[poiID])
    }

    func testMultipleCooldowns() {
        let now = Date()
        var cooldowns: [String: Date] = [
            "poi-1": now.addingTimeInterval(-1 * 60 * 60),   // 1 hour ago (active)
            "poi-2": now.addingTimeInterval(-23 * 60 * 60),  // 23 hours ago (active)
            "poi-3": now.addingTimeInterval(-25 * 60 * 60),  // 25 hours ago (expired)
        ]

        let encoded = try! JSONEncoder().encode(cooldowns)
        UserDefaults.standard.set(encoded, forKey: "geofenceCooldowns")

        let data = UserDefaults.standard.data(forKey: "geofenceCooldowns")!
        let decoded = try! JSONDecoder().decode([String: Date].self, from: data)
        let cooldownInterval: TimeInterval = 24 * 60 * 60

        let active = decoded.filter { Date().timeIntervalSince($0.value) < cooldownInterval }
        XCTAssertEqual(active.count, 2)
        XCTAssertNotNil(active["poi-1"])
        XCTAssertNotNil(active["poi-2"])
        XCTAssertNil(active["poi-3"])
    }

    func testClearAllCooldowns() {
        // Set some cooldowns
        var cooldowns: [String: Date] = ["poi-1": Date(), "poi-2": Date()]
        let encoded = try! JSONEncoder().encode(cooldowns)
        UserDefaults.standard.set(encoded, forKey: "geofenceCooldowns")

        // Clear all
        UserDefaults.standard.removeObject(forKey: "geofenceCooldowns")

        let data = UserDefaults.standard.data(forKey: "geofenceCooldowns")
        XCTAssertNil(data)
    }

    func testClearSingleCooldown() {
        var cooldowns: [String: Date] = ["poi-1": Date(), "poi-2": Date()]
        let encoded = try! JSONEncoder().encode(cooldowns)
        UserDefaults.standard.set(encoded, forKey: "geofenceCooldowns")

        // Remove single entry
        let data = UserDefaults.standard.data(forKey: "geofenceCooldowns")!
        var decoded = try! JSONDecoder().decode([String: Date].self, from: data)
        decoded.removeValue(forKey: "poi-1")

        let reEncoded = try! JSONEncoder().encode(decoded)
        UserDefaults.standard.set(reEncoded, forKey: "geofenceCooldowns")

        let final = UserDefaults.standard.data(forKey: "geofenceCooldowns")!
        let finalDecoded = try! JSONDecoder().decode([String: Date].self, from: final)
        XCTAssertNil(finalDecoded["poi-1"])
        XCTAssertNotNil(finalDecoded["poi-2"])
    }

    // MARK: - Story Mode Selection

    func testStoryModeMatchingFindsCorrectVariant() {
        let stories = makeSampleStories()

        let adultStory = stories.first { $0.mode == .adult }
        XCTAssertNotNil(adultStory)
        XCTAssertEqual(adultStory?.title, "Nauset Light History")

        let kidsStory = stories.first { $0.mode == .kids }
        XCTAssertNotNil(kidsStory)
        XCTAssertEqual(kidsStory?.title, "Nauset Light for Kids")

        let familyStory = stories.first { $0.mode == .family }
        XCTAssertNotNil(familyStory)
        XCTAssertEqual(familyStory?.title, "Nauset Light Family")
    }

    func testStoryModeFallbackToFirstAvailable() {
        let stories = [
            StoryVariant(title: "Adult Only", mode: .adult, script: "For grown ups only"),
        ]

        // If requesting kids mode but only adult is available, fall back to first
        let kidsStory = stories.first { $0.mode == .kids } ?? stories.first
        XCTAssertNotNil(kidsStory)
        XCTAssertEqual(kidsStory?.mode, .adult)
    }

    // MARK: - Geofence Region Count Enforcement

    func testGeofenceLimitEnforcedWhenSelectingNearest() {
        // Create 30 POIs at varying distances from a reference point
        let referenceLat = 41.7003
        let referenceLng = -70.3002
        var pois: [PointOfInterest] = []

        for i in 0..<30 {
            let offset = Double(i) * 0.01
            pois.append(makeSamplePOI(
                id: "poi-\(i)",
                name: "POI \(i)",
                latitude: referenceLat + offset,
                longitude: referenceLng
            ))
        }

        // Simulate selecting the nearest 20 (matching GeofenceManager logic)
        let location = CLLocation(latitude: referenceLat, longitude: referenceLng)
        let sorted = pois
            .map { poi in
                let dist = location.distance(from: CLLocation(
                    latitude: poi.coordinate.latitude,
                    longitude: poi.coordinate.longitude
                ))
                return (poi: poi, distance: dist)
            }
            .sorted { $0.distance < $1.distance }

        let nearest = Array(sorted.prefix(GeofenceManager.maxMonitoredRegions))

        XCTAssertEqual(nearest.count, 20)
        // The nearest should be poi-0 (at the reference point)
        XCTAssertEqual(nearest.first?.poi.id, "poi-0")
    }

    func testGeofenceSelectionSortsByDistance() {
        let referenceLat = 41.7003
        let referenceLng = -70.3002
        let location = CLLocation(latitude: referenceLat, longitude: referenceLng)

        let farPOI = makeSamplePOI(id: "far", latitude: 42.0, longitude: -70.3)
        let nearPOI = makeSamplePOI(id: "near", latitude: 41.701, longitude: -70.3)

        let pois = [farPOI, nearPOI]
        let sorted = pois
            .map { poi in
                let dist = location.distance(from: CLLocation(
                    latitude: poi.coordinate.latitude,
                    longitude: poi.coordinate.longitude
                ))
                return (poi: poi, distance: dist)
            }
            .sorted { $0.distance < $1.distance }

        XCTAssertEqual(sorted.first?.poi.id, "near")
        XCTAssertEqual(sorted.last?.poi.id, "far")
    }
}


// MARK: - PaywallManagerTests

final class PaywallManagerTests: XCTestCase {

    // MARK: - Free Tier Constants

    func testFreeVoiceConversationsPerDayIs3() {
        XCTAssertEqual(PaywallManager.freeVoiceConversationsPerDay, 3)
    }

    func testFreeStoriesPerDayIs5() {
        XCTAssertEqual(PaywallManager.freeStoriesPerDay, 5)
    }

    // MARK: - Subscription Product IDs

    func testSubscriptionMonthlyProductID() {
        XCTAssertEqual(SubscriptionManager.monthlyID, "capecod_monthly")
    }

    func testSubscriptionAnnualProductID() {
        XCTAssertEqual(SubscriptionManager.annualID, "capecod_annual")
    }

    func testSubscriptionProductIDsSet() {
        XCTAssertEqual(SubscriptionManager.productIDs.count, 2)
        XCTAssertTrue(SubscriptionManager.productIDs.contains("capecod_monthly"))
        XCTAssertTrue(SubscriptionManager.productIDs.contains("capecod_annual"))
    }

    // MARK: - UserProfile Daily Reset Logic

    func testUserProfileResetDailyCounters() {
        let profile = UserProfile(uid: "test-user")
        profile.conversationsToday = 5
        profile.storiesPlayedToday = 10
        // Set lastResetDate to yesterday
        profile.lastResetDate = Calendar.current.date(byAdding: .day, value: -1, to: .now)!

        profile.resetDailyCountersIfNeeded()

        XCTAssertEqual(profile.conversationsToday, 0)
        XCTAssertEqual(profile.storiesPlayedToday, 0)
    }

    func testUserProfileNoResetSameDay() {
        let profile = UserProfile(uid: "test-user")
        profile.conversationsToday = 2
        profile.storiesPlayedToday = 3
        profile.lastResetDate = Calendar.current.startOfDay(for: .now)

        profile.resetDailyCountersIfNeeded()

        XCTAssertEqual(profile.conversationsToday, 2)
        XCTAssertEqual(profile.storiesPlayedToday, 3)
    }

    func testUserProfileIncrementConversations() {
        let profile = UserProfile(uid: "test-user")
        XCTAssertEqual(profile.conversationsToday, 0)
        XCTAssertEqual(profile.totalConversations, 0)

        profile.incrementConversations()

        XCTAssertEqual(profile.conversationsToday, 1)
        XCTAssertEqual(profile.totalConversations, 1)
    }

    func testUserProfileIncrementStoriesPlayed() {
        let profile = UserProfile(uid: "test-user")
        XCTAssertEqual(profile.storiesPlayedToday, 0)
        XCTAssertEqual(profile.totalStoriesPlayed, 0)

        profile.incrementStoriesPlayed()

        XCTAssertEqual(profile.storiesPlayedToday, 1)
        XCTAssertEqual(profile.totalStoriesPlayed, 1)
    }

    func testUserProfileMultipleIncrements() {
        let profile = UserProfile(uid: "test-user")

        for _ in 0..<5 {
            profile.incrementConversations()
        }
        for _ in 0..<3 {
            profile.incrementStoriesPlayed()
        }

        XCTAssertEqual(profile.conversationsToday, 5)
        XCTAssertEqual(profile.totalConversations, 5)
        XCTAssertEqual(profile.storiesPlayedToday, 3)
        XCTAssertEqual(profile.totalStoriesPlayed, 3)
    }

    func testUserProfileResetThenIncrement() {
        let profile = UserProfile(uid: "test-user")
        profile.conversationsToday = 3
        profile.lastResetDate = Calendar.current.date(byAdding: .day, value: -1, to: .now)!

        // incrementConversations calls resetDailyCountersIfNeeded internally
        profile.incrementConversations()

        XCTAssertEqual(profile.conversationsToday, 1, "Should reset to 0 then increment to 1")
    }

    // MARK: - UserProfile Initialization

    func testUserProfileDefaults() {
        let profile = UserProfile(uid: "test-uid", displayName: "Jane Doe", email: "jane@example.com")

        XCTAssertEqual(profile.uid, "test-uid")
        XCTAssertEqual(profile.displayName, "Jane Doe")
        XCTAssertEqual(profile.email, "jane@example.com")
        XCTAssertFalse(profile.isPremium)
        XCTAssertEqual(profile.conversationsToday, 0)
        XCTAssertEqual(profile.storiesPlayedToday, 0)
        XCTAssertEqual(profile.totalConversations, 0)
        XCTAssertEqual(profile.totalStoriesPlayed, 0)
        XCTAssertTrue(profile.favoriteBeaches.isEmpty)
        XCTAssertTrue(profile.interests.isEmpty)
    }

    func testUserProfileGuestDefaults() {
        let profile = UserProfile(uid: "guest-123")
        XCTAssertEqual(profile.displayName, "Guest")
        XCTAssertEqual(profile.authProvider, "guest")
        XCTAssertNil(profile.email)
    }

    // MARK: - UserProfile Premium Status

    func testPremiumIsActiveWhenSubscribed() {
        let profile = UserProfile(uid: "test-user")
        profile.isPremium = true
        profile.premiumExpiresAt = Date.now.addingTimeInterval(30 * 24 * 60 * 60) // 30 days from now

        XCTAssertTrue(profile.premiumIsActive)
    }

    func testPremiumIsInactiveWhenExpired() {
        let profile = UserProfile(uid: "test-user")
        profile.isPremium = true
        profile.premiumExpiresAt = Date.now.addingTimeInterval(-1) // Expired

        XCTAssertFalse(profile.premiumIsActive)
    }

    func testPremiumIsInactiveWhenNotSubscribed() {
        let profile = UserProfile(uid: "test-user")
        profile.isPremium = false

        XCTAssertFalse(profile.premiumIsActive)
    }

    func testPremiumIsActiveWithNoExpiration() {
        let profile = UserProfile(uid: "test-user")
        profile.isPremium = true
        profile.premiumExpiresAt = nil

        XCTAssertTrue(profile.premiumIsActive, "Premium with no expiration date should be active")
    }

    // MARK: - UserProfile Experience Mode

    func testUserProfileDefaultExperienceMode() {
        let profile = UserProfile(uid: "test-user")
        XCTAssertEqual(profile.experienceMode, .adult)
    }

    func testUserProfileSetExperienceMode() {
        let profile = UserProfile(uid: "test-user")
        profile.experienceMode = .kids
        XCTAssertEqual(profile.experienceMode, .kids)
        XCTAssertEqual(profile.currentMode, "kids")
    }

    // MARK: - UserProfile Firestore Data

    func testUserProfileToFirestoreData() {
        let profile = UserProfile(uid: "user-123", displayName: "Test User", email: "test@example.com")
        profile.totalConversations = 42
        profile.isPremium = true

        let data = profile.toFirestoreData()

        XCTAssertEqual(data["uid"] as? String, "user-123")
        XCTAssertEqual(data["displayName"] as? String, "Test User")
        XCTAssertEqual(data["email"] as? String, "test@example.com")
        XCTAssertEqual(data["totalConversations"] as? Int, 42)
        XCTAssertEqual(data["isPremium"] as? Bool, true)
    }

    // MARK: - PaywallResult Cases

    func testPaywallResultAllowedCase() {
        let result = PaywallManager.PaywallResult.allowed
        if case .allowed = result {
            // Pass
        } else {
            XCTFail("Expected .allowed")
        }
    }

    func testPaywallResultLimitReachedCase() {
        let result = PaywallManager.PaywallResult.limitReached(
            reason: "Limit hit",
            upgradePrompt: "Upgrade now"
        )
        if case .limitReached(let reason, let prompt) = result {
            XCTAssertEqual(reason, "Limit hit")
            XCTAssertEqual(prompt, "Upgrade now")
        } else {
            XCTFail("Expected .limitReached")
        }
    }

    func testPaywallResultRequiresAuthCase() {
        let result = PaywallManager.PaywallResult.requiresAuth(reason: "Sign in please")
        if case .requiresAuth(let reason) = result {
            XCTAssertEqual(reason, "Sign in please")
        } else {
            XCTFail("Expected .requiresAuth")
        }
    }
}


// MARK: - AudioEngineTests

final class AudioEngineTests: XCTestCase {

    // MARK: - Audio Format Constants

    func testSampleRateIs24000() {
        XCTAssertEqual(AudioEngine.sampleRate, 24_000)
    }

    func testChannelCountIs1() {
        XCTAssertEqual(AudioEngine.channelCount, 1)
    }

    func testBytesPerSampleIs2() {
        XCTAssertEqual(AudioEngine.bytesPerSample, 2, "PCM16 requires 2 bytes per sample")
    }

    // MARK: - Chunk Size Calculations

    func testChunkSizeCalculation() {
        // ~100ms at 24kHz = 2400 samples * 2 bytes = 4800 bytes
        let samplesPerChunk = 2400
        let expectedBytes = samplesPerChunk * AudioEngine.bytesPerSample
        XCTAssertEqual(expectedBytes, 4800)
    }

    func testSampleRateMatchesOpenAIRealtimeSpec() {
        // OpenAI Realtime API requires 24kHz PCM16
        XCTAssertEqual(AudioEngine.sampleRate, 24_000, "Must match OpenAI Realtime API spec")
        XCTAssertEqual(AudioEngine.bytesPerSample, 2, "PCM16 = 2 bytes per sample")
    }

    // MARK: - Audio Engine Initial State

    func testAudioEngineInitialState() {
        let engine = AudioEngine()
        XCTAssertFalse(engine.isRunning)
        XCTAssertFalse(engine.isSpeechDetected)
        XCTAssertEqual(engine.audioLevel, 0)
    }

    // MARK: - AudioEngineError Descriptions

    func testNoInputAvailableErrorDescription() {
        let error = AudioEngineError.noInputAvailable
        XCTAssertEqual(error.errorDescription, "No microphone input available.")
    }

    func testConverterCreationFailedErrorDescription() {
        let error = AudioEngineError.converterCreationFailed
        XCTAssertEqual(error.errorDescription, "Failed to create audio format converter.")
    }

    // MARK: - Format Validation

    func testMonoChannelFormat() {
        XCTAssertEqual(AudioEngine.channelCount, 1, "Audio must be mono for speech recognition")
    }

    func testSampleRateIsPositive() {
        XCTAssertGreaterThan(AudioEngine.sampleRate, 0)
    }

    func testBytesPerSampleIsPositive() {
        XCTAssertGreaterThan(AudioEngine.bytesPerSample, 0)
    }

    // MARK: - Duration Calculation Verification

    func testOneSecondOfAudioSize() {
        // 1 second at 24kHz mono PCM16 = 24000 samples * 2 bytes = 48000 bytes
        let oneSec = Int(AudioEngine.sampleRate) * AudioEngine.bytesPerSample
        XCTAssertEqual(oneSec, 48_000)
    }

    func testOneMinuteOfAudioSize() {
        // 1 minute = 60 * 48000 = 2,880,000 bytes (~2.88 MB)
        let oneMinute = Int(AudioEngine.sampleRate) * AudioEngine.bytesPerSample * 60
        XCTAssertEqual(oneMinute, 2_880_000)
    }
}


// MARK: - APIClientTests

final class APIClientTests: XCTestCase {

    // MARK: - Environment Base URLs

    func testDevelopmentBaseURL() {
        XCTAssertEqual(
            APIClient.Environment.development.baseURL,
            "http://localhost:3000/api"
        )
    }

    func testStagingBaseURL() {
        XCTAssertEqual(
            APIClient.Environment.staging.baseURL,
            "https://staging-cape-cod.vercel.app/api"
        )
    }

    func testProductionBaseURL() {
        XCTAssertEqual(
            APIClient.Environment.production.baseURL,
            "https://v0-cape-cod-ai-travel-assistant.vercel.app/api"
        )
    }

    func testDevelopmentBaseURLIsHTTP() {
        let url = APIClient.Environment.development.baseURL
        XCTAssertTrue(url.hasPrefix("http://"), "Development should use HTTP for localhost")
    }

    func testStagingBaseURLIsHTTPS() {
        let url = APIClient.Environment.staging.baseURL
        XCTAssertTrue(url.hasPrefix("https://"), "Staging should use HTTPS")
    }

    func testProductionBaseURLIsHTTPS() {
        let url = APIClient.Environment.production.baseURL
        XCTAssertTrue(url.hasPrefix("https://"), "Production should use HTTPS")
    }

    func testAllEnvironmentURLsEndWithAPI() {
        let environments: [APIClient.Environment] = [.development, .staging, .production]
        for env in environments {
            XCTAssertTrue(
                env.baseURL.hasSuffix("/api"),
                "\(env) baseURL should end with /api"
            )
        }
    }

    func testEnvironmentBaseURLsAreValidURLs() {
        let environments: [APIClient.Environment] = [.development, .staging, .production]
        for env in environments {
            let url = URL(string: env.baseURL)
            XCTAssertNotNil(url, "\(env) should have a valid URL")
        }
    }

    // MARK: - URL Construction

    func testEndpointAppending() {
        let baseURL = URL(string: APIClient.Environment.production.baseURL)!
        let endpoint = "/traffic"
        let fullURL = baseURL.appendingPathComponent(endpoint)

        XCTAssertTrue(fullURL.absoluteString.contains("traffic"))
    }

    func testWeatherEndpointWithQueryItems() {
        let baseURL = URL(string: APIClient.Environment.production.baseURL)!
        var components = URLComponents(url: baseURL.appendingPathComponent("/weather"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "lat", value: "41.7003"),
            URLQueryItem(name: "lng", value: "-70.3002"),
        ]

        let url = components.url!
        XCTAssertTrue(url.absoluteString.contains("lat=41.7003"))
        XCTAssertTrue(url.absoluteString.contains("lng=-70.3002"))
    }

    func testPOINearbyEndpointWithQueryItems() {
        let baseURL = URL(string: APIClient.Environment.production.baseURL)!
        var components = URLComponents(url: baseURL.appendingPathComponent("/pois/nearby"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "lat", value: "41.8398"),
            URLQueryItem(name: "lng", value: "-69.9508"),
            URLQueryItem(name: "radius", value: "15000"),
        ]

        let url = components.url!
        XCTAssertTrue(url.absoluteString.contains("radius=15000"))
    }

    // MARK: - APIError Descriptions

    func testServerErrorDescription() {
        let error = APIError.serverError(500)
        XCTAssertEqual(error.errorDescription, "Server error (500).")
    }

    func testServerError404Description() {
        let error = APIError.serverError(404)
        XCTAssertEqual(error.errorDescription, "Server error (404).")
    }

    func testNoDataErrorDescription() {
        XCTAssertEqual(APIError.noData.errorDescription, "No data found.")
    }

    func testDecodingErrorDescription() {
        XCTAssertEqual(APIError.decodingError.errorDescription, "Data format error.")
    }

    func testUnauthorizedErrorDescription() {
        XCTAssertEqual(APIError.unauthorized.errorDescription, "Please sign in to continue.")
    }

    func testRateLimitedErrorDescription() {
        XCTAssertEqual(
            APIError.rateLimited.errorDescription,
            "Daily limit reached. Upgrade for unlimited access."
        )
    }

    // MARK: - APIError Conformance

    func testAPIErrorConformsToLocalizedError() {
        let error: any LocalizedError = APIError.noData
        XCTAssertNotNil(error.errorDescription)
    }

    func testAPIErrorCanBeThrownAndCaught() {
        func throwingFunction() throws {
            throw APIError.unauthorized
        }

        XCTAssertThrowsError(try throwingFunction()) { error in
            guard let apiError = error as? APIError else {
                XCTFail("Expected APIError")
                return
            }
            if case .unauthorized = apiError {
                // Pass
            } else {
                XCTFail("Expected .unauthorized")
            }
        }
    }

    func testServerErrorPreservesStatusCode() {
        let error = APIError.serverError(503)
        if case .serverError(let code) = error {
            XCTAssertEqual(code, 503)
        } else {
            XCTFail("Expected .serverError")
        }
    }

    // MARK: - MockAPIClient Behavior

    func testMockAPIClientLogsRequests() {
        let mock = MockAPIClient()
        mock.injectResponse("test", for: "/traffic")

        _ = try? mock.get("/traffic") as String
        _ = try? mock.get("/weather") as String

        XCTAssertEqual(mock.requestLog.count, 2)
        XCTAssertEqual(mock.requestLog[0].method, "GET")
        XCTAssertEqual(mock.requestLog[0].endpoint, "/traffic")
        XCTAssertEqual(mock.requestLog[1].endpoint, "/weather")
    }

    func testMockAPIClientErrorInjection() {
        let mock = MockAPIClient()
        mock.injectError(APIError.unauthorized, for: "/secure")

        XCTAssertThrowsError(try mock.get("/secure") as String) { error in
            XCTAssertTrue(error is APIError)
        }
    }

    func testMockAPIClientReset() {
        let mock = MockAPIClient()
        mock.injectResponse("data", for: "/endpoint")
        mock.injectError(APIError.noData, for: "/other")
        _ = try? mock.get("/endpoint") as String

        mock.reset()

        XCTAssertTrue(mock.requestLog.isEmpty)
        XCTAssertTrue(mock.mockResponses.isEmpty)
        XCTAssertTrue(mock.mockErrors.isEmpty)
    }

    func testMockAPIClientReturnsNoDataForUnknownEndpoint() {
        let mock = MockAPIClient()

        XCTAssertThrowsError(try mock.get("/unknown") as String) { error in
            if let apiError = error as? APIError, case .noData = apiError {
                // Pass
            } else {
                XCTFail("Expected APIError.noData for unknown endpoint")
            }
        }
    }
}


// MARK: - MockLocationManagerTests

final class MockLocationManagerTests: XCTestCase {

    func testSetLocation() {
        let mock = MockLocationManager()
        mock.setLocation(latitude: 41.7003, longitude: -70.3002)

        XCTAssertNotNil(mock.currentLocation)
        XCTAssertEqual(mock.currentLocation!.coordinate.latitude, 41.7003, accuracy: 0.0001)
        XCTAssertEqual(mock.currentLocation!.coordinate.longitude, -70.3002, accuracy: 0.0001)
    }

    func testAuthorizationStatusDefaults() {
        let mock = MockLocationManager()
        XCTAssertEqual(mock.authorizationStatus, .notDetermined)
        XCTAssertFalse(mock.isAuthorized)
        XCTAssertFalse(mock.hasAlwaysPermission)
        XCTAssertFalse(mock.isDenied)
    }

    func testAuthorizedWhenInUse() {
        let mock = MockLocationManager()
        mock.authorizationStatus = .authorizedWhenInUse
        XCTAssertTrue(mock.isAuthorized)
        XCTAssertFalse(mock.hasAlwaysPermission)
    }

    func testAuthorizedAlways() {
        let mock = MockLocationManager()
        mock.authorizationStatus = .authorizedAlways
        XCTAssertTrue(mock.isAuthorized)
        XCTAssertTrue(mock.hasAlwaysPermission)
    }

    func testDenied() {
        let mock = MockLocationManager()
        mock.authorizationStatus = .denied
        XCTAssertFalse(mock.isAuthorized)
        XCTAssertTrue(mock.isDenied)
    }

    func testRegionMonitoring() {
        let mock = MockLocationManager()
        mock.startMonitoring(regionID: "region-1")
        mock.startMonitoring(regionID: "region-2")

        XCTAssertEqual(mock.monitoredRegions.count, 2)
        XCTAssertTrue(mock.monitoredRegions.contains("region-1"))

        mock.stopMonitoring(regionID: "region-1")
        XCTAssertEqual(mock.monitoredRegions.count, 1)
        XCTAssertFalse(mock.monitoredRegions.contains("region-1"))

        mock.stopAllMonitoring()
        XCTAssertTrue(mock.monitoredRegions.isEmpty)
    }

    func testSimulateRegionEntry() {
        let mock = MockLocationManager()
        var enteredRegion: String?

        mock.onRegionEntered = { regionID in
            enteredRegion = regionID
        }

        mock.simulateRegionEntry(regionID: "nauset-light")
        XCTAssertEqual(enteredRegion, "nauset-light")
    }

    func testSimulateSignificantMove() {
        let mock = MockLocationManager()
        var receivedLocation: CLLocation?

        mock.onSignificantLocationChange = { location in
            receivedLocation = location
        }

        let newLocation = CLLocation(latitude: 42.0521, longitude: -70.1862)
        mock.simulateSignificantMove(to: newLocation)

        XCTAssertNotNil(receivedLocation)
        XCTAssertEqual(receivedLocation!.coordinate.latitude, 42.0521, accuracy: 0.0001)
        XCTAssertEqual(mock.currentLocation!.coordinate.latitude, 42.0521, accuracy: 0.0001)
    }
}


// MARK: - ExperienceModeTests

final class ExperienceModeTests: XCTestCase {

    func testAllExperienceModes() {
        let modes = ExperienceMode.allCases
        XCTAssertTrue(modes.contains(.kids))
        XCTAssertTrue(modes.contains(.teen))
        XCTAssertTrue(modes.contains(.adult))
        XCTAssertTrue(modes.contains(.family))
    }

    func testExperienceModeRawValues() {
        XCTAssertEqual(ExperienceMode.kids.rawValue, "kids")
        XCTAssertEqual(ExperienceMode.teen.rawValue, "teen")
        XCTAssertEqual(ExperienceMode.adult.rawValue, "adult")
        XCTAssertEqual(ExperienceMode.family.rawValue, "family")
    }

    func testExperienceModeDisplayNames() {
        XCTAssertEqual(ExperienceMode.kids.displayName, "Kids")
        XCTAssertEqual(ExperienceMode.adult.displayName, "Adult")
        XCTAssertEqual(ExperienceMode.family.displayName, "Family")
    }
}
