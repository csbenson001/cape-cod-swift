import Foundation
import Network

// MARK: - Cache TTL Configuration

enum CacheTTL {
    static let weather: TimeInterval = 3600          // 1 hour
    static let tides: TimeInterval = 86400           // 24 hours
    static let events: TimeInterval = 86400          // 24 hours
    static let pois: TimeInterval = 604800           // 7 days
    static let stories: TimeInterval = 2592000       // 30 days
    static let restaurants: TimeInterval = 604800    // 7 days
}

// MARK: - Cache Keys

enum CacheKey {
    static let pois = "offline_cache_pois"
    static let stories = "offline_cache_stories"
    static let events = "offline_cache_events"
    static let weather = "offline_cache_weather"
    static let tides = "offline_cache_tides"
    static let restaurants = "offline_cache_restaurants"

    static let allKeys = [pois, stories, events, weather, tides, restaurants]

    static func displayName(for key: String) -> String {
        switch key {
        case pois: "POIs"
        case stories: "Stories"
        case events: "Events"
        case weather: "Weather"
        case tides: "Tides"
        case restaurants: "Restaurants"
        default: key
        }
    }

    static func ttl(for key: String) -> TimeInterval {
        switch key {
        case pois: CacheTTL.pois
        case stories: CacheTTL.stories
        case events: CacheTTL.events
        case weather: CacheTTL.weather
        case tides: CacheTTL.tides
        case restaurants: CacheTTL.restaurants
        default: CacheTTL.events
        }
    }
}

// MARK: - Cached Data Summary

struct CachedDataSummary: Equatable {
    var entries: [CachedEntryInfo] = []

    var totalSizeBytes: Int {
        entries.reduce(0) { $0 + $1.sizeBytes }
    }

    var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(totalSizeBytes), countStyle: .file)
    }
}

struct CachedEntryInfo: Identifiable, Equatable {
    let id: String
    let displayName: String
    let itemCount: Int
    let cachedDate: Date
    let sizeBytes: Int
    let isExpired: Bool

    var timeAgoString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: cachedDate, relativeTo: Date())
    }
}

// MARK: - Cache Envelope

/// Wraps cached data with metadata for expiry and introspection.
struct CacheEnvelope<T: Codable>: Codable {
    let data: T
    let cachedAt: Date
    let itemCount: Int
}

// MARK: - Offline Cache Manager

@preconcurrency @MainActor
@Observable
final class OfflineCacheManager {
    static let shared = OfflineCacheManager()

    var isOnline: Bool = true
    var lastSyncDate: Date? {
        get { UserDefaults.standard.object(forKey: "offline_last_sync") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "offline_last_sync") }
    }
    var cachedDataSummary = CachedDataSummary()
    var autoDownloadEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "offline_auto_download") }
        set { UserDefaults.standard.set(newValue, forKey: "offline_auto_download") }
    }

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.heycapecod.networkmonitor")
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        startMonitoring()
        refreshSummary()
    }

    // MARK: - Network Monitoring

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOnline = path.status == .satisfied
            }
        }
        monitor.start(queue: monitorQueue)
    }

    // MARK: - Cache Operations

    func cacheData<T: Codable>(_ data: T, forKey key: String, itemCount: Int = 1) {
        let envelope = CacheEnvelope(data: data, cachedAt: Date(), itemCount: itemCount)
        if let encoded = try? encoder.encode(envelope) {
            defaults.set(encoded, forKey: key)
            refreshSummary()
        }
    }

    func loadCached<T: Codable>(forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        guard let envelope = try? decoder.decode(CacheEnvelope<T>.self, from: data) else { return nil }

        let ttl = CacheKey.ttl(for: key)
        let age = Date().timeIntervalSince(envelope.cachedAt)

        // Return data even if expired — stale data is better than no data offline
        if age > ttl {
            print("-- Cache expired for \(key) (age: \(Int(age))s, ttl: \(Int(ttl))s) — returning stale data")
        }
        return envelope.data
    }

    /// Returns cached data only if it is within its TTL.
    func loadFresh<T: Codable>(forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        guard let envelope = try? decoder.decode(CacheEnvelope<T>.self, from: data) else { return nil }

        let ttl = CacheKey.ttl(for: key)
        let age = Date().timeIntervalSince(envelope.cachedAt)
        guard age <= ttl else { return nil }
        return envelope.data
    }

    func clearCache() {
        for key in CacheKey.allKeys {
            defaults.removeObject(forKey: key)
        }
        defaults.removeObject(forKey: "offline_last_sync")
        refreshSummary()
    }

    func clearCache(forKey key: String) {
        defaults.removeObject(forKey: key)
        refreshSummary()
    }

    // MARK: - Summary

    func refreshSummary() {
        var entries: [CachedEntryInfo] = []

        for key in CacheKey.allKeys {
            guard let data = defaults.data(forKey: key) else { continue }

            // Decode just the metadata (cachedAt, itemCount) without the full payload
            struct MetadataEnvelope: Codable {
                let cachedAt: Date
                let itemCount: Int
            }

            let meta: MetadataEnvelope
            let dec = JSONDecoder()
            dec.dateDecodingStrategy = .iso8601
            if let m = try? dec.decode(MetadataEnvelope.self, from: data) {
                meta = m
            } else {
                continue
            }

            let ttl = CacheKey.ttl(for: key)
            let age = Date().timeIntervalSince(meta.cachedAt)

            entries.append(CachedEntryInfo(
                id: key,
                displayName: CacheKey.displayName(for: key),
                itemCount: meta.itemCount,
                cachedDate: meta.cachedAt,
                sizeBytes: data.count,
                isExpired: age > ttl
            ))
        }

        cachedDataSummary = CachedDataSummary(entries: entries)
    }

    func cacheSizeBytes() -> Int {
        cachedDataSummary.totalSizeBytes
    }
}
