import SwiftUI

// MARK: - Cape Cod Spacing & Layout Constants

/// 8-point grid spacing system with corner radii and shadow definitions.
enum CodSpacing {

    // MARK: - Grid Spacing

    /// 4pt — extra small gaps, tight padding
    static let xs: CGFloat = 4
    /// 8pt — small gaps, icon-to-label spacing
    static let sm: CGFloat = 8
    /// 16pt — standard internal padding
    static let md: CGFloat = 16
    /// 24pt — generous spacing between related elements
    static let lg: CGFloat = 24
    /// 32pt — section spacing within a screen
    static let xl: CGFloat = 32
    /// 48pt — major section separators
    static let xxl: CGFloat = 48

    // MARK: - Screen Layout

    /// 20pt — screen edge padding (slightly more than Apple default for premium feel)
    static let screenEdge: CGFloat = 20
    /// 32pt — between major content sections
    static let sectionSpacing: CGFloat = 32
    /// 16pt — standard card internal padding
    static let cardPadding: CGFloat = 16
}

// MARK: - Corner Radii

enum CodRadius {
    /// 16pt — cards, image containers
    static let card: CGFloat = 16
    /// 12pt — buttons
    static let button: CGFloat = 12
    /// 10pt — input fields
    static let input: CGFloat = 10
    /// 8pt — small chips, tags
    static let chip: CGFloat = 8
    /// 24pt — large featured cards
    static let featured: CGFloat = 24
}

// MARK: - Shadows

struct CodShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    /// Subtle shadow for standard cards
    static let card = CodShadow(
        color: .black.opacity(0.08),
        radius: 12,
        x: 0,
        y: 4
    )

    /// Elevated shadow for modals, popovers
    static let elevated = CodShadow(
        color: .black.opacity(0.12),
        radius: 20,
        x: 0,
        y: 8
    )

    /// Subtle shadow for buttons on press
    static let button = CodShadow(
        color: .black.opacity(0.06),
        radius: 8,
        x: 0,
        y: 2
    )
}

// MARK: - Shadow View Modifier

struct CodShadowModifier: ViewModifier {
    let shadow: CodShadow

    func body(content: Content) -> some View {
        content.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

extension View {
    func codShadow(_ shadow: CodShadow = .card) -> some View {
        modifier(CodShadowModifier(shadow: shadow))
    }
}
