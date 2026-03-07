import SwiftUI

// MARK: - Favorite Button

/// Heart/favorite button with bouncy scale animation and haptic feedback.
struct FavoriteButton: View {
    @Binding var isFavorited: Bool

    var body: some View {
        Button {
            withAnimation(CodAnimation.bouncy) {
                isFavorited.toggle()
            }
            UIImpactFeedbackGenerator(style: isFavorited ? .medium : .light).impactOccurred()
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .font(.system(size: CodSpacing.screenEdge, weight: .medium))
                .foregroundStyle(isFavorited ? Color.capeCod.cranberry : Color.capeCod.driftwood)
                .scaleEffect(isFavorited ? 1.0 : 0.9)
                .frame(width: 44, height: 44)
                .contentTransition(.symbolEffect(.replace))
        }
    }
}

// MARK: - Cape Cod Toggle Style

/// Custom toggle style with Cape Cod colors — Ocean Blue when on, Driftwood when off.
struct CodToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Capsule()
                .fill(configuration.isOn ? Color.capeCod.oceanBlue : Color.capeCod.driftwood.opacity(0.3))
                .frame(width: 50, height: 30)
                .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                    Circle()
                        .fill(.white)
                        .frame(width: 26, height: 26)
                        .padding(2)
                        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                }
                .onTapGesture {
                    withAnimation(CodAnimation.quick) {
                        configuration.isOn.toggle()
                    }
                    UISelectionFeedbackGenerator().selectionChanged()
                }
        }
    }
}

extension ToggleStyle where Self == CodToggleStyle {
    static var capeCod: CodToggleStyle { CodToggleStyle() }
}

// MARK: - Segmented Control with Sliding Pill

/// Custom segmented control with a sliding pill indicator instead of the default style.
struct CodSegmentedControl: View {
    let options: [String]
    @Binding var selection: Int
    @Namespace private var pillAnimation

    var body: some View {
        HStack(spacing: CodSpacing.xs) {
            ForEach(options.indices, id: \.self) { index in
                Button {
                    withAnimation(CodAnimation.quick) {
                        selection = index
                    }
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    Text(options[index])
                        .codTextStyle(.cardTitle)
                        .foregroundStyle(selection == index ? Color.capeCod.textOnPrimary : Color.capeCod.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, CodSpacing.sm + 2)
                        .background {
                            if selection == index {
                                Capsule()
                                    .fill(Color.capeCod.primary)
                                    .matchedGeometryEffect(id: "pill", in: pillAnimation)
                            }
                        }
                }
            }
        }
        .padding(CodSpacing.xs)
        .background(Color.capeCod.surface, in: Capsule())
    }
}

// MARK: - Image Placeholder (Blurred Gradient)

/// Placeholder for loading images — shows a blurred gradient in the category color.
struct ImagePlaceholder: View {
    let categoryColor: Color
    var aspectRatio: CGFloat = 16.0 / 9.0

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [categoryColor.opacity(0.3), categoryColor.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(aspectRatio, contentMode: .fill)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: CodSpacing.lg))
                    .foregroundStyle(categoryColor.opacity(0.4))
            )
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }
}

// MARK: - Preview

#Preview("Micro-Interactions") {
    MicroInteractionsPreview()
}

private struct MicroInteractionsPreview: View {
    @State private var isFavorited = false
    @State private var isToggled = true
    @State private var isToggled2 = false
    @State private var segmentIndex = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CodSpacing.sectionSpacing) {
                Text("Micro-Interactions").codTextStyle(.heroTitle)

                // Favorite button
                VStack(alignment: .leading, spacing: CodSpacing.md) {
                    Text("FAVORITE BUTTON").codTextStyle(.label)
                    HStack(spacing: CodSpacing.lg) {
                        FavoriteButton(isFavorited: $isFavorited)
                        Text(isFavorited ? "Saved to favorites" : "Tap to favorite")
                            .codTextStyle(.body)
                    }
                }

                // Toggle
                VStack(alignment: .leading, spacing: CodSpacing.md) {
                    Text("CUSTOM TOGGLE").codTextStyle(.label)
                    Toggle("Notifications", isOn: $isToggled)
                        .toggleStyle(.capeCod)
                        .codTextStyle(.body)
                    Toggle("Dark Mode", isOn: $isToggled2)
                        .toggleStyle(.capeCod)
                        .codTextStyle(.body)
                }

                // Segmented control
                VStack(alignment: .leading, spacing: CodSpacing.md) {
                    Text("SEGMENTED CONTROL").codTextStyle(.label)
                    CodSegmentedControl(
                        options: ["All", "Beaches", "Historic", "Nature"],
                        selection: $segmentIndex
                    )
                }

                // Image placeholder
                VStack(alignment: .leading, spacing: CodSpacing.md) {
                    Text("IMAGE PLACEHOLDERS").codTextStyle(.label)
                    HStack(spacing: CodSpacing.md) {
                        ImagePlaceholder(categoryColor: Color.capeCod.oceanBlue)
                            .frame(height: 120)
                        ImagePlaceholder(categoryColor: Color.capeCod.duneGrass, aspectRatio: 1)
                            .frame(width: 100, height: 100)
                    }
                }

                // Stagger demo
                VStack(alignment: .leading, spacing: CodSpacing.md) {
                    Text("STAGGER ANIMATION").codTextStyle(.label)
                    ForEach(0..<4) { i in
                        CodCard(size: .standard) {
                            CodCardContent(
                                title: ["Nauset Beach", "Coast Guard Beach", "Marconi Beach", "Race Point"][i],
                                metadata: "\(i + 1).2 mi away"
                            )
                        }
                        .staggered(index: i)
                    }
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.xxl)
        }
        .background(Color.capeCod.background)
    }
}
