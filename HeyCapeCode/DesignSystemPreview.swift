import SwiftUI

// MARK: - Design System Preview

/// A living style guide showcasing every component in the Hey Cape Cod design system.
/// Includes all components, micro-interactions, and visual flourishes
/// in both light and dark mode.
struct DesignSystemPreview: View {
    @State private var selectedFilter = 0
    @State private var isFavorited = false
    @State private var isToggled = true
    @State private var segmentIndex = 0
    @State private var metricValue = 47
    @State private var activeBanner: BannerData?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CodSpacing.sectionSpacing) {
                header
                colorPalette
                typographyShowcase
                buttonShowcase
                chipShowcase
                microInteractionsShowcase
                cardShowcase
                metricShowcase
                animatedCounterShowcase
                voiceButtonShowcase
                waveformShowcase
                loadingShowcase
                emptyStateShowcase
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.xxl)
        }
        .background(Color.capeCod.background)
        .banner($activeBanner)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Hey Cape Cod")
                .codTextStyle(.heroTitle)
            Text("Design System")
                .codTextStyle(.sectionTitle)
                .foregroundStyle(Color.capeCod.oceanBlue)
            Text("A living style guide for the premium Cape Cod travel companion.")
                .codTextStyle(.body)
                .padding(.top, CodSpacing.xs)
        }
        .padding(.top, CodSpacing.xl)
    }

    // MARK: - Color Palette

    private var colorPalette: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Color Palette")

            Text("PRIMARY").codTextStyle(.label)
            HStack(spacing: CodSpacing.sm) {
                colorSwatch("Ocean Blue", Color.capeCod.oceanBlue)
                colorSwatch("Deep Navy", Color.capeCod.deepNavy)
                colorSwatch("Sunset Orange", Color.capeCod.sunsetOrange)
                colorSwatch("Seafoam", Color.capeCod.seafoam)
            }

            Text("NEUTRALS").codTextStyle(.label)
            HStack(spacing: CodSpacing.sm) {
                colorSwatch("Sand", Color.capeCod.sand)
                colorSwatch("Driftwood", Color.capeCod.driftwood)
                colorSwatch("Shell White", Color.capeCod.shellWhite)
                colorSwatch("Fog", Color.capeCod.fog)
            }

            Text("SEMANTIC").codTextStyle(.label)
            HStack(spacing: CodSpacing.sm) {
                colorSwatch("Dune Grass", Color.capeCod.duneGrass)
                colorSwatch("Cranberry", Color.capeCod.cranberry)
                colorSwatch("Lobster Red", Color.capeCod.lobsterRed)
                colorSwatch("Sandbar", Color.capeCod.sandbarYellow)
            }
        }
    }

    private func colorSwatch(_ name: String, _ color: Color) -> some View {
        VStack(spacing: CodSpacing.xs) {
            RoundedRectangle(cornerRadius: CodRadius.chip)
                .fill(color)
                .frame(height: CodSpacing.xxl)
                .overlay(
                    RoundedRectangle(cornerRadius: CodRadius.chip)
                        .strokeBorder(Color.capeCod.cardBorder, lineWidth: 0.5)
                )
            Text(name)
                .codTextStyle(.label)
                .textCase(nil)
                .tracking(0)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Typography

    private var typographyShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Typography")

            Text("Hero Title (SF Rounded 34pt)")
                .codTextStyle(.heroTitle)
            Text("Section Title (22pt Semibold)")
                .codTextStyle(.sectionTitle)
            Text("Card Title (17pt Semibold)")
                .codTextStyle(.cardTitle)
            Text("Body text for descriptions and general content. (15pt)")
                .codTextStyle(.body)
            Text("Story body with generous line spacing for long-form reading. This demonstrates the 1.4x line height that makes editorial content feel premium and comfortable.")
                .codTextStyle(.storyBody)
            Text("Caption for metadata and timestamps (13pt)")
                .codTextStyle(.caption)
            Text("Category Label")
                .codTextStyle(.label)

            HStack(alignment: .firstTextBaseline, spacing: CodSpacing.xs) {
                Text("47")
                    .codTextStyle(.metric)
                Text("min")
                    .codTextStyle(.metricUnit)
            }
        }
    }

    // MARK: - Buttons

    private var buttonShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Buttons")

            CodButton("Get Directions", variant: .primary, icon: "arrow.triangle.turn.up.right.diamond.fill", isFullWidth: true) {}
            CodButton("Save to Trip", variant: .secondary, icon: "bookmark") {}
            CodButton("Start Tour", variant: .accent, icon: "play.fill", isFullWidth: true) {}
            CodButton("Learn More", variant: .ghost, icon: "arrow.right") {}

            Text("ICON BUTTONS").codTextStyle(.label)
            HStack(spacing: CodSpacing.md) {
                CodIconButton("heart") {}
                CodIconButton("square.and.arrow.up") {}
                CodIconButton("mappin.and.ellipse") {}
                CodIconButton("ellipsis") {}
            }
        }
    }

    // MARK: - Chips

    private var chipShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Chips & Tags")

            Text("CATEGORIES").codTextStyle(.label)
            FlowLayout(spacing: CodSpacing.sm) {
                CodChip("Beach", style: .category(.blue), icon: "sun.max.fill")
                CodChip("Historic", style: .category(.brown), icon: "building.columns.fill")
                CodChip("Nature", style: .category(.green), icon: "leaf.fill")
                CodChip("Food", style: .category(.orange), icon: "fork.knife")
            }

            Text("STATUS").codTextStyle(.label)
            HStack(spacing: CodSpacing.sm) {
                CodChip("Open Now", style: .status(.open))
                CodChip("Closing Soon", style: .status(.closingSoon))
                CodChip("Closed", style: .status(.closed))
            }

            Text("FILTERS (TOGGLEABLE)").codTextStyle(.label)
            HStack(spacing: CodSpacing.sm) {
                CodChip("Family Friendly", style: .filter, isSelected: selectedFilter == 0) { selectedFilter = 0 }
                CodChip("Pet Friendly", style: .filter, isSelected: selectedFilter == 1) { selectedFilter = 1 }
                CodChip("Free", style: .filter, isSelected: selectedFilter == 2) { selectedFilter = 2 }
            }
        }
    }

    // MARK: - Micro-Interactions

    private var microInteractionsShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Micro-Interactions")

            Text("FAVORITE BUTTON").codTextStyle(.label)
            HStack(spacing: CodSpacing.md) {
                FavoriteButton(isFavorited: $isFavorited)
                Text(isFavorited ? "Saved" : "Tap to save")
                    .codTextStyle(.body)
            }

            Text("CUSTOM TOGGLE").codTextStyle(.label)
            Toggle("Notifications", isOn: $isToggled)
                .toggleStyle(.capeCod)
                .codTextStyle(.body)

            Text("SEGMENTED CONTROL").codTextStyle(.label)
            CodSegmentedControl(
                options: ["All", "Beaches", "Historic"],
                selection: $segmentIndex
            )

            Text("BANNER TRIGGER").codTextStyle(.label)
            CodButton("Show Shark Alert", variant: .secondary, icon: "exclamationmark.triangle.fill") {
                withAnimation(CodAnimation.spring) {
                    activeBanner = BannerData(
                        message: "Shark spotted near Nauset Beach",
                        style: .danger,
                        icon: "exclamationmark.triangle.fill",
                        actionLabel: "Details"
                    )
                }
            }
        }
    }

    // MARK: - Cards

    private var cardShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Cards")

            Text("FEATURED").codTextStyle(.label)
            CodCard(size: .featured) {
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [Color.capeCod.oceanBlue, Color.capeCod.seafoam],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 220)

                    VStack(alignment: .leading, spacing: CodSpacing.xs) {
                        CodCardBadge(text: "Featured", color: Color.capeCod.sunsetOrange)
                        Text("Race Point Beach")
                            .codTextStyle(.sectionTitle)
                            .foregroundStyle(.white)
                    }
                    .padding(CodSpacing.cardPadding)
                }
                CodCardContent(
                    title: "Race Point Beach",
                    subtitle: "Stunning Atlantic-facing beach at the tip of Cape Cod.",
                    metadata: "Provincetown  \u{2022}  2.3 mi"
                )
            }

            Text("STANDARD WITH STAGGER").codTextStyle(.label)
            ForEach(0..<2) { i in
                CodCard(size: .standard, action: {}) {
                    CodCardContent(
                        title: ["Chatham Lighthouse", "Cape Cod Rail Trail"][i],
                        subtitle: ["Historic lighthouse with panoramic ocean views.", "26-mile paved bike path through the Cape."][i],
                        metadata: ["\(0.8) mi", "\(1.2) mi"][i],
                        badge: ([("Historic", Color.capeCod.driftwood), ("Nature", Color.capeCod.duneGrass)][i])
                    )
                }
                .staggered(index: i)
            }
        }
    }

    // MARK: - Metrics

    private var metricShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Metric Cards")

            HStack(spacing: CodSpacing.md) {
                MetricCard(
                    value: "47",
                    unit: "min",
                    label: "Bourne Bridge",
                    icon: "car.fill",
                    tint: Color.capeCod.lobsterRed,
                    trend: .up,
                    isLive: true
                )
                MetricCard(
                    value: "74",
                    unit: "\u{00B0}F",
                    label: "Water Temp",
                    icon: "thermometer.medium",
                    tint: Color.capeCod.oceanBlue,
                    trend: .stable
                )
            }
        }
    }

    // MARK: - Animated Counter

    private var animatedCounterShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Animated Counter")

            HStack(alignment: .firstTextBaseline, spacing: CodSpacing.xs) {
                AnimatedCounter(metricValue, color: Color.capeCod.lobsterRed)
                Text("min delay")
                    .codTextStyle(.metricUnit)
            }

            CodButton("Randomize", variant: .secondary, icon: "arrow.triangle.2.circlepath") {
                metricValue = Int.random(in: 5...120)
            }
        }
    }

    // MARK: - Voice Button

    private var voiceButtonShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Voice Assistant")

            let sampleAudio: [CGFloat] = (0..<48).map { i in
                0.2 + 0.8 * abs(sin(CGFloat(i) / 48 * .pi * 4))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.xl) {
                    PulsingCircle(state: .idle) {}
                    PulsingCircle(state: .listening, audioLevels: sampleAudio) {}
                    PulsingCircle(state: .thinking) {}
                    PulsingCircle(state: .speaking, audioLevels: sampleAudio) {}
                    PulsingCircle(state: .error) {}
                }
                .padding(.vertical, CodSpacing.lg)
            }
        }
    }

    // MARK: - Waveforms

    private var waveformShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Waveform Views")

            let sampleLevels: [CGFloat] = (0..<40).map { i in
                0.3 + 0.7 * abs(sin(CGFloat(i) / 40 * .pi * 3))
            }

            Text("LISTENING").codTextStyle(.label)
            WaveformView(levels: sampleLevels, style: .linear, color: Color.capeCod.seafoam)
                .frame(maxWidth: .infinity)

            Text("SPEAKING").codTextStyle(.label)
            WaveformView(levels: sampleLevels, style: .linear, color: Color.capeCod.sunsetOrange)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Loading States

    private var loadingShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Loading Skeletons")

            LoadingSkeleton(variant: .card)

            HStack(spacing: CodSpacing.md) {
                LoadingSkeleton(variant: .metric)
                LoadingSkeleton(variant: .metric)
            }

            ForEach(0..<2, id: \.self) { _ in
                LoadingSkeleton(variant: .listRow)
            }
        }
    }

    // MARK: - Empty States

    private var emptyStateShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Empty States")

            EmptyStateView.noStories(onRefresh: {})
                .frame(height: 260)
                .background(Color.capeCod.surface)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))

            EmptyStateView.offline(onRetry: {})
                .frame(height: 260)
                .background(Color.capeCod.surface)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: CodSpacing.xs) {
            Text(title)
                .codTextStyle(.sectionTitle)
            Rectangle()
                .fill(Color.capeCod.oceanBlue.opacity(0.3))
                .frame(height: 1)
        }
    }
}

// MARK: - Previews

#Preview("Design System - Light") {
    DesignSystemPreview()
        .preferredColorScheme(.light)
}

#Preview("Design System - Dark") {
    DesignSystemPreview()
        .preferredColorScheme(.dark)
}
