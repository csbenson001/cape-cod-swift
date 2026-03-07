import SwiftUI

// MARK: - ScrollScreenLayout

/// Standard scrollable screen template used by every feature screen.
/// Provides a large navigation title that collapses on scroll, optional hero section,
/// section headers with "See All" links, pull-to-refresh, and safe area handling.
struct ScrollScreenLayout<Hero: View, Content: View>: View {
    let title: String
    let hero: (() -> Hero)?
    let onRefresh: (() async -> Void)?
    @ViewBuilder let content: () -> Content

    init(
        title: String,
        @ViewBuilder hero: @escaping () -> Hero,
        onRefresh: (() async -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.hero = hero
        self.onRefresh = onRefresh
        self.content = content
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero section (full bleed, no horizontal padding)
                    if let hero {
                        hero()
                    }

                    // Main content with screen edge padding
                    VStack(alignment: .leading, spacing: CodSpacing.sectionSpacing) {
                        content()
                    }
                    .padding(.horizontal, CodSpacing.screenEdge)
                    .padding(.top, hero != nil ? CodSpacing.lg : CodSpacing.sm)
                    .padding(.bottom, CodSpacing.xxl)
                }
            }
            .refreshable {
                await onRefresh?()
            }
            .background(Color.capeCod.background)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.capeCod.background, for: .navigationBar)
        }
        .tint(Color.capeCod.primary)
    }
}

// No-hero convenience initializer
extension ScrollScreenLayout where Hero == EmptyView {
    init(
        title: String,
        onRefresh: (() async -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.hero = nil
        self.onRefresh = onRefresh
        self.content = content
    }
}

// MARK: - SectionHeader

/// Reusable section header with title and optional "See All" button.
struct SectionHeader: View {
    let title: String
    var seeAllAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .codTextStyle(.sectionTitle)

            Spacer()

            if let seeAllAction {
                Button(action: seeAllAction) {
                    HStack(spacing: CodSpacing.xs) {
                        Text("See All")
                            .font(.system(size: 15, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(Color.capeCod.primary)
                }
            }
        }
    }
}

// MARK: - ContentSection

/// Groups a section header with its content, applying consistent spacing.
struct ContentSection<Content: View>: View {
    let title: String
    var seeAllAction: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            SectionHeader(title: title, seeAllAction: seeAllAction)
            content()
        }
    }
}

// MARK: - Preview

#Preview("Scroll Screen Layout") {
    ScrollScreenLayout(
        title: "Explore",
        hero: {
            // Hero gradient placeholder
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [Color.capeCod.oceanBlue, Color.capeCod.seafoam],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 200)

                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    Text("Good Morning")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                    Text("Explore Cape Cod")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.sm)
            }
        },
        onRefresh: {
            try? await Task.sleep(for: .seconds(1))
        }
    ) {
        ContentSection(title: "Nearby Beaches", seeAllAction: {}) {
            ForEach(0..<3) { i in
                CodCard(size: .standard, action: {}) {
                    CodCardContent(
                        title: ["Nauset Beach", "Coast Guard Beach", "Marconi Beach"][i],
                        subtitle: "Beautiful sandy beach with lifeguards.",
                        metadata: "\(String(format: "%.1f", Double.random(in: 0.3...3.0))) mi away",
                        badge: ("Beach", Color.capeCod.oceanBlue)
                    )
                }
            }
        }

        ContentSection(title: "Traffic Updates", seeAllAction: {}) {
            HStack(spacing: CodSpacing.md) {
                MetricCard(
                    value: "12",
                    unit: "min",
                    label: "Bourne Bridge",
                    icon: "car.fill",
                    tint: Color.capeCod.duneGrass
                )
                MetricCard(
                    value: "47",
                    unit: "min",
                    label: "Sagamore",
                    icon: "car.fill",
                    tint: Color.capeCod.lobsterRed,
                    trend: .up
                )
            }
        }

        ContentSection(title: "Stories for You") {
            CodCard(size: .standard) {
                CodCardContent(
                    title: "The Secret History of Provincetown",
                    subtitle: "A walking audio tour through four centuries of Cape Cod history.",
                    metadata: "12 min listen"
                )
            }
        }
    }
}
