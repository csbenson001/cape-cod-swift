import SwiftUI

// MARK: - LoadingSkeleton

/// Shimmer loading placeholder — never show a blank screen.
/// Provides pre-built variants matching real content dimensions.
struct LoadingSkeleton: View {
    let variant: SkeletonVariant

    var body: some View {
        switch variant {
        case .card:
            cardSkeleton
        case .metric:
            metricSkeleton
        case .listRow:
            listRowSkeleton
        case .mapPlaceholder:
            mapSkeleton
        case .custom(let width, let height, let radius):
            ShimmerRect(radius: radius)
                .frame(width: width, height: height)
        }
    }

    // MARK: - Card Skeleton

    private var cardSkeleton: some View {
        VStack(alignment: .leading, spacing: 0) {
            ShimmerRect(radius: 0)
                .frame(height: 160)

            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                ShimmerRect()
                    .frame(width: 100, height: 20)
                ShimmerRect()
                    .frame(height: 16)
                ShimmerRect()
                    .frame(width: 140, height: 14)
            }
            .padding(CodSpacing.cardPadding)
        }
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }

    // MARK: - Metric Skeleton

    private var metricSkeleton: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            ShimmerRect()
                .frame(width: 80, height: 12)
            ShimmerRect()
                .frame(width: 60, height: 28)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surface)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }

    // MARK: - List Row Skeleton

    private var listRowSkeleton: some View {
        HStack(spacing: CodSpacing.md) {
            ShimmerRect(radius: CodRadius.chip)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                ShimmerRect()
                    .frame(width: 160, height: 16)
                ShimmerRect()
                    .frame(width: 100, height: 13)
            }

            Spacer()

            ShimmerRect()
                .frame(width: 40, height: 16)
        }
        .padding(.vertical, CodSpacing.sm)
    }

    // MARK: - Map Placeholder

    private var mapSkeleton: some View {
        ZStack {
            ShimmerRect(radius: CodRadius.card)
                .frame(height: 200)
            Image(systemName: "map")
                .font(.system(size: 32))
                .foregroundStyle(Color.capeCod.driftwood.opacity(0.3))
        }
    }
}

// MARK: - Skeleton Variant

enum SkeletonVariant {
    case card
    case metric
    case listRow
    case mapPlaceholder
    case custom(width: CGFloat?, height: CGFloat, radius: CGFloat)
}

// MARK: - Shimmer Rectangle

/// Animated gradient shimmer rectangle.
struct ShimmerRect: View {
    let radius: CGFloat

    init(radius: CGFloat = 6) {
        self.radius = radius
    }

    @State private var phase: CGFloat = -1.0

    var body: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(Color.capeCod.driftwood.opacity(0.12))
            .overlay(
                GeometryReader { geometry in
                    shimmerGradient
                        .frame(width: geometry.size.width * 2)
                        .offset(x: phase * geometry.size.width)
                }
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            )
            .onAppear {
                withAnimation(CodAnimation.shimmer) {
                    phase = 2.0
                }
            }
    }

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            colors: [
                .clear,
                Color.capeCod.driftwood.opacity(0.08),
                Color.capeCod.shellWhite.opacity(0.4),
                Color.capeCod.driftwood.opacity(0.08),
                .clear,
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Preview

#Preview("Loading Skeletons") {
    ScrollView {
        VStack(spacing: CodSpacing.lg) {
            Text("Card Skeleton").codTextStyle(.sectionTitle)
            LoadingSkeleton(variant: .card)

            Text("Metric Skeletons").codTextStyle(.sectionTitle)
            HStack(spacing: CodSpacing.md) {
                LoadingSkeleton(variant: .metric)
                LoadingSkeleton(variant: .metric)
            }

            Text("List Row Skeletons").codTextStyle(.sectionTitle)
            ForEach(0..<3, id: \.self) { _ in
                LoadingSkeleton(variant: .listRow)
            }

            Text("Map Placeholder").codTextStyle(.sectionTitle)
            LoadingSkeleton(variant: .mapPlaceholder)
        }
        .padding(CodSpacing.screenEdge)
    }
    .background(Color.capeCod.background)
}
