import SwiftUI

// MARK: - CodChip

/// Small pill-shaped component for category labels, status indicators, and filters.
struct CodChip: View {
    let text: String
    let style: CodChipStyle
    let icon: String?
    var isSelected: Bool = false
    var action: (() -> Void)? = nil

    init(
        _ text: String,
        style: CodChipStyle = .category(.blue),
        icon: String? = nil,
        isSelected: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.text = text
        self.style = style
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        let chipContent = HStack(spacing: CodSpacing.xs) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, CodSpacing.sm + 2)
        .padding(.vertical, CodSpacing.xs + 2)
        .foregroundStyle(chipForeground)
        .background(chipBackground)
        .clipShape(Capsule())
        .overlay {
            if style.isOutlined && !isSelected {
                Capsule()
                    .strokeBorder(chipForeground.opacity(0.4), lineWidth: 1)
            }
        }

        if let action {
            Button(action: {
                UISelectionFeedbackGenerator().selectionChanged()
                action()
            }) {
                chipContent
            }
            .buttonStyle(CodButtonPressStyle(variant: .ghost))
        } else {
            chipContent
        }
    }

    private var chipForeground: Color {
        if isSelected { return .white }
        return style.color
    }

    private var chipBackground: Color {
        if isSelected { return style.color }
        return style.color.opacity(0.12)
    }
}

// MARK: - Chip Styles

enum CodChipStyle {
    case category(CodChipColor)
    case status(CodStatusType)
    case filter
    case mode

    var color: Color {
        switch self {
        case .category(let color): return color.value
        case .status(let status): return status.color
        case .filter: return Color.capeCod.oceanBlue
        case .mode: return Color.capeCod.driftwood
        }
    }

    var isOutlined: Bool {
        switch self {
        case .filter: return true
        default: return false
        }
    }
}

enum CodChipColor {
    case blue, brown, green, orange

    var value: Color {
        switch self {
        case .blue: return Color.capeCod.oceanBlue
        case .brown: return Color.capeCod.driftwood
        case .green: return Color.capeCod.duneGrass
        case .orange: return Color.capeCod.sunsetOrange
        }
    }
}

enum CodStatusType {
    case open, closingSoon, closed

    var color: Color {
        switch self {
        case .open: return Color.capeCod.duneGrass
        case .closingSoon: return Color.capeCod.sandbarYellow
        case .closed: return Color.capeCod.driftwood
        }
    }

    var label: String {
        switch self {
        case .open: return "Open Now"
        case .closingSoon: return "Closing Soon"
        case .closed: return "Closed"
        }
    }
}

// MARK: - Preview

#Preview("Chips") {
    VStack(alignment: .leading, spacing: CodSpacing.md) {
        Text("Categories").codTextStyle(.sectionTitle)
        FlowLayout(spacing: CodSpacing.sm) {
            CodChip("Beach", style: .category(.blue), icon: "sun.max.fill")
            CodChip("Historic", style: .category(.brown), icon: "building.columns.fill")
            CodChip("Nature", style: .category(.green), icon: "leaf.fill")
            CodChip("Food", style: .category(.orange), icon: "fork.knife")
        }

        Text("Status").codTextStyle(.sectionTitle)
        HStack(spacing: CodSpacing.sm) {
            CodChip("Open Now", style: .status(.open))
            CodChip("Closing Soon", style: .status(.closingSoon))
            CodChip("Closed", style: .status(.closed))
        }

        Text("Filters").codTextStyle(.sectionTitle)
        HStack(spacing: CodSpacing.sm) {
            CodChip("Family Friendly", style: .filter, isSelected: true) {}
            CodChip("Pet Friendly", style: .filter, isSelected: false) {}
        }
    }
    .padding(CodSpacing.screenEdge)
    .background(Color.capeCod.background)
}

// MARK: - Flow Layout (for wrapping chips)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}
