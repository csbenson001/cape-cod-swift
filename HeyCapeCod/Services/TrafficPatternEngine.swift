import Foundation

// MARK: - Traffic Pattern Engine

/// Predicts Cape Cod bridge traffic using hardcoded historical patterns.
/// Patterns reflect well-established, year-over-year trends for the
/// Bourne and Sagamore bridges.
enum TrafficPatternEngine {

    // MARK: - Types

    enum Bridge: String, CaseIterable, Identifiable {
        case sagamore = "Sagamore"
        case bourne = "Bourne"
        case either = "Either"

        var id: String { rawValue }
    }

    enum Direction: String, CaseIterable, Identifiable {
        case boston = "Boston"
        case providence = "Providence"
        case newYork = "New York"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .boston: "arrow.up.right"
            case .providence: "arrow.right"
            case .newYork: "arrow.down.right"
            }
        }

        /// Preferred bridge for this destination
        var preferredBridge: Bridge {
            switch self {
            case .boston: .sagamore
            case .providence: .bourne
            case .newYork: .bourne
            }
        }
    }

    enum TrafficSeverity: Int, Comparable {
        case clear = 0
        case light = 1
        case moderate = 2
        case heavy = 3
        case severe = 4

        static func < (lhs: TrafficSeverity, rhs: TrafficSeverity) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        var label: String {
            switch self {
            case .clear: "Clear"
            case .light: "Light"
            case .moderate: "Moderate"
            case .heavy: "Heavy"
            case .severe: "Severe"
            }
        }
    }

    struct TrafficPrediction {
        let expectedDelay: Int      // minutes
        let confidence: Double      // 0.0–1.0
        let recommendation: String
        let severity: TrafficSeverity
    }

    struct HourlyPrediction: Identifiable {
        let id = UUID()
        let hour: Int
        let expectedDelay: Int
        let severity: TrafficSeverity

        var hourLabel: String {
            let period = hour >= 12 ? "PM" : "AM"
            let display = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
            return "\(display)\(period)"
        }
    }

    // MARK: - Public API

    static func predictDelay(
        date: Date,
        hour: Int,
        bridge: Bridge,
        direction: Direction
    ) -> TrafficPrediction {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date) // 1=Sun, 7=Sat
        let month = cal.component(.month, from: date)
        let isSummer = (6...9).contains(month)
        let isHoliday = Self.isHolidayWeekend(date)

        var delay = baseDelay(hour: hour, weekday: weekday, isSummer: isSummer, isHoliday: isHoliday)

        // Bridge-specific adjustments
        if bridge == .bourne && weekday == 6 { delay = max(0, delay - 5) }
        if bridge == .sagamore && weekday == 1 { delay = max(0, delay - 5) }

        // Direction multiplier for off-Cape
        if direction == .newYork { delay = Int(Double(delay) * 1.1) }

        let severity = Self.severity(for: delay)
        let confidence = isHoliday ? 0.7 : (isSummer ? 0.8 : 0.85)
        let rec = recommendation(delay: delay, hour: hour, severity: severity)

        return TrafficPrediction(
            expectedDelay: delay,
            confidence: confidence,
            recommendation: rec,
            severity: severity
        )
    }

    static func optimalDepartureWindow(
        date: Date,
        direction: Direction
    ) -> (start: Date, end: Date, expectedDelay: Int) {
        let predictions = generateHourlyPredictions(date: date, direction: direction)
        let cal = Calendar.current

        // Find the window with the lowest delay between 6AM-10PM
        let bestHour = predictions.min(by: { $0.expectedDelay < $1.expectedDelay })
        let bestDelay = bestHour?.expectedDelay ?? 0

        // Find contiguous low-delay window around best hour
        let threshold = max(15, bestDelay + 10)
        let lowDelayHours = predictions.filter { $0.expectedDelay <= threshold }

        guard let first = lowDelayHours.first, let last = lowDelayHours.last else {
            let noon = cal.date(bySettingHour: 6, minute: 0, second: 0, of: date)!
            return (noon, cal.date(byAdding: .hour, value: 2, to: noon)!, bestDelay)
        }

        let startDate = cal.date(bySettingHour: first.hour, minute: 0, second: 0, of: date)!
        let endDate = cal.date(bySettingHour: last.hour, minute: 59, second: 0, of: date)!

        return (startDate, endDate, bestDelay)
    }

    static func generateHourlyPredictions(
        date: Date,
        direction: Direction
    ) -> [HourlyPrediction] {
        (6...22).map { hour in
            let prediction = predictDelay(
                date: date,
                hour: hour,
                bridge: direction.preferredBridge,
                direction: direction
            )
            return HourlyPrediction(
                hour: hour,
                expectedDelay: prediction.expectedDelay,
                severity: prediction.severity
            )
        }
    }

    // MARK: - Base Delay Patterns

    private static func baseDelay(hour: Int, weekday: Int, isSummer: Bool, isHoliday: Bool) -> Int {
        var delay: Int

        if isHoliday {
            delay = holidayDelay(hour: hour)
        } else {
            switch weekday {
            case 6: delay = fridayDelay(hour: hour)     // Friday
            case 7: delay = saturdayDelay(hour: hour)   // Saturday
            case 1: delay = sundayDelay(hour: hour)     // Sunday
            case 2: delay = mondayDelay(hour: hour)     // Monday
            default: delay = weekdayDelay(hour: hour)   // Tue-Thu
            }
        }

        // Summer multiplier
        if isSummer && !isHoliday {
            delay = Int(Double(delay) * 1.4)
        }

        return delay
    }

    private static func fridayDelay(hour: Int) -> Int {
        switch hour {
        case 6...8: return 5
        case 9...11: return 15
        case 12...13: return 30
        case 14...15: return 60
        case 16...17: return 90
        case 18...19: return 60
        case 20...21: return 20
        default: return 0
        }
    }

    private static func saturdayDelay(hour: Int) -> Int {
        switch hour {
        case 6...7: return 5
        case 8...9: return 15
        case 10...11: return 35
        case 12...13: return 25
        case 14...17: return 15
        case 18...21: return 10
        default: return 0
        }
    }

    private static func sundayDelay(hour: Int) -> Int {
        switch hour {
        case 6...9: return 5
        case 10...12: return 20
        case 13...14: return 45
        case 15...16: return 75
        case 17...18: return 55
        case 19...20: return 25
        case 21...22: return 10
        default: return 0
        }
    }

    private static func mondayDelay(hour: Int) -> Int {
        switch hour {
        case 7...9: return 15
        case 10...11: return 30
        case 12...13: return 40
        case 14...15: return 30
        case 16...18: return 20
        default: return 5
        }
    }

    private static func weekdayDelay(hour: Int) -> Int {
        switch hour {
        case 7...8: return 15
        case 9...15: return 5
        case 16...17: return 15
        default: return 0
        }
    }

    private static func holidayDelay(hour: Int) -> Int {
        switch hour {
        case 6...7: return 20
        case 8...9: return 45
        case 10...11: return 90
        case 12...13: return 120
        case 14...15: return 110
        case 16...17: return 90
        case 18...19: return 60
        case 20...21: return 30
        default: return 10
        }
    }

    // MARK: - Helpers

    private static func severity(for delay: Int) -> TrafficSeverity {
        switch delay {
        case 0..<5: return .clear
        case 5..<15: return .light
        case 15..<30: return .moderate
        case 30..<60: return .heavy
        default: return .severe
        }
    }

    private static func recommendation(delay: Int, hour: Int, severity: TrafficSeverity) -> String {
        switch severity {
        case .clear: return "Clear sailing \u{2014} no delays expected."
        case .light: return "Light traffic, smooth crossing."
        case .moderate: return "Some slowdowns expected. Allow extra time."
        case .heavy: return "Expect significant delays. Consider adjusting departure."
        case .severe: return "Severe congestion. Delay departure if possible."
        }
    }

    static func isHolidayWeekend(_ date: Date) -> Bool {
        let cal = Calendar.current
        let month = cal.component(.month, from: date)
        let day = cal.component(.day, from: date)
        let weekday = cal.component(.weekday, from: date)

        // Memorial Day weekend
        if month == 5 && day >= 25 && weekday >= 6 { return true }
        if month == 5 && day >= 26 && weekday == 1 { return true }

        // July 4th weekend
        if month == 7 && (2...5).contains(day) { return true }

        // Labor Day weekend
        if month == 9 && day <= 7 {
            if weekday >= 6 || weekday <= 2 { return true }
        }

        return false
    }
}
