import SwiftUI

// MARK: - Social Hub View

/// Central hub for all social and sharing features.
struct SocialHubView: View {
    @State private var selectedCardType: ShareableCardGenerator.CardType?
    @State private var showBeachCheckIn = false
    @State private var showMomsGuide = false
    @State private var showCommunityTips = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    heroHeader
                        .staggered(index: 0)
                    shareYourCapeCodSection
                        .staggered(index: 1)
                    beachCheckInSection
                        .staggered(index: 2)
                    momsEssentialsSection
                        .staggered(index: 3)
                    communityTipsSection
                        .staggered(index: 4)
                    inviteFriendsSection
                        .staggered(index: 5)
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Social")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedCardType) { cardType in
                ShareableCardPreview(cardType: cardType)
            }
            .sheet(isPresented: $showBeachCheckIn) {
                BeachCheckInView()
            }
            .sheet(isPresented: $showMomsGuide) {
                MomsMustHaveView()
            }
            .sheet(isPresented: $showCommunityTips) {
                CommunityTipsView()
            }
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 32))
                .foregroundStyle(Color.capeCod.sunsetOrange)
            Text("Share Your\nCape Cod")
                .codTextStyle(.heroTitle)
                .multilineTextAlignment(.center)
            Text("Create beautiful cards, check into beaches,\nand share your Cape Cod adventures")
                .codTextStyle(.body)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CodSpacing.md)
    }

    // MARK: - Share Your Cape Cod

    private var shareYourCapeCodSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader(title: "Create & Share", icon: "square.and.arrow.up")

            LazyVGrid(columns: shareCardColumns, spacing: CodSpacing.md) {
                ForEach(Array(ShareableCardGenerator.CardType.allCases.enumerated()), id: \.element.id) { index, cardType in
                    shareCardButton(cardType, index: index)
                }
            }
        }
    }

    private var shareCardColumns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }

    private func shareCardButton(_ cardType: ShareableCardGenerator.CardType, index: Int) -> some View {
        Button {
            CodHaptic.tap()
            selectedCardType = cardType
        } label: {
            VStack(spacing: CodSpacing.sm) {
                Image(systemName: cardType.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(
                            colors: cardType.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                Text(cardType.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.capeCod.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(CodSpacing.md)
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .staggered(index: index)
    }

    // MARK: - Beach Check-In

    private var beachCheckInSection: some View {
        Button {
            CodHaptic.tap()
            showBeachCheckIn = true
        } label: {
            beachCheckInCard
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
    }

    private var beachCheckInCard: some View {
        HStack(spacing: CodSpacing.md) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.capeCod.oceanBlue)
            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                Text("Beach Check-In")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.capeCod.textPrimary)
                Text("Check in, share conditions, see who's at the beach")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.capeCod.textSecondary)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.capeCod.driftwood)
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Mom's Essentials

    private var momsEssentialsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader(title: "Mom's Cape Cod Essentials", icon: "heart.fill")

            Button {
                CodHaptic.tap()
                showMomsGuide = true
            } label: {
                momsEssentialsCard
            }
            .buttonStyle(CodButtonPressStyle(variant: .ghost))
        }
    }

    private var momsEssentialsCard: some View {
        VStack(spacing: CodSpacing.md) {
            momsCardHeader
            momsCardCategories
        }
        .padding(CodSpacing.cardPadding)
        .background(
            LinearGradient(
                colors: [Color.capeCod.sunsetOrange.opacity(0.1), Color.capeCod.seafoam.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private var momsCardHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                Text("Mom's Must-Have Guide")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.capeCod.textPrimary)
                Text("Curated tips from Cape Cod moms")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.capeCod.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.capeCod.driftwood)
        }
    }

    private var momsCardCategories: some View {
        HStack(spacing: CodSpacing.sm) {
            ForEach(MomCategory.allCases.prefix(4)) { cat in
                momCategoryBadge(cat)
            }
        }
    }

    private func momCategoryBadge(_ category: MomCategory) -> some View {
        VStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.capeCod.sunsetOrange)
            Text(shortCategoryName(category))
                .font(.system(size: 10))
                .foregroundStyle(Color.capeCod.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private func shortCategoryName(_ category: MomCategory) -> String {
        switch category {
        case .beachDay: return "Beach"
        case .rainyDay: return "Rainy"
        case .kidFriendlyDining: return "Dining"
        case .packingEssentials: return "Packing"
        case .hiddenGems: return "Gems"
        }
    }

    // MARK: - Community Tips

    private var communityTipsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader(title: "Community Tips", icon: "person.3.fill")

            Button {
                CodHaptic.tap()
                showCommunityTips = true
            } label: {
                communityTipsCard
            }
            .buttonStyle(CodButtonPressStyle(variant: .ghost))
        }
    }

    private var communityTipsCard: some View {
        HStack(spacing: CodSpacing.md) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.capeCod.seafoam)
                .frame(width: 48, height: 48)
                .background(Color.capeCod.seafoam.opacity(0.15))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                Text("Tips from fellow visitors")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.capeCod.textPrimary)
                Text("Parking hacks, food finds, hidden spots")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.capeCod.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.capeCod.driftwood)
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Invite Friends

    private var inviteFriendsSection: some View {
        inviteFriendsCard
    }

    private var inviteFriendsCard: some View {
        VStack(spacing: CodSpacing.md) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 32))
                .foregroundStyle(.white)
            Text("Invite Friends to Cape Cod")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
            Text("Share the app with friends planning their trip")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            Button {
                CodHaptic.tap()
                let service = SocialSharingService()
                let text = service.shareText(for: .inviteFriend)
                service.shareViaiMessage(text: text)
            } label: {
                Text("Share App Link")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .padding(.horizontal, CodSpacing.lg)
                    .padding(.vertical, CodSpacing.sm)
                    .background(.white)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(CodSpacing.xl)
        .background(Color.capeCod.oceanGradient)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.capeCod.oceanBlue)
            Text(title)
                .codTextStyle(.sectionTitle)
        }
    }
}

// MARK: - Identifiable Conformance for CardType

extension ShareableCardGenerator.CardType: @retroactive Hashable {}

#Preview {
    SocialHubView()
}
