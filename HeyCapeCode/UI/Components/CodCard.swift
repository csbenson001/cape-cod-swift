import SwiftUI

// MARK: - CodCard

/// The primary card component for Hey Cape Cod.
/// Three sizes: `.compact` (horizontal scroll), `.standard` (vertical lists), `.featured` (full-width hero).
/// Supports image headers with gradient overlays, titles, subtitles, metadata, and badges.
struct CodCard<Content: View>: View {
    let size: CodCardSize
    let action: (() -> Void)?
    @ViewBuilder let content: () -> Content

    @State private var isPressed = false

    init(
        size: CodCardSize = .standard,
        action: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.size = size
        self.action = action
        self.content = content
    }

    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    cardBody
                }
                .buttonStyle(CodCardButtonStyle())
            } else {
                cardBody
            }
        }
        .frame(width: size.width)
    }

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
        .codShadow(size == .featured ? .elevated : .card)
        .overlay(
            RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                .strokeBorder(Color.capeCod.driftwood.opacity(0.15), lineWidth: 0.5)
        )
    }
}

// MARK: - Card Size

enum CodCardSize {
    case compact
    case standard
    case featured

    var width: CGFloat? {
        switch self {
        case .compact: return 200
        case .standard: return nil
        case .featured: return nil
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .compact: return CodRadius.card
        case .standard: return CodRadius.card
        case .featured: return CodRadius.featured
        }
    }

    var imageHeight: CGFloat {
        switch self {
        case .compact: return 120
        case .standard: return 160
        case .featured: return 220
        }
    }
}

// MARK: - Card Subcomponents

/// Image header with optional gradient overlay for text readability.
struct CodCardImage: View {
    let imageName: String
    let size: CodCardSize
    let systemImage: Bool

    init(_ imageName: String, size: CodCardSize = .standard, systemImage: Bool = false) {
        self.imageName = imageName
        self.size = size
        self.systemImage = systemImage
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if systemImage {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: size.imageHeight)
                    .clipped()
            } else {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: size.imageHeight)
                    .clipped()
            }

            // Gradient overlay for text legibility on images
            LinearGradient(
                colors: [.clear, .black.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(height: size.imageHeight)
        .clipped()
    }
}

/// Badge overlay for cards (e.g., tide status, category).
struct CodCardBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, CodSpacing.sm)
            .padding(.vertical, CodSpacing.xs)
            .background(color, in: Capsule())
    }
}

/// Standard card content layout with title, subtitle, and optional metadata.
struct CodCardContent: View {
    let title: String
    var subtitle: String? = nil
    var metadata: String? = nil
    var badge: (text: String, color: Color)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.xs) {
            if let badge {
                CodCardBadge(text: badge.text, color: badge.color)
            }

            Text(title)
                .codTextStyle(.cardTitle)
                .lineLimit(2)

            if let subtitle {
                Text(subtitle)
                    .codTextStyle(.body)
                    .lineLimit(2)
            }

            if let metadata {
                Text(metadata)
                    .codTextStyle(.caption)
            }
        }
        .padding(CodSpacing.cardPadding)
    }
}

// MARK: - Card Button Style (Press Animation)

struct CodCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.capeCodQuick, value: configuration.isPressed)
    }
}

// MARK: - Animation Extension

extension Animation {
    static let capeCodSpring = Animation.spring(response: 0.35, dampingFraction: 0.7)
    static let capeCodQuick = Animation.spring(response: 0.25, dampingFraction: 0.8)
    static let capeCodGentle = Animation.easeInOut(duration: 1.0)
}

// MARK: - Preview

#Preview("Card Sizes") {
    ScrollView {
        VStack(spacing: CodSpacing.lg) {
            // Featured card
            CodCard(size: .featured) {
                Rectangle()
                    .fill(Color.capeCod.oceanBlue.opacity(0.3))
                    .frame(height: 220)
                CodCardContent(
                    title: "Welcome to Cape Cod",
                    subtitle: "Discover beaches, trails, and hidden gems.",
                    badge: ("Featured", Color.capeCod.sunsetOrange)
                )
            }

            // Standard card
            CodCard(size: .standard) {
                CodCardContent(
                    title: "Chatham Lighthouse",
                    subtitle: "Historic lighthouse with panoramic ocean views.",
                    metadata: "0.8 mi away"
                )
            }

            // Compact cards in horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.md) {
                    ForEach(0..<3) { i in
                        CodCard(size: .compact) {
                            Rectangle()
                                .fill(Color.capeCod.seafoam.opacity(0.3))
                                .frame(height: 120)
                            CodCardContent(title: "Beach \(i + 1)", metadata: "Open")
                        }
                    }
                }
                .padding(.horizontal, CodSpacing.screenEdge)
            }
        }
        .padding(CodSpacing.screenEdge)
    }
    .background(Color.capeCod.background)
}
