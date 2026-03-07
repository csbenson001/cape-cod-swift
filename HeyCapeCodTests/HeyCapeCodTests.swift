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

    func testBeachWeatherBoundaryConditions() {
        // Exactly at threshold: 72 degrees, 14.9 wind
        let borderline = CurrentWeather(
            temperature: 72,
            feelsLike: 72,
            condition: .partlyCloudy,
            humidity: 60,
            windSpeed: 14,
            windDirection: "S",
            uvIndex: 5,
            visibility: 10,
            pressure: 30.0,
            dewPoint: 58
        )
        XCTAssertTrue(borderline.isBeachWeather)

        // Just below threshold: 71 degrees
        let tooCold = CurrentWeather(
            temperature: 71,
            feelsLike: 71,
            condition: .clear,
            humidity: 50,
            windSpeed: 5,
            windDirection: "SW",
            uvIndex: 8,
            visibility: 10,
            pressure: 30.0,
            dewPoint: 55
        )
        XCTAssertFalse(tooCold.isBeachWeather)

        // Too windy: 15 mph
        let tooWindy = CurrentWeather(
            temperature: 85,
            feelsLike: 88,
            condition: .clear,
            humidity: 50,
            windSpeed: 15,
            windDirection: "NE",
            uvIndex: 9,
            visibility: 10,
            pressure: 30.0,
            dewPoint: 60
        )
        XCTAssertFalse(tooWindy.isBeachWeather)
    }

    func testWeatherConditionTypeProperties() {
        XCTAssertEqual(WeatherConditionType.clear.displayName, "Clear")
        XCTAssertEqual(WeatherConditionType.clear.icon, "sun.max.fill")
        XCTAssertEqual(WeatherConditionType.rain.displayName, "Rain")
        XCTAssertEqual(WeatherConditionType.thunderstorm.icon, "cloud.bolt.rain.fill")
        XCTAssertEqual(WeatherConditionType.allCases.count, 8)
    }

    func testWeatherDataStaleness() {
        let freshWeather = WeatherData(
            current: CurrentWeather(
                temperature: 75, feelsLike: 75, condition: .clear,
                humidity: 50, windSpeed: 10, windDirection: "SW",
                uvIndex: 6, visibility: 10, pressure: 30.0, dewPoint: 55
            ),
            hourly: [],
            daily: [],
            alerts: [],
            fetchedAt: .now
        )
        XCTAssertFalse(freshWeather.isStale)

        let staleWeather = WeatherData(
            current: freshWeather.current,
            hourly: [],
            daily: [],
            alerts: [],
            fetchedAt: Date.now.addingTimeInterval(-1801)
        )
        XCTAssertTrue(staleWeather.isStale)
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

    func testTideTypeProperties() {
        XCTAssertEqual(TideType.high.rawValue, "H")
        XCTAssertEqual(TideType.low.rawValue, "L")
        XCTAssertEqual(TideType.low.displayName, "Low Tide")
        XCTAssertEqual(TideType.high.icon, "arrow.up.to.line")
    }

    func testTideStationProperties() {
        XCTAssertEqual(TideStation.woodsHole.rawValue, "8447930")
        XCTAssertEqual(TideStation.hyannis.name, "Hyannis")
        XCTAssertEqual(TideStation.allCases.count, 7)
    }

    func testTideDataStatus() {
        let future = Date.now.addingTimeInterval(3600)
        let tideData = TideData(
            stationID: "8447930",
            stationName: "Woods Hole",
            predictions: [
                TidePrediction(time: future, height: 4.2, type: .high)
            ],
            fetchedAt: .now
        )

        XCTAssertNotNil(tideData.nextTide)
        XCTAssertEqual(tideData.currentTideStatus, .rising)
        XCTAssertFalse(tideData.isStale)
    }

    func testTideDataFalling() {
        let future = Date.now.addingTimeInterval(3600)
        let tideData = TideData(
            stationID: "8447930",
            stationName: "Woods Hole",
            predictions: [
                TidePrediction(time: future, height: 0.5, type: .low)
            ],
            fetchedAt: .now
        )
        XCTAssertEqual(tideData.currentTideStatus, .falling)
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

    func testTrafficRouteNoDelay() {
        let route = TrafficRoute(
            id: UUID(),
            name: "Bourne Bridge",
            origin: "Mainland",
            destination: "Cape Cod",
            currentTravelTime: 300,
            typicalTravelTime: 600,
            congestionLevel: .free,
            distance: 2.0
        )
        // Delay should be 0 (not negative) when current < typical
        XCTAssertEqual(route.delayMinutes, 0)
    }

    func testTrafficReportStaleness() {
        let freshReport = TrafficReport(
            routes: [],
            incidents: [],
            bridgeStatus: BridgeStatus(
                bourneBridge: .init(status: .open, delayMinutes: 0, lastUpdated: .now),
                sagamoreBridge: .init(status: .open, delayMinutes: 0, lastUpdated: .now)
            ),
            fetchedAt: .now
        )
        XCTAssertFalse(freshReport.isStale)

        let staleReport = TrafficReport(
            routes: [],
            incidents: [],
            bridgeStatus: freshReport.bridgeStatus,
            fetchedAt: Date.now.addingTimeInterval(-301)
        )
        XCTAssertTrue(staleReport.isStale)
    }

    func testTrafficLevelMapping() {
        XCTAssertEqual(TrafficLevel.clear.toCongestionLevel, .free)
        XCTAssertEqual(TrafficLevel.moderate.toCongestionLevel, .moderate)
        XCTAssertEqual(TrafficLevel.heavy.toCongestionLevel, .heavy)
        XCTAssertEqual(TrafficLevel.severe.toCongestionLevel, .severe)
    }

    func testTrafficLevelBridgeMapping() {
        XCTAssertEqual(TrafficLevel.clear.toBridgeConditionStatus, .open)
        XCTAssertEqual(TrafficLevel.moderate.toBridgeConditionStatus, .open)
        XCTAssertEqual(TrafficLevel.heavy.toBridgeConditionStatus, .restricted)
        XCTAssertEqual(TrafficLevel.severe.toBridgeConditionStatus, .restricted)
    }

    func testTrafficResponseToReport() {
        let response = TrafficResponse(
            bridges: .init(
                sagamore: .init(delayMinutes: 15, status: .heavy, direction: "both", lastUpdated: "2024-01-01"),
                bourne: .init(delayMinutes: 5, status: .moderate, direction: "both", lastUpdated: "2024-01-01")
            ),
            routes: .init(
                route6: .init(status: .clear, delayMinutes: 0),
                route3: .init(status: .moderate, delayMinutes: 10)
            ),
            recommendation: "Take the Bourne Bridge",
            updatedAt: "2024-01-01T00:00:00Z"
        )

        let report = response.toTrafficReport()
        XCTAssertEqual(report.routes.count, 4)
        XCTAssertEqual(report.routes[0].name, "Sagamore Bridge")
        XCTAssertEqual(report.routes[0].currentTravelTime, 900) // 15 * 60
        XCTAssertEqual(report.routes[0].congestionLevel, .heavy)
        XCTAssertEqual(report.routes[1].name, "Bourne Bridge")
        XCTAssertEqual(report.routes[1].currentTravelTime, 300) // 5 * 60
        XCTAssertEqual(report.bridgeStatus.sagamoreBridge.status, .restricted)
        XCTAssertEqual(report.bridgeStatus.bourneBridge.status, .open)
    }

    // MARK: - Geofence Tests

    func testGeofenceMaxRegions() {
        XCTAssertEqual(GeofenceManager.maxMonitoredRegions, 20)
    }

    func testStoryVariantDurationEstimate() {
        // "one two three four five" = 5 words / 2.5 = 2 seconds
        let story = StoryVariant(
            title: "Test Story",
            mode: .adult,
            script: "one two three four five"
        )
        XCTAssertEqual(story.duration, 2.0, accuracy: 0.01)
    }

    func testStoryVariantExplicitDuration() {
        let story = StoryVariant(
            title: "Test Story",
            mode: .kids,
            script: "short",
            duration: 120
        )
        XCTAssertEqual(story.duration, 120)
    }

    func testStoryVariantID() {
        let story = StoryVariant(
            title: "Lighthouse Tale",
            mode: .adult,
            script: "Once upon a time..."
        )
        XCTAssertEqual(story.id, "Lighthouse Tale-adult")
    }

    func testStoryModeProperties() {
        XCTAssertEqual(GeofenceManager.StoryMode.adult.displayName, "Adult")
        XCTAssertEqual(GeofenceManager.StoryMode.kids.displayName, "Kids")
        XCTAssertEqual(GeofenceManager.StoryMode.family.displayName, "Family")
        XCTAssertEqual(GeofenceManager.StoryMode.allCases.count, 3)
    }

    func testPointOfInterestEquality() {
        let poi1 = PointOfInterest(
            id: "test-1", name: "Test", coordinate: .init(latitude: 41.7, longitude: -70.3),
            geofenceRadius: 100, category: .beach, town: .barnstable,
            description: "Test POI", stories: [], facts: [], tips: [],
            imageSystemName: nil
        )
        let poi2 = PointOfInterest(
            id: "test-1", name: "Different Name", coordinate: .init(latitude: 42.0, longitude: -71.0),
            geofenceRadius: 200, category: .lighthouse, town: .provincetown,
            description: "Other", stories: [], facts: [], tips: [],
            imageSystemName: nil
        )
        XCTAssertEqual(poi1, poi2, "POIs with the same ID should be equal")
    }

    // MARK: - Paywall Tests

    func testPaywallFreeTierLimits() {
        XCTAssertEqual(PaywallManager.freeVoiceConversationsPerDay, 3)
        XCTAssertEqual(PaywallManager.freeStoriesPerDay, 5)
    }

    // MARK: - UserProfile Tests

    func testUserProfileCreation() {
        let profile = UserProfile(
            uid: "test-user-123",
            displayName: "Test User",
            email: "test@example.com"
        )
        XCTAssertEqual(profile.uid, "test-user-123")
        XCTAssertEqual(profile.displayName, "Test User")
        XCTAssertEqual(profile.email, "test@example.com")
        XCTAssertEqual(profile.authProvider, "guest")
        XCTAssertFalse(profile.isPremium)
        XCTAssertEqual(profile.conversationsToday, 0)
        XCTAssertEqual(profile.storiesPlayedToday, 0)
        XCTAssertEqual(profile.currentMode, ExperienceMode.adult.rawValue)
        XCTAssertEqual(profile.visitType, "tourist")
        XCTAssertTrue(profile.interests.isEmpty)
    }

    func testUserProfileExperienceMode() {
        let profile = UserProfile(uid: "test")
        XCTAssertEqual(profile.experienceMode, .adult)

        profile.experienceMode = .kids
        XCTAssertEqual(profile.currentMode, "kids")
        XCTAssertEqual(profile.experienceMode, .kids)

        profile.experienceMode = .family
        XCTAssertEqual(profile.currentMode, "family")
    }

    func testUserProfilePremiumStatus() {
        let profile = UserProfile(uid: "test")
        XCTAssertFalse(profile.premiumIsActive)

        profile.isPremium = true
        profile.premiumExpiresAt = Date.now.addingTimeInterval(86400) // tomorrow
        XCTAssertTrue(profile.premiumIsActive)

        profile.premiumExpiresAt = Date.now.addingTimeInterval(-86400) // yesterday
        XCTAssertFalse(profile.premiumIsActive)
    }

    func testUserProfileDailyCounterReset() {
        let profile = UserProfile(uid: "test")

        // Set counters to non-zero with today's date
        profile.conversationsToday = 5
        profile.storiesPlayedToday = 10
        profile.lastResetDate = Calendar.current.startOfDay(for: .now)

        // Should not reset (same day)
        profile.resetDailyCountersIfNeeded()
        XCTAssertEqual(profile.conversationsToday, 5)
        XCTAssertEqual(profile.storiesPlayedToday, 10)

        // Set to yesterday — should reset
        profile.lastResetDate = Calendar.current.startOfDay(for: Date.now.addingTimeInterval(-86400))
        profile.resetDailyCountersIfNeeded()
        XCTAssertEqual(profile.conversationsToday, 0)
        XCTAssertEqual(profile.storiesPlayedToday, 0)
    }

    func testUserProfileIncrementCounters() {
        let profile = UserProfile(uid: "test")
        profile.lastResetDate = Calendar.current.startOfDay(for: .now)

        profile.incrementConversations()
        XCTAssertEqual(profile.conversationsToday, 1)
        XCTAssertEqual(profile.totalConversations, 1)

        profile.incrementConversations()
        XCTAssertEqual(profile.conversationsToday, 2)
        XCTAssertEqual(profile.totalConversations, 2)

        profile.incrementStoriesPlayed()
        XCTAssertEqual(profile.storiesPlayedToday, 1)
        XCTAssertEqual(profile.totalStoriesPlayed, 1)
    }

    func testUserProfileFirestoreData() {
        let profile = UserProfile(
            uid: "test-123",
            displayName: "John Doe",
            email: "john@example.com"
        )
        profile.currentMode = "family"
        profile.interests = ["beaches", "history"]
        profile.isPremium = true

        let data = profile.toFirestoreData()

        XCTAssertEqual(data["uid"] as? String, "test-123")
        XCTAssertEqual(data["displayName"] as? String, "John Doe")
        XCTAssertEqual(data["email"] as? String, "john@example.com")
        XCTAssertEqual(data["currentMode"] as? String, "family")
        XCTAssertEqual(data["interests"] as? [String], ["beaches", "history"])
        XCTAssertEqual(data["isPremium"] as? Bool, true)
    }

    func testUserProfileUpdateFromFirestore() {
        let profile = UserProfile(uid: "test")

        let firestoreData: [String: Any] = [
            "displayName": "Updated Name",
            "currentMode": "teen",
            "visitType": "local",
            "interests": ["food", "nature"],
            "isPremium": true,
            "favoriteBeaches": ["Coast Guard Beach"],
        ]

        profile.updateFromFirestore(firestoreData)

        XCTAssertEqual(profile.displayName, "Updated Name")
        XCTAssertEqual(profile.currentMode, "teen")
        XCTAssertEqual(profile.visitType, "local")
        XCTAssertEqual(profile.interests, ["food", "nature"])
        XCTAssertTrue(profile.isPremium)
        XCTAssertEqual(profile.favoriteBeaches, ["Coast Guard Beach"])
        XCTAssertNotNil(profile.lastSyncedAt)
    }

    // MARK: - Audio Engine Tests

    func testAudioEngineConstants() {
        XCTAssertEqual(AudioEngine.sampleRate, 24_000)
        XCTAssertEqual(AudioEngine.channelCount, 1)
        XCTAssertEqual(AudioEngine.bytesPerSample, 2)
    }

    func testAudioEngineInitialState() {
        let engine = AudioEngine()
        XCTAssertFalse(engine.isRunning)
        XCTAssertFalse(engine.isSpeechDetected)
        XCTAssertEqual(engine.audioLevel, 0)
    }

    func testPCM16Base64Encoding() {
        // Verify that PCM16 data encodes to valid base64
        let sampleData = Data([0x00, 0x01, 0xFF, 0x7F]) // 2 PCM16 samples
        let base64 = sampleData.base64EncodedString()
        XCTAssertFalse(base64.isEmpty)

        // Verify round-trip
        let decoded = Data(base64Encoded: base64)
        XCTAssertEqual(decoded, sampleData)
    }

    func testPCM16ChunkSize() {
        // ~100ms at 24kHz = 2400 samples * 2 bytes = 4800 bytes
        let expectedChunkBytes = 2400 * 2
        XCTAssertEqual(expectedChunkBytes, 4800)
    }

    // MARK: - App State Tests

    func testAppTabProperties() {
        XCTAssertEqual(AppTab.home.title, "Home")
        XCTAssertEqual(AppTab.explore.icon, "safari.fill")
        XCTAssertEqual(AppTab.allCases.count, 5)
    }

    func testAppTabAllCases() {
        let tabs = AppTab.allCases
        XCTAssertEqual(tabs[0], .home)
        XCTAssertEqual(tabs[1], .explore)
        XCTAssertEqual(tabs[2], .weather)
        XCTAssertEqual(tabs[3], .traffic)
        XCTAssertEqual(tabs[4], .settings)
    }

    func testAppErrorDescriptions() {
        XCTAssertNotNil(AppError.networkUnavailable.errorDescription)
        XCTAssertNotNil(AppError.locationDenied.errorDescription)
        XCTAssertNotNil(AppError.microphoneDenied.errorDescription)
        XCTAssertNotNil(AppError.apiError("test").errorDescription)
    }

    func testAppStateInitialValues() {
        let state = AppState()
        XCTAssertEqual(state.selectedTab, .home)
        XCTAssertFalse(state.isVoiceAssistantPresented)
        XCTAssertNil(state.currentError)
        XCTAssertFalse(state.showingError)
        XCTAssertFalse(state.isListening)
    }

    func testAppStateErrorPresentation() {
        let state = AppState()
        XCTAssertFalse(state.showingError)

        state.presentError(.networkUnavailable)
        XCTAssertTrue(state.showingError)
        XCTAssertNotNil(state.currentError)

        state.showingError = false
        XCTAssertNil(state.currentError)
    }

    // MARK: - Auth Error Tests

    func testAuthErrorDescriptions() {
        XCTAssertNotNil(AuthError.appleSignInFailed.errorDescription)
        XCTAssertNotNil(AuthError.invalidCredentials.errorDescription)
        XCTAssertNotNil(AuthError.weakPassword.errorDescription)
        XCTAssertNotNil(AuthError.emailNotVerified.errorDescription)
        XCTAssertNotNil(AuthError.accountExists.errorDescription)
        XCTAssertNotNil(AuthError.signInFailed("test").errorDescription)
    }

    func testAuthUserTokenExpiry() {
        let expired = AuthManager.AuthUser(
            uid: "test", email: nil, displayName: nil, photoURL: nil,
            provider: .apple, isGuest: false,
            idToken: "token", refreshToken: nil,
            tokenExpiresAt: Date.now.addingTimeInterval(-120) // 2 minutes ago
        )
        XCTAssertTrue(expired.isTokenExpired)

        let valid = AuthManager.AuthUser(
            uid: "test", email: nil, displayName: nil, photoURL: nil,
            provider: .apple, isGuest: false,
            idToken: "token", refreshToken: nil,
            tokenExpiresAt: Date.now.addingTimeInterval(3600) // 1 hour from now
        )
        XCTAssertFalse(valid.isTokenExpired)

        // Token expiring within 60s buffer should be treated as expired
        let almostExpired = AuthManager.AuthUser(
            uid: "test", email: nil, displayName: nil, photoURL: nil,
            provider: .apple, isGuest: false,
            idToken: "token", refreshToken: nil,
            tokenExpiresAt: Date.now.addingTimeInterval(30) // 30s from now, within 60s buffer
        )
        XCTAssertTrue(almostExpired.isTokenExpired)
    }

    // MARK: - Location Model Tests

    func testAllTownsCovered() {
        XCTAssertEqual(CapeCodTown.allCases.count, 15)
    }

    func testAllRegionsCovered() {
        XCTAssertEqual(CapeRegion.allCases.count, 4)
    }

    func testLocationCategoryAllCases() {
        XCTAssertEqual(LocationCategory.allCases.count, 10)
    }

    func testCodLocationCoordinate() {
        let location = CodLocation(
            name: "Test", latitude: 41.7, longitude: -70.3,
            category: .beach, town: .barnstable
        )
        XCTAssertEqual(location.coordinate.latitude, 41.7, accuracy: 0.001)
        XCTAssertEqual(location.coordinate.longitude, -70.3, accuracy: 0.001)
    }

    // MARK: - Interest Enum Tests

    func testInterestAllCases() {
        XCTAssertEqual(Interest.allCases.count, 10)
    }

    func testInterestProperties() {
        XCTAssertEqual(Interest.beaches.displayName, "Beaches")
        XCTAssertFalse(Interest.beaches.icon.isEmpty)
        XCTAssertEqual(Interest.history.displayName, "History")
    }

    // MARK: - Congestion Level Tests

    func testCongestionLevelDisplayNames() {
        XCTAssertEqual(CongestionLevel.free.displayName, "Free")
        XCTAssertEqual(CongestionLevel.severe.displayName, "Severe")
    }

    func testBridgeConditionStatus() {
        XCTAssertEqual(BridgeStatus.BridgeCondition.Status.open.displayName, "Open")
        XCTAssertEqual(BridgeStatus.BridgeCondition.Status.closed.displayName, "Closed")
        XCTAssertEqual(BridgeStatus.BridgeCondition.Status.restricted.displayName, "Restricted")
    }
}
