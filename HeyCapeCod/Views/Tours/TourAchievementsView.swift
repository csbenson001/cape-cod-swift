import SwiftUI

// MARK: - Achievement Unlocked Banner

/// A toast banner that slides in from the top when a new achievement is unlocked.
/// Auto-dismisses after 3 seconds with a celebration scale-bounce animation.
struct AchievementUnlockedBanner: View {
    let achievement: TourAchievement
    var onDismiss: () -> Void

    @State private var isVisible = false
    @State private var iconScale: CGFloat = 0.3

    var body: some View {
        if isVisible {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: achievement.icon)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .scaleEffect(iconScale)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Achievement Unlocked!")
                        .font(.system(size: 12, weight: .bold))
                        .textCase(.uppercase)
                        .tracking(1.0)
                        .foregroundStyle(.white.opacity(0.9))

                    Text(achievement.displayName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                }

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, CodSpacing.cardPadding)
            .padding(.vertical, CodSpacing.sm + 4)
            .background(
                LinearGradient(
                    colors: [Color.capeCod.sandbarYellow, Color.capeCod.sunsetOrange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .codShadow(.elevated)
            .padding(.horizontal, CodSpacing.screenEdge)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    func appear() -> some View {
        self.onAppear {
            withAnimation(CodAnimation.spring) {
                isVisible = true
            }
            withAnimation(CodAnimation.bouncy.delay(0.15)) {
                iconScale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(CodAnimation.spring) {
                    isVisible = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onDismiss()
                }
            }
        }
    }
}

// MARK: - Tour Achievements View

/// Full-screen achievements gallery showing unlocked and locked achievements
/// with progress tracking, category filtering, and animated transitions.
struct TourAchievementsView: View {
    @State private var service = TourAchievementService.shared
    @State private var selectedCategory: AchievementCategory?
    @State private var showBanner = false

    private let columns = [
        GridItem(.flexible(), spacing: CodSpacing.sm),
        GridItem(.flexible(), spacing: CodSpacing.sm),
    ]

    private var filteredAchievements: [TourAchievement] {
        if let category = selectedCategory {
            return TourAchievement.allCases.filter { $0.category == category }
        }
        return Array(TourAchievement.allCases)
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    headerSection
                    categoryFilters
                    achievementsGrid
                }
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)

            // Achievement unlocked banner overlay
            if let recent = service.recentUnlock {
                AchievementUnlockedBanner(achievement: recent) {
                    service.recentUnlock = nil
                }
                .appear()
                .padding(.top, CodSpacing.sm)
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: CodSpacing.lg) {
            // Trophy + progress ring
            ZStack {
                // Background ring (track)
                Circle()
                    .stroke(Color.capeCod.fog, lineWidth: 8)
                    .frame(width: 100, height: 100)

                // Progress ring
                Circle()
                    .trim(from: 0, to: service.overallProgress)
                    .stroke(
                        Color.capeCod.oceanGradient,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(CodAnimation.spring, value: service.overallProgress)

                // Trophy icon
                Image(systemName: "trophy.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.capeCod.sandbarYellow)
            }

            // Stats summary
            VStack(spacing: CodSpacing.xs) {
                Text("\(service.unlockedCount)/\(service.totalAchievements)")
                    .codTextStyle(.heroTitle)

                Text("Achievements Unlocked")
                    .codTextStyle(.subtitle)
            }

            // Stat pills
            HStack(spacing: CodSpacing.sm) {
                statPill(icon: "mappin.and.ellipse", value: "\(service.totalPOIsVisited)", label: "POIs")
                statPill(icon: "headphones", value: "\(service.totalStoriesPlayed)", label: "Stories")
                statPill(icon: "map", value: "\(service.totalToursCompleted)", label: "Tours")
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.top, CodSpacing.sm)
    }

    private func statPill(icon: String, value: String, label: String) -> some View {
        VStack(spacing: CodSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.capeCod.oceanBlue)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.capeCod.textPrimary)

            Text(label)
                .codTextStyle(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CodSpacing.sm)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
        .adaptiveCardStyle(cornerRadius: CodRadius.sm)
    }

    // MARK: - Category Filters

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                CodChip(
                    "All",
                    style: .filter,
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation(CodAnimation.quick) {
                        selectedCategory = nil
                    }
                    CodHaptic.selection()
                }

                ForEach(AchievementCategory.allCases) { category in
                    CodChip(
                        category.displayName,
                        style: .filter,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(CodAnimation.quick) {
                            selectedCategory = category
                        }
                        CodHaptic.selection()
                    }
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
    }

    // MARK: - Achievements Grid

    private var achievementsGrid: some View {
        LazyVGrid(columns: columns, spacing: CodSpacing.sm) {
            ForEach(Array(filteredAchievements.enumerated()), id: \.element.id) { index, achievement in
                AchievementCard(
                    achievement: achievement,
                    isUnlocked: service.isUnlocked(achievement),
                    progress: service.progress(for: achievement)
                )
                .staggered(index: index)
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .animation(CodAnimation.spring, value: selectedCategory)
    }
}

// MARK: - Achievement Card

/// Individual achievement card displayed in the grid.
/// Shows vibrant colors when unlocked, grayed-out state with progress when locked.
struct AchievementCard: View {
    let achievement: TourAchievement
    let isUnlocked: Bool
    let progress: Double

    @State private var showDetail = false

    var body: some View {
        VStack(spacing: CodSpacing.sm) {
            // Icon area
            ZStack(alignment: .topTrailing) {
                // Icon background circle
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: isUnlocked ? achievement.icon : "lock.fill")
                            .font(.system(size: isUnlocked ? 24 : 20, weight: .bold))
                            .foregroundStyle(iconForegroundColor)
                    }

                // Checkmark badge for unlocked
                if isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.capeCod.duneGrass)
                        .background(Circle().fill(Color.capeCod.cardBackground).padding(2))
                        .offset(x: 4, y: -4)
                }
            }

            // Achievement name
            Text(achievement.displayName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isUnlocked ? Color.capeCod.textPrimary : Color.capeCod.driftwood)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            // Description
            Text(achievement.description)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(isUnlocked ? Color.capeCod.textSecondary : Color.capeCod.fog)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            // Progress bar for locked achievements
            if !isUnlocked {
                progressBar
            }
        }
        .padding(CodSpacing.cardPadding)
        .frame(maxWidth: .infinity)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .opacity(isUnlocked ? 1.0 : 0.75)
        .codAccessibleCard(
            label: "\(achievement.displayName) achievement",
            hint: isUnlocked
                ? "Unlocked. \(achievement.description)"
                : "\(Int(progress * 100)) percent complete. \(achievement.requirement)"
        )
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: CodSpacing.xs) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.capeCod.fog)
                        .frame(height: 6)

                    // Fill
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.capeCod.driftwood.opacity(0.6))
                        .frame(width: geometry.size.width * progress, height: 6)
                        .animation(CodAnimation.spring, value: progress)
                }
            }
            .frame(height: 6)

            Text(achievement.requirement)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.capeCod.driftwood)
        }
    }

    // MARK: - Colors

    private var iconBackgroundColor: Color {
        if isUnlocked {
            return Color.capeCod.oceanBlue.opacity(0.15)
        }
        return Color.capeCod.fog
    }

    private var iconForegroundColor: Color {
        if isUnlocked {
            return Color.capeCod.oceanBlue
        }
        return Color.capeCod.driftwood
    }
}

// MARK: - Preview

#Preview("Achievements View") {
    NavigationStack {
        TourAchievementsView()
    }
}

#Preview("Unlocked Banner") {
    ZStack(alignment: .top) {
        Color.capeCod.background.ignoresSafeArea()

        AchievementUnlockedBanner(achievement: .explorer) {}
            .appear()
            .padding(.top, 60)
    }
}
