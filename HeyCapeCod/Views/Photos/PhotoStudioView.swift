import SwiftUI
import PhotosUI

// MARK: - Photo Studio Data Models

/// Cape Cod themed photo frame styles
enum PhotoFrame: String, CaseIterable, Identifiable {
    case none
    case beachVibes
    case goldenHour
    case nautical
    case lobsterFest
    case pirateAdventure
    case sharkWeek
    case seashell
    case capeCodClassic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "None"
        case .beachVibes: return "Beach Vibes"
        case .goldenHour: return "Golden Hour"
        case .nautical: return "Nautical"
        case .lobsterFest: return "Lobster Fest"
        case .pirateAdventure: return "Pirate Adventure"
        case .sharkWeek: return "Shark Week"
        case .seashell: return "Seashell"
        case .capeCodClassic: return "Cape Cod Classic"
        }
    }

    var icon: String {
        switch self {
        case .none: return "photo"
        case .beachVibes: return "water.waves"
        case .goldenHour: return "sunset.fill"
        case .nautical: return "anchor.circle.fill"
        case .lobsterFest: return "flame.fill"
        case .pirateAdventure: return "flag.fill"
        case .sharkWeek: return "tropicalstorm"
        case .seashell: return "sparkles"
        case .capeCodClassic: return "square.fill"
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .none: return 0
        case .capeCodClassic: return 12
        default: return 10
        }
    }
}

/// Color filter presets for photos
enum PhotoFilter: String, CaseIterable, Identifiable {
    case normal
    case warmSunset
    case coolOcean
    case vintagePostcard
    case dramaticStorm

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .warmSunset: return "Warm Sunset"
        case .coolOcean: return "Cool Ocean"
        case .vintagePostcard: return "Vintage"
        case .dramaticStorm: return "Storm"
        }
    }

    var icon: String {
        switch self {
        case .normal: return "circle"
        case .warmSunset: return "sun.max.fill"
        case .coolOcean: return "snowflake"
        case .vintagePostcard: return "camera.filters"
        case .dramaticStorm: return "cloud.bolt.fill"
        }
    }
}

/// A draggable sticker that can be placed on the photo
struct PhotoSticker: Identifiable {
    let id = UUID()
    let content: String
    let label: String
    var position: CGSize = .zero
    var scale: CGFloat = 1.0

    static let available: [(String, String)] = [
        ("building.columns.fill", "Lighthouse"),
        ("pawprint.fill", "Seal"),
        ("water.waves", "Whale Tail"),
        ("fish.fill", "Lobster"),
        ("leaf.fill", "Cranberry"),
        ("tropicalstorm", "Shark Fin"),
        ("bird.fill", "Seagull"),
        ("snowflake", "Ice Cream"),
        ("figure.walk", "Flip Flops"),
        ("building.2.fill", "Sandcastle"),
        ("star.fill", "Starfish"),
        ("anchor.circle.fill", "Anchor"),
        ("sailboat.fill", "Sailboat"),
        ("tortoise.fill", "Crab"),
        ("circle.hexagongrid.fill", "Shell"),
    ]
}

// MARK: - Photo Studio View Model

@Observable
final class PhotoStudioViewModel {
    var selectedPhoto: UIImage?
    var photoPickerItem: PhotosPickerItem?
    var selectedFrame: PhotoFrame = .none
    var selectedFilter: PhotoFilter = .normal
    var stickers: [PhotoSticker] = []
    var showWatermark = true
    var watermarkYear = Calendar.current.component(.year, from: Date())

    var isShowingCamera = false
    var isShowingSourcePicker = false
    var isExporting = false
    var exportedImage: UIImage?
    var showSaveSuccess = false
    var showSaveError = false

    var activeEditTab: EditTab = .frames

    enum EditTab: String, CaseIterable {
        case frames = "Frames"
        case stickers = "Stickers"
        case filters = "Filters"
        case stamp = "Stamp"

        var icon: String {
            switch self {
            case .frames: return "rectangle.on.rectangle"
            case .stickers: return "star.circle.fill"
            case .filters: return "camera.filters"
            case .stamp: return "textformat"
            }
        }
    }

    func loadPhoto() async {
        guard let item = photoPickerItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            selectedPhoto = image
        }
    }

    func addSticker(content: String, label: String) {
        let sticker = PhotoSticker(
            content: content,
            label: label,
            position: CGSize(
                width: CGFloat.random(in: -40...40),
                height: CGFloat.random(in: -40...40)
            )
        )
        stickers.append(sticker)
    }

    func removeSticker(_ sticker: PhotoSticker) {
        stickers.removeAll { $0.id == sticker.id }
    }

    func updateStickerPosition(_ sticker: PhotoSticker, offset: CGSize) {
        guard let index = stickers.firstIndex(where: { $0.id == sticker.id }) else { return }
        stickers[index].position = offset
    }

    func updateStickerScale(_ sticker: PhotoSticker, scale: CGFloat) {
        guard let index = stickers.firstIndex(where: { $0.id == sticker.id }) else { return }
        stickers[index].scale = max(0.5, min(3.0, scale))
    }

    func clearAll() {
        stickers.removeAll()
        selectedFrame = .none
        selectedFilter = .normal
        showWatermark = true
    }

    @MainActor
    func renderImage(size: CGSize) -> UIImage? {
        let renderer = ImageRenderer(content:
            PhotoCanvasView(viewModel: self, canvasSize: size)
                .frame(width: size.width, height: size.height)
        )
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }

    @MainActor
    func saveToPhotoLibrary(size: CGSize) {
        guard let image = renderImage(size: size) else {
            showSaveError = true
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showSaveSuccess = true
    }
}

// MARK: - Photo Studio View

struct PhotoStudioView: View {
    @State private var viewModel = PhotoStudioViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.capeCod.background
                    .ignoresSafeArea()

                if viewModel.selectedPhoto != nil {
                    editorView
                } else {
                    photoPickerLanding
                }
            }
            .navigationTitle("Photo Studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.capeCod.textSecondary)
                    }
                }

                if viewModel.selectedPhoto != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                viewModel.selectedPhoto = nil
                                viewModel.clearAll()
                            } label: {
                                Label("New Photo", systemImage: "photo.badge.plus")
                            }

                            Button(role: .destructive) {
                                viewModel.clearAll()
                            } label: {
                                Label("Reset Edits", systemImage: "arrow.counterclockwise")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.capeCod.oceanBlue)
                        }
                    }
                }
            }
            .onChange(of: viewModel.photoPickerItem) { _, _ in
                Task { await viewModel.loadPhoto() }
            }
            .fullScreenCover(isPresented: $viewModel.isShowingCamera) {
                CameraPickerView(image: $viewModel.selectedPhoto)
                    .ignoresSafeArea()
            }
            .alert("Saved!", isPresented: $viewModel.showSaveSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your Cape Cod photo has been saved to your library.")
            }
            .alert("Save Failed", isPresented: $viewModel.showSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Unable to save. Please check your photo library permissions.")
            }
        }
    }

    // MARK: - Photo Picker Landing

    private var photoPickerLanding: some View {
        VStack(spacing: CodSpacing.sectionSpacing) {
            Spacer()

            // Hero icon
            VStack(spacing: CodSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.capeCod.oceanBlue.opacity(0.12))
                        .frame(width: 100, height: 100)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color.capeCod.oceanGradient)
                }
                .staggered(index: 0)

                Text("Cape Cod Photo Studio")
                    .codTextStyle(.heroTitle)
                    .multilineTextAlignment(.center)
                    .staggered(index: 1)

                Text("Add frames, stickers, and filters\nto your Cape Cod memories")
                    .codTextStyle(.subtitle)
                    .multilineTextAlignment(.center)
                    .staggered(index: 2)
            }

            // Pick buttons
            VStack(spacing: CodSpacing.md) {
                PhotosPicker(
                    selection: $viewModel.photoPickerItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack(spacing: CodSpacing.sm) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Choose from Library")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 52)
                    .foregroundStyle(Color.capeCod.textOnPrimary)
                    .background(Color.capeCod.oceanBlue)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                }
                .buttonStyle(CodButtonPressStyle(variant: .primary))
                .staggered(index: 3)

                Button {
                    viewModel.isShowingCamera = true
                } label: {
                    HStack(spacing: CodSpacing.sm) {
                        Image(systemName: "camera")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Take a Photo")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 52)
                    .foregroundStyle(Color.capeCod.oceanBlue)
                    .background(Color.capeCod.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous)
                            .strokeBorder(Color.capeCod.oceanBlue.opacity(0.3), lineWidth: 1.5)
                    )
                }
                .buttonStyle(CodButtonPressStyle(variant: .secondary))
                .staggered(index: 4)
            }
            .padding(.horizontal, CodSpacing.xl)

            Spacer()

            // Branding footer
            Text("Hey Cape Cod")
                .codTextStyle(.caption)
                .staggered(index: 5)
                .padding(.bottom, CodSpacing.lg)
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Editor View

    private var editorView: some View {
        VStack(spacing: 0) {
            // Photo canvas
            GeometryReader { geometry in
                let canvasSize = CGSize(
                    width: geometry.size.width - CodSpacing.screenEdge * 2,
                    height: geometry.size.height
                )

                ScrollView(.init()) {
                    photoCanvas(canvasSize: canvasSize)
                        .frame(width: canvasSize.width, height: canvasSize.height)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.vertical, CodSpacing.sm)

            Divider()
                .foregroundStyle(Color.capeCod.cardBorder)

            // Edit tabs
            editTabBar

            // Edit panel content
            editPanel
                .frame(height: 140)
                .padding(.bottom, CodSpacing.sm)

            // Action buttons
            actionBar
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.bottom, CodSpacing.md)
        }
    }

    // MARK: - Photo Canvas

    @ViewBuilder
    private func photoCanvas(canvasSize: CGSize) -> some View {
        if let photo = viewModel.selectedPhoto {
            ZStack {
                // Photo with filter
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .modifier(PhotoFilterModifier(filter: viewModel.selectedFilter))
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))

                // Frame overlay
                if viewModel.selectedFrame != .none {
                    PhotoFrameOverlay(frame: viewModel.selectedFrame, size: canvasSize)
                        .allowsHitTesting(false)
                }

                // Stickers
                ForEach(viewModel.stickers) { sticker in
                    DraggableStickerView(
                        sticker: sticker,
                        onPositionChange: { offset in
                            viewModel.updateStickerPosition(sticker, offset: offset)
                        },
                        onScaleChange: { scale in
                            viewModel.updateStickerScale(sticker, scale: scale)
                        },
                        onRemove: {
                            withAnimation(CodAnimation.quick) {
                                viewModel.removeSticker(sticker)
                            }
                            CodHaptic.light()
                        }
                    )
                }

                // Watermark
                if viewModel.showWatermark {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Cape Cod \(String(viewModel.watermarkYear))")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                                .padding(.horizontal, CodSpacing.sm)
                                .padding(.vertical, CodSpacing.xs)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
                                .padding(CodSpacing.sm)
                        }
                    }
                    .allowsHitTesting(false)
                }

                // Hey Cape Cod branding (always visible)
                VStack {
                    HStack {
                        Text("Hey Cape Cod")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                            .padding(.horizontal, CodSpacing.xs + 2)
                            .padding(.vertical, 2)
                            .background(.black.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
                            .padding(CodSpacing.sm)
                        Spacer()
                    }
                    Spacer()
                }
                .allowsHitTesting(false)
            }
        }
    }

    // MARK: - Edit Tab Bar

    private var editTabBar: some View {
        HStack(spacing: 0) {
            ForEach(PhotoStudioViewModel.EditTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(CodAnimation.quick) {
                        viewModel.activeEditTab = tab
                    }
                    CodHaptic.selection()
                } label: {
                    VStack(spacing: CodSpacing.xs) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .semibold))
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, CodSpacing.sm)
                    .foregroundStyle(
                        viewModel.activeEditTab == tab
                            ? Color.capeCod.oceanBlue
                            : Color.capeCod.textSecondary
                    )
                    .background(
                        viewModel.activeEditTab == tab
                            ? Color.capeCod.oceanBlue.opacity(0.1)
                            : Color.clear
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color.capeCod.surface)
    }

    // MARK: - Edit Panels

    private var editPanel: some View {
        Group {
            switch viewModel.activeEditTab {
            case .frames:
                framesPanel
            case .stickers:
                stickersPanel
            case .filters:
                filtersPanel
            case .stamp:
                stampPanel
            }
        }
    }

    private var framesPanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                ForEach(Array(PhotoFrame.allCases.enumerated()), id: \.element.id) { index, frame in
                    Button {
                        withAnimation(CodAnimation.spring) {
                            viewModel.selectedFrame = frame
                        }
                        CodHaptic.selection()
                    } label: {
                        VStack(spacing: CodSpacing.xs) {
                            ZStack {
                                RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous)
                                    .fill(Color.capeCod.surface)
                                    .frame(width: 64, height: 64)

                                if frame != .none {
                                    framePreviewThumbnail(frame)
                                        .frame(width: 56, height: 56)
                                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
                                }

                                Image(systemName: frame.icon)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(
                                        viewModel.selectedFrame == frame
                                            ? Color.capeCod.oceanBlue
                                            : Color.capeCod.textSecondary
                                    )
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous)
                                    .strokeBorder(
                                        viewModel.selectedFrame == frame
                                            ? Color.capeCod.oceanBlue
                                            : Color.clear,
                                        lineWidth: 2.5
                                    )
                            )

                            Text(frame.displayName)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(
                                    viewModel.selectedFrame == frame
                                        ? Color.capeCod.oceanBlue
                                        : Color.capeCod.textSecondary
                                )
                                .lineLimit(1)
                        }
                        .staggered(index: index)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.vertical, CodSpacing.sm)
        }
    }

    private var stickersPanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                ForEach(Array(PhotoSticker.available.enumerated()), id: \.offset) { index, item in
                    Button {
                        withAnimation(CodAnimation.bouncy) {
                            viewModel.addSticker(content: item.0, label: item.1)
                        }
                        CodHaptic.tap()
                    } label: {
                        VStack(spacing: CodSpacing.xs) {
                            ZStack {
                                Circle()
                                    .fill(Color.capeCod.surface)
                                    .frame(width: 52, height: 52)

                                Image(systemName: item.0)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundStyle(Color.capeCod.oceanBlue)
                            }

                            Text(item.1)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(Color.capeCod.textSecondary)
                                .lineLimit(1)
                        }
                        .staggered(index: index)
                    }
                    .buttonStyle(StickerPressStyle())
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.vertical, CodSpacing.sm)
        }
    }

    private var filtersPanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                ForEach(Array(PhotoFilter.allCases.enumerated()), id: \.element.id) { index, filter in
                    Button {
                        withAnimation(CodAnimation.spring) {
                            viewModel.selectedFilter = filter
                        }
                        CodHaptic.selection()
                    } label: {
                        VStack(spacing: CodSpacing.xs) {
                            ZStack {
                                RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous)
                                    .fill(filterPreviewColor(filter))
                                    .frame(width: 64, height: 64)

                                if let photo = viewModel.selectedPhoto {
                                    Image(uiImage: photo)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 64, height: 64)
                                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
                                        .modifier(PhotoFilterModifier(filter: filter))
                                }

                                Image(systemName: filter.icon)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous)
                                    .strokeBorder(
                                        viewModel.selectedFilter == filter
                                            ? Color.capeCod.oceanBlue
                                            : Color.clear,
                                        lineWidth: 2.5
                                    )
                            )

                            Text(filter.displayName)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(
                                    viewModel.selectedFilter == filter
                                        ? Color.capeCod.oceanBlue
                                        : Color.capeCod.textSecondary
                                )
                        }
                        .staggered(index: index)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.vertical, CodSpacing.sm)
        }
    }

    private var stampPanel: some View {
        VStack(spacing: CodSpacing.md) {
            Toggle(isOn: $viewModel.showWatermark) {
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: "textformat")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.capeCod.oceanBlue)
                    Text("Cape Cod \(String(viewModel.watermarkYear))")
                        .codTextStyle(.cardTitle)
                }
            }
            .tint(Color.capeCod.oceanBlue)
            .onChange(of: viewModel.showWatermark) { _, _ in
                CodHaptic.selection()
            }

            if viewModel.showWatermark {
                HStack(spacing: CodSpacing.md) {
                    Text("Year")
                        .codTextStyle(.caption)

                    Stepper(
                        value: $viewModel.watermarkYear,
                        in: 2000...2099
                    ) {
                        Text(String(viewModel.watermarkYear))
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.capeCod.textPrimary)
                    }
                }
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.vertical, CodSpacing.sm)
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: CodSpacing.sm) {
            // Save to library
            Button {
                let size = CGSize(width: 1080, height: 1080)
                viewModel.saveToPhotoLibrary(size: size)
                CodHaptic.success()
            } label: {
                HStack(spacing: CodSpacing.xs) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Save")
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .foregroundStyle(Color.capeCod.oceanBlue)
                .background(Color.capeCod.surface)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous)
                        .strokeBorder(Color.capeCod.oceanBlue.opacity(0.3), lineWidth: 1.5)
                )
            }
            .buttonStyle(CodButtonPressStyle(variant: .secondary))

            // Share
            if let rendered = viewModel.renderImage(size: CGSize(width: 1080, height: 1080)),
               let data = rendered.pngData(),
               let shareImage = UIImage(data: data) {
                ShareLink(
                    item: Image(uiImage: shareImage),
                    preview: SharePreview(
                        "My Cape Cod Photo",
                        image: Image(uiImage: shareImage)
                    )
                ) {
                    HStack(spacing: CodSpacing.xs) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Share")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .foregroundStyle(Color.capeCod.textOnPrimary)
                    .background(Color.capeCod.sunsetOrange)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                }
                .buttonStyle(CodButtonPressStyle(variant: .accent))
            } else {
                // Fallback share button when image isn't ready yet
                Button {
                    CodHaptic.light()
                } label: {
                    HStack(spacing: CodSpacing.xs) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Share")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .foregroundStyle(Color.capeCod.textOnPrimary)
                    .background(Color.capeCod.sunsetOrange)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
                }
                .buttonStyle(CodButtonPressStyle(variant: .accent))
            }
        }
    }

    // MARK: - Helpers

    private func filterPreviewColor(_ filter: PhotoFilter) -> Color {
        switch filter {
        case .normal: return Color.capeCod.fog
        case .warmSunset: return Color.capeCod.sunsetOrange.opacity(0.3)
        case .coolOcean: return Color.capeCod.oceanBlue.opacity(0.3)
        case .vintagePostcard: return Color.capeCod.sand
        case .dramaticStorm: return Color.capeCod.deepNavy.opacity(0.4)
        }
    }

    @ViewBuilder
    private func framePreviewThumbnail(_ frame: PhotoFrame) -> some View {
        RoundedRectangle(cornerRadius: CodRadius.sm - 2, style: .continuous)
            .strokeBorder(framePreviewGradient(frame), lineWidth: 3)
    }

    private func framePreviewGradient(_ frame: PhotoFrame) -> some ShapeStyle {
        switch frame {
        case .beachVibes:
            return AnyShapeStyle(Color.capeCod.oceanGradient)
        case .goldenHour:
            return AnyShapeStyle(Color.capeCod.sunsetGradient)
        case .nautical:
            return AnyShapeStyle(Color.capeCod.deepNavy)
        case .lobsterFest:
            return AnyShapeStyle(Color.capeCod.cranberry)
        case .pirateAdventure:
            return AnyShapeStyle(Color.capeCod.deepNavy)
        case .sharkWeek:
            return AnyShapeStyle(Color.capeCod.oceanBlue)
        case .seashell:
            return AnyShapeStyle(Color.capeCod.seafoam)
        case .capeCodClassic:
            return AnyShapeStyle(Color.capeCod.driftwood)
        case .none:
            return AnyShapeStyle(Color.clear)
        }
    }
}

// MARK: - Photo Canvas View (for rendering export)

/// A standalone canvas view used for ImageRenderer export.
struct PhotoCanvasView: View {
    let viewModel: PhotoStudioViewModel
    let canvasSize: CGSize

    var body: some View {
        ZStack {
            Color.capeCod.background

            if let photo = viewModel.selectedPhoto {
                ZStack {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                        .modifier(PhotoFilterModifier(filter: viewModel.selectedFilter))
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))

                    if viewModel.selectedFrame != .none {
                        PhotoFrameOverlay(frame: viewModel.selectedFrame, size: canvasSize)
                    }

                    ForEach(viewModel.stickers) { sticker in
                        Image(systemName: sticker.content)
                            .font(.system(size: 36 * sticker.scale, weight: .bold))
                            .foregroundStyle(Color.capeCod.oceanBlue)
                            .shadow(color: .white.opacity(0.8), radius: 2, x: 0, y: 1)
                            .offset(sticker.position)
                    }

                    if viewModel.showWatermark {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("Cape Cod \(String(viewModel.watermarkYear))")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                                    .padding(.horizontal, CodSpacing.sm)
                                    .padding(.vertical, CodSpacing.xs)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
                                    .padding(CodSpacing.sm)
                            }
                        }
                    }

                    // Branding
                    VStack {
                        HStack {
                            Text("Hey Cape Cod")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                                .padding(.horizontal, CodSpacing.xs + 2)
                                .padding(.vertical, 2)
                                .background(.black.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
                                .padding(CodSpacing.sm)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .padding(CodSpacing.md)
            }
        }
    }
}

// MARK: - Photo Frame Overlay

struct PhotoFrameOverlay: View {
    let frame: PhotoFrame
    let size: CGSize

    var body: some View {
        switch frame {
        case .none:
            EmptyView()

        case .beachVibes:
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.capeCod.oceanBlue,
                            Color.capeCod.seafoam,
                            Color.capeCod.oceanBlue.opacity(0.6),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: frame.borderWidth
                )
                .overlay(beachWaveAccents)

        case .goldenHour:
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.capeCod.sunsetOrange,
                            Color.capeCod.sandbarYellow,
                            Color.capeCod.sunsetOrange.opacity(0.8),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: frame.borderWidth
                )

        case .nautical:
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .strokeBorder(Color.capeCod.deepNavy, lineWidth: frame.borderWidth)
                .overlay(nauticalAccents)

        case .lobsterFest:
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.capeCod.cranberry,
                            Color.capeCod.lobsterRed,
                            Color.capeCod.cranberry,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: frame.borderWidth
                )
                .overlay(lobsterAccents)

        case .pirateAdventure:
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.capeCod.deepNavy,
                            Color(hex: 0x2C1810),
                            Color.capeCod.deepNavy,
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: frame.borderWidth
                )
                .overlay(pirateAccents)

        case .sharkWeek:
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.capeCod.deepNavy,
                            Color.capeCod.oceanBlue,
                            Color.capeCod.deepNavy,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: frame.borderWidth
                )
                .overlay(sharkAccents)

        case .seashell:
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.capeCod.seafoam.opacity(0.6),
                            Color.capeCod.sand,
                            Color.capeCod.seafoam.opacity(0.6),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: frame.borderWidth
                )
                .overlay(seashellAccents)

        case .capeCodClassic:
            ZStack {
                RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                    .strokeBorder(Color.capeCod.driftwood, lineWidth: frame.borderWidth)

                // "Cape Cod" text at the bottom
                VStack {
                    Spacer()
                    Text("CAPE COD")
                        .font(.system(size: 12, weight: .black, design: .serif))
                        .tracking(4)
                        .foregroundStyle(Color.capeCod.driftwood)
                        .padding(.horizontal, CodSpacing.md)
                        .padding(.vertical, CodSpacing.xs)
                        .background(Color.capeCod.background.opacity(0.9))
                        .offset(y: frame.borderWidth / 2)
                }
            }
        }
    }

    // MARK: - Frame Accent Views

    private var beachWaveAccents: some View {
        ZStack {
            // Wave icons at corners
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "water.waves")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .offset(x: -6, y: 6)
                }
                Spacer()
                HStack {
                    Image(systemName: "water.waves")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.capeCod.seafoam)
                        .offset(x: 6, y: -6)
                    Spacer()
                }
            }
        }
    }

    private var nauticalAccents: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "anchor.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.capeCod.deepNavy)
                        .background(Circle().fill(Color.capeCod.background).frame(width: 18, height: 18))
                        .offset(x: -2, y: -2)
                    Spacer()
                    Image(systemName: "circle.circle")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.capeCod.deepNavy)
                        .offset(x: 2, y: -2)
                }
                Spacer()
                HStack {
                    Image(systemName: "circle.circle")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.capeCod.deepNavy)
                        .offset(x: -2, y: 2)
                    Spacer()
                    Image(systemName: "anchor.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.capeCod.deepNavy)
                        .background(Circle().fill(Color.capeCod.background).frame(width: 18, height: 18))
                        .offset(x: 2, y: 2)
                }
            }
        }
    }

    private var lobsterAccents: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Text("🦞")
                        .font(.system(size: 16))
                        .offset(x: -4, y: -2)
                }
                Spacer()
                HStack {
                    Text("🦞")
                        .font(.system(size: 16))
                        .scaleEffect(x: -1, y: 1)
                        .offset(x: 4, y: 2)
                    Spacer()
                }
            }
        }
    }

    private var pirateAccents: some View {
        ZStack {
            VStack {
                HStack {
                    Text("🏴‍☠️")
                        .font(.system(size: 14))
                        .offset(x: -2, y: -2)
                    Spacer()
                    Image(systemName: "flag.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.capeCod.sandbarYellow)
                        .offset(x: 2, y: -2)
                }
                Spacer()
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.capeCod.sandbarYellow)
                        .offset(x: -2, y: 2)
                    Spacer()
                    Text("🏴‍☠️")
                        .font(.system(size: 14))
                        .offset(x: 2, y: 2)
                }
            }
        }
    }

    private var sharkAccents: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "tropicalstorm")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .offset(x: 4, y: -4)
                    Spacer()
                    Text("🦈")
                        .font(.system(size: 16))
                        .offset(x: -4, y: -4)
                }
            }
        }
    }

    private var seashellAccents: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "sparkle")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.capeCod.seafoam)
                        .offset(x: 2, y: 2)
                    Spacer()
                    Image(systemName: "sparkle")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.capeCod.sand)
                        .offset(x: -4, y: 4)
                }
                Spacer()
                HStack {
                    Image(systemName: "sparkle")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.capeCod.sand)
                        .offset(x: 4, y: -4)
                    Spacer()
                    Image(systemName: "sparkle")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.capeCod.seafoam)
                        .offset(x: -2, y: -2)
                }
            }
        }
    }
}

// MARK: - Photo Filter Modifier

struct PhotoFilterModifier: ViewModifier {
    let filter: PhotoFilter

    func body(content: Content) -> some View {
        switch filter {
        case .normal:
            content

        case .warmSunset:
            content
                .saturation(1.2)
                .contrast(1.05)
                .overlay(
                    Color.capeCod.sunsetOrange.opacity(0.15)
                        .blendMode(.overlay)
                        .allowsHitTesting(false)
                )

        case .coolOcean:
            content
                .saturation(1.1)
                .contrast(1.05)
                .overlay(
                    Color.capeCod.oceanBlue.opacity(0.12)
                        .blendMode(.overlay)
                        .allowsHitTesting(false)
                )

        case .vintagePostcard:
            content
                .saturation(0.7)
                .contrast(1.1)
                .overlay(
                    Color.capeCod.sand.opacity(0.2)
                        .blendMode(.overlay)
                        .allowsHitTesting(false)
                )

        case .dramaticStorm:
            content
                .saturation(0.5)
                .contrast(1.3)
                .overlay(
                    Color.capeCod.deepNavy.opacity(0.15)
                        .blendMode(.overlay)
                        .allowsHitTesting(false)
                )
        }
    }
}

// MARK: - Draggable Sticker View

struct DraggableStickerView: View {
    let sticker: PhotoSticker
    let onPositionChange: (CGSize) -> Void
    let onScaleChange: (CGFloat) -> Void
    let onRemove: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var isSelected = false

    var body: some View {
        Image(systemName: sticker.content)
            .font(.system(size: 36 * sticker.scale * currentScale, weight: .bold))
            .foregroundStyle(Color.capeCod.oceanBlue)
            .shadow(color: .white.opacity(0.8), radius: 2, x: 0, y: 1)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Button {
                        onRemove()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.capeCod.cranberry)
                            .background(Circle().fill(Color.capeCod.background).frame(width: 16, height: 16))
                    }
                    .offset(x: 8, y: -8)
                    .transition(.codScale)
                }
            }
            .offset(
                x: sticker.position.width + dragOffset.width,
                y: sticker.position.height + dragOffset.height
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                        if !isSelected {
                            withAnimation(CodAnimation.quick) {
                                isSelected = true
                            }
                        }
                    }
                    .onEnded { value in
                        let newPosition = CGSize(
                            width: sticker.position.width + value.translation.width,
                            height: sticker.position.height + value.translation.height
                        )
                        onPositionChange(newPosition)
                        dragOffset = .zero
                        CodHaptic.light()
                    }
            )
            .simultaneousGesture(
                MagnifyGesture()
                    .onChanged { value in
                        currentScale = value.magnification
                    }
                    .onEnded { value in
                        onScaleChange(sticker.scale * value.magnification)
                        currentScale = 1.0
                    }
            )
            .onTapGesture {
                withAnimation(CodAnimation.quick) {
                    isSelected.toggle()
                }
                CodHaptic.selection()
            }
    }
}

// MARK: - Sticker Press Style

private struct StickerPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.capeCodQuick, value: configuration.isPressed)
    }
}

// MARK: - Camera Picker (UIKit bridge)

struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView

        init(_ parent: CameraPickerView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Previews

#Preview("Photo Studio - Landing") {
    PhotoStudioView()
}

#Preview("Photo Studio - With Photo") {
    PhotoStudioView()
}
