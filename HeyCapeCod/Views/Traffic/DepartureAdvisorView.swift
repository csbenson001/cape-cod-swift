import SwiftUI
import Charts

// MARK: - Departure Advisor View

/// Smart departure timing tool that helps users plan bridge crossings
/// to minimize traffic delays leaving Cape Cod.
struct DepartureAdvisorView: View {
    @State private var selectedDate = Date()
    @State private var selectedBridge: TrafficPatternEngine.Bridge = .either
    @State private var selectedDirection: TrafficPatternEngine.Direction = .boston
    @State private var showAlarmSheet = false

    private var predictions: [TrafficPatternEngine.HourlyPrediction] {
        TrafficPatternEngine.generateHourlyPredictions(
            date: selectedDate,
            direction: selectedDirection
        )
    }

    private var optimalWindow: (start: Date, end: Date, expectedDelay: Int) {
        TrafficPatternEngine.optimalDepartureWindow(
            date: selectedDate,
            direction: selectedDirection
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                inputsCard
                    .staggered(index: 0)

                recommendationCard
                    .staggered(index: 1)

                TrafficPredictionChart(
                    predictions: predictions,
                    optimalStart: Calendar.current.component(.hour, from: optimalWindow.start),
                    optimalEnd: Calendar.current.component(.hour, from: optimalWindow.end)
                )
                .staggered(index: 2)

                setAlarmButton
                    .staggered(index: 3)
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background)
        .navigationTitle("Departure Advisor")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAlarmSheet) {
            NavigationStack {
                DepartureAlarmView(
                    prefillDate: selectedDate,
                    prefillDirection: selectedDirection
                )
            }
            .presentationDetents([.large])
        }
    }

    // MARK: - Inputs Card

    private var inputsCard: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Plan Your Departure")
                .codTextStyle(.sectionTitle)

            // Date picker
            datePickerRow

            // Bridge picker
            bridgePickerRow

            // Direction picker
            directionPickerRow
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private var datePickerRow: some View {
        VStack(alignment: .leading, spacing: CodSpacing.xs) {
            Text("Departure Date")
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.textSecondary)

            DatePicker(
                "Date",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .onChange(of: selectedDate) { _, _ in
                CodHaptic.selection()
            }
        }
    }

    private var bridgePickerRow: some View {
        VStack(alignment: .leading, spacing: CodSpacing.xs) {
            Text("Preferred Bridge")
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.textSecondary)

            Picker("Bridge", selection: $selectedBridge) {
                ForEach(TrafficPatternEngine.Bridge.allCases) { bridge in
                    Text(bridge.rawValue).tag(bridge)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedBridge) { _, _ in
                CodHaptic.selection()
            }
        }
    }

    private var directionPickerRow: some View {
        VStack(alignment: .leading, spacing: CodSpacing.xs) {
            Text("Destination")
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.textSecondary)

            HStack(spacing: CodSpacing.sm) {
                ForEach(TrafficPatternEngine.Direction.allCases) { dir in
                    directionChip(dir)
                }
            }
        }
    }

    private func directionChip(_ direction: TrafficPatternEngine.Direction) -> some View {
        let isSelected = selectedDirection == direction

        return Button {
            withAnimation(CodAnimation.quick) {
                selectedDirection = direction
            }
            CodHaptic.selection()
        } label: {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: direction.icon)
                    .font(.caption)
                Text(direction.rawValue)
                    .codTextStyle(.label)
            }
            .padding(.horizontal, CodSpacing.sm)
            .padding(.vertical, CodSpacing.xs + 2)
            .background(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.surface)
            .foregroundStyle(isSelected ? Color.capeCod.textOnPrimary : Color.capeCod.textPrimary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recommendation Card

    private var recommendationCard: some View {
        let window = optimalWindow
        let cal = Calendar.current
        let startHour = cal.component(.hour, from: window.start)
        let endHour = cal.component(.hour, from: window.end)
        let peakPrediction = predictions.max(by: { $0.expectedDelay < $1.expectedDelay })
        let isHoliday = TrafficPatternEngine.isHolidayWeekend(selectedDate)

        return VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: recommendationIcon)
                    .font(.title2)
                    .foregroundStyle(recommendationColor)

                Text("Recommendation")
                    .codTextStyle(.sectionTitle)

                Spacer()

                if isHoliday {
                    Text("Holiday")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.capeCod.shellWhite)
                        .padding(.horizontal, CodSpacing.sm)
                        .padding(.vertical, CodSpacing.xs)
                        .background(Color.capeCod.cranberry)
                        .clipShape(Capsule())
                }
            }

            Text(buildRecommendationText(startHour: startHour, endHour: endHour, window: window, peak: peakPrediction))
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textPrimary)

            // Optimal window badge
            optimalBadge(startHour: startHour, endHour: endHour, delay: window.expectedDelay)
        }
        .padding(CodSpacing.cardPadding)
        .background(recommendationColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .strokeBorder(recommendationColor.opacity(0.3), lineWidth: 1)
        )
    }

    private func optimalBadge(startHour: Int, endHour: Int, delay: Int) -> some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.capeCod.duneGrass)

            Text("Best window: \(formatHour(startHour))\u{2013}\(formatHour(endHour))")
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.duneGrass)

            Spacer()

            Text("~\(delay) min delay")
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
        .padding(CodSpacing.sm)
        .background(Color.capeCod.duneGrass.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
    }

    // MARK: - Set Alarm Button

    private var setAlarmButton: some View {
        CodButton(
            "Set Departure Alarm",
            variant: .primary,
            icon: "alarm.fill",
            isFullWidth: true
        ) {
            CodHaptic.tap()
            showAlarmSheet = true
        }
    }

    // MARK: - Helpers

    private var recommendationIcon: String {
        let peak = predictions.max(by: { $0.expectedDelay < $1.expectedDelay })
        switch peak?.severity {
        case .severe: return "exclamationmark.triangle.fill"
        case .heavy: return "exclamationmark.circle.fill"
        default: return "checkmark.seal.fill"
        }
    }

    private var recommendationColor: Color {
        let peak = predictions.max(by: { $0.expectedDelay < $1.expectedDelay })
        switch peak?.severity {
        case .severe: return Color.capeCod.cranberry
        case .heavy: return Color.capeCod.sunsetOrange
        case .moderate: return Color.capeCod.sandbarYellow
        default: return Color.capeCod.duneGrass
        }
    }

    private func buildRecommendationText(
        startHour: Int,
        endHour: Int,
        window: (start: Date, end: Date, expectedDelay: Int),
        peak: TrafficPatternEngine.HourlyPrediction?
    ) -> String {
        let peakDelay = peak?.expectedDelay ?? 0
        let peakHour = peak?.hour ?? 14
        let windowDelay = window.expectedDelay

        if peakDelay < 15 {
            return "Light traffic expected all day. You can leave whenever is convenient."
        }

        return "Leave by \(formatHour(endHour)) to avoid the afternoon rush. Expected delay: \(windowDelay) minutes. After \(formatHour(peakHour - 1)), expect \(peakDelay)-\(peakDelay + 30) minute delays."
    }

    private func formatHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let display = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(display):00 \(period)"
    }
}

#Preview {
    NavigationStack {
        DepartureAdvisorView()
    }
}
