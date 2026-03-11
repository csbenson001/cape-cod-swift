import SwiftUI

// MARK: - Shareable Card Preview & Share Sheet

/// Presents a card preview with share options.
struct ShareableCardPreview: View {
    let cardType: ShareableCardGenerator.CardType
    @State private var sharingService = SocialSharingService()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.lg) {
                    cardPreviewSection
                    shareButtonsSection
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Share Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Card Preview

    private var cardPreviewSection: some View {
        VStack(spacing: CodSpacing.md) {
            Text("Preview")
                .codTextStyle(.label)
                .frame(maxWidth: .infinity, alignment: .leading)

            cardForType
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.featured, style: .continuous))
                .adaptiveCardStyle(cornerRadius: CodRadius.featured)
        }
    }

    @ViewBuilder
    private var cardForType: some View {
        switch cardType {
        case .myCapeCodDay:
            MyCapeCodeDayCard(
                activities: sampleActivities,
                date: .now
            )
        case .beachReport:
            BeachReportCard(
                beachName: "Nauset Beach",
                conditions: "Sunny & Clear",
                temperature: "78°F",
                windSpeed: "8 mph SW"
            )
        case .bucketList:
            BucketListCard(
                items: sampleBucketItems,
                totalCompleted: 3
            )
        case .restaurantPick:
            RestaurantPickCard(
                restaurantName: "The Lobster Pot",
                cuisine: "Seafood",
                recommendation: "Best lobster rolls on the Cape!",
                town: "Provincetown"
            )
        }
    }

    // MARK: - Share Buttons

    private var shareButtonsSection: some View {
        VStack(spacing: CodSpacing.md) {
            Text("Share To")
                .codTextStyle(.label)
                .frame(maxWidth: .infinity, alignment: .leading)

            platformButtons

            CodButton("Share via...", variant: .secondary, icon: "square.and.arrow.up", isFullWidth: true) {
                shareCard()
            }
        }
    }

    private var platformButtons: some View {
        HStack(spacing: CodSpacing.md) {
            ForEach(SocialSharingService.SocialPlatform.allCases) { platform in
                platformButton(platform)
            }
        }
    }

    private func platformButton(_ platform: SocialSharingService.SocialPlatform) -> some View {
        Button {
            CodHaptic.tap()
            shareToplatform(platform)
        } label: {
            VStack(spacing: CodSpacing.xs) {
                Image(systemName: platform.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(platform.color)
                    .frame(width: 52, height: 52)
                    .background(platform.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                Text(platform.displayName)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.capeCod.textSecondary)
            }
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .frame(maxWidth: .infinity)
    }

    // MARK: - Share Actions

    private func shareCard() {
        guard let image = ShareableCardGenerator.renderCard(cardForType) else { return }
        let text = sharingService.shareText(for: .dailySummary)
        sharingService.shareImage(image, text: text)
        CodHaptic.success()
    }

    private func shareToplatform(_ platform: SocialSharingService.SocialPlatform) {
        guard let image = ShareableCardGenerator.renderCard(cardForType) else { return }
        switch platform {
        case .instagram:
            sharingService.shareToInstagramStories(image: image)
        default:
            sharingService.shareImage(image, text: sharingService.shareText(for: .dailySummary))
        }
        CodHaptic.success()
    }

    // MARK: - Sample Data

    private var sampleActivities: [String] {
        [
            "Morning walk at Nauset Beach",
            "Lobster lunch in Chatham",
            "Visited Highland Lighthouse",
            "Ice cream at Sundae School",
            "Sunset at Race Point"
        ]
    }

    private var sampleBucketItems: [BucketListItem] {
        [
            BucketListItem(title: "Watch sunset at Race Point", isCompleted: true),
            BucketListItem(title: "Eat a lobster roll", isCompleted: true),
            BucketListItem(title: "Visit a lighthouse", isCompleted: true),
            BucketListItem(title: "Go whale watching", isCompleted: false),
            BucketListItem(title: "Bike the Rail Trail", isCompleted: false),
            BucketListItem(title: "See seals at Chatham", isCompleted: false)
        ]
    }
}

#Preview {
    ShareableCardPreview(cardType: .beachReport)
}
