import Foundation

@preconcurrency @MainActor
protocol TideServiceProtocol: Sendable {
    func fetchTides(station: TideStation, date: Date) async throws -> TideData
}

@preconcurrency @MainActor
@Observable
final class TideService: TideServiceProtocol {
    private let session: URLSession
    private let baseURL = "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter"
    private var cache: [String: TideData] = [:]

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: config)
    }

    func fetchTides(station: TideStation, date: Date = .now) async throws -> TideData {
        let cacheKey = "\(station.id)-\(dateString(date))"
        if let cached = cache[cacheKey], !cached.isStale {
            return cached
        }

        let beginDate = dateString(date)
        let endDate = dateString(Calendar.current.date(byAdding: .day, value: 2, to: date) ?? date)

        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "begin_date", value: beginDate),
            URLQueryItem(name: "end_date", value: endDate),
            URLQueryItem(name: "station", value: station.rawValue),
            URLQueryItem(name: "product", value: "predictions"),
            URLQueryItem(name: "datum", value: "MLLW"),
            URLQueryItem(name: "time_zone", value: "lst_ldt"),
            URLQueryItem(name: "interval", value: "hilo"),
            URLQueryItem(name: "units", value: "english"),
            URLQueryItem(name: "application", value: "HeyCapeCod"),
            URLQueryItem(name: "format", value: "json"),
        ]

        guard let url = components.url else {
            throw TideServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw TideServiceError.requestFailed
        }

        let tideData = try parseTideResponse(data, station: station)
        cache[cacheKey] = tideData
        return tideData
    }

    private func parseTideResponse(_ data: Data, station: TideStation) throws -> TideData {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let predictions = json["predictions"] as? [[String: String]] else {
            throw TideServiceError.invalidResponse
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        let tidePredictions = predictions.compactMap { prediction -> TidePrediction? in
            guard let timeStr = prediction["t"],
                  let heightStr = prediction["v"],
                  let typeStr = prediction["type"],
                  let time = dateFormatter.date(from: timeStr),
                  let height = Double(heightStr),
                  let type = TideType(rawValue: typeStr) else {
                return nil
            }
            return TidePrediction(time: time, height: height, type: type)
        }

        return TideData(
            stationID: station.rawValue,
            stationName: station.name,
            predictions: tidePredictions,
            fetchedAt: .now
        )
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
}

enum TideServiceError: LocalizedError {
    case invalidURL
    case requestFailed
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid NOAA API URL."
        case .requestFailed: "Failed to fetch tide data."
        case .invalidResponse: "Could not parse tide predictions."
        }
    }
}
