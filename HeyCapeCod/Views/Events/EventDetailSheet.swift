import SwiftUI
import MapKit
import EventKit

struct EventDetailSheet: View {
    let event: CapeCodEvent
    @Environment(\.dismiss) private var dismiss
    @State private var calendarStatus: CalendarAddStatus = .idle
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.lg) {
                    heroSection
                        .staggered(index: 0)

                    detailsSection
                        .staggered(index: 1)

                    mapSection
                        .staggered(index: 2)

                    actionButtons
                        .staggered(index: 3)

                    if let description = Optional(event.description), !description.isEmpty {
                        descriptionSection(description)
                            .staggered(index: 4)
                    }
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.xxl)
            }
            .background(Color.capeCod.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: CodSpacing.md) {
            // Category + Name
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: event.categoryIcon)
                    .font(.title2)
                    .foregroundStyle(categoryColor)
                    .frame(width: 52, height: 52)
                    .background(categoryColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))

                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    Text(event.name)
                        .codTextStyle(.sectionTitle)
                    Text(event.category.capitalized)
                        .codTextStyle(.label)
                        .foregroundStyle(categoryColor)
                }

                Spacer()
            }

            // Price badge
            HStack {
                if event.isFree {
                    Label("Free Event", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.capeCod.duneGrass)
                } else if let price = event.price {
                    Label(price, systemImage: "ticket.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.capeCod.sunsetOrange)
                }
                Spacer()
                if event.isRecurring {
                    Label("Recurring", systemImage: "arrow.triangle.2.circlepath")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.capeCod.oceanBlue)
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        VStack(spacing: CodSpacing.md) {
            detailRow(icon: "calendar", title: "Date", value: event.isRecurring ? "\(event.formattedDate) (Weekly)" : event.formattedDateRange)

            Divider().foregroundStyle(Color.capeCod.cardBorder)

            detailRow(icon: "clock", title: "Time", value: event.time)

            Divider().foregroundStyle(Color.capeCod.cardBorder)

            detailRow(icon: "building.2", title: "Venue", value: event.venue)

            Divider().foregroundStyle(Color.capeCod.cardBorder)

            detailRow(icon: "mappin.and.ellipse", title: "Location", value: event.location)

            Divider().foregroundStyle(Color.capeCod.cardBorder)

            detailRow(icon: "map", title: "Town", value: event.town)
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: CodSpacing.md) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.capeCod.oceanBlue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .codTextStyle(.caption)
                Text(value)
                    .codTextStyle(.body)
            }

            Spacer()
        }
    }

    // MARK: - Map Section

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Location")
                .codTextStyle(.cardTitle)

            Map {
                Marker(event.venue, coordinate: coordinateForTown(event.town))
                    .tint(Color.capeCod.sunsetOrange)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .allowsHitTesting(false)
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: CodSpacing.sm) {
            // Get Directions
            Button {
                CodHaptic.tap()
                openDirections()
            } label: {
                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, CodSpacing.md)
                    .background(Color.capeCod.oceanBlue)
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
            }

            HStack(spacing: CodSpacing.sm) {
                // Add to Calendar
                Button {
                    CodHaptic.tap()
                    addToCalendar()
                } label: {
                    Label(calendarButtonLabel, systemImage: calendarButtonIcon)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, CodSpacing.md)
                        .background(Color.capeCod.surfaceElevated)
                        .foregroundStyle(Color.capeCod.textPrimary)
                        .font(.system(size: 14, weight: .medium))
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                        .adaptiveCardStyle()
                }

                // Share
                Button {
                    CodHaptic.selection()
                    showShareSheet = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, CodSpacing.md)
                        .background(Color.capeCod.surfaceElevated)
                        .foregroundStyle(Color.capeCod.textPrimary)
                        .font(.system(size: 14, weight: .medium))
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                        .adaptiveCardStyle()
                }
            }

            // Website
            if let urlString = event.website, let url = URL(string: urlString) {
                Link(destination: url) {
                    Label("Visit Website", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, CodSpacing.md)
                        .background(Color.capeCod.surfaceElevated)
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .font(.system(size: 14, weight: .medium))
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                        .adaptiveCardStyle()
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            let text = "\(event.name)\n\(event.formattedDateRange) at \(event.venue), \(event.town)\n\(event.website ?? "")"
            ShareSheet(items: [text])
        }
    }

    // MARK: - Description

    private func descriptionSection(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("About")
                .codTextStyle(.cardTitle)

            Text(description)
                .codTextStyle(.storyBody)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Calendar

    private var calendarButtonLabel: String {
        switch calendarStatus {
        case .idle: return "Add to Calendar"
        case .added: return "Added!"
        case .denied: return "No Access"
        case .error: return "Error"
        }
    }

    private var calendarButtonIcon: String {
        switch calendarStatus {
        case .idle: return "calendar.badge.plus"
        case .added: return "checkmark.circle.fill"
        case .denied: return "lock.fill"
        case .error: return "exclamationmark.triangle"
        }
    }

    private func addToCalendar() {
        let store = EKEventStore()
        store.requestFullAccessToEvents { granted, error in
            DispatchQueue.main.async {
                guard granted, error == nil else {
                    calendarStatus = .denied
                    return
                }
                let calEvent = EKEvent(eventStore: store)
                calEvent.title = event.name
                calEvent.location = "\(event.venue), \(event.town)"
                calEvent.notes = event.description
                calEvent.startDate = event.parsedDate
                calEvent.endDate = event.parsedEndDate ?? Calendar.current.date(byAdding: .hour, value: 3, to: event.parsedDate)
                calEvent.calendar = store.defaultCalendarForNewEvents

                do {
                    try store.save(calEvent, span: .thisEvent)
                    calendarStatus = .added
                    CodHaptic.success()
                } catch {
                    calendarStatus = .error
                }
            }
        }
    }

    // MARK: - Directions

    private func openDirections() {
        let coordinate = coordinateForTown(event.town)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = event.venue
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }

    // MARK: - Helpers

    private var categoryColor: Color {
        switch event.categoryColor {
        case .festivals: return Color.capeCod.sunsetOrange
        case .concerts: return Color.capeCod.oceanBlue
        case .markets: return Color.capeCod.duneGrass
        case .parades: return Color.capeCod.cranberry
        case .theater: return Color.capeCod.seafoam
        case .sports: return Color.capeCod.sunsetOrange
        case .family: return Color.capeCod.oceanBlue
        case .food: return Color.capeCod.cranberry
        }
    }

    private func coordinateForTown(_ town: String) -> CLLocationCoordinate2D {
        let coords: [String: CLLocationCoordinate2D] = [
            "Barnstable": CLLocationCoordinate2D(latitude: 41.7003, longitude: -70.3002),
            "Bourne": CLLocationCoordinate2D(latitude: 41.7415, longitude: -70.5989),
            "Brewster": CLLocationCoordinate2D(latitude: 41.7601, longitude: -70.0820),
            "Chatham": CLLocationCoordinate2D(latitude: 41.6821, longitude: -69.9597),
            "Dennis": CLLocationCoordinate2D(latitude: 41.7354, longitude: -70.1939),
            "Eastham": CLLocationCoordinate2D(latitude: 41.8301, longitude: -69.9728),
            "Falmouth": CLLocationCoordinate2D(latitude: 41.5515, longitude: -70.6146),
            "Harwich": CLLocationCoordinate2D(latitude: 41.6843, longitude: -70.0755),
            "Mashpee": CLLocationCoordinate2D(latitude: 41.6490, longitude: -70.4812),
            "Orleans": CLLocationCoordinate2D(latitude: 41.7898, longitude: -69.9900),
            "Provincetown": CLLocationCoordinate2D(latitude: 42.0584, longitude: -70.1786),
            "Sandwich": CLLocationCoordinate2D(latitude: 41.7590, longitude: -70.4934),
            "Truro": CLLocationCoordinate2D(latitude: 42.0112, longitude: -70.0515),
            "Wellfleet": CLLocationCoordinate2D(latitude: 41.9376, longitude: -70.0325),
            "Yarmouth": CLLocationCoordinate2D(latitude: 41.7059, longitude: -70.2286),
        ]
        return coords[town] ?? CLLocationCoordinate2D(latitude: 41.7003, longitude: -70.3002)
    }
}

// MARK: - Calendar Status

private enum CalendarAddStatus {
    case idle, added, denied, error
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    EventDetailSheet(event: EventService.fallbackEvents().first!)
}
