import Foundation

// MARK: - CapeCodRegion extensions for area preferences

extension CapeCodRegion {
    /// Display name (same as rawValue for this enum).
    var displayName: String { rawValue }

    /// All 15+ Cape Cod towns in region order.
    static var allTowns: [String] {
        allCases.flatMap(\.towns)
    }

    /// Find which region a town belongs to.
    static func region(for town: String) -> CapeCodRegion? {
        allCases.first { $0.towns.contains(town) }
    }
}
