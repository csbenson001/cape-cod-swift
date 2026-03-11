import SwiftUI

// MARK: - Mom's Must-Have Cape Cod Guide

struct MomsMustHaveView: View {
    @State private var selectedCategory: MomCategory = .beachDay
    @State private var showShareGuide = false
    @State private var showInviteFriend = false
    @State private var sharingService = SocialSharingService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    heroSection
                        .staggered(index: 0)
                    categoryPicker
                        .staggered(index: 1)
                    tipsSection
                        .staggered(index: 2)
                    actionButtons
                        .staggered(index: 3)
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Mom's Guide")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showShareGuide) {
                ShareGuideSheet(category: selectedCategory)
            }
            .sheet(isPresented: $showInviteFriend) {
                InviteFriendSheet()
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: CodSpacing.md) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.capeCod.sunsetOrange)
            Text("Mom's Must-Have\nCape Cod Guide")
                .codTextStyle(.heroTitle)
                .multilineTextAlignment(.center)
            Text("Curated tips from Cape Cod moms, for Cape Cod moms")
                .codTextStyle(.body)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CodSpacing.lg)
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                ForEach(MomCategory.allCases) { category in
                    categoryChip(category)
                }
            }
        }
    }

    private func categoryChip(_ category: MomCategory) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(CodAnimation.quick) {
                selectedCategory = category
            }
            CodHaptic.selection()
        } label: {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                Text(category.title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, CodSpacing.md)
            .padding(.vertical, CodSpacing.sm)
            .foregroundStyle(isSelected ? Color.capeCod.textOnPrimary : Color.capeCod.textPrimary)
            .background(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.surface)
            .clipShape(Capsule())
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
    }

    // MARK: - Tips

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack {
                Text(selectedCategory.title)
                    .codTextStyle(.sectionTitle)
                Spacer()
                Text("\(selectedCategory.tips.count) tips")
                    .codTextStyle(.caption)
            }

            ForEach(Array(selectedCategory.tips.enumerated()), id: \.offset) { index, tip in
                tipCard(tip, index: index)
            }
        }
    }

    private func tipCard(_ tip: MomTip, index: Int) -> some View {
        HStack(alignment: .top, spacing: CodSpacing.md) {
            Image(systemName: tip.icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.capeCod.oceanBlue)
                .frame(width: 36, height: 36)
                .background(Color.capeCod.oceanBlue.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                Text(tip.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.capeCod.textPrimary)
                Text(tip.detail)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.capeCod.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(CodSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .staggered(index: index)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: CodSpacing.md) {
            CodButton("Share This Guide", variant: .primary, icon: "square.and.arrow.up", isFullWidth: true) {
                showShareGuide = true
            }
            CodButton("Invite a Friend", variant: .accent, icon: "person.badge.plus", isFullWidth: true) {
                showInviteFriend = true
            }
        }
    }
}

// MARK: - Mom Category

enum MomCategory: String, CaseIterable, Identifiable {
    case beachDay
    case rainyDay
    case kidFriendlyDining
    case packingEssentials
    case hiddenGems

    var id: String { rawValue }

    var title: String {
        switch self {
        case .beachDay: "Beach Day Prep"
        case .rainyDay: "Rainy Day Plans"
        case .kidFriendlyDining: "Kid-Friendly Restaurants"
        case .packingEssentials: "Packing Essentials"
        case .hiddenGems: "Hidden Gems for Families"
        }
    }

    var icon: String {
        switch self {
        case .beachDay: "sun.max.fill"
        case .rainyDay: "cloud.rain.fill"
        case .kidFriendlyDining: "fork.knife"
        case .packingEssentials: "suitcase.fill"
        case .hiddenGems: "sparkles"
        }
    }

    var tips: [MomTip] {
        switch self {
        case .beachDay: return MomTipData.beachDayTips
        case .rainyDay: return MomTipData.rainyDayTips
        case .kidFriendlyDining: return MomTipData.kidFriendlyDiningTips
        case .packingEssentials: return MomTipData.packingTips
        case .hiddenGems: return MomTipData.hiddenGemsTips
        }
    }
}

// MARK: - Mom Tip

struct MomTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
}

// MARK: - Share Guide Sheet

struct ShareGuideSheet: View {
    let category: MomCategory
    @State private var sharingService = SocialSharingService()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: CodSpacing.lg) {
                guidePreview
                CodButton("Share", variant: .primary, icon: "square.and.arrow.up", isFullWidth: true) {
                    shareGuide()
                }
            }
            .padding(CodSpacing.screenEdge)
            .background(Color.capeCod.background)
            .navigationTitle("Share Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var guidePreview: some View {
        ShareableGuideCard(category: category)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.featured, style: .continuous))
            .adaptiveCardStyle(cornerRadius: CodRadius.featured)
    }

    private func shareGuide() {
        let card = ShareableGuideCard(category: category)
        if let image = ShareableCardGenerator.renderCard(card) {
            sharingService.shareImage(image, text: "Check out these \(category.title) tips for Cape Cod! #HeyCapeCode #CapeCodMom")
            CodHaptic.success()
        }
    }
}

// MARK: - Shareable Guide Card

struct ShareableGuideCard: View {
    let category: MomCategory

    var body: some View {
        cardContent
            .frame(width: 360, height: 520)
    }

    private var cardContent: some View {
        ZStack {
            LinearGradient(
                colors: [Color.capeCod.oceanBlue, Color.capeCod.seafoam],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: CodSpacing.md) {
                guideHeader
                Spacer()
                tipsList
                Spacer()
                footer
            }
            .padding(CodSpacing.lg)
        }
    }

    private var guideHeader: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: category.icon)
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.9))
            Text("Mom's Guide")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .textCase(.uppercase)
                .tracking(1.5)
            Text(category.title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private var tipsList: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            ForEach(category.tips.prefix(5)) { tip in
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: tip.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.8))
                        .frame(width: 20)
                    Text(tip.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(CodSpacing.md)
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }

    private var footer: some View {
        HStack {
            Text("Hey Cape Cod")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text("Mom's Must-Have Guide")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// MARK: - Invite Friend Sheet

struct InviteFriendSheet: View {
    @State private var personalMessage = ""
    @State private var sharingService = SocialSharingService()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: CodSpacing.lg) {
                inviteHeader
                messageInput
                CodButton("Send Invite", variant: .accent, icon: "paperplane.fill", isFullWidth: true) {
                    sendInvite()
                }
                Spacer()
            }
            .padding(CodSpacing.screenEdge)
            .background(Color.capeCod.background)
            .navigationTitle("Invite a Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var inviteHeader: some View {
        VStack(spacing: CodSpacing.md) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.capeCod.sunsetOrange)
            Text("Share the Cape Cod love!")
                .codTextStyle(.sectionTitle)
            Text("Invite a friend to plan their Cape Cod trip with Hey Cape Cod")
                .codTextStyle(.body)
                .multilineTextAlignment(.center)
        }
    }

    private var messageInput: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Add a personal note")
                .codTextStyle(.caption)
            TextField("I'm using this app for our Cape trip...", text: $personalMessage, axis: .vertical)
                .lineLimit(3...6)
                .padding(CodSpacing.md)
                .background(Color.capeCod.surface)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
        }
    }

    private func sendInvite() {
        var text = sharingService.shareText(for: .inviteFriend)
        if !personalMessage.isEmpty {
            text = "\(personalMessage)\n\n\(text)"
        }
        sharingService.shareViaiMessage(text: text)
        CodHaptic.success()
    }
}

#Preview {
    MomsMustHaveView()
}
