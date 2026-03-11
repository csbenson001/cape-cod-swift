import SwiftUI

// MARK: - Bridge Timing Predictor

/// Historical traffic pattern engine for Cape Cod bridge crossings.
/// Patterns are well-established and consistent year over year.
enum BridgeTimingPredictor {

    struct TimeSlot: Identifiable {
        let id = UUID()
        let hour: Int
        let label: String
        let congestionLevel: CongestionLevel
        let estimatedDelay: Int
        let recommendation: String
    }

    enum Direction: String, CaseIterable {
        case toTheCape = "To the Cape"
        case offTheCape = "Off the Cape"

        var icon: String {
            switch self {
            case .toTheCape: "arrow.right"
            case .offTheCape: "arrow.left"
            }
        }
    }

    // MARK: - Season & Holiday Detection

    static var isSummer: Bool {
        let month = Calendar.current.component(.month, from: .now)
        return (6...9).contains(month)
    }

    static var isHolidayWeekend: Bool {
        let calendar = Calendar.current
        let now = Date.now
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        let weekday = calendar.component(.weekday, from: now) // 1=Sun, 7=Sat

        // Memorial Day weekend (last Monday of May, Fri-Mon)
        if month == 5 && day >= 25 && weekday >= 6 { return true }
        if month == 5 && day >= 26 && weekday == 1 { return true }
        if month == 5 && day >= 27 && weekday == 2 { return true }

        // July 4th weekend (July 2-5)
        if month == 7 && (2...5).contains(day) { return true }

        // Labor Day weekend (first Monday of September, Fri-Mon)
        if month == 9 && day <= 7 {
            if weekday == 2 && day <= 7 { return true } // Monday
            if weekday == 1 && day <= 6 { return true } // Sunday before
            if weekday == 7 && day <= 5 { return true } // Saturday before
            if weekday == 6 && day <= 4 { return true } // Friday before
        }

        return false
    }

    static var currentDayOfWeek: Int {
        Calendar.current.component(.weekday, from: .now) // 1=Sun, 7=Sat
    }

    static var currentHour: Int {
        Calendar.current.component(.hour, from: .now)
    }

    static var seasonLabel: String {
        if isHolidayWeekend { return "Holiday Weekend" }
        if isSummer { return "Summer Season" }
        let month = Calendar.current.component(.month, from: .now)
        switch month {
        case 3...5: return "Spring"
        case 6...8: return "Summer"
        case 9...11: return "Fall"
        default: return "Winter"
        }
    }

    // MARK: - Pattern Generation

    static func generateTimeline(for direction: Direction) -> [TimeSlot] {
        let dayOfWeek = currentDayOfWeek
        let slots = (6...23).map { hour -> TimeSlot in
            let base = baseCongestion(hour: hour, dayOfWeek: dayOfWeek, direction: direction)
            let adjusted = adjustForConditions(base)
            let delay = estimatedDelay(for: adjusted)
            let label = formatHour(hour)
            let rec = shortRecommendation(for: adjusted, hour: hour)
            return TimeSlot(hour: hour, label: label, congestionLevel: adjusted, estimatedDelay: delay, recommendation: rec)
        }
        return slots
    }

    private static func baseCongestion(hour: Int, dayOfWeek: Int, direction: Direction) -> CongestionLevel {
        if isHolidayWeekend {
            return holidayCongestion(hour: hour)
        }

        switch dayOfWeek {
        case 6: // Friday
            return direction == .toTheCape
                ? fridayToCape(hour: hour)
                : fridayOffCape(hour: hour)
        case 1: // Sunday
            return direction == .offTheCape
                ? sundayOffCape(hour: hour)
                : sundayToCape(hour: hour)
        case 7: // Saturday
            return saturdayCongestion(hour: hour)
        default: // Mon-Thu
            return weekdayCongestion(hour: hour)
        }
    }

    // MARK: - Day-Specific Patterns

    private static func fridayToCape(hour: Int) -> CongestionLevel {
        switch hour {
        case 6..<9: return .light
        case 9..<11: return .moderate
        case 11..<14: return .heavy
        case 14..<17: return .severe
        case 17..<19: return .heavy
        case 19..<21: return .moderate
        default: return .light
        }
    }

    private static func fridayOffCape(hour: Int) -> CongestionLevel {
        switch hour {
        case 7..<9: return .light
        case 15..<18: return .moderate
        default: return .free
        }
    }

    private static func sundayOffCape(hour: Int) -> CongestionLevel {
        switch hour {
        case 6..<10: return .light
        case 10..<12: return .moderate
        case 12..<15: return .heavy
        case 15..<18: return .severe
        case 18..<20: return .heavy
        case 20..<22: return .moderate
        default: return .light
        }
    }

    private static func sundayToCape(hour: Int) -> CongestionLevel {
        switch hour {
        case 10..<14: return .light
        case 14..<17: return .moderate
        default: return .free
        }
    }

    private static func saturdayCongestion(hour: Int) -> CongestionLevel {
        switch hour {
        case 6..<8: return .light
        case 8..<10: return .moderate
        case 10..<16: return .heavy
        case 16..<20: return .moderate
        case 20..<22: return .light
        default: return .free
        }
    }

    private static func weekdayCongestion(hour: Int) -> CongestionLevel {
        switch hour {
        case 7..<9: return .moderate  // commuter
        case 16..<18: return .moderate // commuter
        default: return .free
        }
    }

    private static func holidayCongestion(hour: Int) -> CongestionLevel {
        switch hour {
        case 6..<10: return .moderate
        case 10..<20: return .severe
        case 20..<22: return .heavy
        default: return .moderate
        }
    }

    // MARK: - Adjustments

    private static func adjustForConditions(_ level: CongestionLevel) -> CongestionLevel {
        guard isSummer && !isHolidayWeekend else { return level }
        // Summer multiplier: bump up one level
        switch level {
        case .free: return .light
        case .light: return .moderate
        case .moderate: return .heavy
        case .heavy: return .severe
        case .severe: return .severe
        }
    }

    private static func estimatedDelay(for level: CongestionLevel) -> Int {
        switch level {
        case .free: return 0
        case .light: return 5
        case .moderate: return 15
        case .heavy: return 35
        case .severe: return 60
        }
    }

    private static func formatHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(displayHour) \(period)"
    }

    private static func shortRecommendation(for level: CongestionLevel, hour: Int) -> String {
        switch level {
        case .free: return "Clear sailing"
        case .light: return "Smooth crossing"
        case .moderate: return "Some slowdowns"
        case .heavy: return "Expect delays"
        case .severe: return "Avoid if possible"
        }
    }

    // MARK: - Smart Recommendation

    static func todayRecommendation(for direction: Direction) -> String {
        let hour = currentHour
        let timeline = generateTimeline(for: direction)
        let currentSlot = timeline.first(where: { $0.hour == hour })
        let currentLevel = currentSlot?.congestionLevel ?? .free

        if isHolidayWeekend {
            return "Holiday weekend \u{2014} expect severe delays 10 AM\u{2013}8 PM. Leave before 7 AM or after 9 PM for the best crossing."
        }

        let dayOfWeek = currentDayOfWeek

        // Find best upcoming windows
        let upcoming = timeline.filter { $0.hour >= hour }
        let bestUpcoming = upcoming.filter { $0.congestionLevel == .free || $0.congestionLevel == .light }
        let bestWindowStart = bestUpcoming.first?.label ?? "early morning"

        switch currentLevel {
        case .free, .light:
            return "Traffic is clear right now \u{2014} great time to cross!"
        case .moderate:
            if let nextClear = bestUpcoming.first {
                return "Moderate traffic now. Conditions should ease around \(nextClear.label)."
            }
            return "Moderate traffic now. Consider crossing soon before it builds."
        case .heavy:
            if let nextClear = bestUpcoming.first(where: { $0.congestionLevel == .light || $0.congestionLevel == .free }) {
                return "Traffic is heavy now. Best to wait until around \(nextClear.label), or leave immediately to beat the worst."
            }
            return "Heavy traffic right now. If you can wait, tomorrow morning will be much better."
        case .severe:
            if let nextClear = bestUpcoming.first(where: { $0.congestionLevel != .severe && $0.congestionLevel != .heavy }) {
                return "Traffic is severe right now. Best to wait until after \(nextClear.label) if possible."
            }
            return "Severe traffic \u{2014} consider delaying your crossing until tomorrow morning."
        }
    }

    static func bestWindowSummary(for direction: Direction) -> String {
        let timeline = generateTimeline(for: direction)
        let clearSlots = timeline.filter { $0.congestionLevel == .free || $0.congestionLevel == .light }
        if clearSlots.isEmpty {
            return "No clear windows today \u{2014} cross as early or late as possible."
        }
        // Find contiguous windows
        let firstClear = clearSlots.first!.label
        let lastClear = clearSlots.last!.label
        if clearSlots.count <= 3 {
            return "Best window: \(firstClear)\u{2013}\(lastClear)"
        }
        // Split into morning and evening windows
        let morning = clearSlots.filter { $0.hour < 12 }
        let evening = clearSlots.filter { $0.hour >= 18 }
        if !morning.isEmpty && !evening.isEmpty {
            return "Leave by \(morning.last!.label) or after \(evening.first!.label)"
        }
        return "Best window: \(firstClear)\u{2013}\(lastClear)"
    }
}

// MARK: - Bridge Timing View

struct BridgeTimingView: View {
    @State private var direction: BridgeTimingPredictor.Direction = .toTheCape
    @State private var showShareSheet = false

    private let calendar = Calendar.current
    private var currentHour: Int { BridgeTimingPredictor.currentHour }

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                // Direction Picker
                directionPicker
                    .staggered(index: 0)

                // Today's Recommendation Hero
                recommendationHero
                    .staggered(index: 1)

                // Hour-by-Hour Timeline
                timelineSection
                    .staggered(index: 2)

                // Pro Tips
                proTipsSection
                    .staggered(index: 3)

                // Share Button
                shareButton
                    .staggered(index: 4)
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background)
        .navigationTitle("Best Time to Cross")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showShareSheet) {
            shareSheet
        }
    }

    // MARK: - Direction Picker

    private var directionPicker: some View {
        Picker("Direction", selection: $direction) {
            ForEach(BridgeTimingPredictor.Direction.allCases, id: \.self) { dir in
                Text(dir.rawValue).tag(dir)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: direction) { _, _ in
            CodHaptic.selection()
        }
        .codAccessible(label: "Travel direction", hint: "Choose to the Cape or off the Cape")
    }

    // MARK: - Recommendation Hero

    private var recommendationHero: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "car.fill")
                    .font(.title2)
                    .foregroundStyle(Color.capeCod.oceanBlue)

                VStack(alignment: .leading, spacing: 2) {
                    Text(dayLabel)
                        .codTextStyle(.caption)
                    if BridgeTimingPredictor.isSummer || BridgeTimingPredictor.isHolidayWeekend {
                        Text(BridgeTimingPredictor.seasonLabel)
                            .codTextStyle(.label)
                            .foregroundStyle(BridgeTimingPredictor.isHolidayWeekend
                                ? Color.capeCod.cranberry
                                : Color.capeCod.sunsetOrange)
                    }
                }

                Spacer()

                Image(systemName: direction.icon)
                    .font(.title3)
                    .foregroundStyle(Color.capeCod.driftwood)
                    .contentTransition(.symbolEffect(.replace))
            }

            Text(BridgeTimingPredictor.bestWindowSummary(for: direction))
                .codTextStyle(.cardTitle)
                .foregroundStyle(Color.capeCod.textPrimary)

            Text(BridgeTimingPredictor.todayRecommendation(for: direction))
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)

            // Current status pill
            if let currentSlot = currentTimeSlot {
                HStack(spacing: CodSpacing.sm) {
                    Circle()
                        .fill(congestionColor(currentSlot.congestionLevel))
                        .frame(width: 10, height: 10)
                        .pulsingGlow(color: congestionColor(currentSlot.congestionLevel), isActive: true)

                    Text("Now: \(currentSlot.congestionLevel.displayName)")
                        .codTextStyle(.label)
                        .foregroundStyle(congestionColor(currentSlot.congestionLevel))

                    if currentSlot.estimatedDelay > 0 {
                        Text("\u{2022} +\(currentSlot.estimatedDelay) min delay")
                            .codTextStyle(.label)
                            .foregroundStyle(Color.capeCod.textSecondary)
                    }
                }
                .padding(.horizontal, CodSpacing.sm)
                .padding(.vertical, CodSpacing.xs)
                .background(congestionColor(currentSlot.congestionLevel).opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.featured, style: .continuous))
        .adaptiveCardStyle(cornerRadius: CodRadius.featured)
        .codAccessibleCard(
            label: "Today's bridge recommendation: \(BridgeTimingPredictor.bestWindowSummary(for: direction))",
            hint: BridgeTimingPredictor.todayRecommendation(for: direction)
        )
    }

    // MARK: - Timeline

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack {
                Text("Hour by Hour")
                    .codTextStyle(.sectionTitle)
                Spacer()
                legendView
            }

            VStack(spacing: 0) {
                ForEach(timeline) { slot in
                    timelineRow(slot)
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .codAccessible(label: "Hour by hour traffic timeline from 6 AM to 11 PM")
    }

    private func timelineRow(_ slot: BridgeTimingPredictor.TimeSlot) -> some View {
        let isNow = slot.hour == currentHour

        return HStack(spacing: CodSpacing.sm) {
            // Time label
            ZStack {
                if isNow {
                    Text("NOW")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.capeCod.shellWhite)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.capeCod.oceanBlue)
                        .clipShape(Capsule())
                } else {
                    Text(slot.label)
                        .codTextStyle(.label)
                        .foregroundStyle(Color.capeCod.textSecondary)
                }
            }
            .frame(width: 52, alignment: .leading)

            // Congestion bar
            GeometryReader { geometry in
                let maxWidth = geometry.size.width
                let barWidth = barFraction(for: slot.congestionLevel) * maxWidth

                RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous)
                    .fill(congestionColor(slot.congestionLevel))
                    .frame(width: max(barWidth, 8), height: 14)
                    .opacity(isNow ? 1.0 : 0.75)
                    .animation(CodAnimation.spring, value: direction)
            }
            .frame(height: 14)

            // Delay
            if slot.estimatedDelay > 0 {
                Text("+\(slot.estimatedDelay)m")
                    .codTextStyle(.label)
                    .monospacedDigit()
                    .foregroundStyle(congestionColor(slot.congestionLevel))
                    .frame(width: 40, alignment: .trailing)
            } else {
                Text("0m")
                    .codTextStyle(.label)
                    .monospacedDigit()
                    .foregroundStyle(Color.capeCod.textSecondary.opacity(0.5))
                    .frame(width: 40, alignment: .trailing)
            }

            // Short note
            Text(slot.recommendation)
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.textSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, CodSpacing.xs + 2)
        .padding(.horizontal, CodSpacing.xs)
        .background(isNow ? Color.capeCod.oceanBlue.opacity(0.06) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
        .codAccessibleGroup(
            label: "\(slot.label): \(slot.congestionLevel.displayName), \(slot.estimatedDelay) minute delay. \(slot.recommendation)\(isNow ? ". Current time." : "")"
        )
    }

    private var legendView: some View {
        HStack(spacing: CodSpacing.xs) {
            legendDot(color: Color.capeCod.trafficClear, label: "Clear")
            legendDot(color: Color.capeCod.trafficModerate, label: "Mod")
            legendDot(color: Color.capeCod.trafficHeavy, label: "Heavy")
            legendDot(color: Color.capeCod.trafficSevere, label: "Severe")
        }
        .codAccessibleHidden()
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color.capeCod.textSecondary)
        }
    }

    // MARK: - Pro Tips

    private var proTipsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color.capeCod.sandbarYellow)
                Text("Pro Tips")
                    .codTextStyle(.sectionTitle)
            }

            ForEach(Array(proTips.enumerated()), id: \.offset) { _, tip in
                HStack(alignment: .top, spacing: CodSpacing.sm) {
                    Image(systemName: tip.icon)
                        .font(.caption)
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .frame(width: 20, alignment: .center)

                    Text(tip.text)
                        .codTextStyle(.caption)
                        .foregroundStyle(Color.capeCod.textSecondary)
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .codAccessible(label: "Pro tips for crossing the Cape Cod bridges")
    }

    // MARK: - Share

    private var shareButton: some View {
        CodButton("Share Today's Bridge Timing", variant: .secondary, icon: "square.and.arrow.up", isFullWidth: true) {
            showShareSheet = true
        }
        .codAccessibleButton("Share today's bridge timing", hint: "Opens share sheet with traffic summary")
    }

    private var shareSheet: some View {
        let text = shareText
        return ShareLink(item: text) {
            Text("Share")
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helpers

    private var timeline: [BridgeTimingPredictor.TimeSlot] {
        BridgeTimingPredictor.generateTimeline(for: direction)
    }

    private var currentTimeSlot: BridgeTimingPredictor.TimeSlot? {
        timeline.first(where: { $0.hour == currentHour })
    }

    private var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: .now)
    }

    private func congestionColor(_ level: CongestionLevel) -> Color {
        switch level {
        case .free: Color.capeCod.trafficClear
        case .light: Color.capeCod.seafoam
        case .moderate: Color.capeCod.trafficModerate
        case .heavy: Color.capeCod.trafficHeavy
        case .severe: Color.capeCod.trafficSevere
        }
    }

    private func barFraction(for level: CongestionLevel) -> CGFloat {
        switch level {
        case .free: 0.1
        case .light: 0.3
        case .moderate: 0.55
        case .heavy: 0.78
        case .severe: 1.0
        }
    }

    private var proTips: [(icon: String, text: String)] {
        var tips: [(icon: String, text: String)] = [
            ("arrow.triangle.branch", "The Bourne Bridge is usually 5\u{2013}10 minutes faster than Sagamore on Fridays."),
            ("arrow.triangle.swap", "Consider Route 25 from the south if both bridges are backed up."),
            ("radio.fill", "Listen to AM 1240 for real-time bridge reports."),
            ("cup.and.saucer.fill", "Pack snacks and water for potential delays \u{2014} especially with kids.")
        ]

        if BridgeTimingPredictor.isSummer {
            tips.append(("sun.max.fill", "Summer traffic peaks June\u{2013}September. Weekday crossings are significantly better than weekends."))
        }

        if BridgeTimingPredictor.isHolidayWeekend {
            tips.append(("exclamationmark.triangle.fill", "Holiday weekend! Both bridges will be extremely congested. Consider crossing very early or very late."))
        }

        let dayOfWeek = BridgeTimingPredictor.currentDayOfWeek
        if dayOfWeek == 6 { // Friday
            tips.append(("clock.fill", "Friday tip: Leave before 9 AM or after 9 PM to avoid the worst Cape-bound traffic."))
        } else if dayOfWeek == 1 { // Sunday
            tips.append(("clock.fill", "Sunday tip: Leave the Cape before 10 AM or after 8 PM to skip the return rush."))
        }

        return tips
    }

    private var shareText: String {
        let day = dayLabel
        let season = BridgeTimingPredictor.seasonLabel
        let window = BridgeTimingPredictor.bestWindowSummary(for: direction)
        let rec = BridgeTimingPredictor.todayRecommendation(for: direction)

        return """
        \u{1F30A} Cape Cod Bridge Traffic \u{2014} \(day)
        \(direction.rawValue) \u{2022} \(season)

        \(window)
        \(rec)

        Shared from Hey Cape Cod
        """
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BridgeTimingView()
    }
}
