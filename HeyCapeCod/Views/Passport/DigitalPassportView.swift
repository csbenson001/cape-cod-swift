import SwiftUI

// MARK: - Passport Data Models

/// XP level tiers for the Cape Cod Digital Passport.
enum PassportLevel: Int, CaseIterable {
    case beachNewcomer = 1
    case sandyExplorer = 2
    case capeAdventurer = 3
    case seasonedLocal = 4
    case capeCodLegend = 5

    var displayName: String {
        switch self {
        case .beachNewcomer: return "Beach Newcomer"
        case .sandyExplorer: return "Sandy Explorer"
        case .capeAdventurer: return "Cape Adventurer"
        case .seasonedLocal: return "Seasoned Local"
        case .capeCodLegend: return "Cape Cod Legend"
        }
    }

    var icon: String {
        switch self {
        case .beachNewcomer: return "figure.walk"
        case .sandyExplorer: return "binoculars.fill"
        case .capeAdventurer: return "map.fill"
        case .seasonedLocal: return "star.fill"
        case .capeCodLegend: return "crown.fill"
        }
    }

    /// Minimum XP required to reach this level.
    var minXP: Int {
        switch self {
        case .beachNewcomer: return 0
        case .sandyExplorer: return 51
        case .capeAdventurer: return 151
        case .seasonedLocal: return 301
        case .capeCodLegend: return 501
        }
    }

    /// Maximum XP for this level (exclusive upper bound for progress bar).
    var maxXP: Int {
        switch self {
        case .beachNewcomer: return 50
        case .sandyExplorer: return 150
        case .capeAdventurer: return 300
        case .seasonedLocal: return 500
        case .capeCodLegend: return 1000 // Arbitrary cap for progress display
        }
    }

    static func level(for xp: Int) -> PassportLevel {
        if xp >= 501 { return .capeCodLegend }
        if xp >= 301 { return .seasonedLocal }
        if xp >= 151 { return .capeAdventurer }
        if xp >= 51 { return .sandyExplorer }
        return .beachNewcomer
    }

    /// Progress within the current level as a 0...1 fraction.
    func progress(for xp: Int) -> Double {
        let range = maxXP - minXP
        guard range > 0 else { return 1.0 }
        let clamped = min(max(xp - minXP, 0), range)
        return Double(clamped) / Double(range)
    }
}

/// A single stamp location within a trail.
struct PassportStamp: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    var checkedInDate: Date?

    var isCheckedIn: Bool { checkedInDate != nil }
}

/// A collection of stamps forming a trail to complete.
struct PassportTrail: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let requiredCount: Int
    var stamps: [PassportStamp]

    var completedCount: Int { stamps.filter(\.isCheckedIn).count }
    var progress: Double { Double(completedCount) / Double(requiredCount) }
    var isComplete: Bool { completedCount >= requiredCount }
}

// MARK: - Passport Persistence

private enum PassportPersistence {
    static let stampsKey = "digital_passport_stamps"
    static let memberSinceKey = "digital_passport_member_since"
    static let streakDatesKey = "digital_passport_streak_dates"

    static func loadStamps() -> [String: Date] {
        guard let data = UserDefaults.standard.data(forKey: stampsKey),
              let stamps = try? JSONDecoder().decode([String: Date].self, from: data) else {
            return [:]
        }
        return stamps
    }

    static func saveStamps(_ stamps: [String: Date]) {
        if let data = try? JSONEncoder().encode(stamps) {
            UserDefaults.standard.set(data, forKey: stampsKey)
        }
    }

    static func loadMemberSince() -> Date {
        let timestamp = UserDefaults.standard.double(forKey: memberSinceKey)
        if timestamp > 0 {
            return Date(timeIntervalSince1970: timestamp)
        }
        let now = Date.now
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: memberSinceKey)
        return now
    }

    static func loadStreakDates() -> Set<String> {
        guard let array = UserDefaults.standard.array(forKey: streakDatesKey) as? [String] else {
            return []
        }
        return Set(array)
    }

    static func saveStreakDates(_ dates: Set<String>) {
        UserDefaults.standard.set(Array(dates), forKey: streakDatesKey)
    }
}

// MARK: - Trail Definitions

private extension PassportTrail {

    static func allTrails(stamps: [String: Date]) -> [PassportTrail] {
        [beachTrail, lighthouseQuest, seafoodTrail, artWalk, natureExplorer, pirateAdventure, hauntedCape]
            .map { trail in
                var mutable = trail
                for i in mutable.stamps.indices {
                    mutable.stamps[i].checkedInDate = stamps[mutable.stamps[i].id]
                }
                return mutable
            }
    }

    static var beachTrail: PassportTrail {
        PassportTrail(
            id: "beach_trail",
            name: "Beach Trail",
            icon: "\u{1F3D6}",
            description: "Visit 8 of the 12 best Cape Cod beaches",
            requiredCount: 8,
            stamps: [
                PassportStamp(id: "beach_nauset", name: "Nauset Beach"),
                PassportStamp(id: "beach_coast_guard", name: "Coast Guard Beach"),
                PassportStamp(id: "beach_marconi", name: "Marconi Beach"),
                PassportStamp(id: "beach_race_point", name: "Race Point Beach"),
                PassportStamp(id: "beach_herring_cove", name: "Herring Cove Beach"),
                PassportStamp(id: "beach_sandy_neck", name: "Sandy Neck Beach"),
                PassportStamp(id: "beach_old_silver", name: "Old Silver Beach"),
                PassportStamp(id: "beach_mayflower", name: "Mayflower Beach"),
                PassportStamp(id: "beach_skaket", name: "Skaket Beach"),
                PassportStamp(id: "beach_corporation", name: "Corporation Beach"),
                PassportStamp(id: "beach_chapin", name: "Chapin Memorial Beach"),
                PassportStamp(id: "beach_cahoon_hollow", name: "Cahoon Hollow Beach"),
            ]
        )
    }

    static var lighthouseQuest: PassportTrail {
        PassportTrail(
            id: "lighthouse_quest",
            name: "Lighthouse Quest",
            icon: "\u{1F526}",
            description: "Visit all 10 Cape Cod lighthouses",
            requiredCount: 10,
            stamps: [
                PassportStamp(id: "light_highland", name: "Highland Light"),
                PassportStamp(id: "light_nauset", name: "Nauset Light"),
                PassportStamp(id: "light_chatham", name: "Chatham Light"),
                PassportStamp(id: "light_nobska", name: "Nobska Light"),
                PassportStamp(id: "light_race_point", name: "Race Point Light"),
                PassportStamp(id: "light_wood_end", name: "Wood End Light"),
                PassportStamp(id: "light_long_point", name: "Long Point Light"),
                PassportStamp(id: "light_sandy_neck", name: "Sandy Neck Light"),
                PassportStamp(id: "light_stage_harbor", name: "Stage Harbor Light"),
                PassportStamp(id: "light_bass_river", name: "Bass River Light"),
            ]
        )
    }

    static var seafoodTrail: PassportTrail {
        PassportTrail(
            id: "seafood_trail",
            name: "Seafood Trail",
            icon: "\u{1F99E}",
            description: "Eat at 6 different clam shacks & lobster spots",
            requiredCount: 6,
            stamps: [
                PassportStamp(id: "food_arnolds", name: "Arnold's Lobster & Clam Bar"),
                PassportStamp(id: "food_kream_n_kone", name: "Kream 'N Kone"),
                PassportStamp(id: "food_cookes", name: "Cooke's Seafood"),
                PassportStamp(id: "food_captain_froslys", name: "Captain Frosty's"),
                PassportStamp(id: "food_mac_shack", name: "Mac's Shack"),
                PassportStamp(id: "food_pjs_family", name: "PJ's Family Restaurant"),
                PassportStamp(id: "food_sams_deli", name: "Sam's Deli"),
                PassportStamp(id: "food_land_ho", name: "Land Ho!"),
            ]
        )
    }

    static var artWalk: PassportTrail {
        PassportTrail(
            id: "art_walk",
            name: "Art Walk",
            icon: "\u{1F3A8}",
            description: "Visit 5 galleries across the Cape",
            requiredCount: 5,
            stamps: [
                PassportStamp(id: "art_paam", name: "PAAM (Provincetown)"),
                PassportStamp(id: "art_wellfleet", name: "Wellfleet Galleries"),
                PassportStamp(id: "art_chatham", name: "Chatham Creative Arts"),
                PassportStamp(id: "art_dennis", name: "Cape Cod Museum of Art"),
                PassportStamp(id: "art_sandwich", name: "Sandwich Glass Museum"),
            ]
        )
    }

    static var natureExplorer: PassportTrail {
        PassportTrail(
            id: "nature_explorer",
            name: "Nature Explorer",
            icon: "\u{1F33F}",
            description: "Visit 5 nature sites on the Cape",
            requiredCount: 5,
            stamps: [
                PassportStamp(id: "nature_seashore", name: "Cape Cod National Seashore"),
                PassportStamp(id: "nature_wellfleet_bay", name: "Wellfleet Bay Sanctuary"),
                PassportStamp(id: "nature_monomoy", name: "Monomoy NWR"),
                PassportStamp(id: "nature_museum", name: "CC Museum of Natural History"),
                PassportStamp(id: "nature_nickerson", name: "Nickerson State Park"),
            ]
        )
    }

    static var pirateAdventure: PassportTrail {
        PassportTrail(
            id: "pirate_adventure",
            name: "Pirate Adventure",
            icon: "\u{1F3F4}\u{200D}\u{2620}\u{FE0F}",
            description: "Discover Cape Cod's pirate history",
            requiredCount: 4,
            stamps: [
                PassportStamp(id: "pirate_whydah", name: "Whydah Pirate Museum"),
                PassportStamp(id: "pirate_expedition", name: "Expedition Whydah"),
                PassportStamp(id: "pirate_marconi", name: "Marconi Beach Wreck Site"),
                PassportStamp(id: "pirate_museum", name: "Pirate Museum"),
            ]
        )
    }

    static var hauntedCape: PassportTrail {
        PassportTrail(
            id: "haunted_cape",
            name: "Haunted Cape",
            icon: "\u{1F47B}",
            description: "Visit 5 haunted and legendary locations",
            requiredCount: 5,
            stamps: [
                PassportStamp(id: "haunt_orleans_inn", name: "Orleans Inn"),
                PassportStamp(id: "haunt_barnstable", name: "Old Jail (Barnstable)"),
                PassportStamp(id: "haunt_highland", name: "Highland Light (Ghost)"),
                PassportStamp(id: "haunt_dan_sears", name: "Dan'l Webster Inn"),
                PassportStamp(id: "haunt_cemetery", name: "Old Cove Cemetery"),
            ]
        )
    }
}

// MARK: - XP Constants

private enum PassportXP {
    static let checkIn = 10
    static let trailCompletion = 25
    static let badge = 50
}

// MARK: - Digital Passport View

struct DigitalPassportView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var checkedStamps: [String: Date] = PassportPersistence.loadStamps()
    @State private var streakDates: Set<String> = PassportPersistence.loadStreakDates()
    @State private var memberSince: Date = PassportPersistence.loadMemberSince()

    @State private var showConfetti = false
    @State private var confettiStampID: String?
    @State private var xpGainedAmount: Int?
    @State private var showXPNotification = false
    @State private var showShareCard = false
    @State private var selectedTrailID: String?

    private var trails: [PassportTrail] {
        PassportTrail.allTrails(stamps: checkedStamps)
    }

    private var totalXP: Int {
        let checkInXP = checkedStamps.count * PassportXP.checkIn
        let completedTrails = trails.filter(\.isComplete)
        let trailXP = completedTrails.count * PassportXP.trailCompletion
        let badgeXP = completedTrails.count * PassportXP.badge
        return checkInXP + trailXP + badgeXP
    }

    private var currentLevel: PassportLevel {
        PassportLevel.level(for: totalXP)
    }

    private var totalCheckIns: Int { checkedStamps.count }
    private var completedTrailCount: Int { trails.filter(\.isComplete).count }

    private var currentStreak: Int {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var streak = 0
        var date = Date.now

        while true {
            let key = formatter.string(from: date)
            if streakDates.contains(key) {
                streak += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: date) else { break }
                date = prev
            } else {
                break
            }
        }
        return streak
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: CodSpacing.sectionSpacing) {
                        passportHeader
                            .staggered(index: 0)

                        statsSection
                            .staggered(index: 1)

                        trailsSection

                        passportCardSection
                            .staggered(index: 2 + trails.count)
                    }
                    .padding(.bottom, CodSpacing.tabBarClearance)
                }
                .background(Color.capeCod.background)

                // XP Notification Banner
                if showXPNotification, let amount = xpGainedAmount {
                    xpNotificationBanner(amount: amount)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(10)
                }

                // Confetti Overlay
                if showConfetti {
                    confettiOverlay
                        .zIndex(20)
                }
            }
            .navigationTitle("Digital Passport")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.capeCod.driftwood)
                    }
                }
            }
        }
    }

    // MARK: - Passport Header

    private var passportHeader: some View {
        VStack(spacing: CodSpacing.lg) {
            // Level badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.capeCod.sandbarYellow, Color.capeCod.sunsetOrange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .shadow(color: Color.capeCod.sunsetOrange.opacity(0.3), radius: 12, y: 4)

                Image(systemName: currentLevel.icon)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: CodSpacing.xs) {
                Text("Level \(currentLevel.rawValue)")
                    .codTextStyle(.label)

                Text(currentLevel.displayName)
                    .codTextStyle(.heroTitle)
            }

            // XP Progress Bar
            VStack(spacing: CodSpacing.sm) {
                HStack {
                    Text("\(totalXP) XP")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.capeCod.textPrimary)

                    Spacer()

                    if currentLevel != .capeCodLegend {
                        Text("\(currentLevel.maxXP) XP to next level")
                            .codTextStyle(.caption)
                    } else {
                        Text("Max Level")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.capeCod.sandbarYellow)
                    }
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.capeCod.fog)
                            .frame(height: 10)

                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.capeCod.sunsetGradient)
                            .frame(
                                width: geometry.size.width * currentLevel.progress(for: totalXP),
                                height: 10
                            )
                            .animation(CodAnimation.spring, value: totalXP)
                    }
                }
                .frame(height: 10)

                // XP breakdown
                HStack(spacing: CodSpacing.md) {
                    xpInfoPill(icon: "mappin", text: "+\(PassportXP.checkIn) check-in")
                    xpInfoPill(icon: "flag.fill", text: "+\(PassportXP.trailCompletion) trail")
                    xpInfoPill(icon: "star.fill", text: "+\(PassportXP.badge) badge")
                }
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.top, CodSpacing.md)
    }

    private func xpInfoPill(icon: String, text: String) -> some View {
        HStack(spacing: CodSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.capeCod.sunsetOrange)

            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.capeCod.textSecondary)
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        HStack(spacing: CodSpacing.sm) {
            statCard(icon: "mappin.and.ellipse", value: "\(totalCheckIns)", label: "Check-ins")
            statCard(icon: "flag.checkered", value: "\(completedTrailCount)", label: "Trails Done")
            statCard(icon: "flame.fill", value: "\(currentStreak)", label: "Day Streak")
            statCard(icon: "calendar", value: memberSinceFormatted, label: "Member")
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    private var memberSinceFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy"
        return formatter.string(from: memberSince)
    }

    private func statCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: CodSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.capeCod.oceanBlue)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.capeCod.textPrimary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.capeCod.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CodSpacing.sm + 2)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
        .adaptiveCardStyle(cornerRadius: CodRadius.sm)
    }

    // MARK: - Trails Section

    private var trailsSection: some View {
        VStack(spacing: CodSpacing.md) {
            HStack {
                Text("Trails")
                    .codTextStyle(.sectionTitle)

                Spacer()

                Text("\(completedTrailCount)/\(trails.count) complete")
                    .codTextStyle(.caption)
            }
            .padding(.horizontal, CodSpacing.screenEdge)

            ForEach(Array(trails.enumerated()), id: \.element.id) { index, trail in
                trailCard(trail: trail)
                    .staggered(index: index + 2)
            }
        }
    }

    private func trailCard(trail: PassportTrail) -> some View {
        let isExpanded = selectedTrailID == trail.id

        return VStack(spacing: 0) {
            // Trail Header
            Button {
                withAnimation(CodAnimation.spring) {
                    selectedTrailID = isExpanded ? nil : trail.id
                }
                CodHaptic.selection()
            } label: {
                HStack(spacing: CodSpacing.sm) {
                    // Trail icon
                    Text(trail.icon)
                        .font(.system(size: 28))
                        .frame(width: 44, height: 44)
                        .background(
                            trail.isComplete
                                ? Color.capeCod.duneGrass.opacity(0.15)
                                : Color.capeCod.oceanBlue.opacity(0.1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))

                    VStack(alignment: .leading, spacing: CodSpacing.xs) {
                        HStack {
                            Text(trail.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.capeCod.textPrimary)

                            if trail.isComplete {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.capeCod.duneGrass)
                            }
                        }

                        Text(trail.description)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(Color.capeCod.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Progress indicator
                    VStack(spacing: 2) {
                        Text("\(trail.completedCount)/\(trail.requiredCount)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                trail.isComplete
                                    ? Color.capeCod.duneGrass
                                    : Color.capeCod.oceanBlue
                            )

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.capeCod.driftwood)
                    }
                }
                .padding(CodSpacing.cardPadding)
            }
            .buttonStyle(.plain)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.capeCod.fog)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(
                            trail.isComplete
                                ? Color.capeCod.duneGrass
                                : Color.capeCod.oceanBlue
                        )
                        .frame(width: geometry.size.width * trail.progress, height: 4)
                        .animation(CodAnimation.spring, value: trail.progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, CodSpacing.cardPadding)

            // Expanded stamp grid
            if isExpanded {
                stampGrid(trail: trail)
                    .padding(CodSpacing.cardPadding)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Stamp Grid

    private func stampGrid(trail: PassportTrail) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: CodSpacing.sm),
            GridItem(.flexible(), spacing: CodSpacing.sm),
            GridItem(.flexible(), spacing: CodSpacing.sm),
        ]

        return VStack(spacing: CodSpacing.md) {
            LazyVGrid(columns: columns, spacing: CodSpacing.sm) {
                ForEach(trail.stamps) { stamp in
                    stampSlot(stamp: stamp, trail: trail)
                }
            }

            // Badge for completed trail
            if trail.isComplete {
                completedBadge(trail: trail)
            }
        }
    }

    private func stampSlot(stamp: PassportStamp, trail: PassportTrail) -> some View {
        let isCheckedIn = checkedStamps[stamp.id] != nil

        return VStack(spacing: CodSpacing.xs) {
            ZStack {
                RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous)
                    .fill(
                        isCheckedIn
                            ? Color.capeCod.oceanBlue.opacity(0.12)
                            : Color.capeCod.fog
                    )
                    .frame(height: 64)

                if isCheckedIn {
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.capeCod.oceanBlue)

                        if let date = checkedStamps[stamp.id] {
                            Text(shortDate(date))
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(Color.capeCod.textSecondary)
                        }
                    }
                } else {
                    Button {
                        checkIn(stamp: stamp, trail: trail)
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.capeCod.driftwood.opacity(0.5))

                            Text("Check In")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color.capeCod.driftwood)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(stamp.name)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(
                    isCheckedIn
                        ? Color.capeCod.textPrimary
                        : Color.capeCod.textSecondary
                )
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func completedBadge(trail: PassportTrail) -> some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.capeCod.sandbarYellow, Color.capeCod.sunsetOrange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("\(trail.name) Badge Earned!")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.capeCod.textPrimary)

                Text("+\(PassportXP.badge) XP")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.capeCod.sunsetOrange)
            }

            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color.capeCod.duneGrass)
        }
        .padding(CodSpacing.sm + 2)
        .background(
            LinearGradient(
                colors: [
                    Color.capeCod.sandbarYellow.opacity(0.1),
                    Color.capeCod.sunsetOrange.opacity(0.05),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous)
                .strokeBorder(Color.capeCod.sandbarYellow.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Passport Card (Shareable)

    private var passportCardSection: some View {
        VStack(spacing: CodSpacing.md) {
            HStack {
                Text("Your Passport Card")
                    .codTextStyle(.sectionTitle)
                Spacer()
            }

            passportShareCard

            ShareLink(
                item: passportShareText,
                preview: SharePreview("My Cape Cod Passport", image: Image(systemName: "globe"))
            ) {
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Share Passport")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
                .foregroundStyle(Color.capeCod.textOnPrimary)
                .background(Color.capeCod.sunsetOrange)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
            }
            .buttonStyle(CodButtonPressStyle(variant: .accent))
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    private var passportShareText: String {
        let trailNames = trails.filter(\.isComplete).map(\.name).joined(separator: ", ")
        let trailSuffix = trailNames.isEmpty ? "" : " Completed: \(trailNames)."
        return "I'm a Level \(currentLevel.rawValue) \(currentLevel.displayName) on my Cape Cod Digital Passport! \(totalCheckIns) check-ins, \(completedTrailCount) trails completed.\(trailSuffix) #HeyCapeCodeApp #CapeCodPassport"
    }

    private var passportShareCard: some View {
        VStack(spacing: CodSpacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CAPE COD")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.8))

                    Text("Digital Passport")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                Image(systemName: currentLevel.icon)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.capeCod.sandbarYellow)
            }

            Divider()
                .background(.white.opacity(0.3))

            // Level & Stats
            HStack(spacing: CodSpacing.lg) {
                VStack(spacing: 2) {
                    Text("\(currentLevel.rawValue)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Level")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }

                VStack(spacing: 2) {
                    Text("\(totalCheckIns)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Stamps")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }

                VStack(spacing: 2) {
                    Text("\(completedTrailCount)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Trails")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()
            }

            // Level name
            HStack {
                Text(currentLevel.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.capeCod.sandbarYellow)

                Spacer()

                Text("\(totalXP) XP")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(CodSpacing.lg)
        .background(
            LinearGradient(
                colors: [
                    Color.capeCod.deepNavy,
                    Color.capeCod.oceanBlue,
                    Color.capeCod.deepNavy.opacity(0.9),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.featured, style: .continuous))
        .codShadow(.elevated)
    }

    // MARK: - Check-In Action

    private func checkIn(stamp: PassportStamp, trail: PassportTrail) {
        let now = Date.now
        checkedStamps[stamp.id] = now
        PassportPersistence.saveStamps(checkedStamps)

        // Record streak date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        streakDates.insert(formatter.string(from: now))
        PassportPersistence.saveStreakDates(streakDates)

        // Calculate XP gained
        var xpGained = PassportXP.checkIn

        // Check if this check-in completed the trail
        let updatedTrails = PassportTrail.allTrails(stamps: checkedStamps)
        if let updatedTrail = updatedTrails.first(where: { $0.id == trail.id }),
           updatedTrail.isComplete,
           !trail.isComplete {
            xpGained += PassportXP.trailCompletion + PassportXP.badge
        }

        // Haptic + confetti
        CodHaptic.success()
        confettiStampID = stamp.id

        withAnimation(CodAnimation.bouncy) {
            showConfetti = true
        }

        // Show XP notification
        xpGainedAmount = xpGained
        withAnimation(CodAnimation.spring) {
            showXPNotification = true
        }

        // Auto-dismiss confetti and notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(CodAnimation.spring) {
                showConfetti = false
                confettiStampID = nil
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(CodAnimation.spring) {
                showXPNotification = false
                xpGainedAmount = nil
            }
        }
    }

    // MARK: - XP Notification Banner

    private func xpNotificationBanner(amount: Int) -> some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.capeCod.sandbarYellow)

            Text("+\(amount) XP")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("earned!")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))

            Spacer()
        }
        .padding(.horizontal, CodSpacing.cardPadding)
        .padding(.vertical, CodSpacing.sm + 4)
        .background(
            LinearGradient(
                colors: [Color.capeCod.oceanBlue, Color.capeCod.seafoam],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .codShadow(.elevated)
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.top, CodSpacing.sm)
    }

    // MARK: - Confetti Overlay

    private var confettiOverlay: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { i in
                ConfettiParticle(index: i, isActive: showConfetti)
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    // MARK: - Helpers

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

// MARK: - Confetti Particle

private struct ConfettiParticle: View {
    let index: Int
    let isActive: Bool

    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0

    private let icons = [
        "star.fill", "sparkle", "circle.fill", "diamond.fill",
        "heart.fill", "seal.fill", "triangle.fill", "square.fill",
    ]

    private let colors: [Color] = [
        Color.capeCod.sunsetOrange, Color.capeCod.oceanBlue,
        Color.capeCod.seafoam, Color.capeCod.sandbarYellow,
        Color.capeCod.cranberry, Color.capeCod.duneGrass,
    ]

    private var randomXStart: CGFloat {
        CGFloat.random(in: -80...80)
    }

    var body: some View {
        Image(systemName: icons[index % icons.count])
            .font(.system(size: CGFloat.random(in: 8...16)))
            .foregroundStyle(colors[index % colors.count])
            .offset(x: offsetX, y: offsetY)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                guard isActive else { return }
                let startX = CGFloat(index % 5) * 60 - 120
                offsetX = startX
                offsetY = UIScreen.main.bounds.height / 3

                withAnimation(
                    .easeOut(duration: Double.random(in: 1.0...2.0))
                    .delay(Double(index) * 0.03)
                ) {
                    offsetY = -UIScreen.main.bounds.height / 2
                    offsetX = startX + CGFloat.random(in: -100...100)
                    rotation = Double.random(in: -360...360)
                    opacity = 1
                }

                withAnimation(
                    .easeIn(duration: 0.5)
                    .delay(Double(index) * 0.03 + 1.0)
                ) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Preview

#Preview("Digital Passport") {
    DigitalPassportView()
}

#Preview("Digital Passport - With Data") {
    DigitalPassportView()
        .onAppear {
            let sampleStamps: [String: Date] = [
                "beach_nauset": .now,
                "beach_coast_guard": .now,
                "beach_marconi": .now,
                "light_highland": .now,
                "light_nauset": .now,
                "light_chatham": .now,
                "food_arnolds": .now,
                "nature_seashore": .now,
                "art_paam": .now,
                "pirate_whydah": .now,
            ]
            if let data = try? JSONEncoder().encode(sampleStamps) {
                UserDefaults.standard.set(data, forKey: "digital_passport_stamps")
            }
        }
}
