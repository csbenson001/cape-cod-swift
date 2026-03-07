import Foundation

/// Request body for POST /api/chat
struct ChatRequest: Encodable {
    let message: String
    let mode: String
    let location: ChatLocation?
}

struct ChatLocation: Encodable {
    let lat: Double
    let lng: Double
}

/// Response from POST /api/chat
struct ChatResponse: Decodable {
    let response: String
    let sources: [String]?
}
