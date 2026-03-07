import SwiftUI

/// Animated splash screen with lighthouse beam sweeping effect.
/// Displays briefly on app launch before transitioning to main content.
struct SplashScreenView: View {
    @State private var beamAngle: Double = -30
    @State private var beamOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var isFinished = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var onComplete: () -> Void

    var body: some View {
        ZStack {
            // Background gradient (deep navy to ocean)
            LinearGradient(
                colors: [
                    Color.capeCod.deepNavy,
                    Color.capeCod.oceanBlue.opacity(0.8),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: CodSpacing.xl) {
                Spacer()

                // Lighthouse + beam
                ZStack {
                    // Beam of light
                    beamShape
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.capeCod.sandbarYellow.opacity(0.6),
                                    Color.capeCod.sandbarYellow.opacity(0),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 200, height: 300)
                        .rotationEffect(.degrees(beamAngle), anchor: .bottom)
                        .opacity(beamOpacity)

                    // Lighthouse icon
                    Image(systemName: "light.beacon.max.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.capeCod.shellWhite, Color.capeCod.sand],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                // App name
                VStack(spacing: CodSpacing.sm) {
                    Text("Hey Cape Cod")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Your AI Travel Companion")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.capeCod.sand.opacity(0.8))
                }
                .opacity(titleOpacity)
                .offset(y: titleOffset)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            if reduceMotion {
                // Skip animation, show immediately
                beamOpacity = 0.5
                titleOpacity = 1
                titleOffset = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onComplete()
                }
            } else {
                startAnimation()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Hey Cape Cod, Your AI Travel Companion, loading")
    }

    // MARK: - Beam Shape

    private var beamShape: some Shape {
        Triangle()
    }

    // MARK: - Animation

    private func startAnimation() {
        // Fade in beam
        withAnimation(.easeIn(duration: 0.4)) {
            beamOpacity = 0.5
        }

        // Sweep beam left to right
        withAnimation(.easeInOut(duration: 1.5).delay(0.3)) {
            beamAngle = 30
        }

        // Fade in title
        withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
            titleOpacity = 1
            titleOffset = 0
        }

        // Complete after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                onComplete()
            }
        }
    }
}

// MARK: - Triangle Shape (beam)

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - 10, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + 10, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    SplashScreenView { }
}
