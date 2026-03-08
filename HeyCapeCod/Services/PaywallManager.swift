import Foundation

/// Manages free-tier usage limits and paywall gating.
///
/// Free tier limits:
/// - 3 voice conversations per day
/// - 5 GPS-triggered stories per day
/// - No offline downloads
/// - Ads shown
///
/// Premium unlocks unlimited everything + offline + no ads.
@MainActor
@Observable
final class PaywallManager {
    static let shared = PaywallManager()

    // MARK: - Free Tier Limits

    static let freeVoiceConversationsPerDay = 3
    static let freeStoriesPerDay = 5

    private init() {}

    // MARK: - Paywall Result

    enum PaywallResult {
        case allowed
        case limitReached(reason: String, upgradePrompt: String)
        case requiresAuth(reason: String)
    }

    // MARK: - Usage Checks

    func canStartVoiceConversation() -> PaywallResult {
        if SubscriptionManager.shared.isSubscribed { return .allowed }

        guard let profile = UserProfileManager.shared.currentProfile else {
            return .requiresAuth(reason: "Sign in to start voice conversations.")
        }

        profile.resetDailyCountersIfNeeded()

        if profile.conversationsToday >= Self.freeVoiceConversationsPerDay {
            return .limitReached(
                reason: "You've used all \(Self.freeVoiceConversationsPerDay) free voice conversations today.",
                upgradePrompt: "Upgrade to Premium for unlimited conversations!"
            )
        }

        return .allowed
    }

    func canPlayStory() -> PaywallResult {
        if SubscriptionManager.shared.isSubscribed { return .allowed }

        guard let profile = UserProfileManager.shared.currentProfile else {
            return .requiresAuth(reason: "Sign in to listen to stories.")
        }

        profile.resetDailyCountersIfNeeded()

        if profile.storiesPlayedToday >= Self.freeStoriesPerDay {
            return .limitReached(
                reason: "You've listened to all \(Self.freeStoriesPerDay) free stories today.",
                upgradePrompt: "Upgrade to Premium for unlimited stories!"
            )
        }

        return .allowed
    }

    func canDownloadOffline() -> PaywallResult {
        if SubscriptionManager.shared.isSubscribed { return .allowed }
        return .limitReached(
            reason: "Offline downloads are a Premium feature.",
            upgradePrompt: "Download stories for offline listening with Premium!"
        )
    }

    var shouldShowAds: Bool {
        !SubscriptionManager.shared.isSubscribed
    }

    // MARK: - Record Usage

    func recordVoiceConversation() {
        UserProfileManager.shared.currentProfile?.incrementConversations()
        UserProfileManager.shared.saveProfile()
    }

    func recordStoryPlayed() {
        UserProfileManager.shared.currentProfile?.incrementStoriesPlayed()
        UserProfileManager.shared.saveProfile()
    }

    // MARK: - Usage Summary

    var voiceConversationsRemaining: Int {
        guard !SubscriptionManager.shared.isSubscribed,
              let profile = UserProfileManager.shared.currentProfile else {
            return .max
        }
        profile.resetDailyCountersIfNeeded()
        return max(0, Self.freeVoiceConversationsPerDay - profile.conversationsToday)
    }

    var storiesRemaining: Int {
        guard !SubscriptionManager.shared.isSubscribed,
              let profile = UserProfileManager.shared.currentProfile else {
            return .max
        }
        profile.resetDailyCountersIfNeeded()
        return max(0, Self.freeStoriesPerDay - profile.storiesPlayedToday)
    }
}
