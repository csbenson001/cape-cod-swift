import Foundation
import CoreLocation

/// Text chat service for AI conversations when voice isn't available.
/// Calls POST /api/chat with the user's message, experience mode, and optional location.
@preconcurrency @MainActor
@Observable
final class ChatService {
    static let shared = ChatService()

    private(set) var isLoading = false

    private init() {}

    /// Send a text message to the AI chat endpoint.
    /// - Parameters:
    ///   - text: The user's message
    ///   - mode: Experience mode (kids, teen, adult, family)
    ///   - location: Optional user location for context-aware responses
    /// - Returns: The AI response text, or nil on failure
    func sendMessage(
        _ text: String,
        mode: ExperienceMode = .adult,
        location: CLLocationCoordinate2D? = nil
    ) async -> String? {
        isLoading = true
        defer { isLoading = false }

        let chatLocation = location.map { ChatLocation(lat: $0.latitude, lng: $0.longitude) }
        let request = ChatRequest(message: text, mode: mode.rawValue, location: chatLocation)

        do {
            let response: ChatResponse = try await APIClient.shared.post("/chat", body: request)
            print("✅ Chat response received (\(response.response.count) chars)")
            return response.response
        } catch let error as APIError {
            switch error {
            case .unauthorized:
                print("❌ Chat requires authentication")
            case .rateLimited:
                print("❌ Chat daily limit reached")
            default:
                print("❌ Chat error: \(error.localizedDescription)")
            }
            return nil
        } catch {
            print("❌ Chat error: \(error.localizedDescription)")
            return nil
        }
    }
}
