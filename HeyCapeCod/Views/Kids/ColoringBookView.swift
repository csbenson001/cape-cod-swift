import SwiftUI
import Photos

// MARK: - Coloring Book View

struct ColoringBookView: View {
    @State private var pages: [ColoringPage] = ColoringPages.allPages
    @State private var selectedPageIndex: Int?
    @State private var selectedColorHex: String? = "FF0000"
    @State private var isErasing = false
    @State private var undoStack: [ColoringAction] = []
    @State private var showClearConfirm = false
    @State private var showSaveSuccess = false
    @State private var showGallery = false
    @State private var savedImages: [SavedColoring] = []
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false
    var body: some View {
        NavigationStack {
            Group {
                if let idx = selectedPageIndex {
                    coloringView(pageIndex: idx)
                } else {
                    galleryGrid
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showGallery) { savedGallerySheet }
            .alert("Clear All Colors?", isPresented: $showClearConfirm) {
                Button("Clear", role: .destructive) { clearAllColors() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will remove all coloring from this page.")
            }
            .overlay { saveSuccessOverlay }
            .sheet(isPresented: $showShareSheet) { shareSheet }
        }
        .onAppear { loadProgress() }
    }
    private var navigationTitle: String {
        if let idx = selectedPageIndex {
            return pages[idx].name
        }
        return "Coloring Book"
    }

    // MARK: - Gallery Grid
    private var galleryGrid: some View {
        ScrollView {
            VStack(spacing: CodSpacing.lg) {
                headerSection
                pagesGrid
            }
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background)
    }

    private var headerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.capeCod.oceanBlue)
            Text("Cape Cod Coloring Book")
                .codTextStyle(.sectionTitle)
            Text("Tap a picture to start coloring!")
                .codTextStyle(.body)
        }
        .padding(.top, CodSpacing.lg)
    }

    private var pagesGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: CodSpacing.md
        ) {
            ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                pageCard(page: page, index: index)
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    private func pageCard(page: ColoringPage, index: Int) -> some View {
        Button {
            withAnimation(CodAnimation.spring) {
                selectedPageIndex = index
                undoStack = []
            }
            CodHaptic.tap()
        } label: {
            VStack(spacing: CodSpacing.sm) {
                pagePreview(page: page)
                Text(page.name)
                    .codTextStyle(.cardTitle)
                    .lineLimit(1)
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .staggered(index: index)
    }

    private func pagePreview(page: ColoringPage) -> some View {
        Canvas { context, size in
            for region in page.regions {
                let path = region.pathData.buildPath(in: size)
                if let fill = region.fillColor {
                    context.fill(path, with: .color(fill))
                }
                context.stroke(path, with: .color(.gray.opacity(0.5)), lineWidth: 0.8)
            }
        }
        .frame(height: 120)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
    }

    // MARK: - Coloring View
    private func coloringView(pageIndex: Int) -> some View {
        VStack(spacing: 0) {
            ColoringCanvasView(
                page: $pages[pageIndex],
                selectedColorHex: $selectedColorHex,
                isErasing: $isErasing,
                undoStack: $undoStack
            )

            Divider()

            ColorPaletteBar(selectedHex: $selectedColorHex, isErasing: $isErasing)

            Divider()

            ColoringToolbar(
                onUndo: performUndo,
                onClear: { showClearConfirm = true },
                onSave: saveToPhotos,
                onShare: shareColoring,
                isErasing: $isErasing
            )
        }
        .background(Color.capeCod.surface)
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if selectedPageIndex != nil {
                Button {
                    withAnimation(CodAnimation.spring) {
                        saveProgress()
                        selectedPageIndex = nil
                    }
                } label: {
                    HStack(spacing: CodSpacing.xs) {
                        Image(systemName: "chevron.left")
                        Text("Pages")
                    }
                    .foregroundStyle(Color.capeCod.oceanBlue)
                }
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            if selectedPageIndex == nil {
                Button {
                    loadSavedImages()
                    showGallery = true
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .foregroundStyle(Color.capeCod.oceanBlue)
                }
            }
        }
    }

    // MARK: - Saved Gallery Sheet

    private var savedGallerySheet: some View {
        NavigationStack {
            savedGalleryContent
                .navigationTitle("My Artwork")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { showGallery = false }
                    }
                }
        }
    }

    private var savedGalleryContent: some View {
        Group {
            if savedImages.isEmpty {
                emptyGalleryView
            } else {
                savedImagesList
            }
        }
    }

    private var emptyGalleryView: some View {
        VStack(spacing: CodSpacing.md) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(Color.capeCod.textSecondary)
            Text("No saved artwork yet")
                .codTextStyle(.body)
            Text("Color a picture and tap Save!")
                .codTextStyle(.caption)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var savedImagesList: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CodSpacing.md) {
                ForEach(savedImages) { saved in
                    savedImageCard(saved)
                }
            }
            .padding(CodSpacing.screenEdge)
        }
    }

    private func savedImageCard(_ saved: SavedColoring) -> some View {
        VStack(spacing: CodSpacing.xs) {
            if let img = saved.image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
            }
            Text(saved.pageName)
                .codTextStyle(.caption)
            Text(saved.date, style: .date)
                .codTextStyle(.caption)
        }
        .padding(CodSpacing.sm)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    // MARK: - Save Success Overlay

    @ViewBuilder
    private var saveSuccessOverlay: some View {
        if showSaveSuccess {
            VStack {
                Spacer()
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.capeCod.seafoam)
                    Text("Saved to Photos!")
                        .codTextStyle(.cardTitle)
                }
                .padding(CodSpacing.cardPadding)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .transition(.codScale)
                .padding(.bottom, CodSpacing.xxl)
            }
        }
    }

    // MARK: - Share Sheet

    @ViewBuilder
    private var shareSheet: some View {
        if let image = shareImage {
            ShareSheetView(items: [image])
        }
    }

    // MARK: - Actions

    private func performUndo() {
        guard let action = undoStack.popLast(),
              let pageIdx = selectedPageIndex,
              let regionIdx = pages[pageIdx].regions.firstIndex(where: { $0.id == action.regionId })
        else { return }
        pages[pageIdx].regions[regionIdx].fillColorHex = action.previousColor
        CodHaptic.selection()
    }

    private func clearAllColors() {
        guard let idx = selectedPageIndex else { return }
        for i in pages[idx].regions.indices {
            pages[idx].regions[i].fillColorHex = nil
        }
        undoStack = []
        CodHaptic.tap()
    }

    @MainActor
    private func saveToPhotos() {
        guard let idx = selectedPageIndex else { return }
        let renderSize = CGSize(width: 600, height: 600)
        guard let image = renderColoringPage(pages[idx], size: renderSize) else { return }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else { return }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            DispatchQueue.main.async {
                saveThumbnail(image: image, pageName: pages[idx].name)
                withAnimation(CodAnimation.spring) {
                    showSaveSuccess = true
                }
                CodHaptic.success()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(CodAnimation.gentle) {
                        showSaveSuccess = false
                    }
                }
            }
        }
    }

    @MainActor
    private func shareColoring() {
        guard let idx = selectedPageIndex else { return }
        let renderSize = CGSize(width: 600, height: 600)
        guard let image = renderColoringPage(pages[idx], size: renderSize) else { return }
        shareImage = image
        showShareSheet = true
    }

    // MARK: - Persistence

    private func saveProgress() {
        for page in pages {
            let colors = page.regions.map { $0.fillColorHex ?? "" }
            UserDefaults.standard.set(colors, forKey: "coloring_\(page.id)")
        }
    }

    private func loadProgress() {
        for i in pages.indices {
            guard let colors = UserDefaults.standard.stringArray(forKey: "coloring_\(pages[i].id)") else { continue }
            for j in pages[i].regions.indices where j < colors.count {
                pages[i].regions[j].fillColorHex = colors[j].isEmpty ? nil : colors[j]
            }
        }
    }

    private func saveThumbnail(image: UIImage, pageName: String) {
        let key = "coloring_saved_\(Date().timeIntervalSince1970)"
        guard let data = image.jpegData(compressionQuality: 0.6) else { return }
        let ud = UserDefaults.standard
        ud.set(data, forKey: key)
        var keys = ud.stringArray(forKey: "coloring_saved_keys") ?? []
        keys.append(key)
        ud.set(keys, forKey: "coloring_saved_keys")
        var names = ud.stringArray(forKey: "coloring_saved_names") ?? []
        names.append(pageName)
        ud.set(names, forKey: "coloring_saved_names")
    }

    private func loadSavedImages() {
        let keys = UserDefaults.standard.stringArray(forKey: "coloring_saved_keys") ?? []
        let names = UserDefaults.standard.stringArray(forKey: "coloring_saved_names") ?? []
        savedImages = keys.enumerated().compactMap { idx, key in
            guard let data = UserDefaults.standard.data(forKey: key),
                  let img = UIImage(data: data) else { return nil }
            return SavedColoring(id: key, pageName: idx < names.count ? names[idx] : "Artwork",
                                 date: Date(), image: img)
        }
    }
}

// MARK: - Saved Coloring Model

struct SavedColoring: Identifiable {
    let id: String
    let pageName: String
    let date: Date
    let image: UIImage?
}

// MARK: - Share Sheet UIKit Bridge

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

#Preview {
    ColoringBookView()
}
