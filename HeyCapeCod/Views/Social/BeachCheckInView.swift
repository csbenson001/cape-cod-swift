import SwiftUI

// MARK: - Beach Check-In View

struct BeachCheckInView: View {
    @State private var viewModel = BeachCheckInViewModel()
    @State private var showShareCard = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    currentCheckInSection
                        .staggered(index: 0)
                    beachPickerSection
                        .staggered(index: 1)
                    recentCheckInsSection
                        .staggered(index: 2)
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Beach Check-In")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showShareCard) {
                if let beach = viewModel.selectedBeach {
                    ShareableCardPreview(cardType: .beachReport)
                        .onAppear { _ = beach } // Suppress unused warning
                }
            }
        }
    }

    // MARK: - Current Check-In

    @ViewBuilder
    private var currentCheckInSection: some View {
        if let checkIn = viewModel.activeCheckIn {
            activeCheckInCard(checkIn)
        } else {
            promptCard
        }
    }

    private func activeCheckInCard(_ checkIn: BeachCheckIn) -> some View {
        VStack(spacing: CodSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    Text("You're at")
                        .codTextStyle(.caption)
                    Text(checkIn.beachName)
                        .codTextStyle(.sectionTitle)
                }
                Spacer()
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }

            statusInput

            HStack(spacing: CodSpacing.md) {
                CodButton("Share", variant: .primary, icon: "square.and.arrow.up") {
                    showShareCard = true
                }
                CodButton("Check Out", variant: .secondary, icon: "xmark") {
                    viewModel.checkOut()
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private var promptCard: some View {
        VStack(spacing: CodSpacing.md) {
            Image(systemName: "beach.umbrella.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.capeCod.oceanBlue)
            Text("At the beach?")
                .codTextStyle(.sectionTitle)
            Text("Check in and share your experience!")
                .codTextStyle(.body)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(CodSpacing.xl)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Status Input

    private var statusInput: some View {
        HStack {
            TextField("How's the beach?", text: $viewModel.statusText)
                .font(.system(size: 15))
                .padding(CodSpacing.sm)
                .background(Color.capeCod.surface)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))

            if !viewModel.statusText.isEmpty {
                Button {
                    CodHaptic.tap()
                    viewModel.postStatus()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.capeCod.oceanBlue)
                }
            }
        }
    }

    // MARK: - Beach Picker

    private var beachPickerSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Popular Beaches")
                .codTextStyle(.sectionTitle)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CodSpacing.md) {
                ForEach(Array(viewModel.beaches.enumerated()), id: \.element) { index, beach in
                    beachCard(beach, index: index)
                }
            }
        }
    }

    private func beachCard(_ beach: String, index: Int) -> some View {
        Button {
            CodHaptic.tap()
            viewModel.checkIn(at: beach)
        } label: {
            VStack(spacing: CodSpacing.sm) {
                Image(systemName: "beach.umbrella.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.capeCod.oceanBlue)
                Text(beach)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.capeCod.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                Text(viewModel.checkInCount(for: beach))
                    .font(.system(size: 12))
                    .foregroundStyle(Color.capeCod.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(CodSpacing.md)
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .staggered(index: index)
    }

    // MARK: - Recent Check-Ins

    private var recentCheckInsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Recent Activity")
                .codTextStyle(.sectionTitle)

            if viewModel.recentCheckIns.isEmpty {
                emptyRecentState
            } else {
                recentCheckInsList
            }
        }
    }

    private var emptyRecentState: some View {
        Text("No recent check-ins yet. Be the first!")
            .codTextStyle(.body)
            .frame(maxWidth: .infinity)
            .padding(CodSpacing.xl)
            .background(Color.capeCod.surface)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }

    private var recentCheckInsList: some View {
        ForEach(viewModel.recentCheckIns) { checkIn in
            recentCheckInRow(checkIn)
        }
    }

    private func recentCheckInRow(_ checkIn: BeachCheckIn) -> some View {
        HStack(spacing: CodSpacing.md) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.capeCod.oceanBlue)
            VStack(alignment: .leading, spacing: 2) {
                Text(checkIn.beachName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.capeCod.textPrimary)
                if !checkIn.status.isEmpty {
                    Text(checkIn.status)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.capeCod.textSecondary)
                }
                Text(checkIn.timestamp.formatted(.relative(presentation: .named)))
                    .font(.system(size: 12))
                    .foregroundStyle(Color.capeCod.driftwood)
            }
            Spacer()
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }
}

// MARK: - Beach Check-In Model

struct BeachCheckIn: Identifiable, Codable {
    let id: UUID
    let beachName: String
    var status: String
    let timestamp: Date

    init(id: UUID = UUID(), beachName: String, status: String = "", timestamp: Date = .now) {
        self.id = id
        self.beachName = beachName
        self.status = status
        self.timestamp = timestamp
    }
}

// MARK: - View Model

@MainActor
@Observable
final class BeachCheckInViewModel {
    var selectedBeach: String?
    var activeCheckIn: BeachCheckIn?
    var recentCheckIns: [BeachCheckIn] = []
    var statusText = ""

    let beaches = [
        "Nauset Beach",
        "Coast Guard Beach",
        "Race Point Beach",
        "Craigville Beach",
        "Mayflower Beach",
        "Marconi Beach",
        "Sandy Neck Beach",
        "Skaket Beach",
        "Old Silver Beach",
        "Cahoon Hollow Beach"
    ]

    init() {
        loadCheckIns()
    }

    func checkIn(at beach: String) {
        let checkIn = BeachCheckIn(beachName: beach)
        activeCheckIn = checkIn
        selectedBeach = beach
        recentCheckIns.insert(checkIn, at: 0)
        saveCheckIns()
        CodHaptic.success()
    }

    func checkOut() {
        activeCheckIn = nil
        selectedBeach = nil
        CodHaptic.selection()
    }

    func postStatus() {
        guard var current = activeCheckIn, !statusText.isEmpty else { return }
        current.status = statusText
        activeCheckIn = current
        if let idx = recentCheckIns.firstIndex(where: { $0.id == current.id }) {
            recentCheckIns[idx] = current
        }
        statusText = ""
        saveCheckIns()
        CodHaptic.tap()
    }

    func checkInCount(for beach: String) -> String {
        let count = recentCheckIns.filter { $0.beachName == beach }.count
        return count == 0 ? "Check in" : "\(count) check-in\(count == 1 ? "" : "s")"
    }

    private func saveCheckIns() {
        if let data = try? JSONEncoder().encode(Array(recentCheckIns.prefix(50))) {
            UserDefaults.standard.set(data, forKey: "beachCheckIns")
        }
    }

    private func loadCheckIns() {
        if let data = UserDefaults.standard.data(forKey: "beachCheckIns"),
           let saved = try? JSONDecoder().decode([BeachCheckIn].self, from: data) {
            recentCheckIns = saved
        }
    }
}

#Preview {
    BeachCheckInView()
}
