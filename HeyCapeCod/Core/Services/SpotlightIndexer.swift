import CoreSpotlight
import UniformTypeIdentifiers
import Foundation

/// Indexes POIs in Spotlight so users can search for Cape Cod locations
/// directly from the iOS home screen.
final class SpotlightIndexer {
    nonisolated(unsafe) static let shared = SpotlightIndexer()
    private let domainIdentifier = "com.heycapecod.pois"

    private init() {}

    /// Index all cached POIs for Spotlight search.
    func indexPOIs(_ pois: [PointOfInterest]) {
        let items = pois.map { poi -> CSSearchableItem in
            let attributes = CSSearchableItemAttributeSet(contentType: .content)
            attributes.title = poi.name
            attributes.contentDescription = poi.description
            attributes.keywords = [poi.town.displayName, poi.category.displayName, "Cape Cod"]

            if let fact = poi.facts.first {
                attributes.contentDescription = "\(poi.description). \(fact)"
            }

            attributes.latitude = NSNumber(value: poi.coordinate.latitude)
            attributes.longitude = NSNumber(value: poi.coordinate.longitude)
            attributes.supportsNavigation = true
            attributes.namedLocation = poi.town.displayName

            return CSSearchableItem(
                uniqueIdentifier: poi.id,
                domainIdentifier: domainIdentifier,
                attributeSet: attributes
            )
        }

        CSSearchableIndex.default().indexSearchableItems(items) { error in
            if let error {
                print("❌ Spotlight indexing error: \(error.localizedDescription)")
            } else {
                print("🔍 Indexed \(items.count) POIs in Spotlight")
            }
        }
    }

    /// Index CodLocations for Spotlight.
    func indexLocations(_ locations: [CodLocation]) {
        let items = locations.map { location -> CSSearchableItem in
            let attributes = CSSearchableItemAttributeSet(contentType: .content)
            attributes.title = location.name
            attributes.contentDescription = location.description
            attributes.keywords = [location.town.displayName, location.category.displayName, "Cape Cod"]
            attributes.latitude = NSNumber(value: location.latitude)
            attributes.longitude = NSNumber(value: location.longitude)
            attributes.supportsNavigation = true
            attributes.namedLocation = location.town.displayName

            return CSSearchableItem(
                uniqueIdentifier: location.id.uuidString,
                domainIdentifier: domainIdentifier,
                attributeSet: attributes
            )
        }

        CSSearchableIndex.default().indexSearchableItems(items) { error in
            if let error {
                print("❌ Spotlight indexing error: \(error.localizedDescription)")
            } else {
                print("🔍 Indexed \(items.count) locations in Spotlight")
            }
        }
    }

    /// Remove all indexed items (e.g., on sign out or data reset).
    func deindexAll() {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [domainIdentifier]) { error in
            if let error {
                print("❌ Spotlight deindex error: \(error.localizedDescription)")
            }
        }
    }
}
