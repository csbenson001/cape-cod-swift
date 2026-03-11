import SwiftUI

// MARK: - Discovery Hub View

/// Central "command center" that organizes all app feature modules
/// into a searchable, categorized grid.
struct DiscoveryHubView: View {
    @State private var searchText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CodSpacing.sectionSpacing) {
                searchBar
                filteredSections
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background.ignoresSafeArea())
        .navigationTitle("Discovery Hub")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Search Bar

private extension DiscoveryHubView {
    var searchBar: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.capeCod.textSecondary)
            TextField("Search features...", text: $searchText)
                .textFieldStyle(.plain)
                .codTextStyle(.body)
            if !searchText.isEmpty {
                Button {
                    withAnimation(CodAnimation.quick) {
                        searchText = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.capeCod.textSecondary)
                }
            }
        }
        .padding(.horizontal, CodSpacing.md)
        .padding(.vertical, CodSpacing.sm + 2)
        .background(Color.capeCod.surface)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
        .adaptiveCardStyle(cornerRadius: CodRadius.input)
    }
}

// MARK: - Sections

private extension DiscoveryHubView {
    var filteredSections: some View {
        let query = searchText.lowercased()
        return ForEach(Array(allSections.enumerated()), id: \.element.title) { sectionIndex, section in
            let filtered = query.isEmpty
                ? section.modules
                : section.modules.filter {
                    $0.name.lowercased().contains(query) ||
                    $0.subtitle.lowercased().contains(query)
                }
            if !filtered.isEmpty {
                sectionView(
                    title: section.title,
                    icon: section.icon,
                    modules: filtered,
                    sectionIndex: sectionIndex
                )
            }
        }
    }

    func sectionView(title: String, icon: String, modules: [HubModule], sectionIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader(title: title, icon: icon)
            moduleGrid(modules: modules, sectionOffset: sectionIndex * 10)
        }
    }

    func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.capeCod.primary)
            Text(title)
                .codTextStyle(.label)
        }
        .codAccessibleHeader(title)
    }

    func moduleGrid(modules: [HubModule], sectionOffset: Int) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: CodSpacing.md),
            GridItem(.flexible(), spacing: CodSpacing.md)
        ]
        return LazyVGrid(columns: columns, spacing: CodSpacing.md) {
            ForEach(Array(modules.enumerated()), id: \.element.name) { index, module in
                NavigationLink(value: module.destination) {
                    moduleCard(module: module)
                }
                .buttonStyle(.plain)
                .staggered(index: sectionOffset + index)
            }
        }
    }
}

// MARK: - Module Card

private extension DiscoveryHubView {
    func moduleCard(module: HubModule) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Image(systemName: module.icon)
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(module.tint)
                .frame(width: 44, height: 44)
                .background(module.tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))

            Text(module.name)
                .codTextStyle(.cardTitle)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(module.subtitle)
                .codTextStyle(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .codAccessibleButton(module.name, hint: module.subtitle)
    }
}

// MARK: - Navigation Destinations

enum HubDestination: Hashable {
    case moodDiscovery
    case localSuggestions
    case dishFinder
    case bestTimeToGo
    case sharkAlert
    case photoWall
    case beachCheckIn
    case events
    case hiddenGems
    case teenHangouts
    case headsUp
    case coloringBook
    case departureAdvisor
    case socialHub
    case appTheme
    case experienceMode
    case aiMemory
    case offlineMode
}

extension View {
    func hubNavigationDestinations() -> some View {
        self.navigationDestination(for: HubDestination.self) { destination in
            switch destination {
            case .moodDiscovery: MoodDiscoveryView()
            case .localSuggestions: LocalSuggestionsView()
            case .dishFinder: DishFinderView()
            case .bestTimeToGo: BestTimeToGoView()
            case .sharkAlert: SharkAlertView()
            case .photoWall: PhotoWallView()
            case .beachCheckIn: BeachCheckInView()
            case .events: EventsView()
            case .hiddenGems: HiddenGemsView()
            case .teenHangouts: TeenHangoutsView()
            case .headsUp: CapeHeadsUpGame()
            case .coloringBook: ColoringBookView()
            case .departureAdvisor: DepartureAdvisorView()
            case .socialHub: SocialHubView()
            case .appTheme: ThemePickerView()
            case .experienceMode: ExperienceModeSelectorView()
            case .aiMemory: ChatMemoryView()
            case .offlineMode: OfflineStatusView()
            }
        }
    }
}

// MARK: - Data Model

private struct HubModule {
    let name: String
    let subtitle: String
    let icon: String
    let tint: Color
    let destination: HubDestination
}

private struct HubSection {
    let title: String
    let icon: String
    let modules: [HubModule]
}

// MARK: - Module Catalog

private extension DiscoveryHubView {
    var allSections: [HubSection] {
        [
            HubSection(title: "Eat & Drink", icon: "fork.knife", modules: [
                HubModule(
                    name: "I'm in the Mood For...",
                    subtitle: "Find your perfect meal",
                    icon: "fork.knife.circle.fill",
                    tint: Color.capeCod.sunsetOrange,
                    destination: .moodDiscovery
                ),
                HubModule(
                    name: "Local Picks",
                    subtitle: "Restaurants by town",
                    icon: "mappin.and.ellipse",
                    tint: Color.capeCod.cranberry,
                    destination: .localSuggestions
                ),
                HubModule(
                    name: "Find a Dish",
                    subtitle: "Best dish across the Cape",
                    icon: "sparkle.magnifyingglass",
                    tint: Color.capeCod.lobsterRed,
                    destination: .dishFinder
                ),
            ]),
            HubSection(title: "Beach & Ocean", icon: "water.waves", modules: [
                HubModule(
                    name: "Best Time to Go",
                    subtitle: "Ideal beach conditions",
                    icon: "clock.fill",
                    tint: Color.capeCod.oceanBlue,
                    destination: .bestTimeToGo
                ),
                HubModule(
                    name: "Shark Activity",
                    subtitle: "Sightings & safety info",
                    icon: "exclamationmark.triangle.fill",
                    tint: Color.capeCod.lobsterRed,
                    destination: .sharkAlert
                ),
                HubModule(
                    name: "Photo Wall",
                    subtitle: "Beach photo gallery",
                    icon: "photo.on.rectangle.angled",
                    tint: Color.capeCod.seafoam,
                    destination: .photoWall
                ),
                HubModule(
                    name: "Beach Check-In",
                    subtitle: "Share your visit",
                    icon: "mappin.circle.fill",
                    tint: Color.capeCod.duneGrass,
                    destination: .beachCheckIn
                ),
            ]),
            HubSection(title: "Discover", icon: "binoculars.fill", modules: [
                HubModule(
                    name: "Events & Happenings",
                    subtitle: "What's on the Cape",
                    icon: "calendar.badge.clock",
                    tint: Color.capeCod.sandbarYellow,
                    destination: .events
                ),
                HubModule(
                    name: "Hidden Cape Cod",
                    subtitle: "Off-the-beaten-path spots",
                    icon: "sparkles",
                    tint: Color.capeCod.deepNavy,
                    destination: .hiddenGems
                ),
                HubModule(
                    name: "Teen Scene",
                    subtitle: "Fun for teens",
                    icon: "headphones",
                    tint: Color.capeCod.seafoam,
                    destination: .teenHangouts
                ),
            ]),
            HubSection(title: "Fun & Games", icon: "gamecontroller.fill", modules: [
                HubModule(
                    name: "Cape Cod Heads Up",
                    subtitle: "Party game for families",
                    icon: "gamecontroller.fill",
                    tint: Color.capeCod.sunsetOrange,
                    destination: .headsUp
                ),
                HubModule(
                    name: "Coloring Book",
                    subtitle: "Cape-themed coloring",
                    icon: "paintbrush.fill",
                    tint: Color.capeCod.cranberry,
                    destination: .coloringBook
                ),
            ]),
            HubSection(title: "Travel Tools", icon: "car.fill", modules: [
                HubModule(
                    name: "Departure Advisor",
                    subtitle: "Beat the bridge traffic",
                    icon: "car.fill",
                    tint: Color.capeCod.driftwood,
                    destination: .departureAdvisor
                ),
                HubModule(
                    name: "Social Hub",
                    subtitle: "Share your Cape trip",
                    icon: "bubble.left.and.bubble.right.fill",
                    tint: Color.capeCod.oceanBlue,
                    destination: .socialHub
                ),
            ]),
            HubSection(title: "Settings", icon: "gearshape.fill", modules: [
                HubModule(
                    name: "App Theme",
                    subtitle: "Customize appearance",
                    icon: "paintpalette.fill",
                    tint: Color.capeCod.primary,
                    destination: .appTheme
                ),
                HubModule(
                    name: "Experience Mode",
                    subtitle: "Tailor your experience",
                    icon: "person.2.fill",
                    tint: Color.capeCod.seafoam,
                    destination: .experienceMode
                ),
                HubModule(
                    name: "AI Memory",
                    subtitle: "Manage AI preferences",
                    icon: "brain",
                    tint: Color.capeCod.deepNavy,
                    destination: .aiMemory
                ),
                HubModule(
                    name: "Offline Mode",
                    subtitle: "Cache management",
                    icon: "wifi.slash",
                    tint: Color.capeCod.fog,
                    destination: .offlineMode
                ),
            ]),
        ]
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DiscoveryHubView()
            .hubNavigationDestinations()
    }
}
