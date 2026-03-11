import SwiftUI

/// Screen 1: Welcome hero with gradient background, branding, and feature highlights.
struct OnboardingWelcomePage: View {
    @State private var waveOffset: CGFloat = 0
    @State private var lighthouseGlow = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.capeCod.deepNavy,
                    Color.capeCod.oceanBlue,
                    Color.capeCod.seafoam.opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Decorative wave at bottom
            waveDecoration
                .offset(y: UIScreen.main.bounds.height * 0.32)

            VStack(spacing: CodSpacing.xl) {
                Spacer()

                lighthouseIcon

                titleSection

                featureHighlights

                Spacer()
                Spacer()
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
    }

    // MARK: - Lighthouse Icon

    private var lighthouseIcon: some View {
        ZStack {
            // Glow ring
            Circle()
                .fill(Color.capeCod.sunsetOrange.opacity(lighthouseGlow ? 0.25 : 0.1))
                .frame(width: 130, height: 130)
                .animation(CodAnimation.pulse, value: lighthouseGlow)

            Image(systemName: "light.beacon.max.fill")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.capeCod.sunsetOrange, Color.capeCod.sand],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.capeCod.sunsetOrange.opacity(0.4), radius: 12)
        }
        .onAppear { lighthouseGlow = true }
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Text("Welcome to")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))

            Text("Hey Cape Cod")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .tracking(-0.5)
                .foregroundStyle(.white)

            Text("Your AI-powered guide to the best of Cape Cod")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, CodSpacing.lg)
        }
    }

    // MARK: - Feature Highlights

    private var featureHighlights: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            featureRow(icon: "mic.fill", color: Color.capeCod.sunsetOrange,
                       text: "Voice-powered Cape Cod conversations")
                .staggered(index: 0, interval: 0.12)

            featureRow(icon: "location.fill", color: Color.capeCod.seafoam,
                       text: "GPS-triggered stories as you explore")
                .staggered(index: 1, interval: 0.12)

            featureRow(icon: "water.waves", color: .white.opacity(0.9),
                       text: "Live tides, weather & beach conditions")
                .staggered(index: 2, interval: 0.12)

            featureRow(icon: "car.fill", color: Color.capeCod.sand,
                       text: "Real-time bridge & traffic updates")
                .staggered(index: 3, interval: 0.12)
        }
        .padding(CodSpacing.lg)
        .background(.ultraThinMaterial.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }

    private func featureRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: CodSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 28)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    // MARK: - Wave Decoration

    private var waveDecoration: some View {
        Wave(offset: waveOffset)
            .fill(Color.capeCod.background.opacity(0.15))
            .frame(height: 80)
            .onAppear {
                withAnimation(
                    .linear(duration: 4.0).repeatForever(autoreverses: false)
                ) {
                    waveOffset = .pi * 2
                }
            }
    }
}

// MARK: - Wave Shape

private struct Wave: Shape {
    var offset: CGFloat

    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midY = height * 0.5

        path.move(to: CGPoint(x: 0, y: midY))

        for x in stride(from: 0, through: width, by: 2) {
            let relX = x / width
            let y = midY + sin(relX * .pi * 3 + offset) * 12
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }
}

#Preview {
    OnboardingWelcomePage()
}
