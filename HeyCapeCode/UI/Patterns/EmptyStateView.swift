import SwiftUI

// MARK: - EmptyStateView

/// Centered placeholder for screens with no data.
/// Shows a large SF Symbol, title, helpful subtitle, and optional action button.
/// Never leave a screen blank — always guide the user.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var iconColor: Color = Color.capeCod.driftwood
    var actionLabel: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: CodSpacing.lg) {
            // Large icon with soft tinted background
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: icon)
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(iconColor.opacity(0.6))
                    .symbolVariant(.fill)
            }

            // Title and subtitle
            VStack(spacing: CodSpacing.sm) {
                Text(title)
                    .codTextStyle(.sectionTitle)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .codTextStyle(.body)
                    .foregroundStyle(Color.capeCod.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }

            // Optional action button
            if let actionLabel, let onAction {
                CodButton(actionLabel, variant: .primary, action: onAction)
                    .padding(.top, CodSpacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(CodSpacing.screenEdge)
    }
}

// MARK: - Common Empty States

extension EmptyStateView {
    /// No stories nearby
    static func noStories(onRefresh: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "headphones",
            title: "No Stories Nearby",
            subtitle: "Drive closer to Cape Cod landmarks to unlock location-based audio stories.",
            iconColor: Color.capeCod.sunsetOrange,
            actionLabel: onRefresh != nil ? "Refresh" : nil,
            onAction: onRefresh
        )
    }

    /// No traffic data
    static func noTraffic(onRefresh: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "car",
            title: "No Traffic Data",
            subtitle: "Traffic conditions are currently unavailable. Check back soon for bridge delays and route updates.",
            iconColor: Color.capeCod.driftwood,
            actionLabel: onRefresh != nil ? "Refresh" : nil,
            onAction: onRefresh
        )
    }

    /// Location not enabled
    static func locationRequired(onEnable: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "location.slash",
            title: "Location Access Needed",
            subtitle: "Enable location services to discover beaches, trails, and stories near you.",
            iconColor: Color.capeCod.oceanBlue,
            actionLabel: "Enable Location",
            onAction: onEnable
        )
    }

    /// No search results
    static func noSearchResults(query: String) -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results for \"\(query)\"",
            subtitle: "Try a different search term or browse categories to explore Cape Cod.",
            iconColor: Color.capeCod.driftwood
        )
    }

    /// No saved places
    static func noSavedPlaces(onExplore: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "bookmark",
            title: "No Saved Places",
            subtitle: "Tap the bookmark icon on any place to save it for your trip.",
            iconColor: Color.capeCod.seafoam,
            actionLabel: "Start Exploring",
            onAction: onExplore
        )
    }

    /// No beach data
    static func noBeachData(onRefresh: (() -> Void)? = nil) -> EmptyStateView {
        EmptyStateView(
            icon: "sun.max",
            title: "No Beach Conditions",
            subtitle: "Beach condition data is temporarily unavailable. Try again in a moment.",
            iconColor: Color.capeCod.sandbarYellow,
            actionLabel: onRefresh != nil ? "Refresh" : nil,
            onAction: onRefresh
        )
    }

    /// Offline / no connection
    static func offline(onRetry: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "wifi.slash",
            title: "You're Offline",
            subtitle: "Check your internet connection. Some features are available offline.",
            iconColor: Color.capeCod.cranberry,
            actionLabel: "Retry",
            onAction: onRetry
        )
    }
}

// MARK: - Preview

#Preview("Empty States") {
    ScrollView {
        VStack(spacing: CodSpacing.xxl) {
            Text("Empty States").codTextStyle(.heroTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, CodSpacing.screenEdge)

            Group {
                sectionLabel("No Stories Nearby")
                EmptyStateView.noStories(onRefresh: {})
                    .frame(height: 300)
                    .background(Color.capeCod.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))

                sectionLabel("Location Required")
                EmptyStateView.locationRequired(onEnable: {})
                    .frame(height: 300)
                    .background(Color.capeCod.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))

                sectionLabel("No Search Results")
                EmptyStateView.noSearchResults(query: "lobster roll")
                    .frame(height: 300)
                    .background(Color.capeCod.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))

                sectionLabel("Offline")
                EmptyStateView.offline(onRetry: {})
                    .frame(height: 300)
                    .background(Color.capeCod.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))

                sectionLabel("No Saved Places")
                EmptyStateView.noSavedPlaces(onExplore: {})
                    .frame(height: 300)
                    .background(Color.capeCod.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))

                sectionLabel("No Traffic Data")
                EmptyStateView.noTraffic(onRefresh: {})
                    .frame(height: 300)
                    .background(Color.capeCod.surface)
                    .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
            }
            .padding(.horizontal, CodSpacing.screenEdge)
        }
        .padding(.bottom, CodSpacing.xxl)
    }
    .background(Color.capeCod.background)
}

private func sectionLabel(_ text: String) -> some View {
    Text(text)
        .codTextStyle(.label)
        .frame(maxWidth: .infinity, alignment: .leading)
}
