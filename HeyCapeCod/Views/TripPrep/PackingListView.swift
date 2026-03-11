import SwiftUI

// MARK: - Models

enum PlannedActivity: String, CaseIterable, Codable, Identifiable {
    case beach = "Beach"
    case hiking = "Hiking"
    case whaleWatch = "Whale Watch"
    case fishing = "Fishing"
    case biking = "Biking"
    case tidePooling = "Tide Pooling"
    case diningOut = "Dining Out"
    case miniGolf = "Mini Golf"
    case museumVisits = "Museum Visits"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .beach: "beach.umbrella.fill"
        case .hiking: "figure.hiking"
        case .whaleWatch: "binoculars.fill"
        case .fishing: "fish.fill"
        case .biking: "bicycle"
        case .tidePooling: "water.waves"
        case .diningOut: "fork.knife"
        case .miniGolf: "flag.fill"
        case .museumVisits: "building.columns.fill"
        }
    }
}

enum PackingCategory: String, CaseIterable, Codable, Identifiable {
    case beachEssentials = "Beach Essentials"
    case clothing = "Clothing"
    case capeSpecific = "Cape Cod Specific"
    case kidsGear = "Kids' Gear"
    case weatherAlerts = "Weather Alerts"
    case documents = "Documents"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .beachEssentials: "beach.umbrella.fill"
        case .clothing: "tshirt.fill"
        case .capeSpecific: "mappin.and.ellipse"
        case .kidsGear: "figure.and.child.holdinghands"
        case .weatherAlerts: "cloud.sun.fill"
        case .documents: "doc.text.fill"
        }
    }

    var color: Color {
        switch self {
        case .beachEssentials: Color.capeCod.oceanBlue
        case .clothing: Color.capeCod.sunsetOrange
        case .capeSpecific: Color.capeCod.seafoam
        case .kidsGear: Color.capeCod.duneGrass
        case .weatherAlerts: Color.capeCod.sandbarYellow
        case .documents: Color.capeCod.driftwood
        }
    }
}

struct PackingItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let category: PackingCategory
    let note: String?
    let isCustom: Bool

    init(id: String = UUID().uuidString, name: String, category: PackingCategory, note: String? = nil, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.note = note
        self.isCustom = isCustom
    }
}

// MARK: - Trip Configuration

struct TripConfig: Codable, Equatable {
    var arrivalDate: Date
    var departureDate: Date
    var adults: Int
    var kids: Int
    var kidsAges: [Int]
    var activities: Set<PlannedActivity>

    static var `default`: TripConfig {
        TripConfig(
            arrivalDate: Date(),
            departureDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            adults: 2,
            kids: 0,
            kidsAges: [],
            activities: [.beach]
        )
    }

    var tripDays: Int {
        max(1, Calendar.current.dateComponents([.day], from: arrivalDate, to: departureDate).day ?? 1)
    }

    var season: CapeCodSeason {
        let month = Calendar.current.component(.month, from: arrivalDate)
        switch month {
        case 6, 7, 8: return .summer
        case 9, 10, 11: return .fall
        case 3, 4, 5: return .spring
        default: return .winter
        }
    }
}

enum CapeCodSeason: String {
    case spring, summer, fall, winter
}

// MARK: - Packing List Generator

private struct PackingListGenerator {

    static func generate(for config: TripConfig) -> [PackingItem] {
        var items: [PackingItem] = []

        // Beach Essentials
        if config.activities.contains(.beach) || config.activities.contains(.tidePooling) {
            items.append(PackingItem(id: "beach-sunscreen", name: "Sunscreen (SPF 50+)", category: .beachEssentials, note: "Reef-safe preferred"))
            items.append(PackingItem(id: "beach-towels", name: "Beach towels (\(config.adults + config.kids))", category: .beachEssentials))
            items.append(PackingItem(id: "beach-chairs", name: "Beach chairs", category: .beachEssentials))
            items.append(PackingItem(id: "beach-umbrella", name: "Beach umbrella", category: .beachEssentials))
            items.append(PackingItem(id: "beach-cooler", name: "Cooler with ice packs", category: .beachEssentials))
            items.append(PackingItem(id: "beach-water", name: "Reusable water bottles", category: .beachEssentials))
        }
        if config.activities.contains(.tidePooling) {
            items.append(PackingItem(id: "beach-reef-shoes", name: "Reef shoes / water shoes", category: .beachEssentials, note: "Essential for rocky tide pools"))
        }

        // Clothing
        let clothingSets = max(config.tripDays, 3)
        items.append(PackingItem(id: "cloth-casual", name: "Casual outfits (\(clothingSets) sets)", category: .clothing))
        items.append(PackingItem(id: "cloth-swimsuits", name: "Swimsuits (2 per person)", category: .clothing))
        items.append(PackingItem(id: "cloth-layers", name: "Light layers / sweatshirts", category: .clothing, note: "Evenings cool down quickly near the water"))
        items.append(PackingItem(id: "cloth-rain", name: "Rain jacket or poncho", category: .clothing))
        items.append(PackingItem(id: "cloth-hat", name: "Sun hat or cap", category: .clothing))
        items.append(PackingItem(id: "cloth-sandals", name: "Sandals / flip-flops", category: .clothing))
        items.append(PackingItem(id: "cloth-walking", name: "Comfortable walking shoes", category: .clothing))
        if config.activities.contains(.diningOut) {
            items.append(PackingItem(id: "cloth-dinner", name: "Dinner outfit (smart casual)", category: .clothing, note: "Some Cape restaurants have dress codes"))
        }
        if config.activities.contains(.hiking) || config.activities.contains(.biking) {
            items.append(PackingItem(id: "cloth-athletic", name: "Athletic wear", category: .clothing))
        }

        // Cape Cod Specific
        items.append(PackingItem(id: "cape-cash", name: "Cash for beach parking", category: .capeSpecific, note: "$25/car at most town beaches"))
        items.append(PackingItem(id: "cape-bugspray", name: "Bug spray", category: .capeSpecific, note: "Greenhead flies in July, mosquitoes near marshes"))
        items.append(PackingItem(id: "cape-sunglasses", name: "Polarized sunglasses", category: .capeSpecific))
        if config.activities.contains(.whaleWatch) {
            items.append(PackingItem(id: "cape-binoculars", name: "Binoculars", category: .capeSpecific, note: "For whale watching and bird watching"))
            items.append(PackingItem(id: "cape-dramamine", name: "Motion sickness remedy", category: .capeSpecific, note: "Whale watch boats can be choppy"))
        }
        items.append(PackingItem(id: "cape-seashore", name: "National Seashore pass", category: .capeSpecific, note: "$25/vehicle daily or $65 season pass"))

        // Kids' Gear
        if config.kids > 0 {
            items.append(PackingItem(id: "kids-sand-toys", name: "Sand toys (buckets, shovels)", category: .kidsGear))
            items.append(PackingItem(id: "kids-flotation", name: "Flotation devices / puddle jumpers", category: .kidsGear))
            items.append(PackingItem(id: "kids-snacks", name: "Snacks and juice boxes", category: .kidsGear))
            items.append(PackingItem(id: "kids-entertainment", name: "Car entertainment (tablets, books)", category: .kidsGear, note: "Bridge traffic can add 1-2 hours"))

            let hasYoungKids = config.kidsAges.contains(where: { $0 <= 3 })
            if hasYoungKids || config.kidsAges.isEmpty {
                items.append(PackingItem(id: "kids-stroller", name: "Stroller", category: .kidsGear))
                items.append(PackingItem(id: "kids-diapers", name: "Diapers and wipes", category: .kidsGear))
            }
            items.append(PackingItem(id: "kids-sunscreen", name: "Kids' sunscreen (mineral)", category: .kidsGear))
            items.append(PackingItem(id: "kids-rashguard", name: "Rash guards", category: .kidsGear))
        }

        // Weather Alerts
        switch config.season {
        case .summer:
            items.append(PackingItem(id: "weather-rain", name: "Rain gear", category: .weatherAlerts, note: "Cape Cod averages 3 rainy days per week in summer"))
            items.append(PackingItem(id: "weather-evening", name: "Evening sweatshirts", category: .weatherAlerts, note: "Evenings cool to low 60s even in summer"))
            items.append(PackingItem(id: "weather-aloe", name: "Aloe vera / after-sun care", category: .weatherAlerts))
        case .fall:
            items.append(PackingItem(id: "weather-warm-layers", name: "Warm layers", category: .weatherAlerts, note: "Temperatures range 45-65F"))
            items.append(PackingItem(id: "weather-wind", name: "Windbreaker", category: .weatherAlerts, note: "Coastal winds pick up in fall"))
        case .spring:
            items.append(PackingItem(id: "weather-cold-water", name: "Wetsuit or dry bag", category: .weatherAlerts, note: "Water is still cold (50-55F) in spring"))
            items.append(PackingItem(id: "weather-spring-layers", name: "Layered clothing", category: .weatherAlerts, note: "Days vary from 45-70F"))
        case .winter:
            items.append(PackingItem(id: "weather-winter", name: "Heavy winter coat", category: .weatherAlerts, note: "Wind chill can be brutal on the coast"))
            items.append(PackingItem(id: "weather-thermals", name: "Thermal underlayers", category: .weatherAlerts))
        }

        // Documents
        items.append(PackingItem(id: "doc-parking", name: "Beach parking sticker info", category: .documents, note: "Check with your rental or town hall"))
        items.append(PackingItem(id: "doc-reservations", name: "Reservation confirmations", category: .documents))
        if config.activities.contains(.fishing) {
            items.append(PackingItem(id: "doc-fishing", name: "Massachusetts fishing license", category: .documents, note: "Required for saltwater fishing, buy online at mass.gov"))
        }
        if config.activities.contains(.whaleWatch) {
            items.append(PackingItem(id: "doc-whale", name: "Whale watch booking confirmation", category: .documents))
        }

        return items
    }
}

// MARK: - Season Tips

private struct SeasonTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
}

private func seasonTips(for season: CapeCodSeason) -> [SeasonTip] {
    switch season {
    case .summer:
        return [
            SeasonTip(icon: "exclamationmark.triangle.fill", title: "Shark Safety", detail: "White sharks are active June-October. Swim near lifeguards, avoid seals, and stay in waist-deep water."),
            SeasonTip(icon: "car.fill", title: "Parking Tips", detail: "Arrive at beaches before 9 AM. Town beach stickers sell out fast -- check your rental for included passes."),
            SeasonTip(icon: "calendar.badge.clock", title: "Reserve Ahead", detail: "Book whale watches, restaurants, and bike rentals at least 2 weeks in advance during peak season."),
            SeasonTip(icon: "road.lanes", title: "Bridge Traffic", detail: "Avoid crossing the Bourne or Sagamore bridges Friday afternoon or Sunday evening. Use the Bourne Bridge for south-side towns.")
        ]
    case .fall:
        return [
            SeasonTip(icon: "leaf.fill", title: "Cranberry Harvest", detail: "Visit cranberry bogs in Harwich and Carver during September-October to see the stunning red harvest."),
            SeasonTip(icon: "person.2.fill", title: "Fewer Crowds", detail: "Post-Labor Day is the best-kept secret. Warm water, empty beaches, and no traffic."),
            SeasonTip(icon: "sunset.fill", title: "Golden Light", detail: "Fall sunsets on Cape Cod Bay are spectacular. Head to Skaket Beach in Orleans for the best views."),
        ]
    case .spring:
        return [
            SeasonTip(icon: "thermometer.snowflake", title: "Cold Water", detail: "Ocean water is 50-55F in spring. Wetsuits recommended for any water activities."),
            SeasonTip(icon: "binoculars.fill", title: "Whale Watching Starts", detail: "Humpback whales return to Stellwagen Bank in April. Book tours from Provincetown or Barnstable."),
            SeasonTip(icon: "bird.fill", title: "Bird Migration", detail: "Spring brings shorebird migration. Visit Wellfleet Bay Wildlife Sanctuary or Monomoy Island."),
        ]
    case .winter:
        return [
            SeasonTip(icon: "snowflake", title: "Off-Season Charm", detail: "Quiet beaches, cozy restaurants, and locals-only vibes. Many galleries and shops stay open year-round."),
            SeasonTip(icon: "fork.knife", title: "Restaurant Closures", detail: "Many seasonal restaurants close November-April. Call ahead or check websites before driving."),
            SeasonTip(icon: "wind", title: "Storm Watching", detail: "Nor'easters create dramatic surf. Watch safely from Nauset Light Beach or Race Point."),
        ]
    }
}

// MARK: - UserDefaults Keys

private enum PackingListKeys {
    static let checkedItems = "packingList_checkedItems"
    static let customItems = "packingList_customItems"
    static let tripConfig = "packingList_tripConfig"
}

// MARK: - Kids Ages Editor (extracted for compiler)

private struct KidsAgesEditorView: View {
    @Binding var kidsAges: [Int]
    let maxKids: Int
    @Binding var newKidAge: String

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.xs) {
            Text("Kids' ages (optional)")
                .codTextStyle(.caption)
            HStack(spacing: CodSpacing.sm) {
                ForEach(kidsAges.indices, id: \.self) { index in
                    ageBadge(age: kidsAges[index], index: index)
                }
                if kidsAges.count < maxKids {
                    addAgeField
                }
            }
        }
    }

    private func ageBadge(age: Int, index: Int) -> some View {
        HStack(spacing: CodSpacing.xs) {
            Text("\(age)")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.capeCod.textPrimary)
            Button {
                withAnimation(CodAnimation.quick) {
                    let _ = kidsAges.remove(at: index)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.capeCod.driftwood)
            }
        }
        .padding(.horizontal, CodSpacing.sm)
        .padding(.vertical, CodSpacing.xs)
        .background {
            let bgColor: Color = Color.capeCod.oceanBlue
            Capsule().fill(bgColor.opacity(0.12))
        }
    }

    private var addAgeField: some View {
        HStack(spacing: CodSpacing.xs) {
            TextField("Age", text: $newKidAge)
                .keyboardType(.numberPad)
                .frame(width: 44)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CodSpacing.sm)
                .padding(.vertical, CodSpacing.xs)
                .background(Color.capeCod.surface)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
            Button {
                if let age = Int(newKidAge), age > 0, age <= 17 {
                    withAnimation(CodAnimation.quick) {
                        kidsAges.append(age)
                        newKidAge = ""
                    }
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }
        }
    }
}

// MARK: - PackingListView

struct PackingListView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var config: TripConfig
    @State private var checkedItemIDs: Set<String> = []
    @State private var customItems: [PackingItem] = []
    @State private var showAddItem = false
    @State private var newItemName = ""
    @State private var newItemCategory: PackingCategory = .capeSpecific
    @State private var showResetConfirmation = false
    @State private var expandedCategories: Set<PackingCategory> = Set(PackingCategory.allCases)
    @State private var showTripSetup = true
    @State private var newKidAge = ""
    @State private var headerAppeared = false

    // MARK: - Init

    init() {
        if let data = UserDefaults.standard.data(forKey: PackingListKeys.tripConfig),
           let saved = try? JSONDecoder().decode(TripConfig.self, from: data) {
            _config = State(initialValue: saved)
        } else {
            _config = State(initialValue: .default)
        }
    }

    // MARK: - Computed

    private var generatedItems: [PackingItem] {
        PackingListGenerator.generate(for: config)
    }

    private var allItems: [PackingItem] {
        generatedItems + customItems
    }

    private var itemsByCategory: [(PackingCategory, [PackingItem])] {
        let grouped = Dictionary(grouping: allItems, by: \.category)
        return PackingCategory.allCases.compactMap { category in
            guard let items = grouped[category], !items.isEmpty else { return nil }
            return (category, items)
        }
    }

    private var totalItems: Int { allItems.count }

    private var packedItems: Int { checkedItemIDs.intersection(Set(allItems.map(\.id))).count }

    private var progress: Double {
        guard totalItems > 0 else { return 0 }
        return Double(packedItems) / Double(totalItems)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    headerSection
                        .staggered(index: 0)

                    progressSection
                        .staggered(index: 1)

                    tripSetupSection
                        .staggered(index: 2)

                    packingListSection
                        .staggered(index: 3)

                    seasonTipsSection
                        .staggered(index: 4)

                    actionButtons
                        .staggered(index: 5)
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Packing List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.capeCod.driftwood)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    shareButton
                }
            }
            .onAppear {
                loadState()
                withAnimation(CodAnimation.gentle) {
                    headerAppeared = true
                }
            }
            .onChange(of: config) { _, _ in
                saveTripConfig()
            }
            .alert("Reset Packing List", isPresented: $showResetConfirmation) {
                Button("Reset", role: .destructive) {
                    resetCheckedItems()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will uncheck all items. Your custom items will be kept.")
            }
            .sheet(isPresented: $showAddItem) {
                addItemSheet
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "suitcase.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.capeCod.oceanBlue)
                .symbolEffect(.bounce, options: .nonRepeating)
                .opacity(headerAppeared ? 1 : 0)

            Text("Smart Packing List")
                .codTextStyle(.heroTitle)
                .multilineTextAlignment(.center)

            Text("Tailored for your Cape Cod trip")
                .codTextStyle(.subtitle)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, CodSpacing.md)
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: CodSpacing.sm) {
            HStack {
                Text("\(packedItems) of \(totalItems) items packed")
                    .codTextStyle(.cardTitle)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .codTextStyle(.caption)
                    .foregroundStyle(progress >= 1.0 ? Color.capeCod.duneGrass : Color.capeCod.driftwood)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.capeCod.surface)
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(progress >= 1.0 ? Color.capeCod.duneGrass : Color.capeCod.oceanBlue)
                        .frame(width: geo.size.width * progress, height: 10)
                        .animation(CodAnimation.spring, value: progress)
                }
            }
            .frame(height: 10)

            if progress >= 1.0 {
                HStack(spacing: CodSpacing.xs) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.capeCod.duneGrass)
                    Text("All packed! You're ready for Cape Cod!")
                        .codTextStyle(.caption)
                        .foregroundStyle(Color.capeCod.duneGrass)
                }
                .transition(.codScale)
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Trip Setup

    private var tripSetupSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Button {
                CodHaptic.light()
                withAnimation(CodAnimation.spring) {
                    showTripSetup.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundStyle(Color.capeCod.oceanBlue)
                    Text("Trip Details")
                        .codTextStyle(.sectionTitle)
                    Spacer()
                    Image(systemName: showTripSetup ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.capeCod.driftwood)
                }
            }
            .buttonStyle(.plain)

            if showTripSetup {
                tripSetupContent
                    .transition(.codSlideUp)
            }
        }
    }

    private var tripSetupContent: some View {
        VStack(spacing: CodSpacing.md) {
            tripDatesSection
            Divider()
            travelersSection
            Divider()
            activitiesSection
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private var tripDatesSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("TRAVEL DATES")
                .codTextStyle(.label)
            DatePicker("Arrival", selection: $config.arrivalDate, displayedComponents: .date)
                .codTextStyle(.body)
                .tint(Color.capeCod.oceanBlue)
            DatePicker("Departure", selection: $config.departureDate, in: config.arrivalDate..., displayedComponents: .date)
                .codTextStyle(.body)
                .tint(Color.capeCod.oceanBlue)
            Text("\(config.tripDays)-day trip  \(config.season.rawValue.capitalized) season")
                .codTextStyle(.caption)
        }
    }

    private var travelersSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("TRAVELERS")
                .codTextStyle(.label)
            Stepper("Adults: \(config.adults)", value: $config.adults, in: 1...10)
                .codTextStyle(.body)
            Stepper("Kids: \(config.kids)", value: $config.kids, in: 0...10)
                .codTextStyle(.body)
                .onChange(of: config.kids) { _, newCount in
                    if newCount < config.kidsAges.count {
                        config.kidsAges = Array(config.kidsAges.prefix(newCount))
                    }
                }
            if config.kids > 0 {
                kidsAgesEditor
            }
        }
    }

    private var kidsAgesEditor: some View {
        KidsAgesEditorView(
            kidsAges: $config.kidsAges,
            maxKids: config.kids,
            newKidAge: $newKidAge
        )
    }

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("PLANNED ACTIVITIES")
                .codTextStyle(.label)
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100), spacing: CodSpacing.sm)
            ], spacing: CodSpacing.sm) {
                ForEach(PlannedActivity.allCases) { activity in
                    activityChip(activity)
                }
            }
        }
    }

    private func activityChip(_ activity: PlannedActivity) -> some View {
        let isSelected = config.activities.contains(activity)
        return Button {
            CodHaptic.selection()
            withAnimation(CodAnimation.quick) {
                if isSelected {
                    config.activities.remove(activity)
                } else {
                    config.activities.insert(activity)
                }
            }
        } label: {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: activity.icon)
                    .font(.system(size: 12))
                Text(activity.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
            }
            .padding(.horizontal, CodSpacing.sm)
            .padding(.vertical, CodSpacing.sm)
            .frame(maxWidth: .infinity)
            .foregroundStyle(isSelected ? Color.capeCod.textOnPrimary : Color.capeCod.textPrimary)
            .background(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.surface)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Packing List

    private var packingListSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack {
                Text("Your Packing List")
                    .codTextStyle(.sectionTitle)

                Spacer()

                Button {
                    CodHaptic.selection()
                    showAddItem = true
                } label: {
                    HStack(spacing: CodSpacing.xs) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Item")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.capeCod.oceanBlue)
                }
            }

            ForEach(Array(itemsByCategory.enumerated()), id: \.element.0) { index, group in
                let (category, items) = group
                categorySection(category: category, items: items, index: index)
            }
        }
    }

    private func categorySection(category: PackingCategory, items: [PackingItem], index: Int) -> some View {
        let isExpanded = expandedCategories.contains(category)
        let checkedCount = items.filter { checkedItemIDs.contains($0.id) }.count

        return VStack(spacing: 0) {
            // Category header
            Button {
                CodHaptic.light()
                withAnimation(CodAnimation.spring) {
                    if isExpanded {
                        expandedCategories.remove(category)
                    } else {
                        expandedCategories.insert(category)
                    }
                }
            } label: {
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: category.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(category.color)
                        .frame(width: 28)

                    Text(category.rawValue)
                        .codTextStyle(.cardTitle)

                    Spacer()

                    Text("\(checkedCount)/\(items.count)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(checkedCount == items.count ? Color.capeCod.duneGrass : Color.capeCod.driftwood)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.capeCod.driftwood)
                }
                .padding(CodSpacing.cardPadding)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        packingItemRow(item: item)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .staggered(index: index)
    }

    private func packingItemRow(item: PackingItem) -> some View {
        let isChecked = checkedItemIDs.contains(item.id)

        return Button {
            CodHaptic.selection()
            withAnimation(CodAnimation.quick) {
                if isChecked {
                    checkedItemIDs.remove(item.id)
                } else {
                    checkedItemIDs.insert(item.id)
                }
            }
            saveCheckedItems()
        } label: {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isChecked ? Color.capeCod.duneGrass : Color.capeCod.driftwood.opacity(0.5))
                    .animation(CodAnimation.bouncy, value: isChecked)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(item.name)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(isChecked ? Color.capeCod.driftwood : Color.capeCod.textPrimary)
                            .strikethrough(isChecked, color: Color.capeCod.driftwood)

                        if item.isCustom {
                            Text("Custom")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Color.capeCod.sunsetOrange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.capeCod.sunsetOrange.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }

                    if let note = item.note {
                        Text(note)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(Color.capeCod.driftwood)
                            .lineLimit(2)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, CodSpacing.cardPadding)
            .padding(.vertical, CodSpacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)

        // Swipe to delete custom items
        .contextMenu {
            if item.isCustom {
                Button(role: .destructive) {
                    withAnimation(CodAnimation.spring) {
                        customItems.removeAll { $0.id == item.id }
                        checkedItemIDs.remove(item.id)
                        saveCustomItems()
                        saveCheckedItems()
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    // MARK: - Add Item Sheet

    private var addItemSheet: some View {
        NavigationStack {
            VStack(spacing: CodSpacing.lg) {
                VStack(alignment: .leading, spacing: CodSpacing.sm) {
                    Text("ITEM NAME")
                        .codTextStyle(.label)

                    TextField("e.g., Beach tent, Fishing rod", text: $newItemName)
                        .font(.system(size: 16))
                        .padding(CodSpacing.cardPadding)
                        .background(Color.capeCod.surface)
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
                }

                VStack(alignment: .leading, spacing: CodSpacing.sm) {
                    Text("CATEGORY")
                        .codTextStyle(.label)

                    ForEach(PackingCategory.allCases) { category in
                        Button {
                            CodHaptic.selection()
                            newItemCategory = category
                        } label: {
                            HStack(spacing: CodSpacing.sm) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 16))
                                    .foregroundStyle(category.color)
                                    .frame(width: 28)

                                Text(category.rawValue)
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundStyle(Color.capeCod.textPrimary)

                                Spacer()

                                if newItemCategory == category {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.capeCod.oceanBlue)
                                }
                            }
                            .padding(CodSpacing.sm)
                            .background(newItemCategory == category ? Color.capeCod.oceanBlue.opacity(0.08) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()
            }
            .padding(CodSpacing.screenEdge)
            .background(Color.capeCod.background)
            .navigationTitle("Add Custom Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        newItemName = ""
                        showAddItem = false
                    }
                    .foregroundStyle(Color.capeCod.driftwood)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        addCustomItem()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(newItemName.trimmingCharacters(in: .whitespaces).isEmpty ? Color.capeCod.driftwood : Color.capeCod.oceanBlue)
                    .disabled(newItemName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Season Tips

    private var seasonTipsSection: some View {
        let tips = seasonTips(for: config.season)

        return VStack(alignment: .leading, spacing: CodSpacing.md) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: seasonIcon(for: config.season))
                    .foregroundStyle(seasonColor(for: config.season))
                Text("\(config.season.rawValue.capitalized) Tips")
                    .codTextStyle(.sectionTitle)
            }

            VStack(spacing: CodSpacing.sm) {
                ForEach(Array(tips.enumerated()), id: \.element.id) { index, tip in
                    HStack(alignment: .top, spacing: CodSpacing.sm) {
                        Image(systemName: tip.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(seasonColor(for: config.season))
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: CodSpacing.xs) {
                            Text(tip.title)
                                .codTextStyle(.cardTitle)

                            Text(tip.detail)
                                .codTextStyle(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(CodSpacing.cardPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.capeCod.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
                    .adaptiveCardStyle()
                    .staggered(index: index)
                }
            }
        }
    }

    private func seasonIcon(for season: CapeCodSeason) -> String {
        switch season {
        case .summer: "sun.max.fill"
        case .fall: "leaf.fill"
        case .spring: "flower.fill"
        case .winter: "snowflake"
        }
    }

    private func seasonColor(for season: CapeCodSeason) -> Color {
        switch season {
        case .summer: Color.capeCod.sunsetOrange
        case .fall: Color.capeCod.cranberry
        case .spring: Color.capeCod.duneGrass
        case .winter: Color.capeCod.oceanBlue
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: CodSpacing.sm) {
            CodButton("Reset All Items", variant: .secondary, icon: "arrow.counterclockwise", isFullWidth: true) {
                showResetConfirmation = true
            }
        }
    }

    // MARK: - Share

    private var shareButton: some View {
        Button {
            CodHaptic.tap()
            sharePackingList()
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.capeCod.oceanBlue)
        }
    }

    private func sharePackingList() {
        var text = "Cape Cod Packing List\n"
        text += "\(config.tripDays)-day trip (\(config.season.rawValue.capitalized))\n"
        text += "\(config.adults) adults"
        if config.kids > 0 {
            text += ", \(config.kids) kids"
        }
        text += "\n\n"

        for (category, items) in itemsByCategory {
            text += "\(category.rawValue):\n"
            for item in items {
                let check = checkedItemIDs.contains(item.id) ? "[x]" : "[ ]"
                text += "  \(check) \(item.name)"
                if let note = item.note {
                    text += " -- \(note)"
                }
                text += "\n"
            }
            text += "\n"
        }

        text += "Shared from Hey Cape Cod"

        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else { return }

        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        topVC.present(activityVC, animated: true)
    }

    // MARK: - Persistence

    private func loadState() {
        // Load checked items
        let savedChecked = UserDefaults.standard.stringArray(forKey: PackingListKeys.checkedItems) ?? []
        checkedItemIDs = Set(savedChecked)

        // Load custom items
        if let data = UserDefaults.standard.data(forKey: PackingListKeys.customItems),
           let items = try? JSONDecoder().decode([PackingItem].self, from: data) {
            customItems = items
        }
    }

    private func saveCheckedItems() {
        UserDefaults.standard.set(Array(checkedItemIDs), forKey: PackingListKeys.checkedItems)
    }

    private func saveCustomItems() {
        if let data = try? JSONEncoder().encode(customItems) {
            UserDefaults.standard.set(data, forKey: PackingListKeys.customItems)
        }
    }

    private func saveTripConfig() {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: PackingListKeys.tripConfig)
        }
    }

    private func resetCheckedItems() {
        CodHaptic.warning()
        withAnimation(CodAnimation.spring) {
            checkedItemIDs.removeAll()
        }
        saveCheckedItems()
    }

    private func addCustomItem() {
        let trimmed = newItemName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let item = PackingItem(name: trimmed, category: newItemCategory, isCustom: true)
        withAnimation(CodAnimation.spring) {
            customItems.append(item)
        }
        saveCustomItems()
        CodHaptic.success()
        newItemName = ""
        showAddItem = false
    }
}

// MARK: - Preview

#Preview("Packing List") {
    PackingListView()
}

#Preview("Packing List - Sheet") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            PackingListView()
        }
}
