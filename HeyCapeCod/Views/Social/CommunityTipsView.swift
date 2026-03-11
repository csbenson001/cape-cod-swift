import SwiftUI

// MARK: - Community Tips View

struct CommunityTipsView: View {
    @State private var viewModel = CommunityTipsViewModel()
    @State private var showAddTip = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    headerSection
                        .staggered(index: 0)
                    categoryFilter
                        .staggered(index: 1)
                    tipsList
                        .staggered(index: 2)
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Community Tips")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTip = true
                        CodHaptic.tap()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.capeCod.oceanBlue)
                    }
                }
            }
            .sheet(isPresented: $showAddTip) {
                AddTipSheet(viewModel: viewModel)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Text("Tips from fellow Cape Cod visitors")
                .codTextStyle(.body)
                .multilineTextAlignment(.center)
            Text("\(viewModel.filteredTips.count) tips shared")
                .codTextStyle(.caption)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                filterChip("All", tag: nil)
                ForEach(CommunityTipCategory.allCases) { cat in
                    filterChip(cat.title, tag: cat)
                }
            }
        }
    }

    private func filterChip(_ title: String, tag: CommunityTipCategory?) -> some View {
        let isSelected = viewModel.selectedCategory == tag
        return Button {
            withAnimation(CodAnimation.quick) {
                viewModel.selectedCategory = tag
            }
            CodHaptic.selection()
        } label: {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .padding(.horizontal, CodSpacing.md)
                .padding(.vertical, CodSpacing.sm)
                .foregroundStyle(isSelected ? Color.capeCod.textOnPrimary : Color.capeCod.textPrimary)
                .background(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.surface)
                .clipShape(Capsule())
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
    }

    // MARK: - Tips List

    private var tipsList: some View {
        VStack(spacing: CodSpacing.md) {
            ForEach(Array(viewModel.filteredTips.enumerated()), id: \.element.id) { index, tip in
                communityTipCard(tip, index: index)
            }
        }
    }

    private func communityTipCard(_ tip: CommunityTip, index: Int) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            tipCardHeader(tip)
            Text(tip.text)
                .font(.system(size: 15))
                .foregroundStyle(Color.capeCod.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            tipCardFooter(tip)
        }
        .padding(CodSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .staggered(index: index)
    }

    private func tipCardHeader(_ tip: CommunityTip) -> some View {
        HStack {
            Image(systemName: tip.category.icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.capeCod.oceanBlue)
            Text(tip.category.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.capeCod.oceanBlue)
            Spacer()
            if !tip.location.isEmpty {
                HStack(spacing: 2) {
                    Image(systemName: "mappin")
                        .font(.system(size: 10))
                    Text(tip.location)
                        .font(.system(size: 12))
                }
                .foregroundStyle(Color.capeCod.textSecondary)
            }
        }
    }

    private func tipCardFooter(_ tip: CommunityTip) -> some View {
        HStack {
            Text(tip.timestamp.formatted(.relative(presentation: .named)))
                .font(.system(size: 12))
                .foregroundStyle(Color.capeCod.driftwood)
            Spacer()
            Button {
                viewModel.toggleLike(tip)
                CodHaptic.light()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: tip.isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 14))
                        .foregroundStyle(tip.isLiked ? Color.capeCod.cranberry : Color.capeCod.driftwood)
                    Text("\(tip.likes)")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.capeCod.driftwood)
                }
            }
        }
    }
}

// MARK: - Add Tip Sheet

struct AddTipSheet: View {
    let viewModel: CommunityTipsViewModel
    @State private var tipText = ""
    @State private var selectedCategory: CommunityTipCategory = .general
    @State private var location = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: CodSpacing.lg) {
                categoryPicker
                tipInput
                locationInput
                Spacer()
                CodButton("Share Tip", variant: .primary, icon: "paperplane.fill", isFullWidth: true) {
                    submitTip()
                }
                .disabled(tipText.isEmpty)
                .opacity(tipText.isEmpty ? 0.5 : 1)
            }
            .padding(CodSpacing.screenEdge)
            .background(Color.capeCod.background)
            .navigationTitle("Add a Tip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Category")
                .codTextStyle(.caption)
            Picker("Category", selection: $selectedCategory) {
                ForEach(CommunityTipCategory.allCases) { cat in
                    Text(cat.title).tag(cat)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var tipInput: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Your Tip")
                .codTextStyle(.caption)
            TextField("Share something helpful...", text: $tipText, axis: .vertical)
                .lineLimit(3...8)
                .padding(CodSpacing.md)
                .background(Color.capeCod.surface)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
        }
    }

    private var locationInput: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Location (optional)")
                .codTextStyle(.caption)
            TextField("e.g. Chatham, Provincetown", text: $location)
                .padding(CodSpacing.md)
                .background(Color.capeCod.surface)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
        }
    }

    private func submitTip() {
        guard !tipText.isEmpty else { return }
        viewModel.addTip(text: tipText, category: selectedCategory, location: location)
        CodHaptic.success()
        dismiss()
    }
}

// MARK: - Community Tip Model

struct CommunityTip: Identifiable, Codable {
    let id: UUID
    let text: String
    let category: CommunityTipCategory
    let location: String
    let timestamp: Date
    var likes: Int
    var isLiked: Bool

    init(id: UUID = UUID(), text: String, category: CommunityTipCategory, location: String = "", likes: Int = 0) {
        self.id = id
        self.text = text
        self.category = category
        self.location = location
        self.timestamp = .now
        self.likes = likes
        self.isLiked = false
    }
}

enum CommunityTipCategory: String, Codable, CaseIterable, Identifiable {
    case general
    case parking
    case food
    case activities
    case weather

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: "General"
        case .parking: "Parking"
        case .food: "Food"
        case .activities: "Activities"
        case .weather: "Weather"
        }
    }

    var icon: String {
        switch self {
        case .general: "lightbulb.fill"
        case .parking: "car.fill"
        case .food: "fork.knife"
        case .activities: "figure.walk"
        case .weather: "cloud.sun.fill"
        }
    }
}

// MARK: - View Model

@MainActor
@Observable
final class CommunityTipsViewModel {
    var tips: [CommunityTip] = []
    var selectedCategory: CommunityTipCategory?

    var filteredTips: [CommunityTip] {
        guard let category = selectedCategory else { return tips }
        return tips.filter { $0.category == category }
    }

    init() {
        loadTips()
        if tips.isEmpty { seedSampleTips() }
    }

    func addTip(text: String, category: CommunityTipCategory, location: String) {
        let tip = CommunityTip(text: text, category: category, location: location)
        tips.insert(tip, at: 0)
        saveTips()
    }

    func toggleLike(_ tip: CommunityTip) {
        guard let idx = tips.firstIndex(where: { $0.id == tip.id }) else { return }
        tips[idx].isLiked.toggle()
        tips[idx].likes += tips[idx].isLiked ? 1 : -1
        saveTips()
    }

    private func saveTips() {
        if let data = try? JSONEncoder().encode(tips) {
            UserDefaults.standard.set(data, forKey: "communityTips")
        }
    }

    private func loadTips() {
        if let data = UserDefaults.standard.data(forKey: "communityTips"),
           let saved = try? JSONDecoder().decode([CommunityTip].self, from: data) {
            tips = saved
        }
    }

    private func seedSampleTips() {
        tips = [
            CommunityTip(text: "Get to Nauset Beach before 9 AM or you won't find parking!", category: .parking, location: "Orleans", likes: 24),
            CommunityTip(text: "The Knack in Orleans has the BEST lobster roll. Worth the wait!", category: .food, location: "Orleans", likes: 18),
            CommunityTip(text: "Low tide at Skaket Beach creates tide pools kids go crazy for.", category: .activities, location: "Orleans", likes: 31),
            CommunityTip(text: "Fog usually burns off by 10 AM. Don't cancel beach plans!", category: .weather, likes: 15),
            CommunityTip(text: "Free parking at Nickerson State Park if you arrive early.", category: .parking, location: "Brewster", likes: 22),
            CommunityTip(text: "PB Boulangerie in Wellfleet - best pastries on the Cape.", category: .food, location: "Wellfleet", likes: 27),
            CommunityTip(text: "Rent bikes from Idle Times in Wellfleet for the Rail Trail.", category: .activities, location: "Wellfleet", likes: 12),
            CommunityTip(text: "Bay side beaches are warmer and calmer for little kids.", category: .general, likes: 35)
        ]
        saveTips()
    }
}

#Preview {
    CommunityTipsView()
}
