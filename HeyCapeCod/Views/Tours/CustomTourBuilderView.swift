import SwiftUI

/// AI-powered custom tour builder that lets users select a theme, duration,
/// region, and interests to generate a personalized Cape Cod tour.
struct CustomTourBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTheme: TourTheme?
    @State private var selectedDuration: TourDuration = .halfDay
    @State private var selectedRegion: CapeRegion?
    @State private var includeFood = false
    @State private var avoidCrowds = false
    @State private var customInterests: String = ""
    @State private var isGenerating = false
    @State private var generatedTour: GuidedTour?
    @State private var showTourDetail = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    headerSection
                    themeSection
                    durationSection
                    regionSection
                    preferencesSection
                    generateButton
                }
                .padding(.bottom, CodSpacing.xxl)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Create Your Tour")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.capeCod.oceanBlue)
                }
            }
            .navigationDestination(isPresented: $showTourDetail) {
                if let tour = generatedTour {
                    TourDetailView(tour: tour)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CodSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.capeCod.oceanBlue.opacity(0.12))
                    .frame(width: 72, height: 72)

                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }

            VStack(spacing: CodSpacing.xs) {
                Text("AI Tour Builder")
                    .codTextStyle(.sectionTitle)

                Text("Tell us what you're into and we'll create a personalized Cape Cod tour just for you")
                    .codTextStyle(.body)
                    .foregroundStyle(Color.capeCod.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.top, CodSpacing.md)
    }

    // MARK: - Theme Selection

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Choose a Theme")
                .codTextStyle(.sectionTitle)
                .padding(.horizontal, CodSpacing.screenEdge)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: CodSpacing.sm) {
                    ForEach(TourTheme.allCases) { theme in
                        ThemeCard(
                            theme: theme,
                            isSelected: selectedTheme == theme,
                            action: {
                                withAnimation(CodAnimation.quick) {
                                    selectedTheme = selectedTheme == theme ? nil : theme
                                }
                                CodHaptic.selection()
                            }
                        )
                    }
                }
                .padding(.horizontal, CodSpacing.screenEdge)
            }
        }
    }

    // MARK: - Duration

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("How Much Time?")
                .codTextStyle(.sectionTitle)

            HStack(spacing: CodSpacing.sm) {
                ForEach(TourDuration.allCases) { duration in
                    Button {
                        withAnimation(CodAnimation.quick) { selectedDuration = duration }
                        CodHaptic.selection()
                    } label: {
                        VStack(spacing: CodSpacing.xs) {
                            Text(duration.displayName)
                                .codTextStyle(.label)
                            Text("\(duration.maxStops) stops")
                                .codTextStyle(.label)
                                .foregroundStyle(Color.capeCod.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, CodSpacing.md)
                        .background(selectedDuration == duration ? Color.capeCod.oceanBlue : Color.capeCod.surfaceElevated)
                        .foregroundStyle(selectedDuration == duration ? .white : Color.capeCod.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
                    }
                    .buttonStyle(CodButtonPressStyle(variant: .ghost))
                }
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Region

    private var regionSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Region (Optional)")
                .codTextStyle(.sectionTitle)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.sm) {
                    regionChip(label: "All Cape", region: nil)
                    ForEach(CapeRegion.allCases) { region in
                        regionChip(label: region.rawValue, region: region)
                    }
                }
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    private func regionChip(label: String, region: CapeRegion?) -> some View {
        Button {
            withAnimation(CodAnimation.quick) { selectedRegion = region }
            CodHaptic.selection()
        } label: {
            Text(label)
                .codTextStyle(.label)
                .padding(.horizontal, CodSpacing.md)
                .padding(.vertical, CodSpacing.sm)
                .background(selectedRegion == region ? Color.capeCod.oceanBlue : Color.capeCod.surfaceElevated)
                .foregroundStyle(selectedRegion == region ? .white : Color.capeCod.textPrimary)
                .clipShape(Capsule())
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Preferences")
                .codTextStyle(.sectionTitle)

            VStack(spacing: CodSpacing.sm) {
                Toggle(isOn: $includeFood) {
                    HStack(spacing: CodSpacing.sm) {
                        Image(systemName: "fork.knife")
                            .foregroundStyle(Color.capeCod.oceanBlue)
                        Text("Include restaurant stops")
                            .codTextStyle(.body)
                    }
                }
                .tint(Color.capeCod.oceanBlue)

                Toggle(isOn: $avoidCrowds) {
                    HStack(spacing: CodSpacing.sm) {
                        Image(systemName: "person.2.slash")
                            .foregroundStyle(Color.capeCod.oceanBlue)
                        Text("Prefer less crowded spots")
                            .codTextStyle(.body)
                    }
                }
                .tint(Color.capeCod.oceanBlue)
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))

            // Custom interests
            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                Text("Anything specific? (optional)")
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.textSecondary)

                TextField("e.g., lighthouses, whale watching, art galleries...", text: $customInterests)
                    .codTextStyle(.body)
                    .padding(CodSpacing.md)
                    .background(Color.capeCod.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        VStack(spacing: CodSpacing.md) {
            CodButton(
                isGenerating ? "Generating..." : "Generate My Tour",
                variant: .primary,
                icon: isGenerating ? "hourglass" : "sparkles",
                isFullWidth: true
            ) {
                generateTour()
            }
            .disabled(isGenerating)

            if isGenerating {
                HStack(spacing: CodSpacing.sm) {
                    ProgressView()
                        .tint(Color.capeCod.oceanBlue)
                    Text("Our AI is crafting your perfect tour...")
                        .codTextStyle(.caption)
                        .foregroundStyle(Color.capeCod.textSecondary)
                }
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Actions

    private func generateTour() {
        CodHaptic.tap()
        isGenerating = true

        Task {
            var interests: [String] = []
            if !customInterests.isEmpty {
                interests = customInterests.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            }

            let request = TourRequest(
                theme: selectedTheme,
                interests: interests,
                duration: selectedDuration,
                region: selectedRegion,
                experienceMode: UserProfileManager.shared.currentProfile?.experienceMode,
                includeFood: includeFood,
                avoidCrowds: avoidCrowds
            )

            let tour = await TourGeneratorService.shared.generateTour(request: request)
            isGenerating = false

            if let tour {
                CodHaptic.success()
                generatedTour = tour
                showTourDetail = true
            }
        }
    }
}

// MARK: - Theme Card

private struct ThemeCard: View {
    let theme: TourTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: CodSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.oceanBlue.opacity(0.1))
                        .frame(width: 52, height: 52)

                    Image(systemName: theme.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(isSelected ? .white : Color.capeCod.oceanBlue)
                }

                Text(theme.displayName)
                    .codTextStyle(.label)
                    .foregroundStyle(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.textPrimary)
                    .lineLimit(1)
            }
            .frame(width: 88)
            .padding(.vertical, CodSpacing.md)
            .background(isSelected ? Color.capeCod.oceanBlue.opacity(0.08) : Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                    .strokeBorder(isSelected ? Color.capeCod.oceanBlue : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleButton(
            "\(theme.displayName) theme",
            hint: isSelected ? "Currently selected" : "Double tap to select"
        )
    }
}

#Preview {
    CustomTourBuilderView()
}
