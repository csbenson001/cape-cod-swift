import SwiftUI

// MARK: - Beach Status View

/// Live Beach Status feature — shows estimated parking, crowd levels, and conditions
/// for all 12 Cape Cod beaches. Users can report real conditions to override estimates.
struct BeachStatusView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sortOption: BeachSortOption = .status
    @State private var sideFilter: BeachSideFilter = .all
    @State private var reportingBeach: CapeCodBeach?
    @State private var isRefreshing = false
    @State private var refreshTimestamp = Date()
    @State private var shareText = ""
    @State private var showShareSheet = false
    @State private var userReports: [String: UserBeachReport] = UserBeachReport.loadAll()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    headerSection
                        .staggered(index: 0)

                    SharkAlertBanner()
                        .staggered(index: 1)

                    filterBar
                        .staggered(index: 2)

                    sortBar
                        .staggered(index: 3)

                    beachList
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)
            .refreshable {
                await performRefresh()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        CodHaptic.selection()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.capeCod.driftwood)
                    }
                    .codAccessibleButton("Close", hint: "Dismiss beach status")
                }
            }
            .sheet(item: $reportingBeach) { beach in
                ReportConditionsSheet(beach: beach) { report in
                    userReports[beach.id] = report
                    UserBeachReport.save(report, forBeachID: beach.id)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showShareSheet) {
                if !shareText.isEmpty {
                    BeachShareSheet(text: shareText)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "car.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.capeCod.oceanBlue)
                .codAccessibleHidden()

            Text("Live Beach Status")
                .codTextStyle(.heroTitle)
                .multilineTextAlignment(.center)
                .codAccessibleHeader("Live Beach Status")

            Text("Estimated parking & crowd levels")
                .codTextStyle(.subtitle)

            HStack(spacing: CodSpacing.xs) {
                Circle()
                    .fill(Color.capeCod.duneGrass)
                    .frame(width: 6, height: 6)
                    .pulsingGlow(color: Color.capeCod.duneGrass, isActive: true)

                Text("Updated \(refreshTimestamp.beachStatusTimeString)")
                    .codTextStyle(.caption)
            }
            .padding(.top, CodSpacing.xs)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, CodSpacing.lg)
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                ForEach(BeachSideFilter.allCases, id: \.self) { filter in
                    filterChip(filter)
                }
            }
        }
    }

    private func filterChip(_ filter: BeachSideFilter) -> some View {
        Button {
            CodHaptic.selection()
            withAnimation(CodAnimation.quick) {
                sideFilter = filter
            }
        } label: {
            Text(filter.label)
                .font(.system(size: 14, weight: sideFilter == filter ? .semibold : .regular))
                .foregroundStyle(
                    sideFilter == filter
                        ? Color.capeCod.textOnPrimary
                        : Color.capeCod.textPrimary
                )
                .padding(.horizontal, CodSpacing.md)
                .padding(.vertical, CodSpacing.sm)
                .background(
                    sideFilter == filter
                        ? Color.capeCod.oceanBlue
                        : Color.capeCod.surface
                )
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleButton(
            filter.label,
            hint: sideFilter == filter ? "Currently selected" : "Filter by \(filter.label)"
        )
    }

    // MARK: - Sort Bar

    private var sortBar: some View {
        HStack {
            Text("Sort by")
                .codTextStyle(.caption)

            Picker("Sort", selection: $sortOption) {
                ForEach(BeachSortOption.allCases, id: \.self) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: sortOption) { _, _ in
                CodHaptic.selection()
            }

            Spacer()
        }
    }

    // MARK: - Beach List

    private var beachList: some View {
        LazyVStack(spacing: CodSpacing.md) {
            ForEach(Array(sortedFilteredBeaches.enumerated()), id: \.element.id) { index, beach in
                beachStatusCard(beach: beach, index: index)
                    .staggered(index: index + 3)
            }
        }
    }

    // MARK: - Beach Status Card

    private func beachStatusCard(beach: CapeCodBeach, index: Int) -> some View {
        let parking = effectiveParkingStatus(for: beach)
        let crowd = effectiveBeachCrowdLevel(for: beach)
        let hasUserReport = activeUserReport(for: beach.id) != nil

        return VStack(alignment: .leading, spacing: CodSpacing.sm) {
            // Top row: name + share
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(beach.name)
                        .codTextStyle(.cardTitle)

                    Text(beach.town + " \u{00B7} " + beach.side.statusDisplayLabel)
                        .codTextStyle(.caption)
                }

                Spacer()

                Button {
                    CodHaptic.light()
                    shareText = "\(beach.name) has parking right now! \u{1F3D6} #CapeCod via @HeyCapeCode"
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .frame(width: 32, height: 32)
                        .background(Color.capeCod.surface)
                        .clipShape(Circle())
                }
                .buttonStyle(CodButtonPressStyle(variant: .ghost))
                .codAccessibleButton("Share \(beach.name) status")
            }

            // Status indicators
            HStack(spacing: CodSpacing.md) {
                // Parking
                statusBadge(
                    icon: parking.icon,
                    label: parking.label,
                    color: parking.color
                )

                // Crowd
                statusBadge(
                    icon: crowd.icon,
                    label: crowd.label,
                    color: crowd.color
                )
            }

            // Conditions summary
            HStack(spacing: CodSpacing.sm) {
                if beach.hasLifeguards {
                    conditionTag("Lifeguards", icon: "shield.checkered")
                }
                if beach.isKidFriendly {
                    conditionTag("Kid-Friendly", icon: "figure.and.child.holdinghands")
                }
                if beach.hasTidePools {
                    conditionTag("Tide Pools", icon: "fossil.shell.fill")
                }
            }

            // Bottom row: timestamp + report button
            HStack {
                if hasUserReport {
                    HStack(spacing: CodSpacing.xs) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 10))
                        Text("User reported")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(Color.capeCod.seafoam)
                } else {
                    Text("Estimated \u{00B7} \(refreshTimestamp.beachStatusTimeString)")
                        .codTextStyle(.caption)
                }

                Spacer()

                Button {
                    CodHaptic.tap()
                    reportingBeach = beach
                } label: {
                    HStack(spacing: CodSpacing.xs) {
                        Image(systemName: "pencil.line")
                            .font(.system(size: 12))
                        Text("Report")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .padding(.horizontal, CodSpacing.sm)
                    .padding(.vertical, CodSpacing.xs)
                    .background(Color.capeCod.oceanBlue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
                }
                .buttonStyle(CodButtonPressStyle(variant: .ghost))
                .codAccessibleButton("Report conditions at \(beach.name)")
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .codAccessibleCard(
            label: "\(beach.name), \(beach.town). Parking: \(parking.label). Crowds: \(crowd.label)",
            hint: "Tap report to submit current conditions"
        )
    }

    private func statusBadge(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: CodSpacing.xs) {
            Text(icon)
                .font(.system(size: 14))

            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, CodSpacing.sm)
        .padding(.vertical, CodSpacing.xs)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
    }

    private func conditionTag(_ text: String, icon: String) -> some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text(text)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundStyle(Color.capeCod.driftwood)
    }

    // MARK: - Data Logic

    private var sortedFilteredBeaches: [CapeCodBeach] {
        let beaches = BeachRecommendationEngine.beaches

        let filtered: [CapeCodBeach]
        switch sideFilter {
        case .all:
            filtered = beaches
        case .bayside:
            filtered = beaches.filter { $0.side == .bayside }
        case .oceanside:
            filtered = beaches.filter { $0.side == .oceanside }
        case .sound:
            filtered = beaches.filter { $0.side == .sound }
        }

        switch sortOption {
        case .status:
            return filtered.sorted { lhs, rhs in
                effectiveParkingStatus(for: lhs).sortOrder < effectiveParkingStatus(for: rhs).sortOrder
            }
        case .name:
            return filtered.sorted { $0.name < $1.name }
        case .town:
            return filtered.sorted { $0.town < $1.town }
        }
    }

    private func effectiveParkingStatus(for beach: CapeCodBeach) -> ParkingStatus {
        if let report = activeUserReport(for: beach.id) {
            return report.parking
        }
        return ParkingEstimator.estimate(for: beach, at: refreshTimestamp)
    }

    private func effectiveBeachCrowdLevel(for beach: CapeCodBeach) -> BeachCrowdLevel {
        if let report = activeUserReport(for: beach.id) {
            return report.crowd
        }
        return ParkingEstimator.estimateCrowd(for: beach, at: refreshTimestamp)
    }

    private func activeUserReport(for beachID: String) -> UserBeachReport? {
        guard let report = userReports[beachID] else { return nil }
        // User reports expire after 2 hours
        if Date().timeIntervalSince(report.timestamp) < 7200 {
            return report
        }
        return nil
    }

    private func performRefresh() async {
        // Simulate network refresh
        try? await Task.sleep(for: .seconds(0.8))
        await MainActor.run {
            CodHaptic.success()
            refreshTimestamp = Date()
            userReports = UserBeachReport.loadAll()
        }
    }
}

// MARK: - Parking Estimator

/// Estimates parking and crowd status based on time of day, day of week, season, and beach popularity.
enum ParkingEstimator {

    // High-popularity beaches fill first
    private static let highPopularity: Set<String> = ["nauset", "coast-guard", "race-point", "old-silver"]
    private static let lowPopularity: Set<String> = ["chapin", "sandy-neck", "town-neck"]

    static func estimate(for beach: CapeCodBeach, at date: Date) -> ParkingStatus {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let month = calendar.component(.month, from: date)
        let isWeekend = calendar.isDateInWeekend(date)
        let isPeakSeason = (month == 7 || month == 8)
        let isShoulder = (month == 6 || month == 9)

        // Base offset: weekends fill 1 hour earlier
        let weekendShift = isWeekend ? -1 : 0
        // Peak season shifts everything earlier
        let seasonShift = isPeakSeason ? -1 : (isShoulder ? 0 : 1)
        // Popularity shift
        let popShift: Int
        if highPopularity.contains(beach.id) {
            popShift = -1
        } else if lowPopularity.contains(beach.id) {
            popShift = 1
        } else {
            popShift = 0
        }

        let effectiveHour = hour - weekendShift - seasonShift - popShift

        // Off-season (Oct-May, not shoulder): always available
        if !isPeakSeason && !isShoulder {
            if effectiveHour >= 10 && effectiveHour < 15 {
                return .fillingUp
            }
            return .available
        }

        // Time-based estimation
        if effectiveHour < 9 {
            return .available
        } else if effectiveHour < 10 {
            return .fillingUp
        } else if effectiveHour < 15 {
            return .full
        } else if effectiveHour < 16 {
            return .fillingUp
        } else {
            return .available
        }
    }

    static func estimateCrowd(for beach: CapeCodBeach, at date: Date) -> BeachCrowdLevel {
        let parking = estimate(for: beach, at: date)
        switch parking {
        case .available:
            return .light
        case .fillingUp:
            return .moderate
        case .full:
            return .heavy
        }
    }
}

// MARK: - Parking Status

enum ParkingStatus: String, CaseIterable, Codable {
    case available
    case fillingUp
    case full

    var icon: String {
        switch self {
        case .available: return "\u{1F7E2}"
        case .fillingUp: return "\u{1F7E1}"
        case .full: return "\u{1F534}"
        }
    }

    var label: String {
        switch self {
        case .available: return "Spots Available"
        case .fillingUp: return "Filling Up"
        case .full: return "Full"
        }
    }

    var color: Color {
        switch self {
        case .available: return Color.capeCod.duneGrass
        case .fillingUp: return Color.capeCod.sandbarYellow
        case .full: return Color.capeCod.cranberry
        }
    }

    var sortOrder: Int {
        switch self {
        case .available: return 0
        case .fillingUp: return 1
        case .full: return 2
        }
    }
}

// MARK: - Beach Crowd Level

enum BeachCrowdLevel: String, CaseIterable, Codable {
    case light
    case moderate
    case heavy

    var icon: String {
        switch self {
        case .light: return "\u{1F6B6}"
        case .moderate: return "\u{1F6B6}\u{200D}\u{2640}\u{FE0F}"
        case .heavy: return "\u{1F46B}"
        }
    }

    var label: String {
        switch self {
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .heavy: return "Heavy"
        }
    }

    var color: Color {
        switch self {
        case .light: return Color.capeCod.duneGrass
        case .moderate: return Color.capeCod.sandbarYellow
        case .heavy: return Color.capeCod.cranberry
        }
    }
}

// MARK: - Sort & Filter Options

enum BeachSortOption: CaseIterable {
    case status
    case name
    case town

    var label: String {
        switch self {
        case .status: return "Status"
        case .name: return "Name"
        case .town: return "Town"
        }
    }
}

enum BeachSideFilter: CaseIterable {
    case all
    case bayside
    case oceanside
    case sound

    var label: String {
        switch self {
        case .all: return "All"
        case .bayside: return "Bay Side"
        case .oceanside: return "Ocean Side"
        case .sound: return "Sound"
        }
    }
}

// MARK: - User Beach Report

struct UserBeachReport: Codable, Identifiable {
    var id: String { beachID }
    let beachID: String
    let parking: ParkingStatus
    let crowd: BeachCrowdLevel
    let note: String
    let timestamp: Date

    // MARK: - Persistence

    private static let storageKey = "BeachStatusUserReports"

    static func save(_ report: UserBeachReport, forBeachID beachID: String) {
        var all = loadAll()
        all[beachID] = report
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    static func loadAll() -> [String: UserBeachReport] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let reports = try? JSONDecoder().decode([String: UserBeachReport].self, from: data)
        else {
            return [:]
        }
        return reports
    }
}

// MARK: - Report Conditions Sheet

struct ReportConditionsSheet: View {
    let beach: CapeCodBeach
    let onSubmit: (UserBeachReport) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedParking: ParkingStatus = .available
    @State private var selectedCrowd: BeachCrowdLevel = .light
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: CodSpacing.lg) {
                // Beach name
                VStack(spacing: CodSpacing.xs) {
                    Text("Report Conditions")
                        .codTextStyle(.sectionTitle)
                        .codAccessibleHeader("Report Conditions")

                    Text(beach.name)
                        .codTextStyle(.subtitle)
                }
                .padding(.top, CodSpacing.md)

                // Parking picker
                VStack(alignment: .leading, spacing: CodSpacing.sm) {
                    Text("PARKING STATUS")
                        .codTextStyle(.label)

                    HStack(spacing: CodSpacing.sm) {
                        ForEach(ParkingStatus.allCases, id: \.self) { status in
                            reportOptionButton(
                                icon: status.icon,
                                label: status.label,
                                isSelected: selectedParking == status,
                                color: status.color
                            ) {
                                CodHaptic.selection()
                                selectedParking = status
                            }
                        }
                    }
                }

                // Crowd picker
                VStack(alignment: .leading, spacing: CodSpacing.sm) {
                    Text("CROWD LEVEL")
                        .codTextStyle(.label)

                    HStack(spacing: CodSpacing.sm) {
                        ForEach(BeachCrowdLevel.allCases, id: \.self) { level in
                            reportOptionButton(
                                icon: level.icon,
                                label: level.label,
                                isSelected: selectedCrowd == level,
                                color: level.color
                            ) {
                                CodHaptic.selection()
                                selectedCrowd = level
                            }
                        }
                    }
                }

                // Note
                VStack(alignment: .leading, spacing: CodSpacing.sm) {
                    Text("NOTE (OPTIONAL)")
                        .codTextStyle(.label)

                    TextField("e.g., Overflow lot still has spots", text: $note)
                        .font(.system(size: 15))
                        .padding(CodSpacing.cardPadding)
                        .background(Color.capeCod.surface)
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
                }

                Spacer()

                // Submit
                CodButton("Submit Report", variant: .primary, icon: "checkmark.circle.fill", isFullWidth: true) {
                    CodHaptic.success()
                    let report = UserBeachReport(
                        beachID: beach.id,
                        parking: selectedParking,
                        crowd: selectedCrowd,
                        note: note,
                        timestamp: Date()
                    )
                    onSubmit(report)
                    dismiss()
                }

                Text("Reports help others and expire after 2 hours.")
                    .codTextStyle(.caption)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.lg)
            .background(Color.capeCod.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.capeCod.driftwood)
                    }
                    .codAccessibleButton("Close")
                }
            }
        }
    }

    private func reportOptionButton(
        icon: String,
        label: String,
        isSelected: Bool,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: CodSpacing.xs) {
                Text(icon)
                    .font(.system(size: 20))

                Text(label)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? color : Color.capeCod.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, CodSpacing.sm)
            .background(
                isSelected ? color.opacity(0.15) : Color.capeCod.surface
            )
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous)
                    .strokeBorder(isSelected ? color : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleButton("\(label) \(isSelected ? ", selected" : "")")
    }
}

// MARK: - Share Sheet

private struct BeachShareSheet: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Beach Side Display Label (Status-specific)

private extension CapeCodBeach.BeachSide {
    var statusDisplayLabel: String {
        switch self {
        case .bayside: return "Bay Side"
        case .oceanside: return "Ocean Side"
        case .sound: return "Nantucket Sound"
        }
    }
}

// MARK: - Date Formatting

private extension Date {
    var beachStatusTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }
}

// MARK: - Preview

#Preview("Beach Status") {
    BeachStatusView()
}

#Preview("Report Sheet") {
    ReportConditionsSheet(
        beach: BeachRecommendationEngine.beaches[0]
    ) { _ in }
}
