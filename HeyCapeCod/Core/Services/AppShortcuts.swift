import AppIntents

// MARK: - App Shortcuts Provider

/// Registers all Hey Cape Cod Siri Shortcuts with the system.
/// Users can discover these in the Shortcuts app or invoke them via Siri.
struct HeyCapeCodShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // MARK: Ask Cape Cod (free-form AI question)
        AppShortcut(
            intent: AskCapeCodIntent(),
            phrases: [
                "Ask \(.applicationName) about \(\.$question)",
                "Ask \(.applicationName) \(\.$question)",
                "Hey \(.applicationName) \(\.$question)",
            ],
            shortTitle: "Ask Cape Cod",
            systemImageName: "mic.fill"
        )

        // MARK: Bridge Traffic
        AppShortcut(
            intent: CheckTrafficIntent(),
            phrases: [
                "\(.applicationName) traffic",
                "Bridge traffic on \(.applicationName)",
                "What's the bridge traffic on \(.applicationName)",
                "How's \(.applicationName) traffic",
            ],
            shortTitle: "Bridge Traffic",
            systemImageName: "car.fill"
        )

        // MARK: Tides
        AppShortcut(
            intent: CheckTidesIntent(),
            phrases: [
                "Check \(.applicationName) tides",
                "\(.applicationName) tide times",
                "When is the next tide on \(.applicationName)",
            ],
            shortTitle: "Check Tides",
            systemImageName: "water.waves"
        )

        // MARK: Best Beach
        AppShortcut(
            intent: BestBeachIntent(),
            phrases: [
                "Best beach right now on \(.applicationName)",
                "Which beach should I go to on \(.applicationName)",
                "\(.applicationName) best beach",
            ],
            shortTitle: "Best Beach",
            systemImageName: "beach.umbrella"
        )

        // MARK: Weather
        AppShortcut(
            intent: CapeCodWeatherIntent(),
            phrases: [
                "\(.applicationName) weather",
                "Weather on \(.applicationName)",
                "What's the weather on \(.applicationName)",
            ],
            shortTitle: "Cape Cod Weather",
            systemImageName: "sun.max.fill"
        )

        // MARK: Events
        AppShortcut(
            intent: CapeCodEventsIntent(),
            phrases: [
                "What's happening on \(.applicationName)",
                "\(.applicationName) events",
                "Things to do on \(.applicationName)",
            ],
            shortTitle: "Cape Cod Events",
            systemImageName: "calendar"
        )

        // MARK: Shark Report
        AppShortcut(
            intent: SharkReportIntent(),
            phrases: [
                "\(.applicationName) shark report",
                "Any shark sightings on \(.applicationName)",
                "Shark sightings near \(.applicationName)",
            ],
            shortTitle: "Shark Report",
            systemImageName: "exclamationmark.triangle.fill"
        )
    }
}
