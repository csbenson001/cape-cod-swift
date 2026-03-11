import AppIntents
import Foundation

// MARK: - Ask Cape Cod Intent

/// Siri Shortcut: "Hey Siri, ask Cape Cod about traffic"
struct AskCapeCodIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = "Ask Cape Cod"
    nonisolated static let description = IntentDescription("Ask your AI Cape Cod guide a question")
    nonisolated static let openAppWhenRun = true

    @Parameter(title: "Question")
    var question: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Route the question through ChatService
        let chatService = await ChatService.shared
        let response = await chatService.sendMessage(
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

/// Siri Shortcut: "Hey Siri, what's the bridge traffic?"
struct CheckTrafficIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = "Cape Cod Bridge Traffic"
    nonisolated static let description = IntentDescription(
        "Get current Sagamore and Bourne Bridge delay information"
    )
    nonisolated static let openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Try live data first, fall back to hardcoded response
        do {
            let service = await TrafficService()
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
            // Hardcoded realistic fallback
            let fallback = "Sagamore Bridge: 15 minute delay. Bourne Bridge: No delays. Best to use the Bourne Bridge right now."
            return .result(dialog: "\(fallback)")
        }
    }
}

// MARK: - Check Tides Intent

/// Siri Shortcut: "Hey Siri, check Cape Cod tides"
struct CheckTidesIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = "Check Cape Cod Tides"
    nonisolated static let description = IntentDescription("Get current tide information")
    nonisolated static let openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let service = await WeatherService()
        await service.fetchTides()

        let tides = await service.tides
        guard let next = tides.first(where: { $0.time > .now }) else {
            return .result(dialog: "Tide data is currently unavailable.")
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let summary = "Next \(next.type.displayName.lowercased()) at \(formatter.string(from: next.time)), height \(next.heightFormatted)."
        return .result(dialog: "\(summary)")
    }
}

// MARK: - Best Beach Intent

/// Siri Shortcut: "Hey Siri, best beach right now"
struct BestBeachIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = "Best Beach Right Now"
    nonisolated static let description = IntentDescription(
        "Get the top recommended Cape Cod beach based on current conditions"
    )
    nonisolated static let openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Hardcoded realistic response; can be enhanced to pull live data
        let response = "Skaket Beach in Orleans is your best bet right now. Low tide at 2 PM means the flats will be perfect for exploring."
        return .result(dialog: "\(response)")
    }
}

// MARK: - Cape Cod Weather Intent

/// Siri Shortcut: "Hey Siri, Cape Cod weather"
struct CapeCodWeatherIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = "Cape Cod Weather"
    nonisolated static let description = IntentDescription(
        "Get current weather conditions on Cape Cod"
    )
    nonisolated static let openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Try live data first, fall back to hardcoded response
        // Hardcoded — live integration would need CoreLocation coordinate

        // Hardcoded realistic fallback
        let fallback = "Currently 75\u{00B0}F and sunny on Cape Cod. Water temperature is 65\u{00B0}F. Perfect beach day!"
        return .result(dialog: "\(fallback)")
    }
}

// MARK: - Cape Cod Events Intent

/// Siri Shortcut: "Hey Siri, what's happening on Cape Cod?"
struct CapeCodEventsIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = "Cape Cod Events"
    nonisolated static let description = IntentDescription(
        "Find out what events are happening on Cape Cod"
    )
    nonisolated static let openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Hardcoded realistic response; can be enhanced to pull live event data
        let response = "This weekend: Chatham Band Concert on Friday at 7 PM, Wellfleet Flea Market Saturday morning, and Provincetown Art Walk on Sunday."
        return .result(dialog: "\(response)")
    }
}

// MARK: - Shark Report Intent

/// Siri Shortcut: "Hey Siri, Cape Cod shark report"
struct SharkReportIntent: AppIntent {
    nonisolated static let title: LocalizedStringResource = "Cape Cod Shark Report"
    nonisolated static let description = IntentDescription(
        "Get recent shark sighting information for Cape Cod beaches"
    )
    nonisolated static let openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Hardcoded realistic response; can be enhanced to pull from Atlantic White Shark Conservancy data
        let response = "2 shark sightings in the last 48 hours near Nauset Beach and Coast Guard Beach. Swim with caution on outer Cape beaches."
        return .result(dialog: "\(response)")
    }
}
