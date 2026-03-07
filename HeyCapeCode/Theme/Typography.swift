import SwiftUI

// MARK: - Cape Cod Typography System

/// Editorial type hierarchy using SF Pro with SF Rounded for hero elements.
/// Every style supports Dynamic Type scaling via @ScaledMetric.
struct CapeCodTypography {

    // MARK: - Font Definitions

    /// 34pt bold rounded, tight tracking — screen headers like "Explore Cape Cod"
    static func heroTitle() -> Font {
        .system(size: 34, weight: .bold, design: .rounded)
    }

    /// 22pt semibold — section headers like "Nearby Beaches"
    static func sectionTitle() -> Font {
        .system(size: 22, weight: .semibold, design: .default)
    }

    /// 17pt semibold — card headers like "Chatham Lighthouse"
    static func cardTitle() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }

    /// 15pt regular — descriptions and general text
    static func body() -> Font {
        .system(size: 15, weight: .regular, design: .default)
    }

    /// 15pt regular with generous line spacing — for story/description text
    static func storyBody() -> Font {
        .system(size: 15, weight: .regular, design: .default)
    }

    /// 13pt regular — metadata, timestamps
    static func caption() -> Font {
        .system(size: 13, weight: .regular, design: .default)
    }

    /// 11pt medium — category tags (apply uppercased + tracking manually)
    static func label() -> Font {
        .system(size: 11, weight: .medium, design: .default)
    }

    /// 28pt light, monospaced digits — big numbers (delays, temps)
    static func metric() -> Font {
        .system(size: 28, weight: .light, design: .default)
            .monospacedDigit()
    }

    /// 13pt regular — units next to metrics ("min", "°F")
    static func metricUnit() -> Font {
        .system(size: 13, weight: .regular, design: .default)
    }
}

// MARK: - View Modifier Approach

/// Apply Cape Cod text styles as view modifiers for full control
/// over tracking, color, and Dynamic Type.
struct CapeCodTextStyle: ViewModifier {
    let style: CodTextStyle
    @ScaledMetric private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        switch style {
        case .heroTitle:
            content
                .font(.system(size: 34 * scale, weight: .bold, design: .rounded))
                .tracking(-0.5)
                .foregroundStyle(Color.capeCod.textPrimary)

        case .sectionTitle:
            content
                .font(.system(size: 22 * scale, weight: .semibold))
                .foregroundStyle(Color.capeCod.textPrimary)

        case .cardTitle:
            content
                .font(.system(size: 17 * scale, weight: .semibold))
                .foregroundStyle(Color.capeCod.textPrimary)

        case .body:
            content
                .font(.system(size: 15 * scale, weight: .regular))
                .foregroundStyle(Color.capeCod.textPrimary)

        case .storyBody:
            content
                .font(.system(size: 15 * scale, weight: .regular))
                .lineSpacing(15 * scale * 0.4)
                .foregroundStyle(Color.capeCod.textPrimary)

        case .caption:
            content
                .font(.system(size: 13 * scale, weight: .regular))
                .foregroundStyle(Color.capeCod.textSecondary)

        case .label:
            content
                .font(.system(size: 11 * scale, weight: .medium))
                .tracking(1.5)
                .textCase(.uppercase)
                .foregroundStyle(Color.capeCod.textSecondary)

        case .metric:
            content
                .font(.system(size: 28 * scale, weight: .light).monospacedDigit())
                .foregroundStyle(Color.capeCod.textPrimary)

        case .metricUnit:
            content
                .font(.system(size: 13 * scale, weight: .regular))
                .foregroundStyle(Color.capeCod.textSecondary)

        case .bannerText:
            content
                .font(.system(size: 14 * scale, weight: .medium))

        case .bannerAction:
            content
                .font(.system(size: 13 * scale, weight: .bold))

        case .miniPlayerTitle:
            content
                .font(.system(size: 14 * scale, weight: .semibold))
                .foregroundStyle(Color.capeCod.textPrimary)

        case .miniPlayerSubtitle:
            content
                .font(.system(size: 12 * scale, weight: .regular))
                .foregroundStyle(Color.capeCod.textSecondary)

        case .tabLabel:
            content
                .font(.system(size: 10 * scale, weight: .medium))
        }
    }
}

enum CodTextStyle {
    case heroTitle
    case sectionTitle
    case cardTitle
    case body
    case storyBody
    case caption
    case label
    case metric
    case metricUnit
    case bannerText
    case bannerAction
    case miniPlayerTitle
    case miniPlayerSubtitle
    case tabLabel
}

extension View {
    func codTextStyle(_ style: CodTextStyle) -> some View {
        modifier(CapeCodTextStyle(style: style))
    }
}
