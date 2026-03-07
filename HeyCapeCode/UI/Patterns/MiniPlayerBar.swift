import SwiftUI

// MARK: - MiniPlayerBar

/// Persistent bar above the tab bar for story audio playback.
/// Shows story title, play/pause, and progress. Tap to expand, swipe to dismiss.
struct MiniPlayerBar: View {
    let title: String
    let subtitle: String
    let progress: Double
    let isPlaying: Bool
    var onPlayPause: () -> Void
    var onTap: () -> Void
    var onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0
    private let barHeight: CGFloat = 60

    var body: some View {
        HStack(spacing: CodSpacing.md) {
            // Track artwork placeholder
            RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous)
                .fill(Color.capeCod.oceanGradient)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "headphones")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                )

            // Title and subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.capeCod.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.capeCod.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Play/Pause button
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onPlayPause()
            }) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.capeCod.primary)
                    .frame(width: 36, height: 36)
                    .contentTransition(.symbolEffect(.replace))
            }

            // Close / skip button
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onDismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.capeCod.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(Color.capeCod.driftwood.opacity(0.12), in: Circle())
            }
        }
        .padding(.horizontal, CodSpacing.md)
        .frame(height: barHeight)
        .background(
            ZStack(alignment: .bottom) {
                // Blurred background material
                Rectangle()
                    .fill(.ultraThinMaterial)

                // Progress bar at the very bottom
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.capeCod.primary)
                        .frame(width: geometry.size.width * progress, height: 2)
                        .animation(.linear(duration: 0.3), value: progress)
                }
                .frame(height: 2)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
        .codShadow(.elevated)
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Only allow right swipe to dismiss
                    if value.translation.width > 0 {
                        dragOffset = value.translation.width
                    }
                }
                .onEnded { value in
                    if value.translation.width > 100 {
                        withAnimation(CodAnimation.spring) {
                            dragOffset = 400
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onDismiss()
                        }
                    } else {
                        withAnimation(CodAnimation.spring) {
                            dragOffset = 0
                        }
                    }
                }
        )
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - MiniPlayerBar Container

/// Use this modifier to attach a MiniPlayerBar above the tab bar.
/// It handles presentation animation and safe spacing.
struct MiniPlayerModifier: ViewModifier {
    let player: MiniPlayerData?
    var onPlayPause: () -> Void
    var onTap: () -> Void
    var onDismiss: () -> Void

    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .bottom) {
            if let player {
                MiniPlayerBar(
                    title: player.title,
                    subtitle: player.subtitle,
                    progress: player.progress,
                    isPlaying: player.isPlaying,
                    onPlayPause: onPlayPause,
                    onTap: onTap,
                    onDismiss: onDismiss
                )
                .padding(.horizontal, CodSpacing.sm)
                .padding(.bottom, CodSpacing.xs)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(CodAnimation.spring, value: player != nil)
    }
}

// MARK: - Player Data

struct MiniPlayerData: Equatable {
    let title: String
    let subtitle: String
    var progress: Double
    var isPlaying: Bool
}

extension View {
    func miniPlayer(
        _ data: MiniPlayerData?,
        onPlayPause: @escaping () -> Void,
        onTap: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        modifier(MiniPlayerModifier(
            player: data,
            onPlayPause: onPlayPause,
            onTap: onTap,
            onDismiss: onDismiss
        ))
    }
}

// MARK: - Preview

#Preview("Mini Player Bar") {
    MiniPlayerPreview()
}

private struct MiniPlayerPreview: View {
    @State private var isPlaying = true
    @State private var showPlayer = true
    @State private var progress = 0.35

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.lg) {
                    Text("The mini player bar sits above the tab bar, showing current story playback.")
                        .codTextStyle(.body)
                        .padding(.top, CodSpacing.lg)

                    CodButton(showPlayer ? "Hide Player" : "Show Player", variant: .secondary) {
                        withAnimation(CodAnimation.spring) {
                            showPlayer.toggle()
                        }
                    }

                    VStack(spacing: CodSpacing.md) {
                        Text("Progress Control").codTextStyle(.sectionTitle)
                        Slider(value: $progress, in: 0...1)
                            .tint(Color.capeCod.primary)
                    }

                    // Static examples at different states
                    VStack(spacing: CodSpacing.md) {
                        Text("Static Examples").codTextStyle(.sectionTitle)

                        MiniPlayerBar(
                            title: "The Mayflower Story",
                            subtitle: "Chapter 1 of 6",
                            progress: 0.35,
                            isPlaying: true,
                            onPlayPause: {},
                            onTap: {},
                            onDismiss: {}
                        )

                        MiniPlayerBar(
                            title: "Whale Tales of Stellwagen",
                            subtitle: "Nature Stories",
                            progress: 0.72,
                            isPlaying: false,
                            onPlayPause: {},
                            onTap: {},
                            onDismiss: {}
                        )
                    }
                }
                .padding(.horizontal, CodSpacing.screenEdge)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Stories")
        }
        .miniPlayer(
            showPlayer ? MiniPlayerData(
                title: "Secret History of Provincetown",
                subtitle: "Walking Tour  \u{2022}  12 min left",
                progress: progress,
                isPlaying: isPlaying
            ) : nil,
            onPlayPause: { isPlaying.toggle() },
            onTap: {},
            onDismiss: { showPlayer = false }
        )
    }
}
