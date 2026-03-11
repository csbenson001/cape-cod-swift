import SwiftUI

// MARK: - Tide Planner View

/// Tide-Smart Day Planner: generates a full day itinerary for Cape Cod
/// that accounts for tide times, sunset, and user interests.
/// Presented as a `.sheet()` from HomeView. Self-contained, iOS 17+.
struct TidePlannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: PlannerDate = .today
    @State private var customDate: Date = .now
    @State private var interests: Set<TidePlannerInterest> = [.beach, .dining]
    @State private var withKids = false
    @State private var generatedPlan: DayPlan?
    @State private var isGenerating = false
    @State private var showShareSheet = false
    @State private var showDatePicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    if let plan = generatedPlan {
                        planHeaderCard(plan)
                            .staggered(index: 0)

                        tideOverviewCard(plan)
                            .staggered(index: 1)

                        timelineSection(plan)
                            .staggered(index: 2)

                        actionButtons
                            .staggered(index: 3)
                    } else {
                        inputSection
                    }
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Day Planner")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if generatedPlan != nil {
                        Button {
                            withAnimation(CodAnimation.spring) {
                                generatedPlan = nil
                            }
                            CodHaptic.light()
                        } label: {
                            HStack(spacing: CodSpacing.xs) {
                                Image(systemName: "chevron.left")
                                Text("Edit")
                            }
                            .foregroundStyle(Color.capeCod.primary)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.capeCod.driftwood)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                shareSheet
            }
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(spacing: CodSpacing.lg) {
            // Hero
            VStack(spacing: CodSpacing.sm) {
                Image(systemName: "water.waves")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .symbolEffect(.variableColor.iterative, options: .repeating)

                Text("Tide-Smart Day Planner")
                    .codTextStyle(.sectionTitle)

                Text("Plan your perfect Cape Cod day around the tides, sunset, and your interests.")
                    .codTextStyle(.body)
                    .foregroundStyle(Color.capeCod.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, CodSpacing.md)
            .staggered(index: 0)

            // Date Selector
            dateSelector
                .staggered(index: 1)

            // TidePlannerInterest Toggles
            interestGrid
                .staggered(index: 2)

            // Kids Toggle
            kidsToggle
                .staggered(index: 3)

            // Generate Button
            CodButton("Generate My Day", variant: .primary, icon: "sparkles", isFullWidth: true) {
                generatePlan()
            }
            .staggered(index: 4)
        }
    }

    // MARK: - Date Selector

    private var dateSelector: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("WHEN")
                .codTextStyle(.label)

            HStack(spacing: CodSpacing.sm) {
                ForEach(PlannerDate.allCases, id: \.self) { option in
                    Button {
                        withAnimation(CodAnimation.quick) {
                            selectedDate = option
                            if option == .pickDate {
                                showDatePicker = true
                            }
                        }
                        CodHaptic.selection()
                    } label: {
                        Text(option.label)
                            .font(.system(size: 14, weight: selectedDate == option ? .semibold : .regular))
                            .foregroundStyle(selectedDate == option ? Color.capeCod.textOnPrimary : Color.capeCod.textPrimary)
                            .padding(.horizontal, CodSpacing.md)
                            .padding(.vertical, CodSpacing.sm)
                            .background(selectedDate == option ? Color.capeCod.oceanBlue : Color.capeCod.surface)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            if showDatePicker && selectedDate == .pickDate {
                DatePicker("Select Date", selection: $customDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Color.capeCod.oceanBlue)
                    .padding(CodSpacing.sm)
                    .background(Color.capeCod.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
                    .transition(.codScale)
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - TidePlannerInterest Grid

    private var interestGrid: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("INTERESTS")
                .codTextStyle(.label)

            LazyVGrid(columns: [
                GridItem(.flexible()), GridItem(.flexible()),
                GridItem(.flexible()), GridItem(.flexible())
            ], spacing: CodSpacing.sm) {
                ForEach(TidePlannerInterest.allCases, id: \.self) { interest in
                    interestChip(interest)
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private func interestChip(_ interest: TidePlannerInterest) -> some View {
        let isSelected = interests.contains(interest)
        return Button {
            withAnimation(CodAnimation.quick) {
                if isSelected {
                    interests.remove(interest)
                } else {
                    interests.insert(interest)
                }
            }
            CodHaptic.selection()
        } label: {
            VStack(spacing: CodSpacing.xs) {
                Image(systemName: interest.icon)
                    .font(.system(size: 18))
                Text(interest.label)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, CodSpacing.sm)
            .foregroundStyle(isSelected ? Color.capeCod.textOnPrimary : Color.capeCod.textPrimary)
            .background(isSelected ? interest.color : Color.capeCod.surface)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
        }
        .buttonStyle(.plain)
        .codAccessibleButton(
            "\(interest.label), \(isSelected ? "selected" : "not selected")",
            hint: "Double tap to \(isSelected ? "remove" : "add") \(interest.label)"
        )
    }

    // MARK: - Kids Toggle

    private var kidsToggle: some View {
        HStack {
            Image(systemName: withKids ? "figure.and.child.holdinghands" : "figure.walk")
                .font(.title3)
                .foregroundStyle(Color.capeCod.oceanBlue)
                .contentTransition(.symbolEffect(.replace))

            VStack(alignment: .leading, spacing: 2) {
                Text("With Kids")
                    .codTextStyle(.cardTitle)
                Text("Adjusts for shorter walks, calmer beaches, kid-friendly stops")
                    .codTextStyle(.caption)
            }

            Spacer()

            Toggle("", isOn: $withKids)
                .tint(Color.capeCod.oceanBlue)
                .labelsHidden()
                .onChange(of: withKids) { _, _ in
                    CodHaptic.selection()
                }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Plan Header

    private func planHeaderCard(_ plan: DayPlan) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    Text(plan.template.title)
                        .codTextStyle(.sectionTitle)
                    Text(plan.dateLabel)
                        .codTextStyle(.caption)
                }
                Spacer()
                Image(systemName: plan.template.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }

            Text(plan.template.description)
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)

            if withKids {
                HStack(spacing: CodSpacing.xs) {
                    Image(systemName: "figure.and.child.holdinghands")
                        .font(.caption)
                    Text("Kid-Friendly Plan")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(Color.capeCod.seafoam)
                .padding(.horizontal, CodSpacing.sm)
                .padding(.vertical, CodSpacing.xs)
                .background(Color.capeCod.seafoam.opacity(0.15))
                .clipShape(Capsule())
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.featured, style: .continuous))
        .adaptiveCardStyle(cornerRadius: CodRadius.featured)
    }

    // MARK: - Tide Overview

    private func tideOverviewCard(_ plan: DayPlan) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "water.waves")
                    .foregroundStyle(Color.capeCod.oceanBlue)
                Text("Today's Tides")
                    .codTextStyle(.cardTitle)
            }

            HStack(spacing: CodSpacing.lg) {
                tideTimeView(label: "Low Tide", time: plan.tideInfo.lowTide1, icon: "arrow.down")
                tideTimeView(label: "High Tide", time: plan.tideInfo.highTide1, icon: "arrow.up")
                tideTimeView(label: "Low Tide", time: plan.tideInfo.lowTide2, icon: "arrow.down")
            }

            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "sunset.fill")
                    .foregroundStyle(Color.capeCod.sunsetOrange)
                Text("Sunset at \(plan.sunsetTime)")
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.sunsetOrange)
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private func tideTimeView(label: String, time: String, icon: String) -> some View {
        VStack(spacing: CodSpacing.xs) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color.capeCod.oceanBlue)
            Text(time)
                .font(.system(size: 15, weight: .semibold).monospacedDigit())
                .foregroundStyle(Color.capeCod.textPrimary)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.capeCod.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Timeline

    private func timelineSection(_ plan: DayPlan) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Your Day")
                .codTextStyle(.sectionTitle)
                .codAccessibleHeader("Your Day timeline")

            VStack(spacing: 0) {
                ForEach(Array(plan.activities.enumerated()), id: \.element.id) { index, activity in
                    activityRow(activity, index: index, isLast: index == plan.activities.count - 1)
                        .staggered(index: index)
                }
            }
        }
    }

    private func activityRow(_ activity: TidePlannerActivity, index: Int, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: CodSpacing.md) {
            // Timeline spine
            VStack(spacing: 0) {
                Circle()
                    .fill(activity.category.color)
                    .frame(width: 14, height: 14)
                    .overlay {
                        Circle()
                            .fill(Color.capeCod.surfaceElevated)
                            .frame(width: 6, height: 6)
                    }

                if !isLast {
                    Rectangle()
                        .fill(Color.capeCod.driftwood.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 14)

            // Content
            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                // Time + Tide
                HStack(spacing: CodSpacing.sm) {
                    Text(activity.time)
                        .font(.system(size: 14, weight: .bold).monospacedDigit())
                        .foregroundStyle(activity.category.color)

                    if let tideIndicator = activity.tideIndicator {
                        HStack(spacing: 2) {
                            Text(tideIndicator.symbol)
                                .font(.system(size: 11))
                            Text(tideIndicator.label)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.capeCod.oceanBlue.opacity(0.1))
                        .clipShape(Capsule())
                    }

                    Spacer()

                    Text(activity.duration)
                        .codTextStyle(.caption)
                }

                // Name + Location
                Text(activity.name)
                    .codTextStyle(.cardTitle)

                Text(activity.location)
                    .codTextStyle(.caption)
                    .foregroundStyle(activity.category.color)

                // Why Now
                Text(activity.whyNow)
                    .codTextStyle(.body)
                    .foregroundStyle(Color.capeCod.textSecondary)

                // Local Tip
                if let tip = activity.localTip {
                    HStack(alignment: .top, spacing: CodSpacing.xs) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.capeCod.sandbarYellow)
                        Text(tip)
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundStyle(Color.capeCod.driftwood)
                            .italic()
                    }
                    .padding(CodSpacing.sm)
                    .background(Color.capeCod.sandbarYellow.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
                }

                // Warning
                if let warning = activity.warning {
                    HStack(alignment: .top, spacing: CodSpacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.capeCod.cranberry)
                        Text(warning)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.capeCod.cranberry)
                    }
                    .padding(CodSpacing.sm)
                    .background(Color.capeCod.cranberry.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
                }
            }
            .padding(.bottom, isLast ? 0 : CodSpacing.lg)
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .padding(.bottom, isLast ? 0 : CodSpacing.sm)
        .codAccessibleGroup(
            label: "\(activity.time): \(activity.name) at \(activity.location). \(activity.whyNow). Duration: \(activity.duration)."
        )
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: CodSpacing.sm) {
            CodButton("Regenerate Plan", variant: .secondary, icon: "arrow.triangle.2.circlepath", isFullWidth: true) {
                generatePlan()
            }
            .codAccessibleButton("Regenerate plan", hint: "Creates a different day plan with your same interests")

            CodButton("Share Plan", variant: .primary, icon: "square.and.arrow.up", isFullWidth: true) {
                showShareSheet = true
            }
            .codAccessibleButton("Share plan", hint: "Opens share sheet with your day plan")
        }
    }

    // MARK: - Share Sheet

    private var shareSheet: some View {
        let text = shareText
        return ShareLink(item: text) {
            Text("Share")
        }
        .presentationDetents([.medium])
    }

    private var shareText: String {
        guard let plan = generatedPlan else { return "" }
        var text = "Cape Cod Day Plan - \(plan.dateLabel)\n"
        text += "\(plan.template.title)\n\n"
        for activity in plan.activities {
            text += "\(activity.time) - \(activity.name)\n"
            text += "  \(activity.location)\n"
            text += "  \(activity.whyNow)\n\n"
        }
        text += "Shared from Hey Cape Cod"
        return text
    }

    // MARK: - Plan Generation

    private func generatePlan() {
        CodHaptic.tap()

        withAnimation(CodAnimation.spring) {
            isGenerating = true
        }

        let planDate = resolvedDate
        let template = selectTemplate()
        let tideInfo = TidePlannerEngine.tideInfo(for: planDate)
        let sunset = TidePlannerEngine.sunsetTime(for: planDate)
        let activities = TidePlannerEngine.buildActivities(
            template: template,
            tideInfo: tideInfo,
            sunset: sunset,
            withKids: withKids,
            interests: interests,
            date: planDate
        )

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        let dateLabel = dateFormatter.string(from: planDate)

        withAnimation(CodAnimation.spring) {
            generatedPlan = DayPlan(
                template: template,
                dateLabel: dateLabel,
                tideInfo: tideInfo,
                sunsetTime: sunset,
                activities: activities
            )
            isGenerating = false
        }
        CodHaptic.success()
    }

    private var resolvedDate: Date {
        switch selectedDate {
        case .today: return .now
        case .tomorrow: return Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
        case .pickDate: return customDate
        }
    }

    private func selectTemplate() -> DayTemplate {
        let candidates: [DayTemplate]

        if interests.contains(.beach) && interests.contains(.dining) {
            candidates = [.beachDay, .foodieDay]
        } else if interests.contains(.tidePools) || interests.contains(.natureWalk) {
            candidates = [.explorerDay, .beachDay]
        } else if interests.contains(.dining) || interests.contains(.shopping) {
            candidates = [.foodieDay, .explorerDay]
        } else if withKids {
            candidates = [.familyFun, .beachDay]
        } else {
            candidates = DayTemplate.allCases
        }

        return candidates.randomElement() ?? .beachDay
    }
}

// MARK: - Data Models

private enum PlannerDate: CaseIterable {
    case today, tomorrow, pickDate

    var label: String {
        switch self {
        case .today: "Today"
        case .tomorrow: "Tomorrow"
        case .pickDate: "Pick Date"
        }
    }
}

private enum TidePlannerInterest: CaseIterable {
    case beach, tidePools, natureWalk, dining
    case shopping, sunset, whaleWatch, fishing

    var label: String {
        switch self {
        case .beach: "Beach"
        case .tidePools: "Tide Pools"
        case .natureWalk: "Nature"
        case .dining: "Dining"
        case .shopping: "Shopping"
        case .sunset: "Sunset"
        case .whaleWatch: "Whales"
        case .fishing: "Fishing"
        }
    }

    var icon: String {
        switch self {
        case .beach: "beach.umbrella"
        case .tidePools: "fossil.shell.fill"
        case .natureWalk: "leaf.fill"
        case .dining: "fork.knife"
        case .shopping: "bag.fill"
        case .sunset: "sunset.fill"
        case .whaleWatch: "water.waves"
        case .fishing: "figure.fishing"
        }
    }

    var color: Color {
        switch self {
        case .beach: Color.capeCod.oceanBlue
        case .tidePools: Color.capeCod.seafoam
        case .natureWalk: Color.capeCod.duneGrass
        case .dining: Color.capeCod.sunsetOrange
        case .shopping: Color.capeCod.driftwood
        case .sunset: Color.capeCod.sunsetOrange
        case .whaleWatch: Color.capeCod.oceanBlue
        case .fishing: Color.capeCod.seafoam
        }
    }
}

private enum ActivityCategory {
    case beach, nature, food, sunset, culture, fun

    var color: Color {
        switch self {
        case .beach: Color.capeCod.oceanBlue
        case .nature: Color.capeCod.duneGrass
        case .food: Color.capeCod.sunsetOrange
        case .sunset: Color(hex: 0xE86A90)
        case .culture: Color.capeCod.driftwood
        case .fun: Color.capeCod.seafoam
        }
    }
}

private struct TideIndicator {
    let symbol: String
    let label: String

    static let lowTide = TideIndicator(symbol: "\u{2193}", label: "Low Tide")
    static let highTide = TideIndicator(symbol: "\u{2191}", label: "High Tide")
    static let incoming = TideIndicator(symbol: "\u{2192}", label: "Incoming")
    static let outgoing = TideIndicator(symbol: "\u{2190}", label: "Outgoing")
}

private struct TidePlannerActivity: Identifiable {
    let id = UUID()
    let time: String
    let name: String
    let location: String
    let whyNow: String
    let duration: String
    let category: ActivityCategory
    let tideIndicator: TideIndicator?
    let localTip: String?
    let warning: String?
}

private struct TideInfo {
    let lowTide1: String
    let highTide1: String
    let lowTide2: String
    let highTide2: String

    var lowTide1Hour: Double
    var highTide1Hour: Double
    var lowTide2Hour: Double
}

private struct DayPlan {
    let template: DayTemplate
    let dateLabel: String
    let tideInfo: TideInfo
    let sunsetTime: String
    let activities: [TidePlannerActivity]
}

private enum DayTemplate: CaseIterable {
    case beachDay, explorerDay, familyFun, rainyDay, foodieDay

    var title: String {
        switch self {
        case .beachDay: "Beach Day"
        case .explorerDay: "Explorer Day"
        case .familyFun: "Family Fun Day"
        case .rainyDay: "Rainy Day Adventure"
        case .foodieDay: "Cape Cod Foodie Day"
        }
    }

    var description: String {
        switch self {
        case .beachDay: "Morning flats walk, afternoon swimming, golden hour sunset -- the quintessential Cape day."
        case .explorerDay: "Lighthouses, nature trails, and hidden gems -- see the Cape like a local."
        case .familyFun: "Beach time, mini golf, ice cream, and pond swimming -- perfect for the whole family."
        case .rainyDay: "Museums, galleries, bowling, and great food -- a rainy day done right."
        case .foodieDay: "From breakfast cafes to lobster dinners -- eat your way across the Cape."
        }
    }

    var icon: String {
        switch self {
        case .beachDay: "sun.max.fill"
        case .explorerDay: "binoculars.fill"
        case .familyFun: "figure.and.child.holdinghands"
        case .rainyDay: "cloud.rain.fill"
        case .foodieDay: "fork.knife.circle.fill"
        }
    }
}

// MARK: - Tide Planner Engine

private enum TidePlannerEngine {

    // MARK: - Tide Calculation

    /// Simulates tide times. Low tides occur roughly every 12h 25m,
    /// shifting ~50 min later each day. Base: Jan 1 low tide at 6:00 AM.
    static func tideInfo(for date: Date) -> TideInfo {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: date))!
        let dayOfYear = calendar.dateComponents([.day], from: startOfYear, to: date).day ?? 0

        // Each day shifts ~50 minutes later
        let shiftMinutes = Double(dayOfYear) * 50.0
        let baseMinutes = 6.0 * 60.0 // 6:00 AM base
        let totalMinutes = baseMinutes + shiftMinutes
        let lowTide1Minutes = totalMinutes.truncatingRemainder(dividingBy: 12.0 * 60.0 + 25.0)

        let lt1 = lowTide1Minutes.truncatingRemainder(dividingBy: 24.0 * 60.0)
        let ht1 = (lt1 + 6.0 * 60.0 + 12.5).truncatingRemainder(dividingBy: 24.0 * 60.0)
        let lt2 = (lt1 + 12.0 * 60.0 + 25.0).truncatingRemainder(dividingBy: 24.0 * 60.0)
        let ht2 = (ht1 + 12.0 * 60.0 + 25.0).truncatingRemainder(dividingBy: 24.0 * 60.0)

        return TideInfo(
            lowTide1: formatMinutes(lt1),
            highTide1: formatMinutes(ht1),
            lowTide2: formatMinutes(lt2),
            highTide2: formatMinutes(ht2),
            lowTide1Hour: lt1 / 60.0,
            highTide1Hour: ht1 / 60.0,
            lowTide2Hour: lt2 / 60.0
        )
    }

    private static func formatMinutes(_ totalMinutes: Double) -> String {
        let hours = Int(totalMinutes) / 60
        let minutes = Int(totalMinutes) % 60
        let adjustedHour = hours % 24
        let period = adjustedHour >= 12 ? "PM" : "AM"
        let displayHour = adjustedHour == 0 ? 12 : (adjustedHour > 12 ? adjustedHour - 12 : adjustedHour)
        return String(format: "%d:%02d %@", displayHour, minutes, period)
    }

    // MARK: - Sunset Times

    static func sunsetTime(for date: Date) -> String {
        let month = Calendar.current.component(.month, from: date)
        switch month {
        case 1: return "4:30 PM"
        case 2: return "5:15 PM"
        case 3: return "6:00 PM"
        case 4: return "7:15 PM"
        case 5: return "7:50 PM"
        case 6: return "8:20 PM"
        case 7: return "8:15 PM"
        case 8: return "7:45 PM"
        case 9: return "7:00 PM"
        case 10: return "6:15 PM"
        case 11: return "4:30 PM"
        case 12: return "4:15 PM"
        default: return "7:00 PM"
        }
    }

    private static func sunsetHour(for date: Date) -> Double {
        let month = Calendar.current.component(.month, from: date)
        switch month {
        case 1: return 16.5
        case 2: return 17.25
        case 3: return 18.0
        case 4: return 19.25
        case 5: return 19.83
        case 6: return 20.33
        case 7: return 20.25
        case 8: return 19.75
        case 9: return 19.0
        case 10: return 18.25
        case 11: return 16.5
        case 12: return 16.25
        default: return 19.0
        }
    }

    // MARK: - Tide Status at Hour

    private static func tideStatus(at hour: Double, tideInfo: TideInfo) -> TideIndicator {
        let lt1 = tideInfo.lowTide1Hour
        let ht1 = tideInfo.highTide1Hour
        let lt2 = tideInfo.lowTide2Hour

        let distToLow1 = abs(hour - lt1)
        let distToHigh1 = abs(hour - ht1)
        let distToLow2 = abs(hour - lt2)

        let nearestLow = min(distToLow1, distToLow2)

        if nearestLow < 1.0 {
            return .lowTide
        } else if distToHigh1 < 1.0 {
            return .highTide
        } else if hour > lt1 && hour < ht1 {
            return .incoming
        } else if hour > ht1 && hour < lt2 {
            return .outgoing
        } else {
            return .incoming
        }
    }

    // MARK: - Activity Building

    static func buildActivities(
        template: DayTemplate,
        tideInfo: TideInfo,
        sunset: String,
        withKids: Bool,
        interests: Set<TidePlannerInterest>,
        date: Date
    ) -> [TidePlannerActivity] {
        let sunsetH = sunsetHour(for: date)

        switch template {
        case .beachDay:
            return beachDayActivities(tideInfo: tideInfo, sunsetH: sunsetH, sunset: sunset, withKids: withKids)
        case .explorerDay:
            return explorerDayActivities(tideInfo: tideInfo, sunsetH: sunsetH, sunset: sunset, withKids: withKids)
        case .familyFun:
            return familyFunActivities(tideInfo: tideInfo, sunsetH: sunsetH, sunset: sunset)
        case .rainyDay:
            return rainyDayActivities(sunsetH: sunsetH, sunset: sunset, withKids: withKids)
        case .foodieDay:
            return foodieDayActivities(tideInfo: tideInfo, sunsetH: sunsetH, sunset: sunset, withKids: withKids)
        }
    }

    // MARK: - Beach Day

    private static func beachDayActivities(tideInfo: TideInfo, sunsetH: Double, sunset: String, withKids: Bool) -> [TidePlannerActivity] {
        let lt1 = tideInfo.lowTide1Hour
        let flatsHour = max(lt1 + 0.5, 7.0) // Start flats walk 30 min after low tide, no earlier than 7 AM

        var activities: [TidePlannerActivity] = []

        // Morning: Brewster Flats walk timed to low tide
        activities.append(TidePlannerActivity(
            time: formatHour(flatsHour),
            name: "Brewster Flats Walk",
            location: "Paines Creek Beach, Brewster",
            whyNow: "Low tide exposes a mile of sandy flats -- perfect for exploring tidal pools and finding hermit crabs. The morning light makes for stunning photos.",
            duration: "1.5 hrs",
            category: .beach,
            tideIndicator: .lowTide,
            localTip: "Park at the Paines Creek lot (free before 9 AM for town sticker holders). Wear water shoes -- the shells can be sharp.",
            warning: "The tide comes in fast on the flats. Head back when you see water rising around your ankles. Never walk out more than 30 minutes."
        ))

        // Late morning: Tide pooling at Skaket
        let tidePoolHour = flatsHour + 2.0
        activities.append(TidePlannerActivity(
            time: formatHour(tidePoolHour),
            name: withKids ? "Tide Pool Discovery" : "Tide Pooling at Skaket",
            location: "Skaket Beach, Orleans",
            whyNow: "The tide is still low enough to explore the rocky pools along the jetty. Look for crabs, sea stars, and tiny fish trapped in the pools.",
            duration: "1 hr",
            category: .nature,
            tideIndicator: tideStatus(at: tidePoolHour, tideInfo: tideInfo),
            localTip: "The best pools are to the left of the main beach near the rock jetty. Bring a small bucket for the kids to observe creatures (then release them!).",
            warning: nil
        ))

        // Lunch at a clam shack
        let lunchHour = tidePoolHour + 1.5
        activities.append(TidePlannerActivity(
            time: formatHour(lunchHour),
            name: "Clam Shack Lunch",
            location: "The Knack, Orleans",
            whyNow: "Beat the lunch rush at this locals' favorite. Their fried clams are legendary, and the lobster roll is pure butter-and-claw goodness.",
            duration: "1 hr",
            category: .food,
            tideIndicator: nil,
            localTip: "Order at the window and grab the picnic table under the big oak tree. Cash and card accepted. Try the clam chowder -- it's won awards.",
            warning: nil
        ))

        // Afternoon swimming
        let swimHour = lunchHour + 1.5
        let swimBeach = withKids ? "Mayflower Beach, Dennis" : "Coast Guard Beach, Eastham"
        let swimName = withKids ? "Warm Water Swimming" : "Afternoon Swim"
        let swimWhy = withKids
            ? "High tide brings warm, calm water perfect for little ones. The gradual slope means kids can wade safely while parents relax."
            : "The incoming tide brings clean swells perfect for body surfing. The National Seashore setting is unbeatable."

        activities.append(TidePlannerActivity(
            time: formatHour(swimHour),
            name: swimName,
            location: swimBeach,
            whyNow: swimWhy,
            duration: "2.5 hrs",
            category: .beach,
            tideIndicator: tideStatus(at: swimHour, tideInfo: tideInfo),
            localTip: withKids
                ? "Bring sand toys -- the bay side has the best sand for castles. The snack bar has ice cream."
                : "Take the shuttle from the Little Creek parking area in summer -- the main lot fills by 10 AM. Bring a boogie board.",
            warning: nil
        ))

        // Ice cream stop
        let iceHour = swimHour + 3.0
        activities.append(TidePlannerActivity(
            time: formatHour(iceHour),
            name: "Ice Cream Break",
            location: "Sundae School, Orleans",
            whyNow: "Cool off after a beach afternoon with homemade ice cream. The Cape Cod Chocolate Chunk and Black Raspberry are local legends.",
            duration: "30 min",
            category: .food,
            tideIndicator: nil,
            localTip: "Lines can be long in summer -- it moves fast though. The patio out back is shaded and quieter than the front.",
            warning: nil
        ))

        // Sunset
        let sunsetViewHour = sunsetH - 0.5
        activities.append(TidePlannerActivity(
            time: formatHour(sunsetViewHour),
            name: "Golden Hour Sunset",
            location: "Rock Harbor, Orleans",
            whyNow: "Rock Harbor faces due west across Cape Cod Bay -- the sunset paints the fishing boats and tidal creek in gold and pink. Arrive 30 minutes early for the best light.",
            duration: "45 min",
            category: .sunset,
            tideIndicator: tideStatus(at: sunsetViewHour, tideInfo: tideInfo),
            localTip: "Walk past the parking lot to the end of the jetty for the best unobstructed view. The fishing boats returning at dusk make perfect silhouettes.",
            warning: nil
        ))

        return activities
    }

    // MARK: - Explorer Day

    private static func explorerDayActivities(tideInfo: TideInfo, sunsetH: Double, sunset: String, withKids: Bool) -> [TidePlannerActivity] {
        var activities: [TidePlannerActivity] = []

        activities.append(TidePlannerActivity(
            time: "8:30 AM",
            name: "Nauset Light Visit",
            location: "Nauset Lighthouse, Eastham",
            whyNow: "The morning light illuminates the iconic red-and-white lighthouse perfectly for photos. Fewer crowds before 10 AM means you might get the whole overlook to yourself.",
            duration: "45 min",
            category: .culture,
            tideIndicator: tideStatus(at: 8.5, tideInfo: tideInfo),
            localTip: "The Three Sisters lighthouses are a 5-minute walk through the woods behind the main light -- most tourists miss them entirely.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: "9:30 AM",
            name: "Atlantic White Cedar Swamp Trail",
            location: "Marconi Station Area, Wellfleet",
            whyNow: "The morning is the coolest part of the day for hiking, and this 1.25-mile boardwalk trail through an ancient swamp is magical in soft light.",
            duration: "1.5 hrs",
            category: .nature,
            tideIndicator: nil,
            localTip: "The trail starts at the Marconi Station overlook -- check out the site of the first US wireless telegraph station before you descend into the swamp.",
            warning: nil
        ))

        let lunchHour = 11.5
        activities.append(TidePlannerActivity(
            time: formatHour(lunchHour),
            name: "Raw Bar Lunch",
            location: "Mac's Shack, Wellfleet",
            whyNow: "Wellfleet oysters are world-famous, and you're eating them steps from where they're harvested. Late morning means the oysters just came in fresh.",
            duration: "1.5 hrs",
            category: .food,
            tideIndicator: nil,
            localTip: "Sit at the raw bar and ask for 'Wellfleet Pearls' -- the small, briny oysters that don't make it onto the regular menu. BYOB is allowed.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: "1:30 PM",
            name: withKids ? "Cape Cod Museum of Natural History" : "Wellfleet Gallery Walk",
            location: withKids ? "869 Route 6A, Brewster" : "Main Street, Wellfleet",
            whyNow: withKids
                ? "The museum's aquarium touch tank and nature trails keep kids engaged during the hot midday hours."
                : "Wellfleet's gallery district is perfect for a midday stroll. Over a dozen galleries line Main Street and Commercial Street.",
            duration: "1.5 hrs",
            category: .culture,
            tideIndicator: nil,
            localTip: withKids
                ? "Ask about the junior naturalist program -- kids get a badge and activity sheet."
                : "Left Bank Gallery and Cove Gallery are the standouts. Thursday evenings in summer feature gallery openings with wine.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: "3:30 PM",
            name: "Fort Hill Overlook",
            location: "Fort Hill, Eastham",
            whyNow: "The afternoon light across Nauset Marsh is breathtaking. The 1.5-mile Red Maple Swamp trail loop is flat and shaded.",
            duration: "1 hr",
            category: .nature,
            tideIndicator: tideStatus(at: 15.5, tideInfo: tideInfo),
            localTip: "The Edward Penniman House at the trailhead is a free historic site with a jawbone arch -- great for photos.",
            warning: nil
        ))

        let sunsetViewHour = sunsetH - 0.75
        activities.append(TidePlannerActivity(
            time: formatHour(sunsetViewHour),
            name: "Sunset at First Encounter",
            location: "First Encounter Beach, Eastham",
            whyNow: "This is where the Pilgrims first met the Wampanoag people in 1620. The wide bay views and historical marker make sunset here feel timeless.",
            duration: "1 hr",
            category: .sunset,
            tideIndicator: tideStatus(at: sunsetViewHour, tideInfo: tideInfo),
            localTip: "Bring a blanket and a bottle of wine. The beach is uncrowded at sunset compared to Rock Harbor. Free parking after 4:30 PM.",
            warning: nil
        ))

        let dinnerHour = sunsetH + 0.5
        activities.append(TidePlannerActivity(
            time: formatHour(dinnerHour),
            name: "Dinner at ABBA",
            location: "ABBA Restaurant, Orleans",
            whyNow: "Cap off an explorer's day with globally inspired cuisine. Their Thai coconut lobster and lamb shank are unforgettable.",
            duration: "1.5 hrs",
            category: .food,
            tideIndicator: nil,
            localTip: "Reservations strongly recommended in summer. The patio is intimate and candlelit. Ask for the specials board -- the chef's daily creations are always the best.",
            warning: nil
        ))

        return activities
    }

    // MARK: - Family Fun Day

    private static func familyFunActivities(tideInfo: TideInfo, sunsetH: Double, sunset: String) -> [TidePlannerActivity] {
        var activities: [TidePlannerActivity] = []

        let lt1 = tideInfo.lowTide1Hour
        let beachHour = max(lt1 - 1.0, 8.0)

        activities.append(TidePlannerActivity(
            time: formatHour(beachHour),
            name: "Morning Beach Play",
            location: "Mayflower Beach, Dennis",
            whyNow: "Low tide reveals acres of warm tidal flats where kids can splash and explore safely. The sandbars create natural wading pools.",
            duration: "2 hrs",
            category: .beach,
            tideIndicator: tideStatus(at: beachHour, tideInfo: tideInfo),
            localTip: "Get there early for parking -- the lot fills by 10 AM in summer. Bring sand toys and a kite; the bay breeze is perfect for flying.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: formatHour(beachHour + 2.5),
            name: "Mini Golf at Pirate's Cove",
            location: "Pirate's Cove, South Yarmouth",
            whyNow: "Kids will love the pirate-themed course with waterfalls and caves. Late morning before the afternoon rush means shorter waits.",
            duration: "1 hr",
            category: .fun,
            tideIndicator: nil,
            localTip: "The Blackbeard's Challenge course (ages 8+) is more fun than Captain's. Ask about the family four-pack discount.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: formatHour(beachHour + 4.0),
            name: "Ice Cream at Four Seas",
            location: "Four Seas Ice Cream, Centerville",
            whyNow: "Cape Cod's oldest ice cream shop (since 1934). The fresh peach and penuche are flavors you won't find anywhere else.",
            duration: "30 min",
            category: .food,
            tideIndicator: nil,
            localTip: "They only take cash. The line looks long but moves quickly. A kids' scoop is huge here.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: "1:30 PM",
            name: "Freshwater Pond Swim",
            location: "Long Pond, Harwich",
            whyNow: "Warm freshwater is a nice change from the ocean, and the gentle shore is perfect for young swimmers. No waves, no currents, just splashing.",
            duration: "2 hrs",
            category: .beach,
            tideIndicator: nil,
            localTip: "Long Pond has a sandy beach with a roped-off swimming area. Bring inflatables -- they're allowed here unlike ocean beaches.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: "4:00 PM",
            name: "Cape Cod Rail Trail Bike Ride",
            location: "Nickerson State Park, Brewster",
            whyNow: "The late afternoon shade on the Rail Trail through Nickerson State Park makes for a comfortable family ride. Flat terrain is great for all ages.",
            duration: "1.5 hrs",
            category: .nature,
            tideIndicator: nil,
            localTip: "Rent bikes at Barb's Bike Shop on the trail. The Nickerson section has gentle hills and ponds to stop at. Bring bug spray for the shaded stretches.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: "6:00 PM",
            name: "Family Dinner",
            location: "Captain Frosty's, Dennis",
            whyNow: "A Cape classic for families -- outdoor seating, fried seafood, and soft-serve ice cream. Kids love the fish and chips, parents love the lobster roll.",
            duration: "1 hr",
            category: .food,
            tideIndicator: nil,
            localTip: "Order at the window and grab a picnic table fast -- they fill up. The fried scallops are the sleeper hit on the menu.",
            warning: nil
        ))

        let sunsetViewHour = sunsetH - 0.33
        activities.append(TidePlannerActivity(
            time: formatHour(sunsetViewHour),
            name: "Sunset at Chapin Beach",
            location: "Chapin Memorial Beach, Dennis",
            whyNow: "Drive your car right onto the beach for a no-hassle sunset experience. Kids can play in the sand while parents watch the sky light up.",
            duration: "45 min",
            category: .sunset,
            tideIndicator: tideStatus(at: sunsetViewHour, tideInfo: tideInfo),
            localTip: "You need a town sticker for the beach in summer, but it's free after 4 PM. Drive to the very end for the best sunset angles.",
            warning: nil
        ))

        return activities
    }

    // MARK: - Rainy Day

    private static func rainyDayActivities(sunsetH: Double, sunset: String, withKids: Bool) -> [TidePlannerActivity] {
        var activities: [TidePlannerActivity] = []

        activities.append(TidePlannerActivity(
            time: "9:30 AM",
            name: withKids ? "Cape Cod Museum of Natural History" : "Heritage Museums & Gardens",
            location: withKids ? "869 Route 6A, Brewster" : "67 Grove Street, Sandwich",
            whyNow: withKids
                ? "The touch tanks, bee exhibit, and indoor aquarium keep kids fascinated for hours. Rainy mornings mean smaller crowds."
                : "The stunning auto museum, art galleries, and indoor gardens are perfect for a rainy morning. The Carousel works rain or shine.",
            duration: "2 hrs",
            category: .culture,
            tideIndicator: nil,
            localTip: withKids
                ? "Pick up the scavenger hunt sheet at the front desk -- it makes the visit an adventure."
                : "Don't miss the vintage car collection in the Shaker barn. The Hidden Hollow outdoor play area has covered sections.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: "12:00 PM",
            name: "Lunch at The Brewster Fish House",
            location: "2208 Route 6A, Brewster",
            whyNow: "Rainy days are the best time to get a table at this tiny, wildly popular restaurant. Their seafood chowder will warm you right up.",
            duration: "1.5 hrs",
            category: .food,
            tideIndicator: nil,
            localTip: "No reservations -- they open at 11:30 and the line forms early. The grilled swordfish and lobster bisque are outstanding.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: "2:00 PM",
            name: withKids ? "Ryan Family Amusements" : "Cape Cinema",
            location: withKids ? "Cape Cod Mall, Hyannis" : "35 Hope Lane, Dennis",
            whyNow: withKids
                ? "Bowling, arcade games, and bumper cars -- everything kids need to burn energy on a rainy afternoon."
                : "This 1930s art deco cinema has a ceiling mural by Rockwell Kent and shows indie and classic films. Pure Cape Cod charm.",
            duration: "2 hrs",
            category: .fun,
            tideIndicator: nil,
            localTip: withKids
                ? "Tuesday is half-price bowling. The claw machines near the back actually work."
                : "Buy tickets at the box office -- no online sales. The seats are original 1930s. Grab popcorn and a local craft beer.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: "4:30 PM",
            name: "Gallery Walk & Shopping",
            location: "Route 6A, Brewster to Dennis",
            whyNow: "Route 6A's antique shops and galleries are perfect for a rainy afternoon browse. Each town has a distinct personality.",
            duration: "1.5 hrs",
            category: .culture,
            tideIndicator: nil,
            localTip: "Stop at Brewster Book Store (one of the Cape's best indie bookstores) and Kingsland Manor for antiques. Hot Chocolate Sparrow in Orleans is worth the drive for a warm-up drink.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: "6:30 PM",
            name: "Dinner at the Chatham Squire",
            location: "487 Main Street, Chatham",
            whyNow: "This cozy tavern has been a Cape Cod institution since 1968. The raw bar and comfort food menu are perfect for a rainy evening.",
            duration: "1.5 hrs",
            category: .food,
            tideIndicator: nil,
            localTip: "Sit in the bar side for faster service and more atmosphere. The fish tacos and Chatham chowder are the moves. Live music some nights.",
            warning: nil
        ))

        return activities
    }

    // MARK: - Foodie Day

    private static func foodieDayActivities(tideInfo: TideInfo, sunsetH: Double, sunset: String, withKids: Bool) -> [TidePlannerActivity] {
        var activities: [TidePlannerActivity] = []

        activities.append(TidePlannerActivity(
            time: "8:00 AM",
            name: "Breakfast at Hole in One",
            location: "Hole in One, Orleans",
            whyNow: "Fresh donuts come out of the fryer starting at 5:30 AM. By 8 AM the apple fritters are still warm and the coffee is strong. A Cape Cod morning ritual.",
            duration: "45 min",
            category: .food,
            tideIndicator: nil,
            localTip: "The apple fritter is the size of your head and costs $3. Get there before 9 for the full donut selection -- they sell out fast.",
            warning: nil
        ))

        let walkHour: Double = 9.0
        activities.append(TidePlannerActivity(
            time: formatHour(walkHour),
            name: "Morning Bayside Walk",
            location: "Corporation Beach, Dennis",
            whyNow: "Walk off breakfast on one of the Cape's prettiest bay beaches. The morning air is crisp and the beach is nearly empty.",
            duration: "1 hr",
            category: .beach,
            tideIndicator: tideStatus(at: walkHour, tideInfo: tideInfo),
            localTip: "The boardwalk down to the beach has benches overlooking the marsh -- beautiful even if you don't walk on the sand.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: "10:30 AM",
            name: "Chatham Fish Pier",
            location: "Chatham Fish Pier, Chatham",
            whyNow: "Watch the fishing boats unload the day's catch. The observation deck lets you see exactly what's coming off the boats -- and what you'll be eating later.",
            duration: "30 min",
            category: .culture,
            tideIndicator: nil,
            localTip: "The seals hang out just off the pier -- bring binoculars. The Chatham Pier Fish Market sells the freshest fish on the Cape, right off the boat.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: "11:30 AM",
            name: "Raw Bar Lunch",
            location: "Wicked Oyster, Wellfleet",
            whyNow: "Wellfleet oysters, littleneck clams, and the best Bloody Mary on the Cape. Sit outside and taste the ocean breeze with every bite.",
            duration: "1.5 hrs",
            category: .food,
            tideIndicator: nil,
            localTip: "Ask for the oyster sampler -- three different Wellfleet farms, three different flavor profiles. The lobster mac and cheese is outrageously good.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: "1:30 PM",
            name: "Farm Stand Tour",
            location: "Crow Farm, East Sandwich",
            whyNow: "Mid-afternoon is perfect for browsing local produce, jams, and baked goods. Cape Cod farm stands are an experience, not just shopping.",
            duration: "45 min",
            category: .nature,
            tideIndicator: nil,
            localTip: "Pick up beach plum jelly -- it's a Cape-only specialty. The corn (when in season) was picked that morning. Combo stands also sell incredible pies.",
            warning: nil
        ))

        activities.append(TidePlannerActivity(
            time: "3:00 PM",
            name: "Cape Cod Brewery Tour",
            location: "Devil's Purse Brewing, South Dennis",
            whyNow: withKids
                ? "The taproom has a family-friendly patio. Parents enjoy craft beer while kids run on the lawn."
                : "Afternoon tastings are relaxed and the bartenders will walk you through their small-batch Cape-inspired brews.",
            duration: "1.5 hrs",
            category: .food,
            tideIndicator: nil,
            localTip: "Try the Handline Kolsch -- it's their flagship and pairs perfectly with seafood. Ask about the seasonal release.",
            warning: nil
        ))

        let sunsetViewHour = sunsetH - 0.5
        activities.append(TidePlannerActivity(
            time: formatHour(sunsetViewHour),
            name: "Pre-Dinner Sunset",
            location: "Skaket Beach, Orleans",
            whyNow: "Skaket's west-facing bay beach delivers the Cape's most reliable sunsets. The sky turns every shade of pink, orange, and gold.",
            duration: "45 min",
            category: .sunset,
            tideIndicator: tideStatus(at: sunsetViewHour, tideInfo: tideInfo),
            localTip: "Bring a bottle of wine and cheese. The parking lot empties at sunset and it becomes your own private show. The tide flats reflect the colors like a mirror.",
            warning: nil
        ))

        let dinnerHour = sunsetH + 0.5
        activities.append(TidePlannerActivity(
            time: formatHour(dinnerHour),
            name: "Lobster Dinner",
            location: "The Lobster Pot, Provincetown",
            whyNow: "End your foodie day with the Cape's most celebrated lobster dinner. The harbor views and bustling Commercial Street atmosphere are the cherry on top.",
            duration: "2 hrs",
            category: .food,
            tideIndicator: nil,
            localTip: "Request a window table upstairs for harbor views. The baked stuffed lobster is the signature dish. Walk Commercial Street after dinner for the full P-town experience.",
            warning: nil
        ))

        return activities
    }

    // MARK: - Formatting Helpers

    private static func formatHour(_ hour: Double) -> String {
        let h = Int(hour)
        let m = Int((hour - Double(h)) * 60)
        let adjustedHour = h % 24
        let period = adjustedHour >= 12 ? "PM" : "AM"
        let displayHour = adjustedHour == 0 ? 12 : (adjustedHour > 12 ? adjustedHour - 12 : adjustedHour)
        if m == 0 {
            return "\(displayHour):00 \(period)"
        }
        return String(format: "%d:%02d %@", displayHour, m, period)
    }
}

// MARK: - Preview

#Preview {
    TidePlannerView()
}
