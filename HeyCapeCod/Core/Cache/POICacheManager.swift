import Foundation
@preconcurrency import SwiftData

/// Manages the SwiftData cache for POIs and stories.
/// Used by POIService to provide fast local reads before API refresh.
@preconcurrency @MainActor
@Observable
final class POICacheManager {
    static let shared = POICacheManager()

    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?

    var lastUpdatedText: String = ""

    private init() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            let schema = Schema([CachedPOI.self, CachedStory.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            do {
                self.modelContainer = try ModelContainer(for: schema, configurations: [config])
            } catch {
                print("⚠️ SwiftData schema changed, recreating cache: \(error)")
                let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
                for ext in ["", "-shm", "-wal"] {
                    try? FileManager.default.removeItem(at: URL(fileURLWithPath: storeURL.path + ext))
                }
                self.modelContainer = try? ModelContainer(for: schema, configurations: [config])
            }
            self.modelContext = self.modelContainer.map { ModelContext($0) }
        }
    }

    // MARK: - POI Cache

    func loadCachedPOIs() -> [POI] {
        guard let context = modelContext else { return [] }
        do {
            let descriptor = FetchDescriptor<CachedPOI>(
                sortBy: [SortDescriptor(\.priority, order: .reverse)]
            )
            let cached = try context.fetch(descriptor)
            if let first = cached.first {
                lastUpdatedText = first.lastUpdatedText
            }
            let pois = cached.map { $0.toPOI() }
            print("💾 Loaded \(pois.count) POIs from cache")
            return pois
        } catch {
            print("❌ Cache read error: \(error)")
            return []
        }
    }

    func savePOIs(_ pois: [POI]) {
        guard let context = modelContext else { return }
        do {
            // Delete existing
            try context.delete(model: CachedPOI.self)

            // Insert fresh
            for poi in pois {
                context.insert(CachedPOI(from: poi))
            }
            try context.save()
            lastUpdatedText = "Updated just now"
            print("💾 Cached \(pois.count) POIs")
        } catch {
            print("❌ Cache write error: \(error)")
        }
    }

    // MARK: - Story Cache

    func loadCachedStories() -> [APIStoryResponse] {
        guard let context = modelContext else { return [] }
        do {
            let descriptor = FetchDescriptor<CachedStory>()
            let cached = try context.fetch(descriptor)
            let stories = cached.compactMap { $0.toAPIStoryResponse() }
            print("💾 Loaded \(stories.count) stories from cache")
            return stories
        } catch {
            return []
        }
    }

    func saveStories(_ stories: [APIStoryResponse]) {
        guard let context = modelContext else { return }
        do {
            try context.delete(model: CachedStory.self)
            for story in stories {
                context.insert(CachedStory(from: story))
            }
            try context.save()
            print("💾 Cached \(stories.count) stories")
        } catch {
            print("❌ Story cache write error: \(error)")
        }
    }

    /// Check if cache has data
    var hasCachedData: Bool {
        guard let context = modelContext else { return false }
        let descriptor = FetchDescriptor<CachedPOI>()
        return (try? context.fetchCount(descriptor)) ?? 0 > 0
    }
}
