import SwiftUI

// MARK: - Best Time To Go View

struct BestTimeToGoView: View {
    @State private var engine = BestTimeEngine.shared
    @State private var rankings: [BeachRanking] = []
    @State private var selectedBeach: BeachProfile?
    @State private var hasAppeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                headerSection
                if rankings.count >= 3 {
                    topPicksSection
                }
                allBeachesSection
            }
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background.ignoresSafeArea())
        .navigationTitle("When Should I Go?")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedBeach) { beach in
            NavigationStack {
                BeachTimeDetailView(beach: beach)
            }
        }
        .onAppear { loadRankings() }
    }
}

// MARK: - Header

private extension BestTimeToGoView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "clock.badge.checkmark")
                    .font(.title2)
                    .foregroundStyle(Color.capeCod.oceanBlue)
                Text("Today's Beach Intelligence")
                    .codTextStyle(.sectionTitle)
            }
            Text("Optimal visit windows based on tides, crowds, parking, and sun position.")
                .codTextStyle(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.top, CodSpacing.md)
    }
}

// MARK: - Top Picks

private extension BestTimeToGoView {
    var topPicksSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("TOP PICKS")
                .codTextStyle(.label)
                .padding(.horizontal, CodSpacing.screenEdge)

            ForEach(Array(rankings.prefix(3).enumerated()), id: \.element.id) { index, ranking in
                TopPickCard(ranking: ranking, rank: index + 1)
                    .onTapGesture {
                        CodHaptic.tap()
                        selectedBeach = ranking.recommendation.beach
                    }
                    .padding(.horizontal, CodSpacing.screenEdge)
                    .staggered(index: index)
            }
        }
    }
}

// MARK: - All Beaches

private extension BestTimeToGoView {
    var allBeachesSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("ALL BEACHES")
                .codTextStyle(.label)
                .padding(.horizontal, CodSpacing.screenEdge)

            ForEach(Array(rankings.enumerated()), id: \.element.id) { index, ranking in
                BeachTimeRow(recommendation: ranking.recommendation)
                    .onTapGesture {
                        CodHaptic.selection()
                        selectedBeach = ranking.recommendation.beach
                    }
                    .padding(.horizontal, CodSpacing.screenEdge)
                    .staggered(index: index + 3)
            }
        }
    }
}

// MARK: - Data Loading

private extension BestTimeToGoView {
    func loadRankings() {
        guard !hasAppeared else { return }
        hasAppeared = true
        withAnimation(CodAnimation.gentle) {
            rankings = engine.rankBeachesForToday()
        }
    }
}

// MARK: - Top Pick Card

private struct TopPickCard: View {
    let ranking: BeachRanking
    let rank: Int

    private var rec: BestTimeRecommendation { ranking.recommendation }

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            topRow
            timeAndRatingRow
            reasonsRow
            if !rec.quickTip.isEmpty {
                quickTipBanner
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private var topRow: some View {
        HStack {
            RankBadge(rank: rank)
            VStack(alignment: .leading, spacing: 2) {
                Text(rec.beach.name)
                    .codTextStyle(.cardTitle)
                Text(rec.beach.town)
                    .codTextStyle(.caption)
            }
            Spacer()
            CrowdBadge(level: rec.crowdLevel)
        }
    }

    private var timeAndRatingRow: some View {
        HStack {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: "clock")
                    .foregroundStyle(Color.capeCod.oceanBlue)
                Text(rec.optimalWindow)
                    .codTextStyle(.body)
            }
            Spacer()
            StarRating(rating: rec.rating)
        }
    }

    private var reasonsRow: some View {
        HStack(spacing: CodSpacing.md) {
            ReasonChip(icon: "water.waves", text: rec.tideInfo.components(separatedBy: "—").first?.trimmingCharacters(in: .whitespaces) ?? "Tides")
            ReasonChip(icon: "car.fill", text: rec.parkingTip.components(separatedBy: "—").first?.trimmingCharacters(in: .whitespaces) ?? "Parking")
        }
        .lineLimit(1)
    }

    private var quickTipBanner: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(Color.capeCod.sunsetOrange)
                .font(.caption)
            Text(rec.quickTip)
                .codTextStyle(.caption)
        }
        .padding(CodSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.capeCod.sand.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
    }
}

// MARK: - Beach Time Row

private struct BeachTimeRow: View {
    let recommendation: BestTimeRecommendation

    var body: some View {
        HStack(spacing: CodSpacing.md) {
            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                Text(recommendation.beach.name)
                    .codTextStyle(.cardTitle)
                Text(recommendation.beach.town)
                    .codTextStyle(.caption)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: CodSpacing.xs) {
                Text(recommendation.optimalWindow)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.capeCod.oceanBlue)
                StarRating(rating: recommendation.rating, size: 10)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }
}

// MARK: - Reusable Components

private struct RankBadge: View {
    let rank: Int

    var body: some View {
        Text("#\(rank)")
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 32, height: 32)
            .background(rankColor)
            .clipShape(Circle())
    }

    private var rankColor: Color {
        switch rank {
        case 1: return Color.capeCod.sunsetOrange
        case 2: return Color.capeCod.oceanBlue
        default: return Color.capeCod.seafoam
        }
    }
}

private struct CrowdBadge: View {
    let level: CrowdLevel

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: level.icon)
            Text(level.rawValue)
        }
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(crowdColor)
        .padding(.horizontal, CodSpacing.sm)
        .padding(.vertical, CodSpacing.xs)
        .background(crowdColor.opacity(0.12))
        .clipShape(Capsule())
    }

    private var crowdColor: Color {
        switch level {
        case .low: return Color.capeCod.duneGrass
        case .moderate: return Color.capeCod.oceanBlue
        case .busy: return Color.capeCod.sandbarYellow
        case .packed: return Color.capeCod.cranberry
        }
    }
}

private struct StarRating: View {
    let rating: Int
    var size: CGFloat = 12

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(star <= rating ? Color.capeCod.sunsetOrange : Color.capeCod.driftwood.opacity(0.4))
            }
        }
    }
}

private struct ReasonChip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: CodSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 11))
        }
        .foregroundStyle(Color.capeCod.textSecondary)
        .lineLimit(1)
    }
}

// MARK: - BeachProfile Identifiable Conformance for Sheet

extension BeachProfile: @retroactive Hashable {
    static func == (lhs: BeachProfile, rhs: BeachProfile) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#Preview {
    NavigationStack {
        BestTimeToGoView()
    }
}
