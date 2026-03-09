import SwiftUI
import MapKit

// MARK: - TourStopInfoCard

/// Expandable rich info card displayed during an active tour, showing
/// details about the current stop including description, facts, tips,
/// and quick action buttons.
struct TourStopInfoCard: View {
    let stop: PointOfInterest
    let stopNumber: Int
    let onListenTapped: () -> Void
    let onAskTapped: () -> Void
    let onDirectionsTapped: () -> Void
    let onShareTapped: () -> Void

    @State private var isExpanded = false
    @State private var dragOffset: CGFloat = 0

    private let expandThreshold: CGFloat = 100

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            dragHandle

            // Header + quick actions (always visible)
            TourStopHeader(
                stop: stop,
                stopNumber: stopNumber
            )
            .padding(.horizontal, CodSpacing.cardPadding)
            .padding(.bottom, CodSpacing.sm)

            StopQuickActions(
                onListen: onListenTapped,
                onAsk: onAskTapped,
                onDirections: onDirectionsTapped,
                onShare: onShareTapped
            )
            .padding(.horizontal, CodSpacing.cardPadding)

            if !isExpanded {
                // Collapsed: truncated description + expand hint
                collapsedContent
            } else {
                // Expanded: full description, facts, tips, extras
                expandedContent
            }
        }
        .padding(.bottom, CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .gesture(expandDragGesture)
        .animation(CodAnimation.spring, value: isExpanded)
        .codAccessibleCard(
            label: "\(stop.name), stop \(stopNumber)",
            hint: isExpanded ? "Swipe down to collapse" : "Swipe up for more details"
        )
    }

    // MARK: - Drag Handle

    private var dragHandle: some View {
        VStack(spacing: CodSpacing.xs) {
            Capsule()
                .fill(Color.capeCod.driftwood.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, CodSpacing.sm)

            Button {
                CodHaptic.light()
                withAnimation(CodAnimation.spring) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.capeCod.driftwood)
                    .frame(width: 32, height: 20)
                    .contentTransition(.symbolEffect(.replace))
            }
            .codAccessibleButton(
                isExpanded ? "Collapse details" : "Expand details"
            )
        }
    }

    // MARK: - Collapsed Content

    private var collapsedContent: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text(stop.description)
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
                .lineLimit(2)
                .padding(.horizontal, CodSpacing.cardPadding)
                .padding(.top, CodSpacing.sm)

            // Distance placeholder
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: "car.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.capeCod.driftwood)
                Text("~5 min drive")
                    .codTextStyle(.caption)
            }
            .padding(.horizontal, CodSpacing.cardPadding)
        }
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: CodSpacing.lg) {
                // Full description
                Text(stop.description)
                    .codTextStyle(.storyBody)
                    .foregroundStyle(Color.capeCod.textSecondary)
                    .padding(.horizontal, CodSpacing.cardPadding)
                    .padding(.top, CodSpacing.sm)

                // Facts section
                if !stop.facts.isEmpty {
                    factsSection
                }

                // Tips section
                if !stop.tips.isEmpty {
                    tipsSection
                }

                // Weather placeholder
                weatherPlaceholder
                    .padding(.horizontal, CodSpacing.cardPadding)

                // Distance/ETA placeholder
                distancePlaceholder
                    .padding(.horizontal, CodSpacing.cardPadding)

                // Share button
                HStack {
                    Spacer()
                    CodButton("Share This Stop", variant: .ghost, icon: "square.and.arrow.up") {
                        CodHaptic.light()
                        onShareTapped()
                    }
                    Spacer()
                }
                .padding(.horizontal, CodSpacing.cardPadding)
            }
        }
        .frame(maxHeight: 360)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Facts Section

    private var factsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Did You Know?")
                .codTextStyle(.sectionTitle)
                .padding(.horizontal, CodSpacing.cardPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.md) {
                    ForEach(Array(stop.facts.enumerated()), id: \.offset) { index, fact in
                        TourFactCard(fact: fact, index: index + 1)
                            .staggered(index: index)
                    }
                }
                .padding(.horizontal, CodSpacing.cardPadding)
            }
        }
    }

    // MARK: - Tips Section

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Insider Tips")
                .codTextStyle(.sectionTitle)
                .padding(.horizontal, CodSpacing.cardPadding)

            VStack(spacing: CodSpacing.xs) {
                ForEach(Array(stop.tips.enumerated()), id: \.offset) { index, tip in
                    TourTipRow(tip: tip)
                        .staggered(index: index, interval: 0.04)
                }
            }
            .padding(.horizontal, CodSpacing.cardPadding)
        }
    }

    // MARK: - Weather Placeholder

    private var weatherPlaceholder: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.capeCod.oceanBlue)

            VStack(alignment: .leading, spacing: 2) {
                Text("Check Conditions")
                    .codTextStyle(.cardTitle)
                Text("View current weather at this stop")
                    .codTextStyle(.caption)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.capeCod.driftwood)
        }
        .padding(CodSpacing.md)
        .background(Color.capeCod.surface)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
    }

    // MARK: - Distance Placeholder

    private var distancePlaceholder: some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: "car.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.capeCod.seafoam)

            Text("~5 min drive")
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)

            Spacer()

            Text(stop.town.region.rawValue)
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.driftwood)
        }
        .padding(CodSpacing.md)
        .background(Color.capeCod.surface)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
    }

    // MARK: - Drag Gesture

    private var expandDragGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                dragOffset = value.translation.height
            }
            .onEnded { value in
                let verticalMovement = value.translation.height

                if !isExpanded && verticalMovement < -expandThreshold {
                    // Swipe up to expand
                    CodHaptic.light()
                    withAnimation(CodAnimation.spring) {
                        isExpanded = true
                    }
                } else if isExpanded && verticalMovement > expandThreshold {
                    // Swipe down to collapse
                    CodHaptic.light()
                    withAnimation(CodAnimation.spring) {
                        isExpanded = false
                    }
                }
                dragOffset = 0
            }
    }
}

// MARK: - TourStopHeader

/// Reusable header displaying stop number badge, POI name, category chip,
/// and town name.
struct TourStopHeader: View {
    let stop: PointOfInterest
    let stopNumber: Int

    var body: some View {
        HStack(spacing: CodSpacing.md) {
            // Stop number badge
            ZStack {
                Circle()
                    .fill(Color.capeCod.oceanBlue)
                    .frame(width: 40, height: 40)

                Text("\(stopNumber)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.capeCod.textOnPrimary)
            }
            .codAccessibleHidden()

            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                Text(stop.name)
                    .codTextStyle(.cardTitle)
                    .lineLimit(1)

                HStack(spacing: CodSpacing.sm) {
                    // Category pill
                    categoryPill

                    // Town name
                    Text(stop.town.displayName)
                        .codTextStyle(.caption)
                }
            }

            Spacer()
        }
        .codAccessibleGroup(
            label: "Stop \(stopNumber), \(stop.name), \(stop.category.displayName) in \(stop.town.displayName)"
        )
    }

    private var categoryPill: some View {
        HStack(spacing: CodSpacing.xs) {
            Image(systemName: stop.category.icon)
                .font(.system(size: 10))
            Text(stop.category.displayName)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(Color.capeCod.oceanBlue)
        .padding(.horizontal, CodSpacing.sm)
        .padding(.vertical, CodSpacing.xs)
        .background(Color.capeCod.oceanBlue.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - StopQuickActions

/// Horizontal row of capsule-shaped action buttons for the current tour stop.
struct StopQuickActions: View {
    let onListen: () -> Void
    let onAsk: () -> Void
    let onDirections: () -> Void
    let onShare: () -> Void

    var body: some View {
        HStack(spacing: CodSpacing.sm) {
            quickActionCapsule(
                icon: "headphones",
                label: "Listen",
                tint: Color.capeCod.sunsetOrange,
                action: onListen
            )

            quickActionCapsule(
                icon: "questionmark.bubble",
                label: "Ask",
                tint: Color.capeCod.seafoam,
                action: onAsk
            )

            quickActionCapsule(
                icon: "arrow.triangle.turn.up.right.diamond",
                label: "Directions",
                tint: Color.capeCod.oceanBlue,
                action: onDirections
            )

            quickActionCapsule(
                icon: "square.and.arrow.up",
                label: "Share",
                tint: Color.capeCod.driftwood,
                action: onShare
            )
        }
    }

    private func quickActionCapsule(
        icon: String,
        label: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            CodHaptic.tap()
            action()
        } label: {
            VStack(spacing: CodSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, CodSpacing.sm)
            .background(tint.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleButton(label)
    }
}

// MARK: - TourFactCard

/// Individual fact display card used in the horizontally scrollable facts section.
struct TourFactCard: View {
    let fact: String
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.capeCod.sandbarYellow)

                Spacer()

                Text("#\(index)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.capeCod.driftwood.opacity(0.5))
            }

            Text(fact)
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(CodSpacing.cardPadding)
        .frame(width: 260, alignment: .leading)
        .background(Color.capeCod.surface)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .strokeBorder(Color.capeCod.cardBorder, lineWidth: 1)
        )
        .codAccessibleCard(label: "Fact \(index): \(fact)")
    }
}

// MARK: - TourTipRow

/// Individual tip display row with a star icon, used in the tips list.
struct TourTipRow: View {
    let tip: String

    var body: some View {
        HStack(alignment: .top, spacing: CodSpacing.md) {
            Image(systemName: "sparkle")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.capeCod.sunsetOrange)
                .frame(width: 20, alignment: .center)
                .padding(.top, 2)

            Text(tip)
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, CodSpacing.sm)
        .padding(.horizontal, CodSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.capeCod.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
        .accessibilityLabel("Tip: \(tip)")
    }
}

// MARK: - Preview

#Preview("Tour Stop Info Card") {
    let sampleStop = BundledContent.allPOIs[0]

    ZStack(alignment: .bottom) {
        Color.capeCod.background
            .ignoresSafeArea()

        TourStopInfoCard(
            stop: sampleStop,
            stopNumber: 1,
            onListenTapped: {},
            onAskTapped: {},
            onDirectionsTapped: {},
            onShareTapped: {}
        )
        .padding(.horizontal, CodSpacing.sm)
        .padding(.bottom, CodSpacing.sm)
    }
}

#Preview("Tour Fact Card") {
    TourFactCard(
        fact: "The Whydah is the only authenticated pirate shipwreck ever discovered",
        index: 1
    )
    .padding(CodSpacing.screenEdge)
    .background(Color.capeCod.background)
}

#Preview("Tour Tip Row") {
    VStack(spacing: CodSpacing.xs) {
        TourTipRow(tip: "Visit on a weekday morning to avoid crowds")
        TourTipRow(tip: "The gift shop has great pirate costumes for kids")
        TourTipRow(tip: "Ask about the seasonal exhibit for extra artifacts")
    }
    .padding(CodSpacing.screenEdge)
    .background(Color.capeCod.background)
}

#Preview("Stop Quick Actions") {
    StopQuickActions(
        onListen: {},
        onAsk: {},
        onDirections: {},
        onShare: {}
    )
    .padding(CodSpacing.screenEdge)
    .background(Color.capeCod.background)
}

#Preview("Tour Stop Header") {
    let sampleStop = BundledContent.allPOIs[0]

    TourStopHeader(stop: sampleStop, stopNumber: 3)
        .padding(CodSpacing.screenEdge)
        .background(Color.capeCod.background)
}
