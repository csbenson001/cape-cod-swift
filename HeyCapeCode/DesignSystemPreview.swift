import SwiftUI

// MARK: - Design System Preview

/// A living style guide showcasing every component in the Hey Cape Cod design system.
/// Scroll through to see colors, typography, buttons, cards, chips, metrics, loading states,
/// and the voice assistant button in both light and dark mode.
struct DesignSystemPreview: View {
    @State private var selectedFilter = 0
    @State private var voiceState: VoiceAssistantState = .idle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CodSpacing.sectionSpacing) {
                header
                colorPalette
                typographyShowcase
                buttonShowcase
                chipShowcase
                cardShowcase
                metricShowcase
                voiceButtonShowcase
                waveformShowcase
                loadingShowcase
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.xxl)
        }
        .background(Color.capeCod.background)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Hey Cape Cod")
                .codTextStyle(.heroTitle)
            Text("Design System")
                .font(.system(size: 22, weight: .light))
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
                .frame(height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: CodRadius.chip)
                        .strokeBorder(Color.capeCod.driftwood.opacity(0.2), lineWidth: 0.5)
                )
            Text(name)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color.capeCod.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Typography

    private var typographyShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Typography")

            Text("Hero Title (34pt Bold)")
                .codTextStyle(.heroTitle)
            Text("Section Title (22pt Semibold)")
                .codTextStyle(.sectionTitle)
            Text("Card Title (17pt Semibold)")
                .codTextStyle(.cardTitle)
            Text("Body text for descriptions and story content. (15pt Regular)")
                .codTextStyle(.body)
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
                CodChip("Family Friendly", style: .filter, isSelected: selectedFilter == 0) {
                    selectedFilter = 0
                }
                CodChip("Pet Friendly", style: .filter, isSelected: selectedFilter == 1) {
                    selectedFilter = 1
                }
                CodChip("Free", style: .filter, isSelected: selectedFilter == 2) {
                    selectedFilter = 2
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
                            .font(.system(size: 22, weight: .bold))
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

            Text("STANDARD").codTextStyle(.label)
            CodCard(size: .standard, action: {}) {
                CodCardContent(
                    title: "Chatham Lighthouse",
                    subtitle: "Historic lighthouse with panoramic ocean views and seal watching.",
                    metadata: "0.8 mi away",
                    badge: ("Historic", Color.capeCod.driftwood)
                )
            }

            Text("COMPACT (HORIZONTAL SCROLL)").codTextStyle(.label)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.md) {
                    ForEach(["Nauset Beach", "Sandy Neck", "Marconi"], id: \.self) { name in
                        CodCard(size: .compact) {
                            Rectangle()
                                .fill(Color.capeCod.seafoam.opacity(0.2))
                                .frame(height: 120)
                            CodCardContent(title: name, metadata: "Beach")
                        }
                    }
                }
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
                    trend: .up
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

            HStack(spacing: CodSpacing.md) {
                MetricCard(
                    value: "2:34",
                    unit: "PM",
                    label: "High Tide",
                    icon: "water.waves",
                    tint: Color.capeCod.seafoam
                )
                MetricCard(
                    value: "82",
                    unit: "\u{00B0}F",
                    label: "Air Temp",
                    icon: "sun.max.fill",
                    tint: Color.capeCod.sandbarYellow,
                    trend: .down
                )
            }
        }
    }

    // MARK: - Voice Button

    private var voiceButtonShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Voice Assistant Button")

            let sampleAudio: [CGFloat] = (0..<48).map { i in
                0.2 + 0.8 * abs(sin(CGFloat(i) / 48 * .pi * 4))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.xl) {
                    stateDemo("Idle", .idle, [])
                    stateDemo("Listening", .listening, sampleAudio)
                    stateDemo("Thinking", .thinking, [])
                    stateDemo("Speaking", .speaking, sampleAudio)
                    stateDemo("Error", .error, [])
                }
                .padding(.vertical, CodSpacing.lg)
            }
        }
    }

    private func stateDemo(_ label: String, _ state: VoiceAssistantState, _ levels: [CGFloat]) -> some View {
        VStack(spacing: CodSpacing.sm) {
            PulsingCircle(state: state, audioLevels: levels) {}
        }
    }

    // MARK: - Waveforms

    private var waveformShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Waveform Views")

            let sampleLevels: [CGFloat] = (0..<40).map { i in
                0.3 + 0.7 * abs(sin(CGFloat(i) / 40 * .pi * 3))
            }

            Text("LINEAR").codTextStyle(.label)
            WaveformView(levels: sampleLevels, style: .linear, color: Color.capeCod.seafoam)
                .frame(maxWidth: .infinity)

            Text("LINEAR (SPEAKING)").codTextStyle(.label)
            WaveformView(levels: sampleLevels, style: .linear, color: Color.capeCod.sunsetOrange)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Loading States

    private var loadingShowcase: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            sectionHeader("Loading Skeletons")

            Text("CARD SKELETON").codTextStyle(.label)
            LoadingSkeleton(variant: .card)

            Text("METRIC SKELETONS").codTextStyle(.label)
            HStack(spacing: CodSpacing.md) {
                LoadingSkeleton(variant: .metric)
                LoadingSkeleton(variant: .metric)
            }

            Text("LIST ROW SKELETONS").codTextStyle(.label)
            ForEach(0..<3, id: \.self) { _ in
                LoadingSkeleton(variant: .listRow)
            }

            Text("MAP PLACEHOLDER").codTextStyle(.label)
            LoadingSkeleton(variant: .mapPlaceholder)
        }
    }

    // MARK: - Section Header Helper

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

// MARK: - Previews (Light & Dark)

#Preview("Design System - Light") {
    DesignSystemPreview()
        .preferredColorScheme(.light)
}

#Preview("Design System - Dark") {
    DesignSystemPreview()
        .preferredColorScheme(.dark)
}
