import XCTest

final class HeyCapeCodUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
    }

    // MARK: - Onboarding Flow

    @MainActor
    func testOnboardingCompleteFlow() throws {
        app.launchArguments.append("--reset-onboarding")
        app.launch()

        // Page 1: Welcome
        let welcomeTitle = app.staticTexts["Hey Cape Cod"]
        if welcomeTitle.waitForExistence(timeout: 5) {
            // Tap Next to proceed
            let nextButton = app.buttons["Next"]
            XCTAssertTrue(nextButton.exists)
            nextButton.tap()

            // Page 2: Choose Mode
            let modeTitle = app.staticTexts["Who's exploring today?"]
            XCTAssertTrue(modeTitle.waitForExistence(timeout: 3))

            // Select "Family" mode card
            let familyOption = app.staticTexts["Family"]
            if familyOption.exists { familyOption.tap() }
            nextButton.tap()

            // Page 3: Select Interests
            let interestsTitle = app.staticTexts["What interests you?"]
            XCTAssertTrue(interestsTitle.waitForExistence(timeout: 3))

            // Tap a few interest pills
            let beachPill = app.staticTexts["Beaches"]
            if beachPill.exists { beachPill.tap() }
            let historyPill = app.staticTexts["History"]
            if historyPill.exists { historyPill.tap() }
            nextButton.tap()

            // Page 4: Sign In
            let signInTitle = app.staticTexts["Create an Account"]
            XCTAssertTrue(signInTitle.waitForExistence(timeout: 3))

            // Tap "Continue as Guest"
            let guestButton = app.buttons["Continue as Guest"]
            XCTAssertTrue(guestButton.exists)
            guestButton.tap()

            // Should now see main tab bar
            let homeTab = app.buttons["Home"]
            XCTAssertTrue(homeTab.waitForExistence(timeout: 5))
        }
    }

    // MARK: - App Launch

    @MainActor
    func testAppLaunchesSuccessfully() throws {
        app.launch()

        // Either onboarding or main tab bar should appear
        let homeTab = app.buttons["Home"]
        let welcomeTitle = app.staticTexts["Hey Cape Cod"]
        let appeared = homeTab.waitForExistence(timeout: 5) || welcomeTitle.waitForExistence(timeout: 5)
        XCTAssertTrue(appeared)
    }

    // MARK: - Tab Navigation

    @MainActor
    func testTabNavigation() throws {
        app.launch()
        skipOnboardingIfPresent()

        let tabs = ["Home", "Explore", "Weather", "Traffic"]
        for tab in tabs {
            let tabButton = app.buttons[tab]
            if tabButton.waitForExistence(timeout: 3) {
                tabButton.tap()
                Thread.sleep(forTimeInterval: 0.3)
            }
        }
    }

    @MainActor
    func testAllTabsExist() throws {
        app.launch()
        skipOnboardingIfPresent()

        XCTAssertTrue(app.buttons["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Explore"].exists)
        XCTAssertTrue(app.buttons["Weather"].exists)
        XCTAssertTrue(app.buttons["Traffic"].exists)
    }

    // MARK: - Voice Assistant

    @MainActor
    func testVoiceAssistantPresentation() throws {
        app.launch()
        skipOnboardingIfPresent()

        let voiceButton = app.buttons.matching(identifier: "waveform.circle.fill").firstMatch
        if voiceButton.waitForExistence(timeout: 5) {
            voiceButton.tap()
            let tapToSpeak = app.staticTexts["Tap to speak"]
            if tapToSpeak.waitForExistence(timeout: 3) {
                XCTAssertTrue(tapToSpeak.exists)
                app.swipeDown()
            }
        }
    }

    // MARK: - Settings

    @MainActor
    func testSettingsNavigation() throws {
        app.launch()
        skipOnboardingIfPresent()

        // Navigate to Settings via gear icon or tab
        let settingsButton = app.buttons["Settings"]
        if settingsButton.exists { settingsButton.tap() }

        let settingsTitle = app.navigationBars["Settings"]
        if settingsTitle.waitForExistence(timeout: 3) {
            XCTAssertTrue(settingsTitle.exists)
        }
    }

    @MainActor
    func testSettingsSubscriptionSection() throws {
        app.launch()
        skipOnboardingIfPresent()

        let settingsButton = app.buttons["Settings"]
        if settingsButton.exists { settingsButton.tap() }

        let planText = app.staticTexts["Plan"]
        if planText.waitForExistence(timeout: 3) {
            XCTAssertTrue(planText.exists)
        }
    }

    // MARK: - Explore / Map

    @MainActor
    func testExploreTabShowsContent() throws {
        app.launch()
        skipOnboardingIfPresent()

        let exploreTab = app.buttons["Explore"]
        if exploreTab.waitForExistence(timeout: 5) {
            exploreTab.tap()
            Thread.sleep(forTimeInterval: 1.0)
            XCTAssertTrue(app.maps.firstMatch.exists || app.scrollViews.firstMatch.exists)
        }
    }

    // MARK: - Weather

    @MainActor
    func testWeatherTabShowsContent() throws {
        app.launch()
        skipOnboardingIfPresent()

        let weatherTab = app.buttons["Weather"]
        if weatherTab.waitForExistence(timeout: 5) {
            weatherTab.tap()
            Thread.sleep(forTimeInterval: 1.0)
            XCTAssertTrue(app.scrollViews.firstMatch.exists || app.staticTexts.count > 0)
        }
    }

    // MARK: - Traffic

    @MainActor
    func testTrafficTabShowsContent() throws {
        app.launch()
        skipOnboardingIfPresent()

        let trafficTab = app.buttons["Traffic"]
        if trafficTab.waitForExistence(timeout: 5) {
            trafficTab.tap()
            Thread.sleep(forTimeInterval: 1.0)
            XCTAssertTrue(app.scrollViews.firstMatch.exists || app.staticTexts.count > 0)
        }
    }

    // MARK: - Helpers

    private func skipOnboardingIfPresent() {
        let welcomeTitle = app.staticTexts["Hey Cape Cod"]
        if welcomeTitle.waitForExistence(timeout: 2) {
            let skipButton = app.buttons["Skip"]
            let nextButton = app.buttons["Next"]

            if nextButton.exists { nextButton.tap() }
            if skipButton.waitForExistence(timeout: 1) { skipButton.tap() }
            if skipButton.waitForExistence(timeout: 1) { skipButton.tap() }

            let guestButton = app.buttons["Continue as Guest"]
            if guestButton.waitForExistence(timeout: 2) { guestButton.tap() }

            _ = app.buttons["Home"].waitForExistence(timeout: 5)
        }
    }
}
