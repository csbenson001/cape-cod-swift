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
