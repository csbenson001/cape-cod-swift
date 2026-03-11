import SwiftUI

// MARK: - Coloring Canvas View

struct ColoringCanvasView: View {
    @Binding var page: ColoringPage
    @Binding var selectedColorHex: String?
    @Binding var isErasing: Bool
    @Binding var undoStack: [ColoringAction]

    @State private var canvasSize: CGSize = .zero
    @State private var lastTappedRegion: String?

    var body: some View {
        GeometryReader { geo in
            let size = fitSize(in: geo.size)
            ZStack {
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))

                Canvas { context, canvasDrawSize in
                    drawRegions(context: context, size: size)
                } symbols: {
                    EmptyView()
                }
                .frame(width: size.width, height: size.height)
                .overlay {
                    regionTapOverlay(size: size)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear { canvasSize = geo.size }
        }
    }

    // MARK: - Drawing

    private func drawRegions(context: GraphicsContext, size: CGSize) {
        for region in page.regions {
            let path = region.pathData.buildPath(in: size)

            // Fill
            if let fillColor = region.fillColor {
                context.fill(path, with: .color(fillColor))
            } else {
                context.fill(path, with: .color(.white))
            }

            // Stroke outline
            context.stroke(
                path,
                with: .color(.black.opacity(0.7)),
                lineWidth: 1.5
            )
        }
    }

    // MARK: - Tap Overlay

    private func regionTapOverlay(size: CGSize) -> some View {
        ZStack {
            ForEach(page.regions) { region in
                regionButton(for: region, size: size)
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func regionButton(for region: ColorRegion, size: CGSize) -> some View {
        let path = region.pathData.buildPath(in: size)
        return path
            .fill(Color.clear)
            .contentShape(path)
            .onTapGesture {
                handleTap(regionId: region.id)
            }
    }

    // MARK: - Tap Handling

    private func handleTap(regionId: String) {
        guard let index = page.regions.firstIndex(where: { $0.id == regionId }) else { return }

        let previousColor = page.regions[index].fillColorHex
        undoStack.append(ColoringAction(regionId: regionId, previousColor: previousColor))

        if isErasing {
            page.regions[index].fillColorHex = nil
        } else if let hex = selectedColorHex {
            page.regions[index].fillColorHex = hex
        }

        lastTappedRegion = regionId
        CodHaptic.light()

        withAnimation(CodAnimation.quick) {
            lastTappedRegion = nil
        }
    }

    // MARK: - Layout

    private func fitSize(in available: CGSize) -> CGSize {
        let aspect: CGFloat = 1.0 // 300x300 source
        let padding: CGFloat = CodSpacing.md
        let maxW = available.width - padding * 2
        let maxH = available.height - padding * 2
        if maxW / aspect <= maxH {
            return CGSize(width: maxW, height: maxW / aspect)
        } else {
            return CGSize(width: maxH * aspect, height: maxH)
        }
    }
}

// MARK: - Color Palette Bar

struct ColorPaletteBar: View {
    @Binding var selectedHex: String?
    @Binding var isErasing: Bool

    @State private var bounceId: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                ForEach(kidColorPalette) { kc in
                    colorCircle(kc)
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.vertical, CodSpacing.sm)
        }
    }

    private func colorCircle(_ kc: KidColor) -> some View {
        let isSelected = !isErasing && selectedHex == kc.hex
        return Button {
            isErasing = false
            selectedHex = kc.hex
            bounceId = kc.id
            CodHaptic.selection()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                bounceId = nil
            }
        } label: {
            Circle()
                .fill(kc.color)
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .strokeBorder(kc.id == "white" ? Color.gray.opacity(0.4) : Color.clear, lineWidth: 1)
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color.capeCod.oceanBlue, lineWidth: isSelected ? 3 : 0)
                        .frame(width: 44, height: 44)
                )
                .scaleEffect(bounceId == kc.id ? 1.25 : 1.0)
                .animation(CodAnimation.spring, value: bounceId)
        }
        .accessibilityLabel(kc.name)
    }
}

// MARK: - Toolbar Row

struct ColoringToolbar: View {
    let onUndo: () -> Void
    let onClear: () -> Void
    let onSave: () -> Void
    let onShare: () -> Void
    @Binding var isErasing: Bool

    var body: some View {
        HStack(spacing: CodSpacing.lg) {
            toolButton(icon: "eraser", label: "Eraser", active: isErasing) {
                isErasing.toggle()
                CodHaptic.selection()
            }
            toolButton(icon: "arrow.uturn.backward", label: "Undo", active: false, action: onUndo)
            toolButton(icon: "trash", label: "Clear", active: false, action: onClear)

            Spacer()

            toolButton(icon: "square.and.arrow.down", label: "Save", active: false, action: onSave)
            toolButton(icon: "square.and.arrow.up", label: "Share", active: false, action: onShare)
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.vertical, CodSpacing.xs)
    }

    private func toolButton(icon: String, label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(active ? Color.capeCod.oceanBlue : Color.capeCod.textSecondary)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(active ? Color.capeCod.oceanBlue : Color.capeCod.textSecondary)
            }
        }
        .accessibilityLabel(label)
    }
}

// MARK: - Snapshot Renderer

@MainActor
func renderColoringPage(_ page: ColoringPage, size: CGSize) -> UIImage? {
    let renderer = ImageRenderer(
        content: SnapshotCanvas(page: page, size: size)
    )
    renderer.scale = UIScreen.main.scale
    return renderer.uiImage
}

private struct SnapshotCanvas: View {
    let page: ColoringPage
    let size: CGSize

    var body: some View {
        Canvas { context, drawSize in
            for region in page.regions {
                let path = region.pathData.buildPath(in: drawSize)
                if let fillColor = region.fillColor {
                    context.fill(path, with: .color(fillColor))
                } else {
                    context.fill(path, with: .color(.white))
                }
                context.stroke(path, with: .color(.black.opacity(0.7)), lineWidth: 1.5)
            }
        }
        .frame(width: size.width, height: size.height)
        .background(Color.white)
    }
}
