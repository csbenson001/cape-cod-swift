import SwiftUI

// MARK: - Shareable Card Generator

/// Generates branded shareable cards for social media.
struct ShareableCardGenerator {

    enum CardType: String, CaseIterable, Identifiable {
        case myCapeCodDay
        case beachReport
        case bucketList
        case restaurantPick

        var id: String { rawValue }

        var title: String {
            switch self {
            case .myCapeCodDay: "My Cape Cod Day"
            case .beachReport: "Beach Report"
            case .bucketList: "Bucket List"
            case .restaurantPick: "Restaurant Pick"
            }
        }

        var icon: String {
            switch self {
            case .myCapeCodDay: "sun.max.fill"
            case .beachReport: "beach.umbrella.fill"
            case .bucketList: "checklist"
            case .restaurantPick: "fork.knife"
            }
        }

        var gradient: [Color] {
            switch self {
            case .myCapeCodDay: [Color.capeCod.oceanBlue, Color.capeCod.seafoam]
            case .beachReport: [Color.capeCod.sunsetOrange, Color(hex: 0xE8B94E)]
            case .bucketList: [Color.capeCod.seafoam, Color.capeCod.duneGrass]
            case .restaurantPick: [Color.capeCod.cranberry, Color.capeCod.sunsetOrange]
            }
        }
    }

    @MainActor
    static func renderCard(_ view: some View) -> UIImage? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }

    @MainActor
    static func renderStoryCard(_ view: some View) -> UIImage? {
        let renderer = ImageRenderer(content: view.frame(width: 1080, height: 1920))
        renderer.scale = 1.0
        return renderer.uiImage
    }
}

// MARK: - My Cape Cod Day Card

struct MyCapeCodeDayCard: View {
    let activities: [String]
    let date: Date

    var body: some View {
        cardContent
            .frame(width: 360, height: 480)
    }

    private var cardContent: some View {
        ZStack {
            backgroundGradient
            VStack(spacing: CodSpacing.md) {
                headerSection
                Spacer()
                activitiesSection
                Spacer()
                brandingFooter
            }
            .padding(CodSpacing.lg)
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.capeCod.oceanBlue, Color.capeCod.seafoam],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var headerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.9))
            Text("My Cape Cod Day")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(date.formatted(.dateTime.month(.wide).day()))
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            ForEach(activities.prefix(5), id: \.self) { activity in
                HStack(spacing: CodSpacing.sm) {
                    Circle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                    Text(activity)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(CodSpacing.md)
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }

    private var brandingFooter: some View {
        HStack {
            Text("Hey Cape Cod")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Image(systemName: "wave.3.right")
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// MARK: - Beach Report Card

struct BeachReportCard: View {
    let beachName: String
    let conditions: String
    let temperature: String
    let windSpeed: String

    var body: some View {
        cardContent
            .frame(width: 360, height: 480)
    }

    private var cardContent: some View {
        ZStack {
            backgroundGradient
            VStack(spacing: CodSpacing.lg) {
                beachHeader
                Spacer()
                conditionsGrid
                Spacer()
                brandingFooter
            }
            .padding(CodSpacing.lg)
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.capeCod.sunsetOrange, Color(hex: 0xE8B94E)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var beachHeader: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "beach.umbrella.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.9))
            Text("Beach Report")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .textCase(.uppercase)
                .tracking(1.5)
            Text(beachName)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
    }

    private var conditionsGrid: some View {
        VStack(spacing: CodSpacing.md) {
            conditionRow(icon: "sun.max.fill", label: "Conditions", value: conditions)
            conditionRow(icon: "thermometer.medium", label: "Temperature", value: temperature)
            conditionRow(icon: "wind", label: "Wind", value: windSpeed)
        }
        .padding(CodSpacing.md)
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }

    private func conditionRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.white.opacity(0.8))
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var brandingFooter: some View {
        HStack {
            Text("Hey Cape Cod")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(Date.now.formatted(.dateTime.month(.abbreviated).day()))
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

// MARK: - Bucket List Card

struct BucketListCard: View {
    let items: [BucketListItem]
    let totalCompleted: Int

    var body: some View {
        cardContent
            .frame(width: 360, height: 480)
    }

    private var cardContent: some View {
        ZStack {
            backgroundGradient
            VStack(spacing: CodSpacing.md) {
                progressHeader
                Spacer()
                itemsList
                Spacer()
                brandingFooter
            }
            .padding(CodSpacing.lg)
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.capeCod.seafoam, Color.capeCod.duneGrass],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var progressHeader: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "checklist")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.9))
            Text("Cape Cod Bucket List")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("\(totalCompleted) of \(items.count) completed")
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private var itemsList: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            ForEach(items.prefix(6)) { item in
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(.white.opacity(item.isCompleted ? 1 : 0.4))
                    Text(item.title)
                        .font(.system(size: 15, weight: item.isCompleted ? .semibold : .regular))
                        .foregroundStyle(.white.opacity(item.isCompleted ? 1 : 0.6))
                        .strikethrough(item.isCompleted, color: .white.opacity(0.5))
                }
            }
        }
        .padding(CodSpacing.md)
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }

    private var brandingFooter: some View {
        HStack {
            Text("Hey Cape Cod")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Image(systemName: "wave.3.right")
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// MARK: - Bucket List Item

struct BucketListItem: Identifiable {
    let id = UUID()
    let title: String
    var isCompleted: Bool
}

// MARK: - Restaurant Pick Card

struct RestaurantPickCard: View {
    let restaurantName: String
    let cuisine: String
    let recommendation: String
    let town: String

    var body: some View {
        cardContent
            .frame(width: 360, height: 480)
    }

    private var cardContent: some View {
        ZStack {
            backgroundGradient
            VStack(spacing: CodSpacing.lg) {
                restaurantHeader
                Spacer()
                detailsSection
                Spacer()
                brandingFooter
            }
            .padding(CodSpacing.lg)
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.capeCod.cranberry, Color.capeCod.sunsetOrange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var restaurantHeader: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "fork.knife")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.9))
            Text("Restaurant Pick")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .textCase(.uppercase)
                .tracking(1.5)
            Text(restaurantName)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(town)
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var detailsSection: some View {
        VStack(spacing: CodSpacing.md) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(.white.opacity(0.8))
                Text(cuisine)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                Spacer()
            }
            Text("\"\(recommendation)\"")
                .font(.system(size: 16, weight: .regular))
                .italic()
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(CodSpacing.md)
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }

    private var brandingFooter: some View {
        HStack {
            Text("Hey Cape Cod")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(Date.now.formatted(.dateTime.month(.abbreviated).day()))
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}
