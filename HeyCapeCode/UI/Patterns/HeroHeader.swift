import SwiftUI

// MARK: - HeroHeader

/// Full-width image header for detail screens (POI detail, beach detail).
/// Image fills ~40% of screen with gradient overlay, parallax scroll effect,
/// and floating back/share buttons. Falls back to category-colored gradient.
struct HeroHeader: View {
    let title: String
    var subtitle: String? = nil
    var imageName: String? = nil
    var categoryColor: Color = Color.capeCod.oceanBlue
    var onBack: (() -> Void)? = nil
    var onShare: (() -> Void)? = nil

    /// Scroll offset for parallax effect — bind from a CoordinateSpace reader.
    var scrollOffset: CGFloat = 0

    private let headerHeight: CGFloat = 340

    var body: some View {
        GeometryReader { geometry in
            let minY = geometry.frame(in: .global).minY
            let parallaxOffset = minY > 0 ? -minY * 0.4 : 0
            let stretchHeight = minY > 0 ? headerHeight + minY : headerHeight

            ZStack(alignment: .bottomLeading) {
                // Background image or gradient fallback
                imageLayer
                    .frame(width: geometry.size.width, height: stretchHeight)
                    .offset(y: parallaxOffset)
                    .clipped()

                // Gradient overlay — fades image into background color
                VStack(spacing: 0) {
                    Spacer()
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.capeCod.background.opacity(0.6),
                            Color.capeCod.background,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: headerHeight * 0.55)
                }

                // Title and subtitle overlaid on gradient
                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    if let subtitle {
                        Text(subtitle)
                            .codTextStyle(.caption)
                    }
                    Text(title)
                        .codTextStyle(.heroTitle)
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.lg)

                // Floating navigation buttons
                VStack {
                    HStack {
                        if let onBack {
                            floatingButton(icon: "chevron.left", action: onBack)
                        }
                        Spacer()
                        if let onShare {
                            floatingButton(icon: "square.and.arrow.up", action: onShare)
                        }
                    }
                    .padding(.horizontal, CodSpacing.screenEdge)
                    .padding(.top, geometry.safeAreaInsets.top + CodSpacing.sm)

                    Spacer()
                }
            }
            .frame(height: stretchHeight)
            .offset(y: minY > 0 ? -minY : 0)
        }
        .frame(height: headerHeight)
    }

    // MARK: - Image Layer

    @ViewBuilder
    private var imageLayer: some View {
        if let imageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .darkModeDimmed()
        } else {
            // Gradient fallback using category color
            ZStack {
                LinearGradient(
                    colors: [
                        categoryColor,
                        categoryColor.opacity(0.6),
                        Color.capeCod.deepNavy.opacity(0.3),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Decorative wave shapes for visual interest
                WaveDecoration(color: .white.opacity(0.08))
                    .offset(y: 60)
                WaveDecoration(color: .white.opacity(0.05))
                    .offset(y: 100)
            }
        }
    }

    // MARK: - Floating Button

    private func floatingButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: CodSpacing.md, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}

// MARK: - Wave Decoration

/// Decorative sine wave shape for gradient fallback headers.
private struct WaveDecoration: View {
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height: CGFloat = 40
                let midY = geometry.size.height / 2
                path.move(to: CGPoint(x: 0, y: midY))

                stride(from: 0, through: width, by: 1).forEach { x in
                    let relativeX = x / width
                    let y = midY + sin(relativeX * .pi * 3) * height
                    path.addLine(to: CGPoint(x: x, y: y))
                }

                path.addLine(to: CGPoint(x: width, y: geometry.size.height))
                path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}

// MARK: - Detail Screen Template

/// Combines HeroHeader with scrollable content for a standard detail screen.
struct DetailScreenLayout<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    var imageName: String? = nil
    var categoryColor: Color = Color.capeCod.oceanBlue
    var onBack: (() -> Void)? = nil
    var onShare: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HeroHeader(
                    title: title,
                    subtitle: subtitle,
                    imageName: imageName,
                    categoryColor: categoryColor,
                    onBack: onBack,
                    onShare: onShare
                )

                VStack(alignment: .leading, spacing: CodSpacing.sectionSpacing) {
                    content()
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.xxl)
            }
        }
        .background(Color.capeCod.background)
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
}

// MARK: - Preview

#Preview("Hero Header — With Gradient Fallback") {
    DetailScreenLayout(
        title: "Chatham Lighthouse",
        subtitle: "Historic  \u{2022}  Chatham, MA",
        categoryColor: Color.capeCod.driftwood,
        onBack: {},
        onShare: {}
    ) {
        HStack(spacing: CodSpacing.sm) {
            CodChip("Historic", style: .category(.brown), icon: "building.columns.fill")
            CodChip("Open Now", style: .status(.open))
            CodChip("Free", style: .filter, isSelected: true) {}
        }

        ContentSection(title: "About") {
            Text("Built in 1877, Chatham Lighthouse is one of the most photographed lighthouses on Cape Cod. The grounds offer panoramic views of the Atlantic Ocean and Chatham Harbor, with opportunities to watch seals basking on the nearby sandbars.")
                .codTextStyle(.storyBody)
        }

        ContentSection(title: "Conditions") {
            HStack(spacing: CodSpacing.md) {
                MetricCard(
                    value: "68",
                    unit: "\u{00B0}F",
                    label: "Temperature",
                    icon: "thermometer.medium",
                    tint: Color.capeCod.oceanBlue
                )
                MetricCard(
                    value: "0.8",
                    unit: "mi",
                    label: "Distance",
                    icon: "location.fill",
                    tint: Color.capeCod.seafoam
                )
            }
        }

        VStack(spacing: CodSpacing.md) {
            CodButton("Get Directions", variant: .primary, icon: "arrow.triangle.turn.up.right.diamond.fill", isFullWidth: true) {}
            CodButton("Save to Trip", variant: .secondary, icon: "bookmark", isFullWidth: true) {}
        }
    }
}

#Preview("Hero Header — Ocean Blue") {
    HeroHeader(
        title: "Race Point Beach",
        subtitle: "Beach  \u{2022}  Provincetown, MA",
        categoryColor: Color.capeCod.oceanBlue,
        onBack: {},
        onShare: {}
    )
    .background(Color.capeCod.background)
}
