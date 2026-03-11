import SwiftUI

/// Screen 3: Interest picking grid, filtered by selected experience mode.
struct OnboardingInterestsPage: View {
    let selectedMode: ExperienceMode
    @Binding var selectedInterests: Set<String>

    private var filteredInterests: [OnboardingInterest] {
        OnboardingInterest.allCases.filter { $0.isVisible(for: selectedMode) }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: CodSpacing.lg) {
                Spacer()
                    .frame(height: CodSpacing.xl)

                headerSection

                interestGrid

                selectionHint

                Spacer()
                    .frame(height: CodSpacing.xxl)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Text("What sounds fun?")
                .codTextStyle(.heroTitle)
                .multilineTextAlignment(.center)

            Text("Pick a few topics and we'll highlight what matters to you.")
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CodSpacing.xl)
        }
    }

    // MARK: - Grid

    private var interestGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 100), spacing: CodSpacing.sm)],
            spacing: CodSpacing.sm
        ) {
            ForEach(filteredInterests) { interest in
                InterestChip(
                    interest: interest,
                    isSelected: selectedInterests.contains(interest.rawValue)
                ) {
                    toggleInterest(interest)
                }
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Hint

    private var selectionHint: some View {
        Group {
            if selectedInterests.isEmpty {
                Text("Select at least one to personalize your experience")
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.driftwood)
            } else {
                Text("\(selectedInterests.count) selected")
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }
        }
        .animation(CodAnimation.quick, value: selectedInterests.count)
    }

    // MARK: - Actions

    private func toggleInterest(_ interest: OnboardingInterest) {
        if selectedInterests.contains(interest.rawValue) {
            selectedInterests.remove(interest.rawValue)
        } else {
            selectedInterests.insert(interest.rawValue)
        }
        CodHaptic.selection()
    }
}

// MARK: - Interest Chip

private struct InterestChip: View {
    let interest: OnboardingInterest
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: CodSpacing.xs) {
            Image(systemName: interest.icon)
                .font(.title3)

            Text(interest.displayName)
                .font(.system(size: 11, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CodSpacing.md)
        .padding(.horizontal, CodSpacing.xs)
        .foregroundStyle(
            isSelected ? Color.capeCod.oceanBlue : Color.capeCod.textSecondary
        )
        .background(
            isSelected
                ? Color.capeCod.oceanBlue.opacity(0.1)
                : Color.capeCod.surfaceElevated
        )
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .stroke(isSelected ? Color.capeCod.oceanBlue : .clear, lineWidth: 1.5)
        )
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(CodAnimation.bouncy, value: isSelected)
        .onTapGesture(perform: onTap)
        .codAccessibleButton(
            interest.displayName,
            hint: isSelected ? "Selected. Double tap to remove." : "Double tap to add."
        )
    }
}

// MARK: - Onboarding Interest Enum

enum OnboardingInterest: String, CaseIterable, Identifiable {
    case beaches
    case hiking
    case history
    case seafood
    case photography
    case whaleWatching
    case fishing
    case artGalleries
    case lighthouses
    case shopping
    case nightlife
    case liveMusic
    case tidePools
    case biking
    case miniGolf
    case sunsets

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beaches: "Beaches & Swimming"
        case .hiking: "Hiking & Nature"
        case .history: "History & Culture"
        case .seafood: "Seafood & Dining"
        case .photography: "Photography"
        case .whaleWatching: "Whale Watching"
        case .fishing: "Fishing"
        case .artGalleries: "Art & Galleries"
        case .lighthouses: "Lighthouses"
        case .shopping: "Shopping"
        case .nightlife: "Nightlife"
        case .liveMusic: "Live Music"
        case .tidePools: "Tide Pooling"
        case .biking: "Biking"
        case .miniGolf: "Mini Golf"
        case .sunsets: "Sunset Watching"
        }
    }

    var icon: String {
        switch self {
        case .beaches: "beach.umbrella"
        case .hiking: "leaf.fill"
        case .history: "building.columns"
        case .seafood: "fork.knife"
        case .photography: "camera.fill"
        case .whaleWatching: "binoculars.fill"
        case .fishing: "fish.fill"
        case .artGalleries: "paintpalette.fill"
        case .lighthouses: "light.beacon.max.fill"
        case .shopping: "bag.fill"
        case .nightlife: "moon.stars.fill"
        case .liveMusic: "music.mic"
        case .tidePools: "water.waves"
        case .biking: "bicycle"
        case .miniGolf: "flag.fill"
        case .sunsets: "sun.horizon.fill"
        }
    }

    /// Determines whether this interest should be shown for a given mode.
    func isVisible(for mode: ExperienceMode) -> Bool {
        switch self {
        case .nightlife:
            // Hide nightlife for kids and teens
            return mode == .adult
        case .miniGolf:
            // Show mini golf for kids, teens, and family
            return mode != .adult
        default:
            return true
        }
    }
}

#Preview {
    OnboardingInterestsPage(
        selectedMode: .family,
        selectedInterests: .constant(["beaches", "lighthouses"])
    )
}
