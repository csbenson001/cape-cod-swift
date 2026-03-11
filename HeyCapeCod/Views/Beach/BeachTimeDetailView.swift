import SwiftUI
import Charts
import UserNotifications

// MARK: - Beach Time Detail View

struct BeachTimeDetailView: View {
    let beach: BeachProfile

    @State private var engine = BestTimeEngine.shared
    @State private var recommendation: BestTimeRecommendation?
    @State private var hourlyScores: [HourlyScore] = []
    @State private var showReminderAlert = false
    @State private var reminderSet = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                beachHeader
                if !hourlyScores.isEmpty {
                    hourlyChartSection
                }
                if let rec = recommendation {
                    detailCardsSection(rec)
                    reminderSection(rec)
                }
            }
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background.ignoresSafeArea())
        .navigationTitle(beach.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }
        }
        .alert("Reminder Set!", isPresented: $showReminderAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if let rec = recommendation {
                Text("We'll remind you at \(reminderTimeText(rec)) to head to \(beach.name).")
            }
        }
        .onAppear { loadData() }
    }
}

// MARK: - Header

private extension BeachTimeDetailView {
    var beachHeader: some View {
        VStack(spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.md) {
                beachIcon
                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    Text(beach.name)
                        .codTextStyle(.sectionTitle)
                    Text(beach.town)
                        .codTextStyle(.caption)
                }
                Spacer()
                if let rec = recommendation {
                    StarRatingLarge(rating: rec.rating)
                }
            }

            if let rec = recommendation {
                optimalWindowBanner(rec)
            }

            attributeChips
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.top, CodSpacing.md)
    }

    var beachIcon: some View {
        Image(systemName: "beach.umbrella")
            .font(.title)
            .foregroundStyle(.white)
            .frame(width: 52, height: 52)
            .background(Color.capeCod.oceanBlue.gradient)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
    }

    func optimalWindowBanner(_ rec: BestTimeRecommendation) -> some View {
        HStack {
            Image(systemName: "clock.badge.checkmark")
                .foregroundStyle(Color.capeCod.seafoam)
            VStack(alignment: .leading, spacing: 2) {
                Text("Best Time Today")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                Text(rec.optimalWindow)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
            }
            Spacer()
            CrowdBadgeLight(level: rec.crowdLevel)
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.deepNavy)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }

    var attributeChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                AttributeChip(icon: "safari", text: "Faces \(beach.facing.rawValue.capitalized)")
                if beach.tideDependent {
                    AttributeChip(icon: "water.waves", text: "Tide Dependent")
                }
                if beach.kidFriendly {
                    AttributeChip(icon: "figure.and.child.holdinghands", text: "Kid Friendly")
                }
                if beach.hasLifeguards {
                    AttributeChip(icon: "cross.circle", text: "Lifeguards")
                }
                if beach.hasRestrooms {
                    AttributeChip(icon: "toilet", text: "Restrooms")
                }
                AttributeChip(icon: "car.fill", text: beach.parkingCapacity.rawValue.capitalized + " Lot")
            }
        }
    }
}

// MARK: - Hourly Chart

private extension BeachTimeDetailView {
    var hourlyChartSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("HOUR-BY-HOUR QUALITY")
                .codTextStyle(.label)

            Chart(hourlyScores) { item in
                BarMark(
                    x: .value("Hour", item.label),
                    y: .value("Score", item.score)
                )
                .foregroundStyle(barColor(for: item.score))
                .cornerRadius(4)
            }
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text("\(v)")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.capeCod.textSecondary)
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(Color.capeCod.driftwood.opacity(0.3))
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.system(size: 9))
                        .foregroundStyle(Color.capeCod.textSecondary)
                }
            }
            .frame(height: 200)

            chartLegend
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .padding(.horizontal, CodSpacing.screenEdge)
        .staggered(index: 0)
    }

    func barColor(for score: Double) -> Color {
        switch score {
        case 75...: return Color.capeCod.duneGrass
        case 50..<75: return Color.capeCod.oceanBlue
        case 25..<50: return Color.capeCod.sandbarYellow
        default: return Color.capeCod.driftwood.opacity(0.5)
        }
    }

    var chartLegend: some View {
        HStack(spacing: CodSpacing.md) {
            LegendDot(color: Color.capeCod.duneGrass, label: "Excellent")
            LegendDot(color: Color.capeCod.oceanBlue, label: "Good")
            LegendDot(color: Color.capeCod.sandbarYellow, label: "Fair")
            LegendDot(color: Color.capeCod.driftwood.opacity(0.5), label: "Poor")
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Detail Cards

private extension BeachTimeDetailView {
    func detailCardsSection(_ rec: BestTimeRecommendation) -> some View {
        VStack(spacing: CodSpacing.md) {
            DetailCard(
                icon: "water.waves", title: "Tide Info",
                content: rec.tideInfo,
                accentColor: Color.capeCod.oceanBlue
            )
            .staggered(index: 1)

            DetailCard(
                icon: "person.3.sequence", title: "Crowd Prediction",
                content: crowdDescription(rec.crowdLevel),
                accentColor: crowdColor(rec.crowdLevel)
            )
            .staggered(index: 2)

            DetailCard(
                icon: "car.fill", title: "Parking",
                content: rec.parkingTip,
                accentColor: Color.capeCod.sunsetOrange
            )
            .staggered(index: 3)

            if !rec.reasons.isEmpty {
                DetailCard(
                    icon: "lightbulb.fill", title: "Tips",
                    content: rec.reasons.joined(separator: "\n"),
                    accentColor: Color.capeCod.seafoam
                )
                .staggered(index: 4)
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    func crowdDescription(_ level: CrowdLevel) -> String {
        switch level {
        case .low: return "Expect a quiet beach day with plenty of space."
        case .moderate: return "Moderate crowds — you'll find a good spot without trouble."
        case .busy: return "Popular day — arrive early for the best spots."
        case .packed: return "Very busy — expect full parking and limited space."
        }
    }

    func crowdColor(_ level: CrowdLevel) -> Color {
        switch level {
        case .low: return Color.capeCod.duneGrass
        case .moderate: return Color.capeCod.oceanBlue
        case .busy: return Color.capeCod.sandbarYellow
        case .packed: return Color.capeCod.cranberry
        }
    }
}

// MARK: - Reminder Section

private extension BeachTimeDetailView {
    func reminderSection(_ rec: BestTimeRecommendation) -> some View {
        Button {
            CodHaptic.success()
            scheduleReminder(rec)
        } label: {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: reminderSet ? "bell.badge.fill" : "bell")
                Text(reminderSet ? "Reminder Set" : "Set Reminder for Best Time")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, CodSpacing.md)
            .background(
                reminderSet
                    ? Color.capeCod.duneGrass
                    : Color.capeCod.oceanBlue
            )
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
        }
        .disabled(reminderSet)
        .padding(.horizontal, CodSpacing.screenEdge)
        .staggered(index: 5)
    }

    func scheduleReminder(_ rec: BestTimeRecommendation) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Time for \(beach.name)!"
            content.body = "Head out now for the best conditions. \(rec.quickTip)"
            content.sound = .default
            let comps = Calendar.current.dateComponents([.hour, .minute], from: rec.optimalStart.addingTimeInterval(-1800))
            let request = UNNotificationRequest(
                identifier: "besttime-\(beach.id)", content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: false))
            UNUserNotificationCenter.current().add(request)
            DispatchQueue.main.async { reminderSet = true; showReminderAlert = true }
        }
    }

    func reminderTimeText(_ rec: BestTimeRecommendation) -> String {
        let fmt = DateFormatter(); fmt.dateFormat = "h:mm a"
        return fmt.string(from: rec.optimalStart.addingTimeInterval(-1800))
    }
}

// MARK: - Data Loading

private extension BeachTimeDetailView {
    func loadData() {
        recommendation = engine.bestTimeToVisit(beach: beach)
        hourlyScores = engine.hourlyScores(beach: beach)
    }
}

// MARK: - Sub-Views

private struct StarRatingLarge: View {
    let rating: Int
    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: 14))
                    .foregroundStyle(star <= rating ? Color.capeCod.sunsetOrange : Color.capeCod.driftwood.opacity(0.4))
            }
        }
    }
}

private struct CrowdBadgeLight: View {
    let level: CrowdLevel
    var body: some View {
        HStack(spacing: 3) { Image(systemName: level.icon); Text(level.rawValue) }
            .font(.system(size: 11, weight: .medium)).foregroundStyle(.white)
            .padding(.horizontal, CodSpacing.sm).padding(.vertical, CodSpacing.xs)
            .background(.white.opacity(0.2)).clipShape(Capsule())
    }
}

private struct AttributeChip: View {
    let icon: String; let text: String
    var body: some View {
        HStack(spacing: CodSpacing.xs) {
            Image(systemName: icon).font(.system(size: 10))
            Text(text).font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(Color.capeCod.oceanBlue)
        .padding(.horizontal, CodSpacing.sm).padding(.vertical, CodSpacing.xs)
        .background(Color.capeCod.oceanBlue.opacity(0.1)).clipShape(Capsule())
    }
}

private struct DetailCard: View {
    let icon: String; let title: String; let content: String; let accentColor: Color
    var body: some View {
        HStack(alignment: .top, spacing: CodSpacing.md) {
            Image(systemName: icon).font(.title3).foregroundStyle(accentColor).frame(width: 32)
            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                Text(title).codTextStyle(.cardTitle)
                Text(content).codTextStyle(.body).fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(CodSpacing.cardPadding).background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)).adaptiveCardStyle()
    }
}

private struct LegendDot: View {
    let color: Color; let label: String
    var body: some View {
        HStack(spacing: CodSpacing.xs) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.system(size: 10)).foregroundStyle(Color.capeCod.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        BeachTimeDetailView(beach: BeachProfile.allBeaches[0])
    }
}
