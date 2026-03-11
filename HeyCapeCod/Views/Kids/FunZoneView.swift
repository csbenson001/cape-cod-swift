import SwiftUI

struct FunZoneView: View {
    @Environment(AppState.self) private var appState
    @State private var showingBingo = false
    @State private var showingPassport = false
    @State private var showingStories = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    heroSection
                    activitiesGrid
                    scavengerHuntSection
                }
                .padding(.bottom, CodSpacing.tabBarClearance)
            }
            .scrollContentBackground(.hidden)
            .background(Color.capeCod.background)
            .navigationTitle("Fun Zone")
            .sheet(isPresented: $showingBingo) {
                NavigationStack { CapeCodBingoView() }
            }
            .sheet(isPresented: $showingPassport) {
                NavigationStack { DigitalPassportView() }
            }
            .sheet(isPresented: $showingStories) {
                NavigationStack { TellMeAStoryView() }
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.capeCod.sunsetOrange)
                .symbolEffect(.pulse, options: .repeating)

            Text("Ahoy, Explorer!")
                .codTextStyle(.sectionTitle)

            Text("Pick an adventure to get started")
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, CodSpacing.lg)
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Activities Grid

    private var activitiesGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: CodSpacing.md),
                      GridItem(.flexible(), spacing: CodSpacing.md)],
            spacing: CodSpacing.md
        ) {
            activityCard(
                title: "Stories",
                icon: "book.fill",
                color: Color.capeCod.oceanBlue,
                description: "Pirate tales & sea legends"
            ) {
                showingStories = true
            }
            .staggered(index: 0)

            activityCard(
                title: "Bingo",
                icon: "square.grid.3x3.fill",
                color: Color.capeCod.sunsetOrange,
                description: "Cape Cod scavenger bingo"
            ) {
                showingBingo = true
            }
            .staggered(index: 1)

            activityCard(
                title: "Passport",
                icon: "stamp.fill",
                color: Color.capeCod.seafoam,
                description: "Collect stamps at stops"
            ) {
                showingPassport = true
            }
            .staggered(index: 2)

            activityCard(
                title: "Coloring",
                icon: "paintpalette.fill",
                color: Color.capeCod.duneGrass,
                description: "Cape Cod coloring book"
            ) {
                // Placeholder for future coloring feature
                CodHaptic.tap()
            }
            .staggered(index: 3)
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Activity Card

    private func activityCard(
        title: String,
        icon: String,
        color: Color,
        description: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            CodHaptic.tap()
            action()
        }) {
            VStack(spacing: CodSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(color)

                Text(title)
                    .codTextStyle(.cardTitle)

                Text(description)
                    .codTextStyle(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleCard(label: title, hint: description)
    }

    // MARK: - Scavenger Hunt

    private var scavengerHuntSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Scavenger Hunts")
                .codTextStyle(.subtitle)
                .padding(.horizontal, CodSpacing.screenEdge)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.md) {
                    scavengerCard(
                        title: "Beach Treasures",
                        items: "Shells, sea glass, driftwood...",
                        icon: "binoculars.fill",
                        index: 0
                    )
                    scavengerCard(
                        title: "Nature Spotter",
                        items: "Seals, herons, horseshoe crabs...",
                        icon: "leaf.fill",
                        index: 1
                    )
                    scavengerCard(
                        title: "Lighthouse Quest",
                        items: "Find all 4 lighthouses!",
                        icon: "location.fill",
                        index: 2
                    )
                }
                .padding(.horizontal, CodSpacing.screenEdge)
            }
        }
    }

    private func scavengerCard(
        title: String,
        items: String,
        icon: String,
        index: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.capeCod.sunsetOrange)
                Text(title)
                    .codTextStyle(.cardTitle)
            }
            Text(items)
                .codTextStyle(.caption)
                .lineLimit(2)

            HStack {
                Text("0/6 found")
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.textSecondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.capeCod.driftwood)
            }
        }
        .frame(width: 200)
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .staggered(index: index)
    }
}

#Preview {
    FunZoneView()
        .environment(AppState())
}
