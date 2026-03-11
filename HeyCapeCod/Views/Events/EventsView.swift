import SwiftUI

struct EventsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = EventsViewModel()
    @State private var selectedEvent: CapeCodEvent?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    headerSection
                        .staggered(index: 0)

                    categoryChips
                        .staggered(index: 1)

                    townFilter
                        .staggered(index: 2)

                    eventsContent
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                viewModel.clearCache()
                await viewModel.loadEvents()
            }
            .task {
                await viewModel.loadEvents()
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailSheet(event: event)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("What's Happening")
                .codTextStyle(.heroTitle)

            Text(viewModel.dateRangeLabel)
                .codTextStyle(.subtitle)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Category Chips

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                ForEach(EventCategory.allCases) { category in
                    EventCategoryChip(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        withAnimation(CodAnimation.quick) {
                            viewModel.selectedCategory = category
                        }
                        CodHaptic.selection()
                        Task { await viewModel.loadEvents() }
                    }
                }
            }
        }
    }

    // MARK: - Town Filter

    private var townFilter: some View {
        HStack {
            Image(systemName: "mappin.circle.fill")
                .foregroundStyle(Color.capeCod.oceanBlue)

            Picker("Town", selection: $viewModel.selectedTown) {
                ForEach(EventTownFilter.allCases) { town in
                    Text(town.rawValue).tag(town)
                }
            }
            .tint(Color.capeCod.oceanBlue)
            .onChange(of: viewModel.selectedTown) {
                Task { await viewModel.loadEvents() }
            }

            Spacer()

            if viewModel.isLoading {
                ProgressView()
                    .tint(Color.capeCod.oceanBlue)
            }
        }
        .padding(.horizontal, CodSpacing.md)
        .padding(.vertical, CodSpacing.sm)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Events Content

    @ViewBuilder
    private var eventsContent: some View {
        if viewModel.isLoading && viewModel.groupedEvents.isEmpty {
            loadingState
                .staggered(index: 3)
        } else if viewModel.groupedEvents.isEmpty {
            emptyState
                .staggered(index: 3)
        } else {
            eventSections
        }
    }

    private var loadingState: some View {
        VStack(spacing: CodSpacing.md) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                    .fill(Color.capeCod.surface)
                    .frame(height: 100)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: CodSpacing.md) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(Color.capeCod.driftwood)

            Text("No Events Found")
                .codTextStyle(.cardTitle)

            Text("Try a different date range, category, or town.")
                .codTextStyle(.caption)
                .multilineTextAlignment(.center)

            if viewModel.error != nil {
                Text("Could not reach the events server.")
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.cranberry)
            }
        }
        .padding(.vertical, CodSpacing.xxl)
    }

    private var eventSections: some View {
        LazyVStack(spacing: CodSpacing.lg, pinnedViews: .sectionHeaders) {
            ForEach(Array(viewModel.groupedEvents.enumerated()), id: \.element.title) { sIdx, section in
                Section {
                    ForEach(Array(section.events.enumerated()), id: \.element.id) { eIdx, event in
                        EventCard(event: event) {
                            CodHaptic.tap()
                            selectedEvent = event
                        }
                        .staggered(index: sIdx * 3 + eIdx + 3)
                    }
                } header: {
                    EventSectionHeader(title: section.title)
                }
            }
        }
    }
}

// MARK: - Event Category Chip

struct EventCategoryChip: View {
    let category: EventCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, CodSpacing.md)
            .padding(.vertical, CodSpacing.sm)
            .background(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.surfaceElevated)
            .foregroundStyle(isSelected ? Color.capeCod.textOnPrimary : Color.capeCod.textPrimary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color.clear : Color.capeCod.cardBorder,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section Header

struct EventSectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .codTextStyle(.sectionTitle)
            Spacer()
        }
        .padding(.vertical, CodSpacing.xs)
        .background(Color.capeCod.background)
    }
}

// MARK: - Event Card

struct EventCard: View {
    let event: CapeCodEvent
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: CodSpacing.md) {
                eventIcon
                eventInfo
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.capeCod.driftwood)
                    .padding(.top, CodSpacing.xs)
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .buttonStyle(.plain)
    }

    private var eventIcon: some View {
        Image(systemName: event.categoryIcon)
            .font(.title3)
            .foregroundStyle(categoryColor)
            .frame(width: 44, height: 44)
            .background(categoryColor.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
    }

    private var eventInfo: some View {
        VStack(alignment: .leading, spacing: CodSpacing.xs) {
            Text(event.name)
                .codTextStyle(.cardTitle)
                .lineLimit(2)

            metadataRow(icon: "calendar", text: event.isRecurring
                ? "\(event.formattedDate) (Weekly)"
                : event.formattedDateRange)
            metadataRow(icon: "clock", text: event.time)
            metadataRow(icon: "mappin", text: event.venue)

            priceBadge
        }
    }

    private func metadataRow(icon: String, text: String) -> some View {
        HStack(spacing: CodSpacing.xs) {
            Image(systemName: icon).font(.caption2)
            Text(text).font(.system(size: 13, weight: .regular)).lineLimit(1)
        }
        .foregroundStyle(Color.capeCod.textSecondary)
    }

    private var priceBadge: some View {
        HStack(spacing: CodSpacing.xs) {
            if event.isFree {
                badgePill("FREE", color: Color.capeCod.duneGrass, bold: true)
            } else if let price = event.price {
                badgePill(price, color: Color.capeCod.sunsetOrange, bold: false)
            }
            badgePill(event.town, color: Color.capeCod.oceanBlue, bold: false)
        }
    }

    private func badgePill(_ text: String, color: Color, bold: Bool) -> some View {
        Text(text)
            .font(.system(size: 11, weight: bold ? .bold : .medium))
            .foregroundStyle(color)
            .padding(.horizontal, CodSpacing.sm)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

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
}

#Preview {
    EventsView()
        .environment(AppState())
}
