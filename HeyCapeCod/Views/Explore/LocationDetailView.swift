import SwiftUI
import MapKit

struct LocationDetailView: View {
    let location: CodLocation
    @State private var showingMap = false
    @State private var region: MKCoordinateRegion

    init(location: CodLocation) {
        self.location = location
        self._region = State(initialValue: MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                // Hero Image
                heroSection

                VStack(alignment: .leading, spacing: CodSpacing.lg) {
                    // Title & Category
                    headerSection

                    Divider()

                    // Description
                    if !location.description.isEmpty {
                        Text(location.description)
                            .codTextStyle(.body)
                    }

                    // Personalized Tip
                    if let tip = personalizedTip {
                        HStack(alignment: .top, spacing: CodSpacing.sm) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(Color.capeCod.sandbarYellow)
                                .font(.system(size: 16))
                            Text(tip)
                                .codTextStyle(.body)
                                .foregroundStyle(Color.capeCod.textSecondary)
                        }
                        .padding(CodSpacing.cardPadding)
                        .background(Color.capeCod.sandbarYellow.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
                    }

                    // Map Preview
                    mapSection

                    // Actions
                    actionsSection
                }
                .padding(.horizontal, CodSpacing.screenEdge)
            }
            .padding(.bottom, CodSpacing.xxl)
        }
        .background(Color.capeCod.background)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(Color.capeCod.deepNavy.opacity(0.2))
                .frame(height: 240)
                .overlay {
                    Image(systemName: location.category.icon)
                        .font(.system(size: 64))
                        .foregroundStyle(Color.capeCod.oceanBlue.opacity(0.2))
                }

            LinearGradient(
                colors: [.clear, Color.capeCod.deepNavy.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack {
                Image(systemName: location.category.icon)
                    .foregroundStyle(Color.capeCod.oceanBlue)
                Text(location.category.displayName)
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.oceanBlue)

                Spacer()

                if let rating = location.rating {
                    HStack(spacing: CodSpacing.xs) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color.capeCod.sandbarYellow)
                        Text(String(format: "%.1f", rating))
                            .codTextStyle(.body)
                        Text("(\(location.reviewCount))")
                            .codTextStyle(.caption)
                    }
                }
            }

            Text(location.name)
                .codTextStyle(.heroTitle)

            Text("\(location.town.displayName) · \(location.town.region.rawValue)")
                .codTextStyle(.subtitle)
        }
    }

    private var personalizedTip: String? {
        let mode = UserProfileManager.shared.currentProfile?.experienceMode ?? .adult
        let visitType = UserProfileManager.shared.currentProfile?.visitType ?? "tourist"

        switch (location.category, mode) {
        case (.beach, .kids):
            return "🏴‍☠️ Fun fact: Cape Cod beaches are great for finding sea glass and hermit crabs! Look in the tide pools at low tide."
        case (.beach, .teen):
            return "Pro tip: This beach is 📸 Instagram-worthy at golden hour. Check the tide schedule for the best sand exposure."
        case (.beach, .adult):
            return "Tip: Arrive before 9 AM for the best parking. \(visitType == "local" ? "Beach stickers required in summer." : "Daily parking fees apply in season — typically $20-30.")"
        case (.beach, .family):
            return "Family tip: The calm bayside is better for little ones. Bring sand toys and check if lifeguards are on duty."
        case (.restaurant, .kids):
            return "🍕 Kid-friendly! Most Cape Cod restaurants have kids' menus. Don't miss the ice cream shops nearby!"
        case (.restaurant, .teen):
            return "Check if they have outdoor seating — waterfront dining on the Cape hits different."
        case (.restaurant, .adult):
            return "Tip: \(visitType == "local" ? "Off-season weeknight specials are the best kept secret." : "Reservations recommended in summer. Ask about locally-caught seafood specials.")"
        case (.restaurant, .family):
            return "Family tip: Early dinner (5-6 PM) avoids the wait. Many spots have kids' menus and high chairs."
        case (.lighthouse, .kids):
            return "🔦 Did you know? Lighthouses spin to warn ships about rocks! See if you can count the light flashes."
        case (.lighthouse, .teen):
            return "The views from lighthouse trails are 🔥. Some let you climb to the top — check hours."
        case (.lighthouse, .adult):
            return "Tip: Visit at sunset for the best photography. Many lighthouses have fascinating keeper histories."
        case (.lighthouse, .family):
            return "Family tip: Kids love climbing lighthouse stairs! Check which ones allow tours and bring a flashlight."
        case (.historic, .kids):
            return "⚓ History adventure! Imagine what Cape Cod looked like hundreds of years ago with pirates and sailors!"
        case (.historic, .adult):
            return "Tip: \(visitType == "tourist" ? "Audio guides are available at most historic sites. Allow 1-2 hours." : "Check for special lecture series and evening events.")"
        case (.nature, .kids):
            return "🦀 Nature explorer time! Bring a magnifying glass to look at shells, bugs, and tide pool creatures."
        case (.nature, .adult):
            return "Tip: Best visited at dawn or dusk for wildlife viewing. Bring binoculars and check trail conditions."
        case (.nature, .family):
            return "Family tip: Short loop trails (under 1 mile) are best with kids. Bring bug spray and water."
        default:
            return nil
        }
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("Location")
                .codTextStyle(.sectionTitle)

            Map(initialPosition: .region(region)) {
                Marker(location.name, coordinate: location.coordinate)
                    .tint(Color.capeCod.oceanBlue)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
            .allowsHitTesting(false)
        }
    }

    private var actionsSection: some View {
        VStack(spacing: CodSpacing.md) {
            CodButton("Get Directions", icon: "arrow.triangle.turn.up.right.diamond.fill") {
                openInMaps()
            }

            CodButton("Ask About This Place", variant: .secondary, icon: "bubble.left.fill") {
                // Navigate to conversation
            }
        }
    }

    private func openInMaps() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
        mapItem.name = location.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

#Preview {
    NavigationStack {
        LocationDetailView(location: CodLocation(
            name: "Nauset Light Beach",
            latitude: 41.8583,
            longitude: -69.9514,
            category: .beach,
            description: "One of Cape Cod's most iconic beaches, famous for its stunning cliffs and the nearby Nauset Lighthouse.",
            town: .eastham,
            rating: 4.8,
            reviewCount: 342
        ))
    }
}
