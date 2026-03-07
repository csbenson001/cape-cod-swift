import XCTest
@testable import HeyCapeCod

final class HeyCapeCodTests: XCTestCase {

    // MARK: - Model Tests

    func testConversationCreation() {
        let conversation = Conversation(title: "Beach Recommendations")
        XCTAssertEqual(conversation.title, "Beach Recommendations")
        XCTAssertTrue(conversation.messages.isEmpty)
        XCTAssertTrue(conversation.isActive)
    }

    func testMessageCreation() {
        let userMsg = Message.user("Best beaches?")
        XCTAssertEqual(userMsg.role, .user)
        XCTAssertEqual(userMsg.content, "Best beaches?")

        let assistantMsg = Message.assistant("Try Nauset Light Beach!")
        XCTAssertEqual(assistantMsg.role, .assistant)
    }

    func testConversationSummary() {
        var conversation = Conversation()
        conversation.messages.append(.user("Tell me about Provincetown"))
        XCTAssertEqual(conversation.summary, "Tell me about Provincetown")
    }

    // MARK: - Location Tests

    func testLocationCategory() {
        let beach = CodLocation(
            name: "Coast Guard Beach",
            latitude: 41.8398,
            longitude: -69.9508,
            category: .beach,
            town: .eastham
        )
        XCTAssertEqual(beach.category.displayName, "Beaches")
        XCTAssertEqual(beach.town.region, .outerCape)
    }

    func testCapeCodTownRegions() {
        XCTAssertEqual(CapeCodTown.sandwich.region, .upperCape)
        XCTAssertEqual(CapeCodTown.barnstable.region, .midCape)
        XCTAssertEqual(CapeCodTown.chatham.region, .lowerCape)
        XCTAssertEqual(CapeCodTown.provincetown.region, .outerCape)
    }

    // MARK: - Story Tests

    func testStoryDurationFormatting() {
        let story = Story(
            title: "Nauset Lighthouse History",
            content: "Built in 1877...",
            duration: 185
        )
        XCTAssertEqual(story.formattedDuration, "3:05")
    }

    // MARK: - Weather Tests

    func testBeachWeatherCondition() {
        let beachDay = CurrentWeather(
            temperature: 78,
            feelsLike: 80,
            condition: .clear,
            humidity: 55,
            windSpeed: 8,
            windDirection: "SW",
            uvIndex: 7,
            visibility: 10,
            pressure: 30.1,
            dewPoint: 62
        )
        XCTAssertTrue(beachDay.isBeachWeather)

        let rainyDay = CurrentWeather(
            temperature: 58,
            feelsLike: 55,
            condition: .rain,
            humidity: 90,
            windSpeed: 20,
            windDirection: "NE",
            uvIndex: 1,
            visibility: 3,
            pressure: 29.8,
            dewPoint: 55
        )
        XCTAssertFalse(rainyDay.isBeachWeather)
    }

    // MARK: - Tide Tests

    func testTidePredictionFormatting() {
        let prediction = TidePrediction(
            time: Date(timeIntervalSince1970: 1700000000),
            height: 3.7,
            type: .high
        )
        XCTAssertEqual(prediction.heightFormatted, "3.7 ft")
        XCTAssertEqual(prediction.type.displayName, "High Tide")
    }

    // MARK: - Traffic Tests

    func testTrafficRouteDelay() {
        let route = TrafficRoute(
            id: UUID(),
            name: "Sagamore Bridge",
            origin: "Plymouth",
            destination: "Bourne",
            currentTravelTime: 1800,
            typicalTravelTime: 600,
            congestionLevel: .heavy,
            distance: 5.0
        )
        XCTAssertEqual(route.delayMinutes, 20)
        XCTAssertEqual(route.travelTimeFormatted, "30 min")
    }

    func testTrafficTravelTimeFormatting() {
        let longRoute = TrafficRoute(
            id: UUID(),
            name: "Route 6",
            origin: "Bourne",
            destination: "Provincetown",
            currentTravelTime: 5400,
            typicalTravelTime: 3600,
            congestionLevel: .moderate,
            distance: 60.0
        )
        XCTAssertEqual(longRoute.travelTimeFormatted, "1h 30m")
    }

    // MARK: - App State Tests

    func testAppTabProperties() {
        XCTAssertEqual(AppTab.home.title, "Home")
        XCTAssertEqual(AppTab.explore.icon, "safari.fill")
        XCTAssertEqual(AppTab.allCases.count, 5)
    }
}
