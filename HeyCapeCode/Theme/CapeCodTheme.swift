import SwiftUI

// MARK: - Cape Cod Color Palette

/// The master design token file for Hey Cape Cod.
/// Colors are inspired by Cape Cod's natural environment —
/// ocean light, golden hour sunsets, weathered shingles, and sandy shores.
extension Color {
    static let capeCod = CapeCodColors()
}

struct CapeCodColors {

    // MARK: - Primary Colors

    /// Ocean Blue — primary actions, links, selected states
    let oceanBlue = Color(light: Color(hex: 0x1A6B8A), dark: Color(hex: 0x3FA8CC))

    /// Deep Navy — dark backgrounds, text on light surfaces
    let deepNavy = Color(light: Color(hex: 0x0D2137), dark: Color(hex: 0x0D2137))

    /// Sunset Orange — accent, CTAs, notifications, AI speaking state
    let sunsetOrange = Color(light: Color(hex: 0xE87040), dark: Color(hex: 0xF08860))

    /// Seafoam — success states, AI listening state, secondary accent
    let seafoam = Color(light: Color(hex: 0x7EC8B8), dark: Color(hex: 0x7EC8B8))

    // MARK: - Neutral Colors

    /// Sand — warm backgrounds, card surfaces in dark mode
    let sand = Color(light: Color(hex: 0xE8D5B7), dark: Color(hex: 0x3A3020))

    /// Driftwood — secondary text, subtle borders
    let driftwood = Color(light: Color(hex: 0xA69279), dark: Color(hex: 0x8C7E6A))

    /// Shell White — primary light background (warm, not stark white)
    let shellWhite = Color(light: Color(hex: 0xFAF6F1), dark: Color(hex: 0x111D2B))

    /// Fog — secondary light background, card surfaces
    let fog = Color(light: Color(hex: 0xF0EDE8), dark: Color(hex: 0x162233))

    // MARK: - Semantic / Nature Colors

    /// Dune Grass — nature/success indicators
    let duneGrass = Color(light: Color(hex: 0x8BA87E), dark: Color(hex: 0xA0C090))

    /// Cranberry — alerts, errors, shark warnings
    let cranberry = Color(light: Color(hex: 0xC94E50), dark: Color(hex: 0xE06668))

    /// Lobster Red — traffic severe
    let lobsterRed = Color(light: Color(hex: 0xD44D2D), dark: Color(hex: 0xE86A4E))

    /// Sandbar Yellow — traffic moderate, warnings
    let sandbarYellow = Color(light: Color(hex: 0xE8B94E), dark: Color(hex: 0xE8B94E))

    // MARK: - Semantic Aliases

    var primary: Color { oceanBlue }
    var secondary: Color { seafoam }
    var accent: Color { sunsetOrange }

    var background: Color { shellWhite }
    var surface: Color { fog }
    var surfaceElevated: Color {
        Color(light: .white, dark: Color(hex: 0x1C2E42))
    }

    var textPrimary: Color {
        Color(light: Color(hex: 0x0D2137), dark: Color(hex: 0xF0EDE8))
    }
    var textSecondary: Color { driftwood }
    var textOnPrimary: Color {
        Color(light: .white, dark: .white)
    }

    // MARK: - Traffic Semantic Colors

    var trafficClear: Color { duneGrass }
    var trafficModerate: Color { sandbarYellow }
    var trafficHeavy: Color { sunsetOrange }
    var trafficSevere: Color { lobsterRed }

    // MARK: - AI State Colors

    var aiListening: Color { seafoam }
    var aiThinking: Color { sunsetOrange }
    var aiSpeaking: Color { sunsetOrange }

    // MARK: - Gradients

    var oceanGradient: LinearGradient {
        LinearGradient(
            colors: [oceanBlue, seafoam],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var sunsetGradient: LinearGradient {
        LinearGradient(
            colors: [sunsetOrange, Color(hex: 0xE8B94E)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
