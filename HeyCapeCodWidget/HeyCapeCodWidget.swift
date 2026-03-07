import WidgetKit
import SwiftUI

// MARK: - Beach Conditions Widget (Small)

struct BeachConditionsEntry: TimelineEntry {
    let date: Date
    let temperature: Int
    let waterTemp: Int?
    let condition: String
    let conditionIcon: String
    let beachRecommendation: String?
    let isPlaceholder: Bool

    static var placeholder: BeachConditionsEntry {
        BeachConditionsEntry(
            date: .now,
            temperature: 75,
            waterTemp: 65,
            condition: "Partly Cloudy",
            conditionIcon: "cloud.sun.fill",
            beachRecommendation: "Coast Guard Beach",
            isPlaceholder: true
        )
    }
}

struct BeachConditionsProvider: TimelineProvider {
    func placeholder(in context: Context) -> BeachConditionsEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (BeachConditionsEntry) -> Void) {
        completion(.placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BeachConditionsEntry>) -> Void) {
        Task {
            let entry = await fetchBeachConditions()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func fetchBeachConditions() async -> BeachConditionsEntry {
        // Fetch from shared UserDefaults (app group) or cached data
        let defaults = UserDefaults(suiteName: "group.com.heycapecod.shared")
        let temp = defaults?.integer(forKey: "widget_temperature") ?? 72
        let waterTemp = defaults?.object(forKey: "widget_waterTemp") as? Int
        let condition = defaults?.string(forKey: "widget_condition") ?? "Clear"
        let icon = defaults?.string(forKey: "widget_conditionIcon") ?? "sun.max.fill"
        let beach = defaults?.string(forKey: "widget_beachRec")

        return BeachConditionsEntry(
            date: .now,
            temperature: temp,
            waterTemp: waterTemp,
            condition: condition,
            conditionIcon: icon,
            beachRecommendation: beach,
            isPlaceholder: false
        )
    }
}

struct BeachConditionsWidgetView: View {
    var entry: BeachConditionsEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: entry.conditionIcon)
                    .font(.title2)
                    .foregroundStyle(.orange)
                Spacer()
                Text("\(entry.temperature)\u{00B0}")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }

            Text(entry.condition)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            if let waterTemp = entry.waterTemp {
                HStack(spacing: 4) {
                    Image(systemName: "water.waves")
                        .font(.caption2)
                        .foregroundStyle(.cyan)
                    Text("\(waterTemp)\u{00B0} water")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            if let beach = entry.beachRecommendation {
                Text(beach)
                    .font(.caption2.bold())
                    .foregroundStyle(.blue)
                    .lineLimit(1)
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// MARK: - Traffic Status Widget (Medium)

struct TrafficStatusEntry: TimelineEntry {
    let date: Date
    let sagamoreDelay: Int
    let bourneDelay: Int
    let sagamoreStatus: String
    let bourneStatus: String
    let recommendation: String
    let isPlaceholder: Bool

    static var placeholder: TrafficStatusEntry {
        TrafficStatusEntry(
            date: .now,
            sagamoreDelay: 15,
            bourneDelay: 5,
            sagamoreStatus: "Heavy",
            bourneStatus: "Moderate",
            recommendation: "Take the Bourne Bridge",
            isPlaceholder: true
        )
    }
}

struct TrafficStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> TrafficStatusEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (TrafficStatusEntry) -> Void) {
        completion(.placeholder)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TrafficStatusEntry>) -> Void) {
        Task {
            let entry = await fetchTrafficStatus()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: .now) ?? .now
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func fetchTrafficStatus() async -> TrafficStatusEntry {
        let defaults = UserDefaults(suiteName: "group.com.heycapecod.shared")
        return TrafficStatusEntry(
            date: .now,
            sagamoreDelay: defaults?.integer(forKey: "widget_sagamoreDelay") ?? 0,
            bourneDelay: defaults?.integer(forKey: "widget_bourneDelay") ?? 0,
            sagamoreStatus: defaults?.string(forKey: "widget_sagamoreStatus") ?? "Clear",
            bourneStatus: defaults?.string(forKey: "widget_bourneStatus") ?? "Clear",
            recommendation: defaults?.string(forKey: "widget_recommendation") ?? "No delays",
            isPlaceholder: false
        )
    }
}

struct TrafficStatusWidgetView: View {
    var entry: TrafficStatusEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "car.fill")
                    .foregroundStyle(.blue)
                Text("Bridge Traffic")
                    .font(.headline)
                Spacer()
                Text(entry.date, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                bridgeCard(
                    name: "Sagamore",
                    delay: entry.sagamoreDelay,
                    status: entry.sagamoreStatus
                )
                bridgeCard(
                    name: "Bourne",
                    delay: entry.bourneDelay,
                    status: entry.bourneStatus
                )
            }

            Text(entry.recommendation)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }

    private func bridgeCard(name: String, delay: Int, status: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.caption.bold())
            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor(status))
                    .frame(width: 8, height: 8)
                Text(status)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            if delay > 0 {
                Text("+\(delay) min")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
            } else {
                Text("No delay")
                    .font(.caption2)
                    .foregroundStyle(.green)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "clear": .green
        case "moderate": .yellow
        case "heavy": .orange
        case "severe": .red
        default: .gray
        }
    }
}

// MARK: - Widget Bundle

@main
struct HeyCapeCodWidgetBundle: WidgetBundle {
    var body: some Widget {
        BeachConditionsWidget()
        TrafficStatusWidget()
    }
}

struct BeachConditionsWidget: Widget {
    let kind = "BeachConditionsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BeachConditionsProvider()) { entry in
            BeachConditionsWidgetView(entry: entry)
        }
        .configurationDisplayName("Beach Conditions")
        .description("Today's weather and beach recommendation.")
        .supportedFamilies([.systemSmall])
    }
}

struct TrafficStatusWidget: Widget {
    let kind = "TrafficStatusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TrafficStatusProvider()) { entry in
            TrafficStatusWidgetView(entry: entry)
        }
        .configurationDisplayName("Bridge Traffic")
        .description("Live Sagamore and Bourne Bridge traffic.")
        .supportedFamilies([.systemMedium])
    }
}
