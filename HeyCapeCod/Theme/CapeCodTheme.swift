import SwiftUI

// MARK: - Cape Cod Color Palette

/// The master design token file for Hey Cape Cod.
/// Colors are inspired by Cape Cod's natural environment —
/// ocean light, golden hour sunsets, weathered shingles, and sandy shores.
extension Color {
    static let capeCod = CapeCodColors()
}

struct CapeCodColors {
    private var palette: ThemePalette { ThemeManager.shared.palette }

    // MARK: - Primary Colors

    var oceanBlue: Color { palette.oceanBlue }
    var deepNavy: Color { palette.deepNavy }
    var sunsetOrange: Color { palette.sunsetOrange }
    var seafoam: Color { palette.seafoam }

    // MARK: - Neutral Colors

    var sand: Color { palette.sand }
    var driftwood: Color { palette.driftwood }
    var shellWhite: Color { palette.shellWhite }
    var fog: Color { palette.fog }

    // MARK: - Semantic / Nature Colors

    var duneGrass: Color { palette.duneGrass }
    var cranberry: Color { palette.cranberry }
    var lobsterRed: Color { palette.lobsterRed }
    var sandbarYellow: Color { palette.sandbarYellow }

    // MARK: - Semantic Aliases

    var primary: Color { palette.primary }
    var secondary: Color { palette.secondary }
    var accent: Color { palette.accent }

    var background: Color { palette.background }
    var surface: Color { palette.surface }
    var surfaceElevated: Color { palette.surfaceElevated }

    var textPrimary: Color { palette.textPrimary }
    var textSecondary: Color { palette.textSecondary }
    var textOnPrimary: Color { palette.textOnPrimary }

    // MARK: - Convenience Aliases

    var cardBackground: Color { palette.cardBackground }
    var primaryText: Color { palette.textPrimary }
    var secondaryText: Color { palette.textSecondary }
    var cardBorder: Color { palette.cardBorder }
    var imageOverlay: Color { palette.imageOverlay }

    // MARK: - Traffic Semantic Colors

    var trafficClear: Color { palette.trafficClear }
    var trafficModerate: Color { palette.trafficModerate }
    var trafficHeavy: Color { palette.trafficHeavy }
    var trafficSevere: Color { palette.trafficSevere }

    // MARK: - AI State Colors

    var aiListening: Color { palette.aiListening }
    var aiThinking: Color { palette.aiThinking }
    var aiSpeaking: Color { palette.aiSpeaking }

    // MARK: - Gradients

    var oceanGradient: LinearGradient { palette.oceanGradient }
    var sunsetGradient: LinearGradient { palette.sunsetGradient }

    func imageOverlayGradient(from startPoint: UnitPoint = .top, to endPoint: UnitPoint = .bottom) -> LinearGradient {
        palette.imageOverlayGradient(from: startPoint, to: endPoint)
    }
}

// MARK: - Adaptive Color Helper

extension Color {
    /// Creates a color that adapts between light and dark mode.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}

// MARK: - Dark Mode Image Dimming

/// Reduces image brightness by 10% in dark mode for a more comfortable viewing experience.
struct DarkModeDimming: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .brightness(colorScheme == .dark ? -0.1 : 0)
    }
}

extension View {
    func darkModeDimmed() -> some View {
        modifier(DarkModeDimming())
    }
}

// MARK: - Adaptive Card Styling

/// Applies shadow in light mode and subtle border in dark mode.
struct AdaptiveCardStyle: ViewModifier {
    let cornerRadius: CGFloat
    let shadow: CodShadow
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        } else {
            content
                .codShadow(shadow)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.04), lineWidth: 0.5)
                )
        }
    }
}

extension View {
    func adaptiveCardStyle(cornerRadius: CGFloat = CodRadius.card, shadow: CodShadow = .card) -> some View {
        modifier(AdaptiveCardStyle(cornerRadius: cornerRadius, shadow: shadow))
    }
}
