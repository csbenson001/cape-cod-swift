import Foundation
@preconcurrency import SwiftData

/// User profile persisted locally via SwiftData with Firestore sync.
///
/// Tracks auth info, preferences, subscription status, and daily usage counters
/// for paywall gating.
@Model
final class UserProfile {
    // MARK: - Identity
    @Attribute(.unique) var uid: String
    var displayName: String
    var email: String?
    var photoURL: String?
    var authProvider: String // AuthManager.AuthProvider.rawValue

    // MARK: - Preferences
    var currentMode: String // ExperienceMode.rawValue
    var visitType: String // "local", "tourist", "dayTrip"
    @Attribute(.transformable(by: NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue))
    var interests: [String] // ["beaches", "history", "food", "nature", "lighthouses"]

    // MARK: - Subscription
    var isPremium: Bool
    var premiumExpiresAt: Date?
    var subscriptionProductId: String?
    var originalTransactionId: String?

    // MARK: - Usage Tracking (for paywall gating)
    var conversationsToday: Int
    var storiesPlayedToday: Int
    var lastResetDate: Date

    // MARK: - Metadata
    var createdAt: Date
    var lastSyncedAt: Date?
    var totalConversations: Int
    var totalStoriesPlayed: Int
    @Attribute(.transformable(by: NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue))
    var favoriteBeaches: [String]
    @Attribute(.transformable(by: NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue))
    var preferredRegions: [String]
    @Attribute(.transformable(by: NSValueTransformerName.secureUnarchiveFromDataTransformerName.rawValue))
    var preferredTowns: [String]

    init(
        uid: String,
        displayName: String = "Guest",
        email: String? = nil,
        photoURL: String? = nil,
        authProvider: String = "guest"
    ) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
        self.photoURL = photoURL
        self.authProvider = authProvider
        self.currentMode = ExperienceMode.adult.rawValue
        self.visitType = "tourist"
        self.interests = []
        self.isPremium = false
        self.premiumExpiresAt = nil
        self.subscriptionProductId = nil
        self.originalTransactionId = nil
        self.conversationsToday = 0
        self.storiesPlayedToday = 0
        self.lastResetDate = Calendar.current.startOfDay(for: .now)
        self.createdAt = .now
        self.lastSyncedAt = nil
        self.totalConversations = 0
        self.totalStoriesPlayed = 0
        self.favoriteBeaches = []
        self.preferredRegions = []
        self.preferredTowns = []
    }

    // MARK: - Computed

    var experienceMode: ExperienceMode {
        get { ExperienceMode(rawValue: currentMode) ?? .adult }
        set { currentMode = newValue.rawValue }
    }

    var premiumIsActive: Bool {
        guard isPremium else { return false }
        if let expires = premiumExpiresAt {
            return expires > .now
        }
        return true
    }

    // MARK: - Daily Reset

    func resetDailyCountersIfNeeded() {
        let today = Calendar.current.startOfDay(for: .now)
        if lastResetDate < today {
            conversationsToday = 0
            storiesPlayedToday = 0
            lastResetDate = today
        }
    }

    func incrementConversations() {
        resetDailyCountersIfNeeded()
        conversationsToday += 1
        totalConversations += 1
    }

    func incrementStoriesPlayed() {
        resetDailyCountersIfNeeded()
        storiesPlayedToday += 1
        totalStoriesPlayed += 1
    }

    // MARK: - Firestore Sync

    /// Convert to dictionary for Firestore upload.
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "uid": uid,
            "displayName": displayName,
            "authProvider": authProvider,
            "currentMode": currentMode,
            "visitType": visitType,
            "interests": interests,
            "isPremium": isPremium,
            "conversationsToday": conversationsToday,
            "storiesPlayedToday": storiesPlayedToday,
            "totalConversations": totalConversations,
            "totalStoriesPlayed": totalStoriesPlayed,
            "favoriteBeaches": favoriteBeaches,
            "preferredRegions": preferredRegions,
            "preferredTowns": preferredTowns,
            "createdAt": createdAt.timeIntervalSince1970,
            "lastSyncedAt": Date.now.timeIntervalSince1970,
        ]

        if let email { data["email"] = email }
        if let photoURL { data["photoURL"] = photoURL }
        if let expires = premiumExpiresAt { data["premiumExpiresAt"] = expires.timeIntervalSince1970 }
        if let productId = subscriptionProductId { data["subscriptionProductId"] = productId }

        return data
    }

    /// Update from Firestore document data.
    func updateFromFirestore(_ data: [String: Any]) {
        if let name = data["displayName"] as? String { displayName = name }
        if let mode = data["currentMode"] as? String { currentMode = mode }
        if let type = data["visitType"] as? String { visitType = type }
        if let tags = data["interests"] as? [String] { interests = tags }
        if let premium = data["isPremium"] as? Bool { isPremium = premium }
        if let expires = data["premiumExpiresAt"] as? TimeInterval {
            premiumExpiresAt = Date(timeIntervalSince1970: expires)
        }
        if let beaches = data["favoriteBeaches"] as? [String] { favoriteBeaches = beaches }
        if let regions = data["preferredRegions"] as? [String] { preferredRegions = regions }
        if let towns = data["preferredTowns"] as? [String] { preferredTowns = towns }
        lastSyncedAt = .now
    }
}

// MARK: - UserProfile Manager

@preconcurrency @MainActor
@Observable
final class UserProfileManager {
    static let shared = UserProfileManager()

    private(set) var currentProfile: UserProfile?
    private var modelContext: ModelContext?

    private init() {}

    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    /// Load or create profile for the authenticated user.
    func loadProfile(for user: AuthManager.AuthUser) {
        guard let context = modelContext else { return }

        let uid = user.uid
        let predicate = #Predicate<UserProfile> { $0.uid == uid }
        let descriptor = FetchDescriptor<UserProfile>(predicate: predicate)

        if let existing = try? context.fetch(descriptor).first {
            existing.resetDailyCountersIfNeeded()
            currentProfile = existing
        } else {
            let profile = UserProfile(
                uid: user.uid,
                displayName: user.displayName ?? "Guest",
                email: user.email,
                photoURL: user.photoURL,
                authProvider: user.provider.rawValue
            )
            context.insert(profile)
            try? context.save()
            currentProfile = profile
        }
    }

    func saveProfile() {
        guard let context = modelContext else { return }
        try? context.save()
    }

    func clearProfile() {
        currentProfile = nil
    }

    // MARK: - Preferred Tide Station (UserDefaults-backed)

    private static let tideStationKey = "preferredTideStation"

    // MARK: - Preferred Weather Location (UserDefaults-backed)

    private static let weatherLocationKey = "preferredWeatherLocation"

    /// Stored as "name|lat|lng" or nil for location services
    var preferredWeatherLocation: WeatherLocation {
        get {
            guard let raw = UserDefaults.standard.string(forKey: Self.weatherLocationKey) else {
                return .capeCodDefault
            }
            let parts = raw.split(separator: "|")
            guard parts.count == 3,
                  let lat = Double(parts[1]),
                  let lng = Double(parts[2]) else {
                return .capeCodDefault
            }
            return WeatherLocation(name: String(parts[0]), latitude: lat, longitude: lng)
        }
        set {
            let raw = "\(newValue.name)|\(newValue.latitude)|\(newValue.longitude)"
            UserDefaults.standard.set(raw, forKey: Self.weatherLocationKey)
        }
    }

    var useLocationServicesForWeather: Bool {
        get { UserDefaults.standard.bool(forKey: "useLocationServicesForWeather") }
        set { UserDefaults.standard.set(newValue, forKey: "useLocationServicesForWeather") }
    }

    // MARK: - Preferred Cape Cod Areas (UserDefaults-backed)

    private static let regionsKey = "preferredCapeCodRegions"
    private static let townsKey = "preferredCapeCodTowns"

    var preferredRegions: [String] {
        get { UserDefaults.standard.stringArray(forKey: Self.regionsKey) ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: Self.regionsKey) }
    }

    var preferredTowns: [String] {
        get { UserDefaults.standard.stringArray(forKey: Self.townsKey) ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: Self.townsKey) }
    }

    /// Summary text for display (e.g., "Mid Cape, Chatham")
    var areaPreferencesSummary: String {
        var parts: [String] = []
        for rawValue in preferredRegions {
            if let region = CapeCodRegion(rawValue: rawValue) {
                parts.append(region.displayName)
            }
        }
        parts.append(contentsOf: preferredTowns)
        if parts.isEmpty { return "All of Cape Cod" }
        return parts.joined(separator: ", ")
    }

    var preferredTideStation: TideStation {
        get {
            if let raw = UserDefaults.standard.string(forKey: Self.tideStationKey),
               let station = TideStation(rawValue: raw) {
                return station
            }
            return .hyannis
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Self.tideStationKey)
        }
    }

    /// Sync profile to Firestore via backend API.
    func syncToCloud() async {
        guard let profile = currentProfile, !AuthManager.shared.isGuest else { return }

        let payload = ProfileSyncPayload(from: profile)
        do {
            let _: EmptyResponse = try await APIClient.shared.put("users/\(profile.uid)", body: payload)
            profile.lastSyncedAt = .now
            saveProfile()
            print("☁️ Profile synced to cloud")
        } catch {
            print("⚠️ Profile sync failed: \(error.localizedDescription)")
        }
    }
}

private struct EmptyResponse: Codable {}

/// Encodable payload for syncing UserProfile to Firestore via the API.
private struct ProfileSyncPayload: Encodable {
    let uid: String
    let displayName: String
    let email: String?
    let photoURL: String?
    let authProvider: String
    let currentMode: String
    let visitType: String
    let interests: [String]
    let isPremium: Bool
    let premiumExpiresAt: Double?
    let subscriptionProductId: String?
    let conversationsToday: Int
    let storiesPlayedToday: Int
    let totalConversations: Int
    let totalStoriesPlayed: Int
    let favoriteBeaches: [String]
    let preferredRegions: [String]
    let preferredTowns: [String]
    let createdAt: Double
    let lastSyncedAt: Double

    init(from profile: UserProfile) {
        self.uid = profile.uid
        self.displayName = profile.displayName
        self.email = profile.email
        self.photoURL = profile.photoURL
        self.authProvider = profile.authProvider
        self.currentMode = profile.currentMode
        self.visitType = profile.visitType
        self.interests = profile.interests
        self.isPremium = profile.isPremium
        self.premiumExpiresAt = profile.premiumExpiresAt?.timeIntervalSince1970
        self.subscriptionProductId = profile.subscriptionProductId
        self.conversationsToday = profile.conversationsToday
        self.storiesPlayedToday = profile.storiesPlayedToday
        self.totalConversations = profile.totalConversations
        self.totalStoriesPlayed = profile.totalStoriesPlayed
        self.favoriteBeaches = profile.favoriteBeaches
        self.preferredRegions = profile.preferredRegions
        self.preferredTowns = profile.preferredTowns
        self.createdAt = profile.createdAt.timeIntervalSince1970
        self.lastSyncedAt = Date.now.timeIntervalSince1970
    }
}
