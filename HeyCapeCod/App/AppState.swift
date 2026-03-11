import SwiftUI

@preconcurrency @MainActor
@Observable
final class AppState {
    // MARK: - Navigation
    var selectedTab: AppTab = .home
    var isVoiceAssistantPresented = false
    var isChatPresented = false

    // MARK: - User Preferences
    var preferredColorScheme: ColorScheme?
    var hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }
    var experienceMode: ExperienceMode = {
        let raw = UserDefaults.standard.string(forKey: "experienceMode") ?? "adult"
        return ExperienceMode(rawValue: raw) ?? .adult
    }() {
        didSet { UserDefaults.standard.set(experienceMode.rawValue, forKey: "experienceMode") }
    }

    /// The tabs visible for the current experience mode
    var visibleTabs: [AppTab] { experienceMode.tabs }

    /// Whether the current mode surfaces kid-friendly content
    var isKidFriendlyContent: Bool {
        experienceMode == .kids || experienceMode == .family
    }

    // MARK: - Active State
    var activeConversation: Conversation?
    var currentLocation: CodLocation?
    var isListening = false

    // MARK: - Errors
    var currentError: AppError?
    var showingError: Bool {
        get { currentError != nil }
        set { if !newValue { currentError = nil } }
    }

    func presentError(_ error: AppError) {
        currentError = error
    }
}

// MARK: - App Tab

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case explore
    case tours
    case dining
    case stories
    case funZone
    case social
    case events
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Home"
        case .explore: "Explore"
        case .tours: "Tours"
        case .dining: "Dining"
        case .stories: "Stories"
        case .funZone: "Fun Zone"
        case .social: "Social"
        case .events: "Events"
        case .profile: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: "house.fill"
        case .explore: "safari.fill"
        case .tours: "map.fill"
        case .dining: "fork.knife"
        case .stories: "book.fill"
        case .funZone: "star.circle.fill"
        case .social: "camera.fill"
        case .events: "calendar.circle.fill"
        case .profile: "person.crop.circle.fill"
        }
    }
}

// MARK: - App Error

enum AppError: LocalizedError, Identifiable {
    case networkUnavailable
    case locationDenied
    case microphoneDenied
    case apiError(String)
    case unknown(Error)

    var id: String {
        switch self {
        case .networkUnavailable: "network"
        case .locationDenied: "location"
        case .microphoneDenied: "microphone"
        case .apiError(let msg): "api-\(msg)"
        case .unknown: "unknown"
        }
    }

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            "No internet connection. Some features may be unavailable."
        case .locationDenied:
            "Location access is needed for GPS-triggered stories and nearby recommendations."
        case .microphoneDenied:
            "Microphone access is needed for voice conversations."
        case .apiError(let message):
            message
        case .unknown(let error):
            error.localizedDescription
        }
    }
}
