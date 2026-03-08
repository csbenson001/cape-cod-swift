import AppIntents
import Foundation

// MARK: - Ask Cape Cod Intent

/// Siri Shortcut: "Hey Siri, ask Cape Cod about traffic"
struct AskCapeCodIntent: AppIntent {
    static let title: LocalizedStringResource = "Ask Cape Cod"
    static let description =IntentDescription("Ask your AI Cape Cod guide a question")
    static let openAppWhenRun =true

    @Parameter(title: "Question")
    var question: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Route the question through ChatService
        let response = await ChatService.shared.sendMessage(
            question,
            mode: .adult,
            location: nil
        )

        let answer = response ?? "I'm not sure about that. Try asking me in the app!"
        return .result(dialog: "\(answer)")
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Ask Cape Cod \(\.$question)")
    }
}

// MARK: - Check Traffic Intent

/// Siri Shortcut: "Hey Siri, check Cape Cod traffic"
struct CheckTrafficIntent: AppIntent {
    static let title: LocalizedStringResource = "Check Cape Cod Traffic"
    static let description =IntentDescription("Get current bridge and traffic conditions")
    static let openAppWhenRun =false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let service = TrafficService()
        do {
            let report = try await service.fetchTrafficReport()
            let sagamore = report.bridgeStatus.sagamoreBridge
            let bourne = report.bridgeStatus.bourneBridge

            let summary = """
            Sagamore Bridge: \(sagamore.status.displayName)\
            \(sagamore.delayMinutes > 0 ? ", \(sagamore.delayMinutes) min delay" : ""). \
            Bourne Bridge: \(bourne.status.displayName)\
            \(bourne.delayMinutes > 0 ? ", \(bourne.delayMinutes) min delay" : "").
            """
            return .result(dialog: "\(summary)")
        } catch {
            return .result(dialog: "Unable to check traffic right now. Please try again later.")
        }
    }
}

// MARK: - Check Tides Intent

/// Siri Shortcut: "Hey Siri, check Cape Cod tides"
struct CheckTidesIntent: AppIntent {
    static let title: LocalizedStringResource = "Check Cape Cod Tides"
    static let description =IntentDescription("Get current tide information")
    static let openAppWhenRun =false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let service = WeatherService()
        await service.fetchTides()

        guard let next = service.tides.first(where: { $0.time > .now }) else {
            return .result(dialog: "Tide data is currently unavailable.")
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let summary = "Next \(next.type.displayName.lowercased()) at \(formatter.string(from: next.time)), height \(next.heightFormatted)."
        return .result(dialog: "\(summary)")
    }
}

// MARK: - App Shortcuts Provider

struct HeyCapeCodShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
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

        AppShortcut(
            intent: CheckTrafficIntent(),
            phrases: [
                "Check \(.applicationName) traffic",
                "\(.applicationName) bridge traffic",
                "How's the \(.applicationName) traffic",
            ],
            shortTitle: "Check Traffic",
            systemImageName: "car.fill"
        )

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
    }
}
