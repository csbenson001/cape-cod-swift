import SwiftUI

// MARK: - HorizontalCardScroll

/// Horizontal scrolling card section (like App Store's featured apps).
/// Shows section title + "See All" button, horizontally scrolling CodCards,
/// with snap-to-card behavior and peek of the next card visible.
struct HorizontalCardScroll<CardContent: View>: View {
    let title: String
    let itemCount: Int
    var seeAllAction: (() -> Void)? = nil
    @ViewBuilder let cardContent: (Int) -> CardContent

    private let cardSpacing: CGFloat = CodSpacing.md

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            SectionHeader(title: title, seeAllAction: seeAllAction)
                .padding(.horizontal, CodSpacing.screenEdge)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: cardSpacing) {
                    ForEach(0..<itemCount, id: \.self) { index in
                        CodCard(size: .compact) {
                            cardContent(index)
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, CodSpacing.screenEdge)
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

// MARK: - Featured Card Scroll (Larger Cards)

/// A wider variant for featured/hero content with larger cards.
struct FeaturedCardScroll<CardContent: View>: View {
    let title: String
    let itemCount: Int
    var seeAllAction: (() -> Void)? = nil
    @ViewBuilder let cardContent: (Int) -> CardContent

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            SectionHeader(title: title, seeAllAction: seeAllAction)
                .padding(.horizontal, CodSpacing.screenEdge)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: CodSpacing.md) {
                    ForEach(0..<itemCount, id: \.self) { index in
                        cardContent(index)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: CodSpacing.md)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, CodSpacing.screenEdge)
            }
            .scrollTargetBehavior(.paging)
        }
    }
}

// MARK: - Preview

#Preview("Horizontal Card Scroll") {
    let beaches = [
        ("Nauset Beach", "Orleans", "Beach"),
        ("Coast Guard", "Eastham", "Beach"),
        ("Marconi Beach", "Wellfleet", "Beach"),
        ("Race Point", "Provincetown", "Beach"),
        ("Sandy Neck", "Barnstable", "Beach"),
    ]

    let pois = [
        ("Chatham Lighthouse", "Historic landmark with ocean views", Color.capeCod.driftwood),
        ("Cape Cod Rail Trail", "26-mile paved bike path", Color.capeCod.duneGrass),
        ("Provincetown Wharf", "Whale watching departures daily", Color.capeCod.oceanBlue),
        ("Wellfleet Drive-In", "Classic outdoor cinema since 1957", Color.capeCod.sunsetOrange),
    ]

    ScrollView {
        VStack(spacing: CodSpacing.sectionSpacing) {
            HorizontalCardScroll(
                title: "Nearby Beaches",
                itemCount: beaches.count,
                seeAllAction: {}
            ) { index in
                let beach = beaches[index]
                ZStack {
                    LinearGradient(
                        colors: [Color.capeCod.oceanBlue.opacity(0.3), Color.capeCod.seafoam.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 120)

                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.capeCod.oceanBlue.opacity(0.3))
                }
                CodCardContent(title: beach.0, metadata: beach.1)
            }

            FeaturedCardScroll(
                title: "Popular Places",
                itemCount: pois.count,
                seeAllAction: {}
            ) { index in
                let poi = pois[index]
                CodCard(size: .featured, action: {}) {
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: [poi.2, poi.2.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 180)

                        Color.capeCod.imageOverlayGradient(from: .center, to: .bottom)
                            .frame(height: 180)

                        Text(poi.0)
                            .codTextStyle(.sectionTitle)
                            .foregroundStyle(.white)
                            .padding(CodSpacing.cardPadding)
                    }

                    CodCardContent(title: poi.0, subtitle: poi.1)
                }
            }

            HorizontalCardScroll(
                title: "By Category",
                itemCount: 4
            ) { index in
                let categories: [(String, String, Color)] = [
                    ("Beaches", "sun.max.fill", Color.capeCod.oceanBlue),
                    ("Historic", "building.columns.fill", Color.capeCod.driftwood),
                    ("Nature", "leaf.fill", Color.capeCod.duneGrass),
                    ("Food", "fork.knife", Color.capeCod.sunsetOrange),
                ]
                let cat = categories[index]

                VStack(spacing: CodSpacing.sm) {
                    Image(systemName: cat.1)
                        .font(.system(size: CodSpacing.lg))
                        .foregroundStyle(cat.2)
                        .frame(width: 56, height: 56)
                        .background(cat.2.opacity(0.12))
                        .clipShape(Circle())

                    Text(cat.0)
                        .codTextStyle(.cardTitle)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, CodSpacing.md)
            }
        }
        .padding(.top, CodSpacing.lg)
    }
    .background(Color.capeCod.background)
}
