import SwiftUI

// MARK: - WaveformView

/// Audio visualization that responds to audio levels.
/// Two styles: `.circular` (for voice button ring) and `.linear` (for story player).
struct WaveformView: View {
    let levels: [CGFloat]
    let style: WaveformStyle
    let color: Color
    let barCount: Int

    init(
        levels: [CGFloat] = [],
        style: WaveformStyle = .linear,
        color: Color = Color.capeCod.seafoam,
        barCount: Int = 40
    ) {
        self.levels = levels
        self.style = style
        self.color = color
        self.barCount = barCount
    }

    var body: some View {
        switch style {
        case .linear:
            linearWaveform
        case .circular(let radius):
            circularWaveform(radius: radius)
        }
    }

    // MARK: - Linear Waveform

    private var linearWaveform: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<barCount, id: \.self) { index in
                let level = normalizedLevel(at: index)
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(color)
                    .frame(width: 3, height: max(3, level * 32))
                    .animation(CodAnimation.waveform, value: level)
            }
        }
        .frame(height: 36)
    }

    // MARK: - Circular Waveform

    private func circularWaveform(radius: CGFloat) -> some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let angleStep = (2 * .pi) / CGFloat(barCount)

            for i in 0..<barCount {
                let level = normalizedLevel(at: i)
                let angle = angleStep * CGFloat(i) - .pi / 2
                let barHeight = max(4, level * 16)
                let innerRadius = radius - 2
                let outerRadius = radius + barHeight

                let innerPoint = CGPoint(
                    x: center.x + innerRadius * cos(angle),
                    y: center.y + innerRadius * sin(angle)
                )
                let outerPoint = CGPoint(
                    x: center.x + outerRadius * cos(angle),
                    y: center.y + outerRadius * sin(angle)
                )

                var path = Path()
                path.move(to: innerPoint)
                path.addLine(to: outerPoint)

                context.stroke(
                    path,
                    with: .color(color),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
            }
        }
        .frame(width: radius * 2 + 40, height: radius * 2 + 40)
    }

    // MARK: - Helpers

    private func normalizedLevel(at index: Int) -> CGFloat {
        guard !levels.isEmpty else { return 0.1 }
        let mappedIndex = index % levels.count
        return min(1.0, max(0.0, levels[mappedIndex]))
    }
}

// MARK: - Waveform Style

enum WaveformStyle {
    case linear
    case circular(radius: CGFloat)
}

// MARK: - Preview

#Preview("Waveform Views") {
    let sampleLevels: [CGFloat] = (0..<40).map { i in
        let x = CGFloat(i) / 40.0
        return 0.3 + 0.7 * abs(sin(x * .pi * 3))
    }

    VStack(spacing: CodSpacing.xl) {
        Text("Linear Waveform").codTextStyle(.sectionTitle)
        WaveformView(
            levels: sampleLevels,
            style: .linear,
            color: Color.capeCod.seafoam
        )

        Text("Circular Waveform").codTextStyle(.sectionTitle)
        WaveformView(
            levels: sampleLevels,
            style: .circular(radius: 50),
            color: Color.capeCod.sunsetOrange
        )
    }
    .padding(CodSpacing.screenEdge)
    .background(Color.capeCod.background)
}
