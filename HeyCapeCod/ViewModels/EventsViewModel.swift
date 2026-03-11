import Foundation

// MARK: - Events View Model

@preconcurrency @MainActor
@Observable
final class EventsViewModel {
    var selectedCategory: EventCategory = .all
    var selectedTown: EventTownFilter = .all
    var isLoading = false
    var error: Error?

    private(set) var events: [CapeCodEvent] = []
    private let eventService = EventService()

    // MARK: - Grouped Events by Date Section

    struct EventSection: Hashable {
        let title: String
        let events: [CapeCodEvent]
    }

    var groupedEvents: [EventSection] {
        guard !events.isEmpty else { return [] }

        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!
        let endOfWeek = cal.date(byAdding: .day, value: 7, to: today)!
        let endOfNextWeek = cal.date(byAdding: .day, value: 14, to: today)!

        var todayEvents: [CapeCodEvent] = []
        var tomorrowEvents: [CapeCodEvent] = []
        var thisWeekEvents: [CapeCodEvent] = []
        var nextWeekEvents: [CapeCodEvent] = []
        var upcomingEvents: [CapeCodEvent] = []

        for event in events {
            let eventDate = cal.startOfDay(for: event.parsedDate)

            if eventDate == today {
                todayEvents.append(event)
            } else if eventDate == tomorrow {
                tomorrowEvents.append(event)
            } else if eventDate > tomorrow && eventDate < endOfWeek {
                thisWeekEvents.append(event)
            } else if eventDate >= endOfWeek && eventDate < endOfNextWeek {
                nextWeekEvents.append(event)
            } else {
                upcomingEvents.append(event)
            }
        }

        var sections: [EventSection] = []
        if !todayEvents.isEmpty { sections.append(EventSection(title: "Today", events: todayEvents)) }
        if !tomorrowEvents.isEmpty { sections.append(EventSection(title: "Tomorrow", events: tomorrowEvents)) }
        if !thisWeekEvents.isEmpty { sections.append(EventSection(title: "This Week", events: thisWeekEvents)) }
        if !nextWeekEvents.isEmpty { sections.append(EventSection(title: "Next Week", events: nextWeekEvents)) }
        if !upcomingEvents.isEmpty { sections.append(EventSection(title: "Upcoming", events: upcomingEvents)) }

        return sections
    }

    // MARK: - Date Range Label

    var dateRangeLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        let start = formatter.string(from: .now)
        let end = formatter.string(from: Calendar.current.date(byAdding: .day, value: 30, to: .now) ?? .now)
        return "\(start) - \(end)"
    }

    // MARK: - Load Events

    func loadEvents() async {
        isLoading = true
        error = nil
        let result = await eventService.fetchEvents(
            category: selectedCategory,
            town: selectedTown
        )
        events = result
        error = eventService.error
        isLoading = false
    }

    func clearCache() {
        eventService.clearCache()
    }
}
