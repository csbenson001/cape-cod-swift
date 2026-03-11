import SwiftUI

// MARK: - Coloring Page Models

struct ColorRegion: Identifiable, Codable {
    let id: String
    let label: String
    let pathData: PathData
    var fillColorHex: String?

    var fillColor: Color? {
        guard let hex = fillColorHex else { return nil }
        return Color(hex: UInt(hex, radix: 16) ?? 0)
    }
}

/// Encodable path representation using simple drawing commands.
struct PathData: Codable {
    let commands: [PathCommand]
}

enum PathCommand: Codable {
    case moveTo(x: CGFloat, y: CGFloat)
    case lineTo(x: CGFloat, y: CGFloat)
    case curve(to: CGPoint, control1: CGPoint, control2: CGPoint)
    case quadCurve(to: CGPoint, control: CGPoint)
    case arc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool)
    case close
}

extension PathData {
    func buildPath(in size: CGSize) -> Path {
        var path = Path()
        let sx = size.width / 300
        let sy = size.height / 300
        for cmd in commands {
            switch cmd {
            case .moveTo(let x, let y):
                path.move(to: CGPoint(x: x * sx, y: y * sy))
            case .lineTo(let x, let y):
                path.addLine(to: CGPoint(x: x * sx, y: y * sy))
            case .curve(let to, let c1, let c2):
                path.addCurve(
                    to: CGPoint(x: to.x * sx, y: to.y * sy),
                    control1: CGPoint(x: c1.x * sx, y: c1.y * sy),
                    control2: CGPoint(x: c2.x * sx, y: c2.y * sy)
                )
            case .quadCurve(let to, let control):
                path.addQuadCurve(
                    to: CGPoint(x: to.x * sx, y: to.y * sy),
                    control: CGPoint(x: control.x * sx, y: control.y * sy)
                )
            case .arc(let center, let radius, let start, let end, let cw):
                path.addArc(
                    center: CGPoint(x: center.x * sx, y: center.y * sy),
                    radius: radius * min(sx, sy),
                    startAngle: .degrees(start),
                    endAngle: .degrees(end),
                    clockwise: cw
                )
            case .close:
                path.closeSubpath()
            }
        }
        return path
    }
}

struct ColoringPage: Identifiable {
    let id: String
    let name: String
    let icon: String
    var regions: [ColorRegion]
}

// MARK: - Coloring Action for Undo

struct ColoringAction {
    let regionId: String
    let previousColor: String?
}

// MARK: - Kid-Friendly Color Palette

struct KidColor: Identifiable {
    let id: String
    let color: Color
    let hex: String
    let name: String
}

let kidColorPalette: [KidColor] = [
    KidColor(id: "red", color: .red, hex: "FF0000", name: "Red"),
    KidColor(id: "orange", color: .orange, hex: "FF8C00", name: "Orange"),
    KidColor(id: "yellow", color: .yellow, hex: "FFD700", name: "Yellow"),
    KidColor(id: "green", color: .green, hex: "32CD32", name: "Green"),
    KidColor(id: "blue", color: .blue, hex: "1E90FF", name: "Blue"),
    KidColor(id: "purple", color: .purple, hex: "9B30FF", name: "Purple"),
    KidColor(id: "pink", color: .pink, hex: "FF69B4", name: "Pink"),
    KidColor(id: "brown", color: .brown, hex: "8B4513", name: "Brown"),
    KidColor(id: "black", color: .black, hex: "000000", name: "Black"),
    KidColor(id: "white", color: .white, hex: "FFFFFF", name: "White"),
    KidColor(id: "cyan", color: .cyan, hex: "00CED1", name: "Cyan"),
    KidColor(id: "magenta", color: Color(hex: 0xFF00FF), hex: "FF00FF", name: "Magenta"),
]

// MARK: - Page Definitions

enum ColoringPages {

    // MARK: Lighthouse
    static func lighthouse() -> ColoringPage {
        ColoringPage(id: "lighthouse", name: "Lighthouse", icon: "light.beacon.max", regions: [
            region("lh_sky", "Sky", [
                .moveTo(x: 0, y: 0), .lineTo(x: 300, y: 0),
                .lineTo(x: 300, y: 180), .lineTo(x: 0, y: 180), .close
            ]),
            region("lh_base", "Tower Base", [
                .moveTo(x: 115, y: 280), .lineTo(x: 185, y: 280),
                .lineTo(x: 175, y: 200), .lineTo(x: 125, y: 200), .close
            ]),
            region("lh_mid", "Tower Middle", [
                .moveTo(x: 125, y: 200), .lineTo(x: 175, y: 200),
                .lineTo(x: 168, y: 140), .lineTo(x: 132, y: 140), .close
            ]),
            region("lh_lantern", "Lantern Room", [
                .moveTo(x: 132, y: 140), .lineTo(x: 168, y: 140),
                .lineTo(x: 165, y: 115), .lineTo(x: 135, y: 115), .close
            ]),
            region("lh_roof", "Roof", [
                .moveTo(x: 135, y: 115), .lineTo(x: 165, y: 115),
                .lineTo(x: 150, y: 90), .close
            ]),
            region("lh_beam_l", "Light Beam Left", [
                .moveTo(x: 135, y: 110), .lineTo(x: 40, y: 60),
                .lineTo(x: 40, y: 80), .lineTo(x: 132, y: 120), .close
            ]),
            region("lh_beam_r", "Light Beam Right", [
                .moveTo(x: 165, y: 110), .lineTo(x: 260, y: 60),
                .lineTo(x: 260, y: 80), .lineTo(x: 168, y: 120), .close
            ]),
            region("lh_ground", "Ground", [
                .moveTo(x: 0, y: 180),
                .quadCurve(to: CGPoint(x: 150, y: 250), control: CGPoint(x: 50, y: 220)),
                .quadCurve(to: CGPoint(x: 300, y: 200), control: CGPoint(x: 250, y: 260)),
                .lineTo(x: 300, y: 300), .lineTo(x: 0, y: 300), .close
            ]),
            region("lh_door", "Door", [
                .moveTo(x: 140, y: 280), .lineTo(x: 160, y: 280),
                .lineTo(x: 160, y: 255),
                .quadCurve(to: CGPoint(x: 140, y: 255), control: CGPoint(x: 150, y: 245)),
                .close
            ]),
            region("lh_stripe", "Red Stripe", [
                .moveTo(x: 128, y: 175), .lineTo(x: 172, y: 175),
                .lineTo(x: 170, y: 160), .lineTo(x: 130, y: 160), .close
            ]),
        ])
    }

    // MARK: Lobster
    static func lobster() -> ColoringPage {
        ColoringPage(id: "lobster", name: "Lobster", icon: "fish", regions: [
            region("lb_body", "Body", [
                .moveTo(x: 100, y: 140),
                .quadCurve(to: CGPoint(x: 200, y: 140), control: CGPoint(x: 150, y: 100)),
                .quadCurve(to: CGPoint(x: 200, y: 200), control: CGPoint(x: 230, y: 170)),
                .quadCurve(to: CGPoint(x: 100, y: 200), control: CGPoint(x: 150, y: 240)),
                .quadCurve(to: CGPoint(x: 100, y: 140), control: CGPoint(x: 70, y: 170)),
                .close
            ]),
            region("lb_tail", "Tail", [
                .moveTo(x: 100, y: 185),
                .quadCurve(to: CGPoint(x: 40, y: 230), control: CGPoint(x: 60, y: 200)),
                .lineTo(x: 25, y: 260), .lineTo(x: 50, y: 250), .lineTo(x: 45, y: 270),
                .lineTo(x: 70, y: 255), .lineTo(x: 65, y: 275),
                .lineTo(x: 90, y: 255),
                .quadCurve(to: CGPoint(x: 110, y: 210), control: CGPoint(x: 100, y: 240)),
                .close
            ]),
            region("lb_claw_l", "Left Claw", [
                .moveTo(x: 120, y: 140),
                .lineTo(x: 80, y: 90), .lineTo(x: 50, y: 60),
                .quadCurve(to: CGPoint(x: 30, y: 80), control: CGPoint(x: 25, y: 55)),
                .quadCurve(to: CGPoint(x: 60, y: 95), control: CGPoint(x: 35, y: 100)),
                .lineTo(x: 50, y: 70),
                .quadCurve(to: CGPoint(x: 75, y: 100), control: CGPoint(x: 65, y: 75)),
                .lineTo(x: 105, y: 135), .close
            ]),
            region("lb_claw_r", "Right Claw", [
                .moveTo(x: 180, y: 140),
                .lineTo(x: 220, y: 90), .lineTo(x: 250, y: 60),
                .quadCurve(to: CGPoint(x: 270, y: 80), control: CGPoint(x: 275, y: 55)),
                .quadCurve(to: CGPoint(x: 240, y: 95), control: CGPoint(x: 265, y: 100)),
                .lineTo(x: 250, y: 70),
                .quadCurve(to: CGPoint(x: 225, y: 100), control: CGPoint(x: 235, y: 75)),
                .lineTo(x: 195, y: 135), .close
            ]),
            region("lb_ant_l", "Left Antenna", [
                .moveTo(x: 130, y: 130),
                .quadCurve(to: CGPoint(x: 90, y: 40), control: CGPoint(x: 100, y: 80)),
                .lineTo(x: 95, y: 42),
                .quadCurve(to: CGPoint(x: 135, y: 132), control: CGPoint(x: 108, y: 82)),
                .close
            ]),
            region("lb_ant_r", "Right Antenna", [
                .moveTo(x: 170, y: 130),
                .quadCurve(to: CGPoint(x: 210, y: 40), control: CGPoint(x: 200, y: 80)),
                .lineTo(x: 205, y: 42),
                .quadCurve(to: CGPoint(x: 165, y: 132), control: CGPoint(x: 192, y: 82)),
                .close
            ]),
            region("lb_legs_l", "Left Legs", [
                .moveTo(x: 105, y: 170), .lineTo(x: 60, y: 190),
                .lineTo(x: 62, y: 195), .lineTo(x: 105, y: 178),
                .lineTo(x: 105, y: 185), .lineTo(x: 65, y: 210),
                .lineTo(x: 67, y: 215), .lineTo(x: 108, y: 195),
                .close
            ]),
            region("lb_legs_r", "Right Legs", [
                .moveTo(x: 195, y: 170), .lineTo(x: 240, y: 190),
                .lineTo(x: 238, y: 195), .lineTo(x: 195, y: 178),
                .lineTo(x: 195, y: 185), .lineTo(x: 235, y: 210),
                .lineTo(x: 233, y: 215), .lineTo(x: 192, y: 195),
                .close
            ]),
            region("lb_eyes", "Eyes", [
                .moveTo(x: 135, y: 135),
                .arc(center: CGPoint(x: 135, y: 130), radius: 6, startAngle: 0, endAngle: 360, clockwise: false),
                .moveTo(x: 165, y: 135),
                .arc(center: CGPoint(x: 165, y: 130), radius: 6, startAngle: 0, endAngle: 360, clockwise: false),
                .close
            ]),
        ])
    }

    // MARK: Seashell Collection
    static func seashell() -> ColoringPage {
        ColoringPage(id: "seashell", name: "Seashells", icon: "fossil.shell", regions: [
            region("sh_spiral_outer", "Spiral Shell Outer", [
                .moveTo(x: 80, y: 100),
                .quadCurve(to: CGPoint(x: 160, y: 100), control: CGPoint(x: 120, y: 50)),
                .quadCurve(to: CGPoint(x: 160, y: 180), control: CGPoint(x: 200, y: 130)),
                .quadCurve(to: CGPoint(x: 80, y: 180), control: CGPoint(x: 120, y: 220)),
                .quadCurve(to: CGPoint(x: 80, y: 100), control: CGPoint(x: 40, y: 130)),
                .close
            ]),
            region("sh_spiral_inner", "Spiral Shell Inner", [
                .moveTo(x: 105, y: 120),
                .quadCurve(to: CGPoint(x: 145, y: 120), control: CGPoint(x: 125, y: 100)),
                .quadCurve(to: CGPoint(x: 145, y: 160), control: CGPoint(x: 165, y: 135)),
                .quadCurve(to: CGPoint(x: 105, y: 160), control: CGPoint(x: 125, y: 180)),
                .quadCurve(to: CGPoint(x: 105, y: 120), control: CGPoint(x: 85, y: 135)),
                .close
            ]),
            region("sh_scallop", "Scallop Shell", [
                .moveTo(x: 210, y: 180),
                .quadCurve(to: CGPoint(x: 240, y: 120), control: CGPoint(x: 210, y: 140)),
                .quadCurve(to: CGPoint(x: 270, y: 120), control: CGPoint(x: 255, y: 100)),
                .quadCurve(to: CGPoint(x: 290, y: 180), control: CGPoint(x: 290, y: 140)),
                .lineTo(x: 210, y: 180), .close
            ]),
            region("sh_conch", "Conch Shell", [
                .moveTo(x: 30, y: 220),
                .quadCurve(to: CGPoint(x: 90, y: 210), control: CGPoint(x: 60, y: 195)),
                .quadCurve(to: CGPoint(x: 110, y: 250), control: CGPoint(x: 115, y: 220)),
                .quadCurve(to: CGPoint(x: 70, y: 280), control: CGPoint(x: 105, y: 275)),
                .quadCurve(to: CGPoint(x: 30, y: 250), control: CGPoint(x: 40, y: 280)),
                .quadCurve(to: CGPoint(x: 30, y: 220), control: CGPoint(x: 20, y: 230)),
                .close
            ]),
            region("sh_dollar_outer", "Sand Dollar", [
                .moveTo(x: 200, y: 240),
                .arc(center: CGPoint(x: 200, y: 260), radius: 30, startAngle: 0, endAngle: 360, clockwise: false),
                .close
            ]),
            region("sh_dollar_inner", "Sand Dollar Center", [
                .moveTo(x: 200, y: 250),
                .arc(center: CGPoint(x: 200, y: 260), radius: 12, startAngle: 0, endAngle: 360, clockwise: false),
                .close
            ]),
            region("sh_tiny1", "Tiny Shell", [
                .moveTo(x: 150, y: 230),
                .quadCurve(to: CGPoint(x: 170, y: 230), control: CGPoint(x: 160, y: 215)),
                .quadCurve(to: CGPoint(x: 170, y: 260), control: CGPoint(x: 180, y: 245)),
                .quadCurve(to: CGPoint(x: 150, y: 260), control: CGPoint(x: 160, y: 270)),
                .quadCurve(to: CGPoint(x: 150, y: 230), control: CGPoint(x: 140, y: 245)),
                .close
            ]),
            region("sh_sand", "Sandy Beach", [
                .moveTo(x: 0, y: 280), .lineTo(x: 300, y: 280),
                .lineTo(x: 300, y: 300), .lineTo(x: 0, y: 300), .close
            ]),
        ])
    }

    // MARK: Starfish
    static func starfish() -> ColoringPage {
        let cx: CGFloat = 150, cy: CGFloat = 150
        let outerR: CGFloat = 110, innerR: CGFloat = 45
        var armRegions: [ColorRegion] = []
        for i in 0..<5 {
            let angle1 = (Double(i) * 72.0 - 90.0) * .pi / 180
            let angle2 = (Double(i) * 72.0 - 90.0 + 36.0) * .pi / 180
            let angle3 = (Double(i) * 72.0 - 90.0 + 72.0) * .pi / 180
            let tipX = cx + outerR * CGFloat(cos(angle1))
            let tipY = cy + outerR * CGFloat(sin(angle1))
            let innerX1 = cx + innerR * CGFloat(cos(angle2))
            let innerY1 = cy + innerR * CGFloat(sin(angle2))
            let nextTipX = cx + outerR * CGFloat(cos(angle3))
            let nextTipY = cy + outerR * CGFloat(sin(angle3))
            armRegions.append(region("sf_arm\(i)", "Arm \(i+1)", [
                .moveTo(x: cx, y: cy),
                .lineTo(x: tipX, y: tipY),
                .lineTo(x: innerX1, y: innerY1),
                .close
            ]))
            armRegions.append(region("sf_wedge\(i)", "Wedge \(i+1)", [
                .moveTo(x: innerX1, y: innerY1),
                .lineTo(x: tipX, y: tipY),
                .lineTo(x: nextTipX, y: nextTipY),
                .close
            ]))
        }
        // Center circle
        armRegions.append(region("sf_center", "Center", [
            .moveTo(x: cx + 20, y: cy),
            .arc(center: CGPoint(x: cx, y: cy), radius: 20,
                 startAngle: 0, endAngle: 360, clockwise: false),
            .close
        ]))
        return ColoringPage(id: "starfish", name: "Starfish", icon: "star", regions: armRegions)
    }

    // MARK: Sailboat

    static func sailboat() -> ColoringPage {
        ColoringPage(id: "sailboat", name: "Sailboat", icon: "sailboat", regions: [
            region("sb_sky", "Sky", [
                .moveTo(x: 0, y: 0), .lineTo(x: 300, y: 0),
                .lineTo(x: 300, y: 180), .lineTo(x: 0, y: 180), .close
            ]),
            region("sb_water", "Water", [
                .moveTo(x: 0, y: 180),
                .quadCurve(to: CGPoint(x: 100, y: 190), control: CGPoint(x: 50, y: 170)),
                .quadCurve(to: CGPoint(x: 200, y: 185), control: CGPoint(x: 150, y: 200)),
                .quadCurve(to: CGPoint(x: 300, y: 190), control: CGPoint(x: 250, y: 175)),
                .lineTo(x: 300, y: 300), .lineTo(x: 0, y: 300), .close
            ]),
            region("sb_hull", "Hull", [
                .moveTo(x: 80, y: 210), .lineTo(x: 230, y: 210),
                .lineTo(x: 210, y: 250), .lineTo(x: 100, y: 250), .close
            ]),
            region("sb_mainsail", "Main Sail", [
                .moveTo(x: 155, y: 60), .lineTo(x: 155, y: 210),
                .lineTo(x: 230, y: 195), .close
            ]),
            region("sb_jib", "Jib Sail", [
                .moveTo(x: 150, y: 60), .lineTo(x: 150, y: 195),
                .lineTo(x: 85, y: 195), .close
            ]),
            region("sb_mast", "Mast", [
                .moveTo(x: 148, y: 50), .lineTo(x: 157, y: 50),
                .lineTo(x: 157, y: 215), .lineTo(x: 148, y: 215), .close
            ]),
            region("sb_flag", "Flag", [
                .moveTo(x: 157, y: 50), .lineTo(x: 185, y: 55),
                .lineTo(x: 157, y: 65), .close
            ]),
            region("sb_sun", "Sun", [
                .moveTo(x: 60, y: 50),
                .arc(center: CGPoint(x: 50, y: 50), radius: 25,
                     startAngle: 0, endAngle: 360, clockwise: false),
                .close
            ]),
            region("sb_cloud", "Cloud", [
                .moveTo(x: 200, y: 50),
                .quadCurve(to: CGPoint(x: 220, y: 30), control: CGPoint(x: 200, y: 30)),
                .quadCurve(to: CGPoint(x: 250, y: 30), control: CGPoint(x: 235, y: 15)),
                .quadCurve(to: CGPoint(x: 270, y: 50), control: CGPoint(x: 270, y: 30)),
                .quadCurve(to: CGPoint(x: 250, y: 60), control: CGPoint(x: 275, y: 60)),
                .quadCurve(to: CGPoint(x: 200, y: 60), control: CGPoint(x: 220, y: 70)),
                .quadCurve(to: CGPoint(x: 200, y: 50), control: CGPoint(x: 190, y: 55)),
                .close
            ]),
        ])
    }

    // MARK: - Helper

    private static func region(_ id: String, _ label: String, _ commands: [PathCommand]) -> ColorRegion {
        ColorRegion(id: id, label: label, pathData: PathData(commands: commands))
    }

    // MARK: - All Pages

    static var allPages: [ColoringPage] {
        [lighthouse(), lobster(), seashell(), starfish(), sailboat()]
    }
}
