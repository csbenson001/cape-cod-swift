import Foundation

/// Tide response from the backend API (/api/weather/tides).
struct TideAPIResponse: Codable {
    let predictions: [TideAPIEntry]
    let station: String
}

struct TideAPIEntry: Codable, Identifiable {
    let time: String
    let height: Double
    let type: String? // "H" for high, "L" for low

    var id: String { time }

    /// Convert to the existing TidePrediction model
    func toTidePrediction() -> TidePrediction? {
        guard let date = ISO8601DateFormatter().date(from: time)
                ?? DateFormatter.tideFormatter.date(from: time) else { return nil }
        let tideType: TideType = (type == "H") ? .high : .low
        return TidePrediction(time: date, height: height, type: tideType)
    }
}

private extension DateFormatter {
    static let tideFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        f.timeZone = TimeZone(identifier: "America/New_York")
        return f
    }()
}
