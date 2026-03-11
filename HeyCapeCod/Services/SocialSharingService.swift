import SwiftUI
import UIKit

// MARK: - Social Sharing Service

/// Handles sharing to social platforms with branded content.
/// Falls back to standard share sheet when specific apps are unavailable.
@MainActor
@Observable
final class SocialSharingService {

    // MARK: - Platform Detection

    enum SocialPlatform: String, CaseIterable, Identifiable {
        case instagram
        case facebook
        case tiktok
        case iMessage

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .instagram: "Instagram"
            case .facebook: "Facebook"
            case .tiktok: "TikTok"
            case .iMessage: "iMessage"
            }
        }

        var icon: String {
            switch self {
            case .instagram: "camera.fill"
            case .facebook: "hand.thumbsup.fill"
            case .tiktok: "play.rectangle.fill"
            case .iMessage: "message.fill"
            }
        }

        var color: Color {
            switch self {
            case .instagram: Color(hex: 0xE1306C)
            case .facebook: Color(hex: 0x1877F2)
            case .tiktok: Color(hex: 0x010101)
            case .iMessage: Color(hex: 0x34C759)
            }
        }

        var urlScheme: String {
            switch self {
            case .instagram: "instagram-stories://share"
            case .facebook: "fb://"
            case .tiktok: "snssdk1233://"
            case .iMessage: "sms://"
            }
        }
    }

    // MARK: - App Detection

    func isAppInstalled(_ platform: SocialPlatform) -> Bool {
        guard let url = URL(string: platform.urlScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    // MARK: - Standard Share Sheet

    func shareViaActivitySheet(
        items: [Any],
        from viewController: UIViewController? = nil
    ) {
        let vc = viewController ?? topViewController()
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        activityVC.excludedActivityTypes = [.assignToContact, .addToReadingList]

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = vc?.view
            popover.sourceRect = CGRect(
                x: UIScreen.main.bounds.midX,
                y: UIScreen.main.bounds.midY,
                width: 0,
                height: 0
            )
        }

        vc?.present(activityVC, animated: true)
    }

    // MARK: - Share Image

    func shareImage(_ image: UIImage, text: String = "") {
        var items: [Any] = [image]
        if !text.isEmpty { items.append(text) }
        shareViaActivitySheet(items: items)
    }

    // MARK: - Share to Instagram Stories

    func shareToInstagramStories(image: UIImage) {
        guard let imageData = image.pngData() else { return }

        if isAppInstalled(.instagram),
           let url = URL(string: "instagram-stories://share") {
            let pasteboardItems: [String: Any] = [
                "com.instagram.sharedSticker.backgroundImage": imageData,
                "com.instagram.sharedSticker.backgroundTopColor": "#1A6B8A",
                "com.instagram.sharedSticker.backgroundBottomColor": "#0D2137"
            ]
            UIPasteboard.general.setItems(
                [pasteboardItems],
                options: [.expirationDate: Date().addingTimeInterval(300)]
            )
            UIApplication.shared.open(url)
        } else {
            shareImage(image, text: "My Cape Cod adventure! #HeyCapeCode #CapeCod")
        }
    }

    // MARK: - Share via iMessage

    func shareViaiMessage(text: String, image: UIImage? = nil) {
        var items: [Any] = [text]
        if let image { items.append(image) }
        shareViaActivitySheet(items: items)
    }

    // MARK: - Generate Share Text

    func shareText(for type: ShareContentType) -> String {
        switch type {
        case .beachCheckIn(let beachName):
            return "Having an amazing day at \(beachName)! 🏖️ #HeyCapeCode #CapeCod"
        case .restaurantPick(let name):
            return "Just discovered \(name) on Cape Cod - highly recommend! 🦞 #HeyCapeCode"
        case .bucketList(let completed, let total):
            return "I've checked off \(completed)/\(total) on my Cape Cod bucket list! 🐚 #HeyCapeCode"
        case .dailySummary:
            return "What an incredible day on Cape Cod! ☀️ #HeyCapeCode #CapeCodLife"
        case .inviteFriend:
            return "I'm using Hey Cape Cod to plan my trip - it's amazing! Check it out: https://heycapecod.app"
        }
    }

    // MARK: - Helpers

    private func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow })
        else { return nil }

        var vc = window.rootViewController
        while let presented = vc?.presentedViewController {
            vc = presented
        }
        return vc
    }
}

// MARK: - Share Content Type

enum ShareContentType {
    case beachCheckIn(beachName: String)
    case restaurantPick(name: String)
    case bucketList(completed: Int, total: Int)
    case dailySummary
    case inviteFriend
}
