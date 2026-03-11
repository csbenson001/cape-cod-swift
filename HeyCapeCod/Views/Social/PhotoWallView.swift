import SwiftUI
import PhotosUI

// MARK: - Data Model

struct PhotoWallPost: Identifiable, Codable {
    let id: UUID
    let beachName: String
    let caption: String
    let imagePath: String
    let timestamp: Date
    var likeCount: Int

    init(id: UUID = UUID(), beachName: String, caption: String = "", imagePath: String, timestamp: Date = .now, likeCount: Int = 0) {
        self.id = id
        self.beachName = beachName
        self.caption = caption
        self.imagePath = imagePath
        self.timestamp = timestamp
        self.likeCount = likeCount
    }
}

// MARK: - Storage Manager

@Observable
final class PhotoWallStore {
    private static let metadataKey = "photoWallPosts"

    var posts: [PhotoWallPost] = []

    init() { load() }

    // MARK: Persistence

    func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.metadataKey),
              let decoded = try? JSONDecoder().decode([PhotoWallPost].self, from: data) else { return }
        posts = decoded.sorted { $0.timestamp > $1.timestamp }
    }

    func save() {
        if let data = try? JSONEncoder().encode(posts) {
            UserDefaults.standard.set(data, forKey: Self.metadataKey)
        }
    }

    // MARK: CRUD

    func addPost(beachName: String, caption: String, imageData: Data) {
        let fileName = UUID().uuidString + ".jpg"
        let url = Self.photosDirectory.appendingPathComponent(fileName)
        try? imageData.write(to: url)
        let post = PhotoWallPost(beachName: beachName, caption: caption, imagePath: fileName)
        posts.insert(post, at: 0)
        save()
    }

    func toggleLike(for postID: UUID) {
        guard let idx = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[idx].likeCount += 1
        save()
    }

    func deletePost(_ postID: UUID) {
        guard let idx = posts.firstIndex(where: { $0.id == postID }) else { return }
        let path = posts[idx].imagePath
        let url = Self.photosDirectory.appendingPathComponent(path)
        try? FileManager.default.removeItem(at: url)
        posts.remove(at: idx)
        save()
    }

    func imageURL(for post: PhotoWallPost) -> URL {
        Self.photosDirectory.appendingPathComponent(post.imagePath)
    }

    // MARK: Directory

    static var photosDirectory: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PhotoWall", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
}

// MARK: - Beach List

private let allBeaches: [String] = [
    "Nauset Beach", "Coast Guard Beach", "Skaket Beach", "Marconi Beach",
    "Cahoon Hollow", "White Crest Beach", "Head of the Meadow", "Race Point",
    "Herring Cove", "Chatham Lighthouse Beach", "Old Silver Beach", "Craigville Beach"
]

// MARK: - Main View

struct PhotoWallView: View {
    @State private var store = PhotoWallStore()
    @State private var selectedBeach: String? = nil
    @State private var showPostSheet = false
    @State private var selectedPost: PhotoWallPost? = nil

    private var filteredPosts: [PhotoWallPost] {
        guard let beach = selectedBeach else { return store.posts }
        return store.posts.filter { $0.beachName == beach }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 0) {
                        beachChipBar
                        if filteredPosts.isEmpty {
                            emptyState
                        } else {
                            photoGrid
                        }
                    }
                    .padding(.bottom, CodSpacing.tabBarClearance)
                }
                .background(Color.capeCod.background)

                postFAB
            }
            .navigationTitle("Photo Wall")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPostSheet) {
                NewPostSheet(store: store)
            }
            .fullScreenCover(item: $selectedPost) { post in
                PhotoDetailView(post: post, store: store)
            }
        }
    }

    // MARK: - Beach Chip Bar

    private var beachChipBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CodSpacing.sm) {
                CodChip(
                    "All Beaches",
                    style: .filter,
                    icon: "beach.umbrella",
                    isSelected: selectedBeach == nil
                ) {
                    withAnimation(CodAnimation.quick) { selectedBeach = nil }
                }

                ForEach(allBeaches, id: \.self) { beach in
                    CodChip(
                        beach,
                        style: .filter,
                        isSelected: selectedBeach == beach
                    ) {
                        withAnimation(CodAnimation.quick) {
                            selectedBeach = selectedBeach == beach ? nil : beach
                        }
                    }
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.vertical, CodSpacing.sm)
        }
    }

    // MARK: - Photo Grid

    private var photoGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: CodSpacing.xs), count: 3)

        return LazyVGrid(columns: columns, spacing: CodSpacing.xs) {
            ForEach(filteredPosts) { post in
                PhotoGridCell(post: post, store: store) {
                    selectedPost = post
                }
                .staggered(index: filteredPosts.firstIndex(where: { $0.id == post.id }) ?? 0)
            }
        }
        .padding(.horizontal, CodSpacing.xs)
        .padding(.top, CodSpacing.sm)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: CodSpacing.lg) {
            Spacer().frame(height: CodSpacing.xl)
            starterCards
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    private var starterCards: some View {
        let beaches = selectedBeach.map { [$0] } ?? ["Nauset Beach", "Coast Guard Beach", "Marconi Beach"]
        let prompts: [String: String] = [
            "Nauset Beach": "Golden cliffs meeting the Atlantic — share your Nauset moment!",
            "Coast Guard Beach": "Where the Outer Cape begins. Capture the panoramic dunes!",
            "Skaket Beach": "Chase the sunset across the flats at low tide.",
            "Marconi Beach": "Dramatic bluffs and endless surf. Be the first to post!",
            "Cahoon Hollow": "Barefoot beach vibes and golden hour glow await.",
            "White Crest Beach": "Surfer's paradise — show us those waves!",
            "Head of the Meadow": "Quiet beauty and wildflower trails. Share the serenity.",
            "Race Point": "Where whales breach and dunes stretch forever.",
            "Herring Cove": "Cape Cod's favorite sunset spot. Capture the magic!",
            "Chatham Lighthouse Beach": "Seals, lighthouse, and classic Cape Cod charm.",
            "Old Silver Beach": "Warm bay waters and family memories.",
            "Craigville Beach": "The heart of the mid-Cape beach scene."
        ]

        return VStack(spacing: CodSpacing.md) {
            ForEach(beaches, id: \.self) { beach in
                StarterCard(
                    beachName: beach,
                    prompt: prompts[beach] ?? "Be the first to share a photo from \(beach)!"
                ) {
                    showPostSheet = true
                }
            }
        }
    }

    // MARK: - FAB

    private var postFAB: some View {
        Button {
            CodHaptic.tap()
            showPostSheet = true
        } label: {
            Image(systemName: "camera.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.capeCod.textOnPrimary)
                .frame(width: 60, height: 60)
                .background(Color.capeCod.oceanBlue)
                .clipShape(Circle())
                .codShadow(.elevated)
        }
        .buttonStyle(CodButtonPressStyle(variant: .primary))
        .padding(.trailing, CodSpacing.screenEdge)
        .padding(.bottom, CodSpacing.tabBarClearance + CodSpacing.md)
        .codAccessibleButton("Post a photo", hint: "Opens camera roll to share a beach photo")
    }
}

// MARK: - Grid Cell

private struct PhotoGridCell: View {
    let post: PhotoWallPost
    let store: PhotoWallStore
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                postImage
                overlayBar
            }
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.chip, style: .continuous))
        }
        .buttonStyle(CodCardButtonStyle())
        .aspectRatio(1, contentMode: .fill)
    }

    private var postImage: some View {
        Group {
            if let uiImage = loadImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.capeCod.seafoam.opacity(0.3))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(Color.capeCod.driftwood)
                    }
            }
        }
    }

    private var overlayBar: some View {
        HStack(spacing: CodSpacing.xs) {
            Text(post.beachName.components(separatedBy: " ").first ?? post.beachName)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer(minLength: 0)

            Image(systemName: "heart.fill")
                .font(.system(size: 8))
                .foregroundStyle(Color.capeCod.cranberry)
            Text("\(post.likeCount)")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, CodSpacing.xs + 2)
        .padding(.vertical, CodSpacing.xs)
        .background(.ultraThinMaterial)
    }

    private func loadImage() -> UIImage? {
        let url = store.imageURL(for: post)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}

// MARK: - Starter Card

private struct StarterCard: View {
    let beachName: String
    let prompt: String
    let onPost: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "camera.on.rectangle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.capeCod.oceanBlue)
                Text(beachName)
                    .codTextStyle(.cardTitle)
            }

            Text(prompt)
                .codTextStyle(.body)

            CodButton("Share a Photo", variant: .secondary, icon: "plus.circle") {
                onPost()
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }
}

// MARK: - New Post Sheet

private struct NewPostSheet: View {
    let store: PhotoWallStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var selectedBeach: String = allBeaches[0]
    @State private var caption: String = ""
    @State private var isPosting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.lg) {
                    photoPicker
                    beachSelector
                    captionField
                    postButton
                }
                .padding(CodSpacing.screenEdge)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Post a Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.capeCod.oceanBlue)
                }
            }
        }
    }

    // MARK: Photo Picker

    private var photoPicker: some View {
        VStack(spacing: CodSpacing.sm) {
            if let data = selectedImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            } else {
                photoPickerPlaceholder
            }

            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text(selectedImageData == nil ? "Choose from Camera Roll" : "Change Photo")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.capeCod.oceanBlue)
            }
            .onChange(of: selectedItem) { _, newItem in
                Task { await loadImage(from: newItem) }
            }
        }
    }

    private var photoPickerPlaceholder: some View {
        RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
            .fill(Color.capeCod.surface)
            .frame(height: 200)
            .overlay {
                VStack(spacing: CodSpacing.sm) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 40, weight: .light))
                        .foregroundStyle(Color.capeCod.driftwood)
                    Text("Select a beach photo")
                        .codTextStyle(.caption)
                }
            }
    }

    // MARK: Beach Selector

    private var beachSelector: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("BEACH").codTextStyle(.label)

            Menu {
                ForEach(allBeaches, id: \.self) { beach in
                    Button(beach) { selectedBeach = beach }
                }
            } label: {
                HStack {
                    Text(selectedBeach)
                        .codTextStyle(.body)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.capeCod.textSecondary)
                }
                .padding(CodSpacing.cardPadding)
                .background(Color.capeCod.surface)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
            }
        }
    }

    // MARK: Caption

    private var captionField: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("CAPTION (OPTIONAL)").codTextStyle(.label)

            TextField("What's the vibe?", text: $caption, axis: .vertical)
                .lineLimit(3...6)
                .codTextStyle(.body)
                .padding(CodSpacing.cardPadding)
                .background(Color.capeCod.surface)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
        }
    }

    // MARK: Post Button

    private var postButton: some View {
        CodButton("Post to Photo Wall", variant: .primary, icon: "paperplane.fill", isFullWidth: true) {
            postPhoto()
        }
        .opacity(selectedImageData == nil ? 0.5 : 1.0)
        .disabled(selectedImageData == nil || isPosting)
        .padding(.top, CodSpacing.sm)
    }

    // MARK: Helpers

    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            // Compress for storage
            if let uiImage = UIImage(data: data),
               let compressed = uiImage.jpegData(compressionQuality: 0.7) {
                selectedImageData = compressed
            } else {
                selectedImageData = data
            }
        }
    }

    private func postPhoto() {
        guard let imageData = selectedImageData else { return }
        isPosting = true
        store.addPost(beachName: selectedBeach, caption: caption, imageData: imageData)
        CodHaptic.success()
        dismiss()
    }
}

// MARK: - Photo Detail View (Full-Screen)

private struct PhotoDetailView: View {
    let post: PhotoWallPost
    let store: PhotoWallStore
    @Environment(\.dismiss) private var dismiss
    @State private var heartScale: CGFloat = 1.0
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                toolbar
                Spacer()
                photoContent
                Spacer()
                bottomBar
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let uiImage = loadImage() {
                PhotoWallShareSheet(items: [uiImage])
            }
        }
        .statusBarHidden()
    }

    // MARK: Toolbar

    private var toolbar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: Circle())
            }
            Spacer()
        }
        .padding(.horizontal, CodSpacing.screenEdge)
        .padding(.top, CodSpacing.sm)
    }

    // MARK: Photo + Info

    private var photoContent: some View {
        VStack(spacing: CodSpacing.md) {
            if let uiImage = loadImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
                    .padding(.horizontal, CodSpacing.sm)
            }

            VStack(spacing: CodSpacing.xs) {
                Text(post.beachName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)

                if !post.caption.isEmpty {
                    Text(post.caption)
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, CodSpacing.xl)
                }

                Text(post.timestamp.timeAgoDisplay())
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    // MARK: Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: CodSpacing.xl) {
            // Like button
            Button {
                store.toggleLike(for: post.id)
                CodHaptic.tap()
                withAnimation(CodAnimation.bouncy) {
                    heartScale = 1.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(CodAnimation.bouncy) {
                        heartScale = 1.0
                    }
                }
            } label: {
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.capeCod.cranberry)
                        .scaleEffect(heartScale)
                    Text("\(post.likeCount)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }

            // Share button
            Button {
                CodHaptic.selection()
                showShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }
        }
        .padding(.bottom, CodSpacing.xl)
    }

    private func loadImage() -> UIImage? {
        let url = store.imageURL(for: post)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}

// MARK: - Share Sheet (UIKit bridge)

private struct PhotoWallShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Time Ago Helper

private extension Date {
    func timeAgoDisplay() -> String {
        let seconds = Int(-timeIntervalSinceNow)
        if seconds < 60 { return "Just now" }
        let minutes = seconds / 60
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        let days = hours / 24
        if days == 1 { return "Yesterday" }
        if days < 7 { return "\(days)d ago" }
        let weeks = days / 7
        if weeks < 4 { return "\(weeks)w ago" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}

// MARK: - Preview

#Preview("Photo Wall") {
    PhotoWallView()
}
