import SwiftUI

// MARK: - Bubble Particles

/// Subtle floating bubble/particle animation for the voice assistant background.
/// Creates an underwater/coastal atmosphere.
struct BubbleParticles: View {
    @State private var bubbles: [Bubble] = (0..<15).map { _ in Bubble.random() }

    var body: some View {
        GeometryReader { geometry in
            ForEach(bubbles) { bubble in
                Circle()
                    .fill(bubble.color)
                    .frame(width: bubble.size, height: bubble.size)
                    .position(bubble.position(in: geometry.size))
                    .opacity(bubble.opacity)
                    .blur(radius: bubble.size * 0.3)
            }
        }
        .onAppear {
            for i in bubbles.indices {
                withAnimation(
                    .easeInOut(duration: bubbles[i].duration)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.2)
                ) {
                    bubbles[i].isAnimating = true
                }
            }
        }
    }
}

private struct Bubble: Identifiable {
    let id = UUID()
    let relativeX: CGFloat
    let relativeStartY: CGFloat
    let relativeEndY: CGFloat
    let size: CGFloat
    let opacity: Double
    let duration: Double
    let color: Color
    var isAnimating = false

    func position(in containerSize: CGSize) -> CGPoint {
        CGPoint(
            x: relativeX * containerSize.width,
            y: (isAnimating ? relativeEndY : relativeStartY) * containerSize.height
        )
    }

    static func random() -> Bubble {
        let colors: [Color] = [
            Color.capeCod.seafoam.opacity(0.15),
            Color.capeCod.oceanBlue.opacity(0.1),
            Color.capeCod.sand.opacity(0.08),
        ]
        return Bubble(
            relativeX: CGFloat.random(in: 0.05...0.95),
            relativeStartY: CGFloat.random(in: 0.6...0.95),
            relativeEndY: CGFloat.random(in: 0.05...0.4),
            size: CGFloat.random(in: 8...40),
            opacity: Double.random(in: 0.3...0.7),
            duration: Double.random(in: 4...8),
            color: colors.randomElement() ?? Color.capeCod.seafoam.opacity(0.15)
        )
    }
}

// MARK: - Lighthouse Beam Sweep

/// Splash screen animation — a rotating lighthouse beam that sweeps across the screen.
struct LighthouseBeamSweep: View {
    @State private var beamAngle: Angle = .degrees(-30)
    @State private var beamOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // Background
            Color.capeCod.deepNavy
                .ignoresSafeArea()

            // Lighthouse beam
            Triangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.capeCod.sandbarYellow.opacity(0.5),
                            Color.capeCod.sandbarYellow.opacity(0.0),
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 200, height: 500)
                .rotationEffect(beamAngle, anchor: .bottom)
                .offset(y: -100)
                .opacity(beamOpacity)
                .blur(radius: 20)

            // App title
            VStack(spacing: CodSpacing.sm) {
                Image(systemName: "lighthouse.fill")
                    .font(.system(size: CodSpacing.xxl, weight: .light))
                    .foregroundStyle(Color.capeCod.sandbarYellow)

                Text("Hey Cape Cod")
                    .codTextStyle(.heroTitle)
                    .foregroundStyle(Color.capeCod.shellWhite)

                Text("Your Cape Cod Companion")
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.driftwood)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.8)) {
                beamOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                beamAngle = .degrees(30)
            }
        }
    }
}

/// Triangle shape for lighthouse beam.
private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.closeSubpath()
        }
    }
}

// MARK: - Weather Condition Gradient

/// Background gradient that reflects current weather conditions.
struct WeatherGradient: View {
    let condition: WeatherCondition

    var body: some View {
        LinearGradient(
            colors: condition.gradientColors,
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

enum WeatherCondition {
    case sunny, cloudy, rainy, foggy, sunset, clear

    var gradientColors: [Color] {
        switch self {
        case .sunny:
            return [Color(hex: 0x4BA3C7), Color(hex: 0x7EC8B8), Color.capeCod.shellWhite]
        case .cloudy:
            return [Color(hex: 0x8899A6), Color(hex: 0xB0BEC5), Color.capeCod.fog]
        case .rainy:
            return [Color(hex: 0x546E7A), Color(hex: 0x78909C), Color.capeCod.fog]
        case .foggy:
            return [Color(hex: 0xB0BEC5), Color(hex: 0xCFD8DC), Color.capeCod.fog]
        case .sunset:
            return [Color(hex: 0xE87040), Color(hex: 0xE8B94E), Color.capeCod.shellWhite]
        case .clear:
            return [Color(hex: 0x0D2137), Color(hex: 0x1A6B8A), Color(hex: 0x162233)]
        }
    }
}

// MARK: - Previews

#Preview("Bubble Particles") {
    ZStack {
        Color.capeCod.background
        BubbleParticles()
    }
    .ignoresSafeArea()
}

#Preview("Lighthouse Splash") {
    LighthouseBeamSweep()
}

#Preview("Weather Gradients") {
    ScrollView(.horizontal) {
        HStack(spacing: 0) {
            ForEach(
                [WeatherCondition.sunny, .cloudy, .rainy, .sunset, .clear],
                id: \.self
            ) { condition in
                WeatherGradient(condition: condition)
                    .frame(width: 200, height: 400)
                    .overlay(alignment: .bottom) {
                        Text("\(condition)")
                            .codTextStyle(.cardTitle)
                            .foregroundStyle(.white)
                            .padding()
                    }
            }
        }
    }
}

extension WeatherCondition: Hashable {}
