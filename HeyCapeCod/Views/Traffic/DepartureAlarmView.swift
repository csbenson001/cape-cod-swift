import SwiftUI
import UserNotifications

// MARK: - Departure Alarm View

/// Lets users set a smart departure alarm based on traffic predictions.
/// The alarm fires 30 minutes before the optimal departure window.
struct DepartureAlarmView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate: Date
    @State private var selectedDirection: TrafficPatternEngine.Direction
    @State private var alarmDate: Date?
    @State private var isAlarmSet = false
    @State private var notificationDenied = false
    @State private var showCancelConfirm = false

    private let notificationID = "departure-alarm"

    init(
        prefillDate: Date = Calendar.current.startOfDay(for: .now),
        prefillDirection: TrafficPatternEngine.Direction = .boston
    ) {
        _selectedDate = State(initialValue: prefillDate)
        _selectedDirection = State(initialValue: prefillDirection)
    }

    private var optimalWindow: (start: Date, end: Date, expectedDelay: Int) {
        TrafficPatternEngine.optimalDepartureWindow(
            date: selectedDate,
            direction: selectedDirection
        )
    }

    private var alarmTime: Date {
        Calendar.current.date(byAdding: .minute, value: -30, to: optimalWindow.start)
            ?? optimalWindow.start
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                headerSection
                    .staggered(index: 0)

                configSection
                    .staggered(index: 1)

                if isAlarmSet, let alarm = alarmDate {
                    alarmActiveCard(alarm)
                        .staggered(index: 2)
                } else {
                    previewCard
                        .staggered(index: 2)
                }

                actionButtons
                    .staggered(index: 3)

                if notificationDenied {
                    permissionWarning
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background)
        .navigationTitle("Departure Alarm")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
        .confirmationDialog("Cancel Alarm?", isPresented: $showCancelConfirm) {
            Button("Cancel Alarm", role: .destructive) { cancelAlarm() }
            Button("Keep Alarm", role: .cancel) {}
        }
        .task { await checkNotificationPermission() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "alarm.waves.left.and.right.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.capeCod.oceanBlue)

            Text("Smart Departure Alarm")
                .codTextStyle(.sectionTitle)

            Text("Get notified 30 minutes before the best time to leave.")
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, CodSpacing.lg)
    }

    // MARK: - Configuration

    private var configSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            // Date
            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                Text("Departure Day")
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
                    isAlarmSet = false
                }
            }

            // Direction
            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                Text("Heading Toward")
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.textSecondary)

                Picker("Direction", selection: $selectedDirection) {
                    ForEach(TrafficPatternEngine.Direction.allCases) { dir in
                        Label(dir.rawValue, systemImage: dir.icon).tag(dir)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedDirection) { _, _ in
                    CodHaptic.selection()
                    isAlarmSet = false
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Preview Card (before alarm set)

    private var previewCard: some View {
        let cal = Calendar.current
        let startHour = cal.component(.hour, from: optimalWindow.start)
        let endHour = cal.component(.hour, from: optimalWindow.end)

        return VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.capeCod.sandbarYellow)
                Text("Optimal Window")
                    .codTextStyle(.sectionTitle)
            }

            HStack(spacing: CodSpacing.lg) {
                timeBlock(
                    label: "Leave Between",
                    time: formatHour(startHour),
                    subtitle: formatHour(endHour),
                    color: Color.capeCod.duneGrass
                )

                Divider()
                    .frame(height: 50)

                timeBlock(
                    label: "Expected Delay",
                    time: "\(optimalWindow.expectedDelay)",
                    subtitle: "minutes",
                    color: Color.capeCod.oceanBlue
                )
            }

            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "bell.fill")
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .font(.caption)
                Text("Alarm will fire at \(alarmTime.formatted(date: .omitted, time: .shortened))")
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.textSecondary)
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Active Alarm Card

    private func alarmActiveCard(_ alarm: Date) -> some View {
        VStack(spacing: CodSpacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.capeCod.duneGrass)

            Text("Alarm Set!")
                .codTextStyle(.sectionTitle)
                .foregroundStyle(Color.capeCod.duneGrass)

            Text(alarm.formatted(date: .abbreviated, time: .shortened))
                .codTextStyle(.subtitle)
                .foregroundStyle(Color.capeCod.textPrimary)

            countdownView(to: alarm)

            Text("You'll get a notification 30 minutes before optimal departure.")
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.duneGrass.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .strokeBorder(Color.capeCod.duneGrass.opacity(0.3), lineWidth: 1)
        )
    }

    private func countdownView(to date: Date) -> some View {
        let remaining = date.timeIntervalSince(.now)
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60

        return HStack(spacing: CodSpacing.md) {
            if hours > 0 {
                countdownUnit(value: hours, unit: "hr")
            }
            countdownUnit(value: max(0, minutes), unit: "min")
        }
    }

    private func countdownUnit(value: Int, unit: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.capeCod.textPrimary)
                .monospacedDigit()
            Text(unit)
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: CodSpacing.sm) {
            if isAlarmSet {
                CodButton(
                    "Cancel Alarm",
                    variant: .secondary,
                    icon: "xmark.circle",
                    isFullWidth: true
                ) {
                    showCancelConfirm = true
                }
            } else {
                CodButton(
                    "Set Alarm",
                    variant: .primary,
                    icon: "alarm.fill",
                    isFullWidth: true
                ) {
                    Task { await setAlarm() }
                }
            }
        }
    }

    // MARK: - Permission Warning

    private var permissionWarning: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.capeCod.sandbarYellow)
            Text("Notifications are disabled. Enable them in Settings to receive departure alerts.")
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.sandbarYellow.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
    }

    // MARK: - Helpers

    private func timeBlock(label: String, time: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.textSecondary)
            Text(time)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(subtitle)
                .codTextStyle(.label)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let display = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(display):00 \(period)"
    }

    // MARK: - Notifications

    private func checkNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        notificationDenied = settings.authorizationStatus == .denied
    }

    private func setAlarm() async {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else {
                notificationDenied = true
                CodHaptic.error()
                return
            }
        } catch {
            notificationDenied = true
            CodHaptic.error()
            return
        }

        // Remove existing
        center.removePendingNotificationRequests(withIdentifiers: [notificationID])

        let content = UNMutableNotificationContent()
        content.title = "Time to Pack Up!"
        content.body = "Leave in the next 30 minutes to beat bridge traffic heading toward \(selectedDirection.rawValue)."
        content.sound = .default
        content.categoryIdentifier = "DEPARTURE_ALARM"

        let fireDate = alarmTime
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: notificationID,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            alarmDate = fireDate
            isAlarmSet = true
            CodHaptic.success()
        } catch {
            CodHaptic.error()
        }
    }

    private func cancelAlarm() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationID])
        isAlarmSet = false
        alarmDate = nil
        CodHaptic.tap()
    }
}

#Preview {
    NavigationStack {
        DepartureAlarmView()
    }
}
