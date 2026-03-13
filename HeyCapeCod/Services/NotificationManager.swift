import Foundation
import UserNotifications

/// Manages local notifications for weather alerts, shark sightings, achievements, and daily digests.
@preconcurrency @MainActor
@Observable
final class NotificationManager {

    static let shared = NotificationManager()

    // MARK: - Public State

    private(set) var isPermissionGranted = false
    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Init

    private init() {
        setupNotificationCategories()
        Task { await refreshPermissionStatus() }
    }

    // MARK: - Permission Management

    /// Request notification permission. Returns `true` if granted.
    @discardableResult
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()

        // Check current status first
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .authorized {
            isPermissionGranted = true
            authorizationStatus = .authorized
            return true
        }

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isPermissionGranted = granted
            authorizationStatus = granted ? .authorized : .denied
            return granted
        } catch {
            print("[NotificationManager] Permission request failed: \(error.localizedDescription)")
            isPermissionGranted = false
            authorizationStatus = .denied
            return false
        }
    }

    /// Refresh the current permission status without prompting.
    func refreshPermissionStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isPermissionGranted = settings.authorizationStatus == .authorized
    }

    // MARK: - Weather Alert

    func scheduleWeatherAlert(condition: String, severity: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "\(severity) Weather Alert"
        content.subtitle = condition
        content.body = message
        content.sound = .default
        content.categoryIdentifier = "WEATHER_ALERT"
        content.threadIdentifier = "weather-alerts"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "weather-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[NotificationManager] Weather alert failed: \(error.localizedDescription)")
            }
        }

        CodHaptic.warning()
    }

    // MARK: - Shark Alert

    func scheduleSharkAlert(location: String, alertLevel: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Shark Alert - \(alertLevel)"
        content.subtitle = location
        content.body = message
        content.categoryIdentifier = "SHARK_ALERT"
        content.threadIdentifier = "shark-alerts"

        // .defaultCritical requires the Critical Alerts entitlement from Apple.
        // Set it here — if the entitlement is missing, the system falls back gracefully.
        content.sound = .defaultCritical

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "shark-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[NotificationManager] Shark alert failed: \(error.localizedDescription)")
            }
        }

        CodHaptic.heavy()
    }

    // MARK: - Achievement Unlock

    func scheduleAchievementNotification(name: String, description: String) {
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked!"
        content.subtitle = name
        content.body = description
        content.sound = .default
        content.categoryIdentifier = "ACHIEVEMENT"
        content.threadIdentifier = "achievements"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "achievement-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[NotificationManager] Achievement notification failed: \(error.localizedDescription)")
            }
        }

        CodHaptic.success()
    }

    // MARK: - Daily Digest

    private static let digestMessages = [
        "Check today's beach conditions, tides, and weather before heading out!",
        "New shark sightings reported — stay informed before your beach day.",
        "Perfect day to explore Cape Cod! See what's happening nearby.",
        "Tide times updated — plan your beach walk or fishing trip.",
        "Discover hidden gems and local tips for today's adventure.",
        "Bridge traffic update available — plan your drive across the Cape.",
    ]

    func scheduleDailyDigest(hour: Int, minute: Int) {
        // Remove any existing daily digest first
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["daily-digest"]
        )

        let content = UNMutableNotificationContent()
        content.title = "Hey Cape Cod"
        content.body = Self.digestMessages.randomElement() ?? Self.digestMessages[0]
        content.sound = .default
        content.categoryIdentifier = "DAILY_DIGEST"
        content.threadIdentifier = "daily-digest"

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily-digest",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("[NotificationManager] Daily digest failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Notification Categories

    private func setupNotificationCategories() {
        let weatherActions = [
            UNNotificationAction(identifier: "WEATHER_VIEW", title: "View Details", options: .foreground),
            UNNotificationAction(identifier: "WEATHER_DISMISS", title: "Dismiss", options: .destructive),
        ]
        let weatherCategory = UNNotificationCategory(
            identifier: "WEATHER_ALERT",
            actions: weatherActions,
            intentIdentifiers: []
        )

        let sharkActions = [
            UNNotificationAction(identifier: "SHARK_VIEW_MAP", title: "View Map", options: .foreground),
            UNNotificationAction(identifier: "SHARK_SAFETY", title: "Safety Tips", options: .foreground),
        ]
        let sharkCategory = UNNotificationCategory(
            identifier: "SHARK_ALERT",
            actions: sharkActions,
            intentIdentifiers: []
        )

        let achievementActions = [
            UNNotificationAction(identifier: "ACHIEVEMENT_VIEW", title: "View Achievements", options: .foreground),
        ]
        let achievementCategory = UNNotificationCategory(
            identifier: "ACHIEVEMENT",
            actions: achievementActions,
            intentIdentifiers: []
        )

        let digestActions = [
            UNNotificationAction(identifier: "DIGEST_OPEN", title: "Open App", options: .foreground),
        ]
        let digestCategory = UNNotificationCategory(
            identifier: "DAILY_DIGEST",
            actions: digestActions,
            intentIdentifiers: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            weatherCategory,
            sharkCategory,
            achievementCategory,
            digestCategory,
        ])
    }

    // MARK: - Badge Management

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    func setBadge(count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count)
    }

    // MARK: - Cleanup

    func removeAllPending() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func removeNotifications(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }
}
