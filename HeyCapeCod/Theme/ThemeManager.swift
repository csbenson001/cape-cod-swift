import SwiftUI

// MARK: - App Theme

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case coastal    // Current default — ocean blues, sandy neutrals
    case forest     // Pine greens, earthy browns, moss tones
    case sunset     // Warm oranges, coral pinks, golden yellows

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .coastal: "Coastal"
        case .forest: "Forest"
        case .sunset: "Sunset"
        }
    }

    var subtitle: String {
        switch self {
        case .coastal: "Ocean blues & sandy shores"
        case .forest: "Pine greens & earthy tones"
        case .sunset: "Warm golds & coral pinks"
        }
    }

    var icon: String {
        switch self {
        case .coastal: "water.waves"
        case .forest: "leaf.fill"
        case .sunset: "sun.horizon.fill"
        }
    }

    var previewColors: [Color] {
        let p = palette
        return [p.primary, p.secondary, p.accent, p.sand]
    }

    // MARK: - Color Palettes

    var palette: ThemePalette {
        switch self {
        case .coastal: .coastal
        case .forest: .forest
        case .sunset: .sunset
        }
    }
}

// MARK: - Theme Palette

struct ThemePalette {
    // Primary
    let oceanBlue: Color
    let deepNavy: Color
    let sunsetOrange: Color
    let seafoam: Color

    // Neutral
    let sand: Color
    let driftwood: Color
    let shellWhite: Color
    let fog: Color

    // Nature
    let duneGrass: Color
    let cranberry: Color
    let lobsterRed: Color
    let sandbarYellow: Color

    // Surface / Text
    let surfaceElevated: Color
    let textPrimary: Color

    // Semantic
    var primary: Color { oceanBlue }
    var secondary: Color { seafoam }
    var accent: Color { sunsetOrange }

    var background: Color { shellWhite }
    var surface: Color { fog }

    var textSecondary: Color { driftwood }
    var textOnPrimary: Color { Color.white }

    var cardBackground: Color { surfaceElevated }
    var cardBorder: Color {
        let lightColor = Color(hex: 0x000000).opacity(0.06)
        let darkColor = Color.white.opacity(0.08)
        return Color(light: Color(lightColor), dark: Color(darkColor))
    }
    var imageOverlay: Color {
        let lightOverlay = deepNavy.opacity(0.4)
        let darkOverlay = deepNavy.opacity(0.5)
        return Color(light: Color(lightOverlay), dark: Color(darkOverlay))
    }

    // Traffic
    var trafficClear: Color { duneGrass }
    var trafficModerate: Color { sandbarYellow }
    var trafficHeavy: Color { sunsetOrange }
    var trafficSevere: Color { lobsterRed }

    // AI
    var aiListening: Color { seafoam }
    var aiThinking: Color { sunsetOrange }
    var aiSpeaking: Color { sunsetOrange }

    // Gradients
    var oceanGradient: LinearGradient {
        LinearGradient(colors: [oceanBlue, seafoam], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var sunsetGradient: LinearGradient {
        LinearGradient(colors: [sunsetOrange, sandbarYellow], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    func imageOverlayGradient(from startPoint: UnitPoint = .top, to endPoint: UnitPoint = .bottom) -> LinearGradient {
        LinearGradient(colors: [.clear, deepNavy.opacity(0.45)], startPoint: startPoint, endPoint: endPoint)
    }
}

// MARK: - Coastal Theme (Default)

extension ThemePalette {
    static let coastal: ThemePalette = {
        let oceanBlue = Color(light: Color(hex: 0x1A6B8A), dark: Color(hex: 0x3FA8CC))
        let deepNavy = Color(light: Color(hex: 0x0D2137), dark: Color(hex: 0x0D2137))
        let sunsetOrange = Color(light: Color(hex: 0xE87040), dark: Color(hex: 0xF08860))
        let seafoam = Color(light: Color(hex: 0x7EC8B8), dark: Color(hex: 0x7EC8B8))
        let sand = Color(light: Color(hex: 0xE8D5B7), dark: Color(hex: 0x3A3020))
        let driftwood = Color(light: Color(hex: 0xA69279), dark: Color(hex: 0x8C7E6A))
        let shellWhite = Color(light: Color(hex: 0xFFFFFF), dark: Color(hex: 0x111D2B))
        let fog = Color(light: Color(hex: 0xF5F5F7), dark: Color(hex: 0x162233))
        let duneGrass = Color(light: Color(hex: 0x8BA87E), dark: Color(hex: 0xA0C090))
        let cranberry = Color(light: Color(hex: 0xC94E50), dark: Color(hex: 0xE06668))
        let lobsterRed = Color(light: Color(hex: 0xD44D2D), dark: Color(hex: 0xE86A4E))
        let sandbarYellow = Color(light: Color(hex: 0xE8B94E), dark: Color(hex: 0xE8B94E))
        let surfaceElevated = Color(light: Color(hex: 0xFFFFFF), dark: Color(hex: 0x1C2E42))
        let textPrimary = Color(light: Color(hex: 0x0D2137), dark: Color(hex: 0xF0EDE8))

        return ThemePalette(
            oceanBlue: oceanBlue, deepNavy: deepNavy, sunsetOrange: sunsetOrange, seafoam: seafoam,
            sand: sand, driftwood: driftwood, shellWhite: shellWhite, fog: fog,
            duneGrass: duneGrass, cranberry: cranberry, lobsterRed: lobsterRed, sandbarYellow: sandbarYellow,
            surfaceElevated: surfaceElevated, textPrimary: textPrimary
        )
    }()
}

// MARK: - Forest Theme

extension ThemePalette {
    static let forest: ThemePalette = {
        let oceanBlue = Color(light: Color(hex: 0x3D7A5F), dark: Color(hex: 0x5FAD83))
        let deepNavy = Color(light: Color(hex: 0x1C2E1F), dark: Color(hex: 0x1C2E1F))
        let sunsetOrange = Color(light: Color(hex: 0xD4874E), dark: Color(hex: 0xE0A06C))
        let seafoam = Color(light: Color(hex: 0x8DB580), dark: Color(hex: 0xA0C890))
        let sand = Color(light: Color(hex: 0xDDD0B8), dark: Color(hex: 0x352E20))
        let driftwood = Color(light: Color(hex: 0x8E7E68), dark: Color(hex: 0x9E8E78))
        let shellWhite = Color(light: Color(hex: 0xFAF8F2), dark: Color(hex: 0x141E16))
        let fog = Color(light: Color(hex: 0xF0EDE4), dark: Color(hex: 0x1A261C))
        let duneGrass = Color(light: Color(hex: 0x6B9E5B), dark: Color(hex: 0x88BB78))
        let cranberry = Color(light: Color(hex: 0xB84E4E), dark: Color(hex: 0xD06666))
        let lobsterRed = Color(light: Color(hex: 0xC4513A), dark: Color(hex: 0xD87058))
        let sandbarYellow = Color(light: Color(hex: 0xD4A843), dark: Color(hex: 0xD4A843))
        let surfaceElevated = Color(light: Color(hex: 0xFFFDF7), dark: Color(hex: 0x223326))
        let textPrimary = Color(light: Color(hex: 0x1C2E1F), dark: Color(hex: 0xEDE8E0))

        return ThemePalette(
            oceanBlue: oceanBlue, deepNavy: deepNavy, sunsetOrange: sunsetOrange, seafoam: seafoam,
            sand: sand, driftwood: driftwood, shellWhite: shellWhite, fog: fog,
            duneGrass: duneGrass, cranberry: cranberry, lobsterRed: lobsterRed, sandbarYellow: sandbarYellow,
            surfaceElevated: surfaceElevated, textPrimary: textPrimary
        )
    }()
}

// MARK: - Sunset Theme

extension ThemePalette {
    static let sunset: ThemePalette = {
        let oceanBlue = Color(light: Color(hex: 0xC86B5A), dark: Color(hex: 0xE08878))
        let deepNavy = Color(light: Color(hex: 0x2D1B2E), dark: Color(hex: 0x2D1B2E))
        let sunsetOrange = Color(light: Color(hex: 0xE8804A), dark: Color(hex: 0xF09868))
        let seafoam = Color(light: Color(hex: 0xF0B088), dark: Color(hex: 0xE8C0A0))
        let sand = Color(light: Color(hex: 0xF0DAC0), dark: Color(hex: 0x382820))
        let driftwood = Color(light: Color(hex: 0xA0887A), dark: Color(hex: 0xB09888))
        let shellWhite = Color(light: Color(hex: 0xFFFBF5), dark: Color(hex: 0x1A1418))
        let fog = Color(light: Color(hex: 0xFAF0E8), dark: Color(hex: 0x221A20))
        let duneGrass = Color(light: Color(hex: 0x8EA87E), dark: Color(hex: 0xA8C098))
        let cranberry = Color(light: Color(hex: 0xC04858), dark: Color(hex: 0xE06070))
        let lobsterRed = Color(light: Color(hex: 0xD04838), dark: Color(hex: 0xE86858))
        let sandbarYellow = Color(light: Color(hex: 0xE8C050), dark: Color(hex: 0xE8C050))
        let surfaceElevated = Color(light: Color(hex: 0xFFFDF8), dark: Color(hex: 0x281E28))
        let textPrimary = Color(light: Color(hex: 0x2D1B2E), dark: Color(hex: 0xF0E8E4))

        return ThemePalette(
            oceanBlue: oceanBlue, deepNavy: deepNavy, sunsetOrange: sunsetOrange, seafoam: seafoam,
            sand: sand, driftwood: driftwood, shellWhite: shellWhite, fog: fog,
            duneGrass: duneGrass, cranberry: cranberry, lobsterRed: lobsterRed, sandbarYellow: sandbarYellow,
            surfaceElevated: surfaceElevated, textPrimary: textPrimary
        )
    }()
}

// MARK: - Theme Manager

@Observable
final class ThemeManager: @unchecked Sendable {
    static let shared = ThemeManager()

    var currentTheme: AppTheme {
        didSet { UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme") }
    }

    var palette: ThemePalette { currentTheme.palette }

    private init() {
        let raw = UserDefaults.standard.string(forKey: "appTheme") ?? "coastal"
        self.currentTheme = AppTheme(rawValue: raw) ?? .coastal
    }
}
