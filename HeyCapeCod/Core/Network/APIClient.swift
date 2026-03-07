import Foundation

/// Central API client for all Hey Cape Cod backend calls.
///
/// - Handles auth token injection from Firebase Auth
/// - Generic GET/POST with Codable decoding
/// - Environment switching (dev vs production)
/// - Structured error handling
final class APIClient {
    static let shared = APIClient()

    /// Firebase Auth token, set after user signs in.
    /// Injected into every authenticated request.
    var authToken: String?

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    // MARK: - Base URL

    var baseURL: URL {
        #if DEBUG
        // Local development server
        URL(string: "http://localhost:3000")!
        #else
        // Production Vercel deployment
        URL(string: "https://hey-cape-cod-backend.vercel.app")!
        #endif
    }

    // MARK: - GET

    func get<T: Decodable>(_ path: String, query: [String: String] = [], requiresAuth: Bool = false) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if requiresAuth {
            guard let token = authToken else { throw APIError.unauthorized }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        print("[APIClient] GET \(url.absoluteString)")
        return try await execute(request)
    }

    // MARK: - POST

    func post<T: Decodable, B: Encodable>(_ path: String, body: B, requiresAuth: Bool = true) async throws -> T {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(body)

        if requiresAuth {
            guard let token = authToken else { throw APIError.unauthorized }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        print("[APIClient] POST \(url.absoluteString)")
        return try await execute(request)
    }

    // MARK: - PUT

    func put<T: Decodable, B: Encodable>(_ path: String, body: B, requiresAuth: Bool = true) async throws -> T {
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(body)

        if requiresAuth {
            guard let token = authToken else { throw APIError.unauthorized }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        print("[APIClient] PUT \(url.absoluteString)")
        return try await execute(request)
    }

    // MARK: - Execute

    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.serverError(0, "Invalid response")
        }

        switch http.statusCode {
        case 200...299:
            do {
                let decoded = try decoder.decode(T.self, from: data)
                print("[APIClient] Success (\(http.statusCode))")
                return decoded
            } catch {
                print("[APIClient] Decode error: \(error)")
                throw APIError.decodingFailed(error)
            }

        case 401:
            throw APIError.unauthorized

        case 429:
            throw APIError.rateLimited

        case 404:
            throw APIError.noData

        default:
            let body = String(data: data, encoding: .utf8) ?? ""
            print("[APIClient] Error \(http.statusCode): \(body)")
            throw APIError.serverError(http.statusCode, body)
        }
    }
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case unauthorized
    case rateLimited
    case noData
    case serverError(Int, String)
    case decodingFailed(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid request URL."
        case .unauthorized: "Please sign in to continue."
        case .rateLimited: "Daily limit reached. Upgrade for unlimited access."
        case .noData: "No data found."
        case .serverError(let code, let msg): "Server error (\(code)): \(msg)"
        case .decodingFailed(let err): "Data format error: \(err.localizedDescription)"
        case .networkError(let err): "Network error: \(err.localizedDescription)"
        }
    }
}
