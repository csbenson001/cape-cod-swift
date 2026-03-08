import Foundation

/// Central API client for all Hey Cape Cod backend calls.
///
/// - Handles auth token injection from Firebase Auth
/// - Generic GET/POST/PUT with Codable decoding
/// - Environment switching (dev/staging/production)
/// - Structured error handling with emoji logging
@preconcurrency @MainActor
final class APIClient {
    static let shared = APIClient()

    /// Firebase Auth token, set after user signs in.
    var authToken: String?

    private let session: URLSession
    private let decoder: JSONDecoder
    private let environment: Environment

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder

        #if DEBUG
        self.environment = .development
        #else
        self.environment = .production
        #endif
    }

    // MARK: - Environment

    enum Environment {
        case development
        case staging
        case production

        var baseURL: String {
            switch self {
            case .development: return "http://localhost:3000/api"
            case .staging: return "https://staging-cape-cod.vercel.app/api"
            case .production: return "https://v0-cape-cod-ai-travel-assistant.vercel.app/api"
            }
        }
    }

    var baseURL: URL {
        URL(string: environment.baseURL)!
    }

    // MARK: - GET

    func get<T: Decodable>(_ endpoint: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIError.serverError(0)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        print("📡 GET \(url.absoluteString)")
        return try await execute(request)
    }

    /// Convenience overload accepting a [String: String] dictionary for query params
    func get<T: Decodable>(_ endpoint: String, query: [String: String]) async throws -> T {
        let items = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        return try await get(endpoint, queryItems: items.isEmpty ? nil : items)
    }

    // MARK: - POST

    func post<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(body)

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        print("📡 POST \(url.absoluteString)")
        return try await execute(request)
    }

    // MARK: - PUT

    func put<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(body)

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        print("📡 PUT \(url.absoluteString)")
        return try await execute(request)
    }

    // MARK: - Execute

    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw APIError.noData
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.serverError(0)
        }

        switch http.statusCode {
        case 200...299:
            do {
                let decoded = try decoder.decode(T.self, from: data)
                print("✅ Success (\(http.statusCode))")
                return decoded
            } catch {
                print("❌ Decode error: \(error)")
                throw APIError.decodingError
            }

        case 401:
            throw APIError.unauthorized

        case 429:
            throw APIError.rateLimited

        case 404:
            throw APIError.noData

        default:
            let body = String(data: data, encoding: .utf8) ?? ""
            print("❌ Server error \(http.statusCode): \(body)")
            throw APIError.serverError(http.statusCode)
        }
    }
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case serverError(Int)
    case noData
    case decodingError
    case unauthorized
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .serverError(let code): "Server error (\(code))."
        case .noData: "No data found."
        case .decodingError: "Data format error."
        case .unauthorized: "Please sign in to continue."
        case .rateLimited: "Daily limit reached. Upgrade for unlimited access."
        }
    }
}
