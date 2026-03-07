import XCTest

final class HeyCapeCodUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunchesSuccessfully() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify main tab bar is visible
        XCTAssertTrue(app.buttons["Home"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testTabNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate through tabs
        let tabs = ["Home", "Explore", "Weather", "Traffic"]
        for tab in tabs {
            if app.buttons[tab].exists {
                app.buttons[tab].tap()
            }
        }
    }

    @MainActor
    func testVoiceAssistantPresentation() throws {
        let app = XCUIApplication()
        app.launch()

        // Tap the center voice button
        let voiceButton = app.buttons.matching(identifier: "waveform.circle.fill").firstMatch
        if voiceButton.exists {
            voiceButton.tap()
            // Voice assistant sheet should appear
            XCTAssertTrue(app.staticTexts["Tap to speak"].waitForExistence(timeout: 3))
        }
    }
}
