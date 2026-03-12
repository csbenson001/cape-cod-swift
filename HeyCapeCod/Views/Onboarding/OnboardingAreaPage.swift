import SwiftUI

/// Onboarding page for selecting Cape Cod regions and towns.
/// Shows the same map + list picker used in Profile settings.
struct OnboardingAreaPage: View {
    @Binding var selectedRegions: Set<String>
    @Binding var selectedTowns: Set<String>

    @State private var activeTab: PickerTab = .map

    private enum PickerTab: String, CaseIterable {
        case map = "Map"
        case list = "List"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: CodSpacing.lg) {
                Spacer()
                    .frame(height: CodSpacing.xl)

                headerSection

                // Tab picker
                Picker("View", selection: $activeTab) {
                    ForEach(PickerTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, CodSpacing.screenEdge)

                switch activeTab {
                case .map:
                    mapContent
                case .list:
                    listContent
                }

                // Selection summary
                if !selectedRegions.isEmpty || !selectedTowns.isEmpty {
                    selectionSummary
                }

                selectionHint

                Spacer()
                    .frame(height: CodSpacing.xxl)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Text("Where on the Cape?")
                .codTextStyle(.heroTitle)
                .multilineTextAlignment(.center)

            Text("Tap regions or towns you want to explore")
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CodSpacing.xl)
        }
    }

    // MARK: - Map Content

    private var mapContent: some View {
        VStack(spacing: CodSpacing.sm) {
            Text("Tap a region to select it")
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.textSecondary)

            CapeCodMapView(
                selectedRegions: $selectedRegions,
                selectedTowns: $selectedTowns
            )
            .frame(height: 280)
            .padding(.horizontal, CodSpacing.screenEdge)
        }
    }

    // MARK: - List Content

    private var listContent: some View {
        VStack(alignment: .leading, spacing: CodSpacing.lg) {
            // Region chips
            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                Text("REGIONS")
                    .codTextStyle(.label)

                FlowLayout(spacing: CodSpacing.sm) {
                    ForEach(CapeCodRegion.allCases) { region in
                        regionChip(region)
                    }
                }
            }

            // Town chips
            VStack(alignment: .leading, spacing: CodSpacing.sm) {
                Text("TOWNS")
                    .codTextStyle(.label)

                let visibleTowns = townsToShow

                FlowLayout(spacing: CodSpacing.sm) {
                    ForEach(visibleTowns, id: \.self) { town in
                        townChip(town)
                    }
                }
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    private var townsToShow: [String] {
        if selectedRegions.isEmpty {
            return CapeCodRegion.allTowns
        }
        return CapeCodRegion.allCases
            .filter { selectedRegions.contains($0.rawValue) }
            .flatMap(\.towns)
    }

    // MARK: - Chips

    private func regionChip(_ region: CapeCodRegion) -> some View {
        let isSelected = selectedRegions.contains(region.rawValue)

        return Button {
            withAnimation(CodAnimation.quick) {
                if isSelected {
                    selectedRegions.remove(region.rawValue)
                } else {
                    selectedRegions.insert(region.rawValue)
                }
            }
            CodHaptic.selection()
        } label: {
            Text(region.displayName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSelected ? .white : Color.capeCod.textPrimary)
                .padding(.horizontal, CodSpacing.md)
                .padding(.vertical, CodSpacing.sm)
                .background(
                    isSelected
                        ? AnyShapeStyle(Color.capeCod.oceanGradient)
                        : AnyShapeStyle(Color.capeCod.surface)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
    }

    private func townChip(_ town: String) -> some View {
        let isSelected = selectedTowns.contains(town)

        return Button {
            withAnimation(CodAnimation.quick) {
                if isSelected {
                    selectedTowns.remove(town)
                } else {
                    selectedTowns.insert(town)
                }
            }
            CodHaptic.light()
        } label: {
            Text(town)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isSelected ? .white : Color.capeCod.oceanBlue)
                .padding(.horizontal, CodSpacing.md)
                .padding(.vertical, CodSpacing.sm)
                .background(
                    isSelected
                        ? Color.capeCod.oceanBlue
                        : Color.capeCod.oceanBlue.opacity(0.1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
    }

    // MARK: - Selection Summary

    private var selectionSummary: some View {
        FlowLayout(spacing: CodSpacing.xs) {
            ForEach(Array(selectedRegions).sorted(), id: \.self) { rawValue in
                if let region = CapeCodRegion(rawValue: rawValue) {
                    Text(region.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, CodSpacing.sm)
                        .padding(.vertical, CodSpacing.xs)
                        .background(Color.capeCod.oceanBlue)
                        .clipShape(Capsule())
                }
            }

            ForEach(Array(selectedTowns).sorted(), id: \.self) { town in
                Text(town)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, CodSpacing.sm)
                    .padding(.vertical, CodSpacing.xs)
                    .background(Color.capeCod.deepNavy)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, CodSpacing.screenEdge)
    }

    // MARK: - Hint

    private var selectionHint: some View {
        Group {
            if selectedRegions.isEmpty && selectedTowns.isEmpty {
                Text("Pick at least one area, or skip to explore all of Cape Cod")
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.driftwood)
            } else {
                let count = selectedRegions.count + selectedTowns.count
                Text("\(count) selected")
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }
        }
        .animation(CodAnimation.quick, value: selectedRegions.count + selectedTowns.count)
    }
}

#Preview {
    OnboardingAreaPage(
        selectedRegions: .constant(["midCape"]),
        selectedTowns: .constant(["Chatham"])
    )
}
