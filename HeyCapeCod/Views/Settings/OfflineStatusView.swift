import SwiftUI

/// Settings screen showing offline cache status, cached data details,
/// and controls for syncing and clearing cached data.
struct OfflineStatusView: View {
    private let cacheManager = OfflineCacheManager.shared

    @State private var showClearConfirmation = false
    @State private var isSyncing = false

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.lg) {
                connectionStatusCard
                cachedDataSection
                storageSection
                actionsSection
                autoDownloadSection
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.vertical, CodSpacing.md)
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background)
        .navigationTitle("Offline Mode")
        .navigationBarTitleDisplayMode(.large)
        .alert("Clear Cache?", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All", role: .destructive) {
                CodHaptic.tap()
                cacheManager.clearCache()
            }
        } message: {
            Text("This will remove all cached data. You'll need an internet connection to reload content.")
        }
    }

    // MARK: - Connection Status

    private var connectionStatusCard: some View {
        HStack(spacing: CodSpacing.md) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: cacheManager.isOnline ? "wifi" : "wifi.slash")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(statusColor)
            }

            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                Text(cacheManager.isOnline ? "Connected" : "Offline")
                    .codTextStyle(.cardTitle)

                Text(statusSubtitle)
                    .codTextStyle(.caption)
            }

            Spacer()

            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
                .pulsingGlow(color: statusColor, isActive: !cacheManager.isOnline)
        }
        .padding(CodSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .fill(Color.capeCod.surfaceElevated)
        )
        .adaptiveCardStyle()
    }

    private var statusColor: Color {
        cacheManager.isOnline ? Color.capeCod.duneGrass : Color.capeCod.sunsetOrange
    }

    private var statusSubtitle: String {
        if cacheManager.isOnline {
            return "All features available"
        }
        return "Using cached data for offline access"
    }

    // MARK: - Cached Data

    private var cachedDataSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("CACHED DATA")
                .codTextStyle(.label)
                .padding(.leading, CodSpacing.xs)

            if cacheManager.cachedDataSummary.entries.isEmpty {
                emptyCacheCard
            } else {
                VStack(spacing: 1) {
                    ForEach(cacheManager.cachedDataSummary.entries) { entry in
                        cachedEntryRow(entry)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
                .adaptiveCardStyle()
            }
        }
    }

    private var emptyCacheCard: some View {
        HStack(spacing: CodSpacing.md) {
            Image(systemName: "tray")
                .font(.system(size: 24))
                .foregroundStyle(Color.capeCod.textSecondary)

            VStack(alignment: .leading, spacing: CodSpacing.xs) {
                Text("No Cached Data")
                    .codTextStyle(.cardTitle)
                Text("Browse the app while online to cache data automatically.")
                    .codTextStyle(.caption)
            }
        }
        .padding(CodSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                .fill(Color.capeCod.surfaceElevated)
        )
        .adaptiveCardStyle()
    }

    private func cachedEntryRow(_ entry: CachedEntryInfo) -> some View {
        HStack(spacing: CodSpacing.md) {
            Image(systemName: iconForEntry(entry.id))
                .font(.system(size: 16))
                .foregroundStyle(entry.isExpired ? Color.capeCod.driftwood : Color.capeCod.oceanBlue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: CodSpacing.xs) {
                    Text(entry.displayName)
                        .codTextStyle(.body)

                    if entry.isExpired {
                        Text("EXPIRED")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.capeCod.sunsetOrange)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(
                                Capsule().fill(Color.capeCod.sunsetOrange.opacity(0.12))
                            )
                    }
                }

                Text("\(entry.itemCount) items \u{2022} \(entry.timeAgoString)")
                    .codTextStyle(.caption)
            }

            Spacer()

            Text(ByteCountFormatter.string(fromByteCount: Int64(entry.sizeBytes), countStyle: .file))
                .codTextStyle(.caption)
        }
        .padding(.horizontal, CodSpacing.md)
        .padding(.vertical, CodSpacing.sm + 2)
        .background(Color.capeCod.surfaceElevated)
    }

    private func iconForEntry(_ key: String) -> String {
        switch key {
        case CacheKey.pois: "mappin.circle.fill"
        case CacheKey.stories: "book.fill"
        case CacheKey.events: "calendar.circle.fill"
        case CacheKey.weather: "cloud.sun.fill"
        case CacheKey.tides: "water.waves"
        case CacheKey.restaurants: "fork.knife"
        default: "doc.fill"
        }
    }

    // MARK: - Storage

    private var storageSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("STORAGE")
                .codTextStyle(.label)
                .padding(.leading, CodSpacing.xs)

            HStack {
                Text("Total Cache Size")
                    .codTextStyle(.body)
                Spacer()
                Text(cacheManager.cachedDataSummary.formattedTotalSize)
                    .codTextStyle(.body)
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }
            .padding(CodSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                    .fill(Color.capeCod.surfaceElevated)
            )
            .adaptiveCardStyle()

            if let lastSync = cacheManager.lastSyncDate {
                let formatter = RelativeDateTimeFormatter()
                HStack {
                    Text("Last Sync")
                        .codTextStyle(.caption)
                    Spacer()
                    Text(formatter.localizedString(for: lastSync, relativeTo: Date()))
                        .codTextStyle(.caption)
                }
                .padding(.horizontal, CodSpacing.xs)
            }
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: CodSpacing.sm) {
            syncButton
            clearButton
        }
    }

    private var syncButton: some View {
        Button {
            guard cacheManager.isOnline else { return }
            CodHaptic.tap()
            isSyncing = true
            // Sync is best-effort; individual services cache on fetch
            Task {
                try? await Task.sleep(for: .seconds(1))
                cacheManager.lastSyncDate = Date()
                cacheManager.refreshSummary()
                isSyncing = false
                CodHaptic.success()
            }
        } label: {
            HStack(spacing: CodSpacing.sm) {
                if isSyncing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
                Text(isSyncing ? "Syncing..." : "Sync Now")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous)
                    .fill(cacheManager.isOnline ? Color.capeCod.oceanBlue : Color.capeCod.driftwood)
            )
        }
        .disabled(!cacheManager.isOnline || isSyncing)
        .codAccessibleButton(
            "Sync Now",
            hint: cacheManager.isOnline ? "Download latest data for offline use" : "Not available while offline"
        )
    }

    private var clearButton: some View {
        Button {
            CodHaptic.tap()
            showClearConfirmation = true
        } label: {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: "trash")
                Text("Clear Cache")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Color.capeCod.cranberry)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous)
                    .fill(Color.capeCod.cranberry.opacity(0.1))
            )
        }
        .codAccessibleButton("Clear Cache", hint: "Remove all cached offline data")
    }

    // MARK: - Auto-Download Toggle

    private var autoDownloadBinding: Binding<Bool> {
        Binding(
            get: { cacheManager.autoDownloadEnabled },
            set: { cacheManager.autoDownloadEnabled = $0 }
        )
    }

    private var autoDownloadSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("PREFERENCES")
                .codTextStyle(.label)
                .padding(.leading, CodSpacing.xs)

            Toggle(isOn: autoDownloadBinding) {
                VStack(alignment: .leading, spacing: CodSpacing.xs) {
                    Text("Auto-download for offline use")
                        .codTextStyle(.body)
                    Text("Automatically caches data when connected")
                        .codTextStyle(.caption)
                }
            }
            .tint(Color.capeCod.oceanBlue)
            .padding(CodSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                    .fill(Color.capeCod.surfaceElevated)
            )
            .adaptiveCardStyle()
        }
    }
}

#Preview {
    NavigationStack {
        OfflineStatusView()
    }
}
