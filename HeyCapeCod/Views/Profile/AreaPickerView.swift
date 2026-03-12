import SwiftUI

/// Two-tab picker for selecting Cape Cod regions and towns.
/// Map tab shows a Cape Cod silhouette with tappable region bubbles.
/// List tab shows region chips and filtered town chips.
struct AreaPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedRegions: Set<String>
    @Binding var selectedTowns: Set<String>

    @State private var activeTab: PickerTab = .map

    private enum PickerTab: String, CaseIterable {
        case map = "Map"
        case list = "List"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab picker
            Picker("View", selection: $activeTab) {
                ForEach(PickerTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.top, CodSpacing.md)

            ScrollView {
                VStack(spacing: CodSpacing.lg) {
                    switch activeTab {
                    case .map:
                        mapTab
                    case .list:
                        listTab
                    }

                    // Selected summary pills
                    if !selectedRegions.isEmpty || !selectedTowns.isEmpty {
                        selectedSummary
                    }
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.vertical, CodSpacing.md)
                .padding(.bottom, CodSpacing.xxl)
            }
        }
        .background(Color.capeCod.background)
        .navigationTitle("Where on the Cape?")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    savePreferences()
                    dismiss()
                }
                .foregroundStyle(Color.capeCod.oceanBlue)
                .fontWeight(.semibold)
            }
        }
    }

    // MARK: - Map Tab

    private var mapTab: some View {
        VStack(spacing: CodSpacing.md) {
            Text("Tap a region to select it")
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.textSecondary)

            CapeCodMapView(
                selectedRegions: $selectedRegions,
                selectedTowns: $selectedTowns
            )
            .frame(height: 300)
        }
    }

    // MARK: - List Tab

    private var listTab: some View {
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
            toggleRegion(region)
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
            toggleTown(town)
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

    // MARK: - Selected Summary

    private var selectedSummary: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("SELECTED")
                .codTextStyle(.label)

            FlowLayout(spacing: CodSpacing.xs) {
                ForEach(Array(selectedRegions).sorted(), id: \.self) { rawValue in
                    if let region = CapeCodRegion(rawValue: rawValue) {
                        summaryPill(region.displayName, isRegion: true) {
                            selectedRegions.remove(rawValue)
                            CodHaptic.selection()
                        }
                    }
                }

                ForEach(Array(selectedTowns).sorted(), id: \.self) { town in
                    summaryPill(town, isRegion: false) {
                        selectedTowns.remove(town)
                        CodHaptic.selection()
                    }
                }
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
    }

    private func summaryPill(_ text: String, isRegion: Bool, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: CodSpacing.xs) {
            Text(text)
                .font(.system(size: 12, weight: .semibold))
            Image(systemName: "xmark")
                .font(.system(size: 9, weight: .bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, CodSpacing.sm)
        .padding(.vertical, CodSpacing.xs + 2)
        .background(isRegion ? Color.capeCod.oceanBlue : Color.capeCod.deepNavy)
        .clipShape(Capsule())
        .onTapGesture(perform: onRemove)
    }

    // MARK: - Actions

    private func toggleRegion(_ region: CapeCodRegion) {
        withAnimation(CodAnimation.quick) {
            if selectedRegions.contains(region.rawValue) {
                selectedRegions.remove(region.rawValue)
            } else {
                selectedRegions.insert(region.rawValue)
            }
        }
        CodHaptic.selection()
    }

    private func toggleTown(_ town: String) {
        withAnimation(CodAnimation.quick) {
            if selectedTowns.contains(town) {
                selectedTowns.remove(town)
            } else {
                selectedTowns.insert(town)
            }
        }
        CodHaptic.selection()
    }

    private func savePreferences() {
        UserProfileManager.shared.preferredRegions = Array(selectedRegions)
        UserProfileManager.shared.preferredTowns = Array(selectedTowns)

        if let profile = UserProfileManager.shared.currentProfile {
            profile.preferredRegions = Array(selectedRegions)
            profile.preferredTowns = Array(selectedTowns)
            UserProfileManager.shared.saveProfile()
        }
    }
}

// MARK: - Cape Cod Map View

struct CapeCodMapView: View {
    @Binding var selectedRegions: Set<String>
    @Binding var selectedTowns: Set<String>

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Ocean background
                RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.capeCod.oceanBlue.opacity(0.06),
                                Color.capeCod.oceanBlue.opacity(0.12),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Cape Cod silhouette
                CapeCodShape()
                    .fill(Color.capeCod.sand.opacity(0.4))
                    .stroke(Color.capeCod.driftwood.opacity(0.3), lineWidth: 1.5)
                    .padding(CodSpacing.lg)

                // Region bubbles
                regionBubble(.upperCape, x: w * 0.18, y: h * 0.62)
                regionBubble(.midCape, x: w * 0.42, y: h * 0.48)
                regionBubble(.lowerCape, x: w * 0.65, y: h * 0.38)
                regionBubble(.outerCape, x: w * 0.84, y: h * 0.22)

                // Town dots for selected regions
                ForEach(CapeCodRegion.allCases) { region in
                    if selectedRegions.contains(region.rawValue) {
                        townDots(for: region, in: geo.size)
                    }
                }
            }
        }
    }

    private func regionBubble(_ region: CapeCodRegion, x: CGFloat, y: CGFloat) -> some View {
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
            VStack(spacing: 2) {
                Text(region.displayName)
                    .font(.system(size: 11, weight: .bold))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? .white : Color.capeCod.oceanBlue)
            .padding(.horizontal, CodSpacing.sm)
            .padding(.vertical, CodSpacing.xs + 2)
            .background(
                isSelected
                    ? AnyShapeStyle(Color.capeCod.oceanGradient)
                    : AnyShapeStyle(Color.capeCod.oceanBlue.opacity(0.12))
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.capeCod.oceanBlue.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color.capeCod.oceanBlue.opacity(0.3) : .clear, radius: 6)
            .scaleEffect(isSelected ? 1.08 : 1.0)
        }
        .buttonStyle(.plain)
        .position(x: x, y: y)
    }

    private func townDots(for region: CapeCodRegion, in size: CGSize) -> some View {
        let positions = townPositions(for: region, in: size)

        return ForEach(Array(zip(region.towns, positions)), id: \.0) { town, pos in
            let isSelected = selectedTowns.contains(town)

            Button {
                withAnimation(CodAnimation.quick) {
                    if isSelected {
                        selectedTowns.remove(town)
                    } else {
                        selectedTowns.insert(town)
                    }
                }
                CodHaptic.light()
            } label: {
                VStack(spacing: 1) {
                    Circle()
                        .fill(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.driftwood)
                        .frame(width: isSelected ? 10 : 7, height: isSelected ? 10 : 7)
                        .shadow(color: isSelected ? Color.capeCod.oceanBlue.opacity(0.4) : .clear, radius: 3)

                    Text(town)
                        .font(.system(size: 8, weight: isSelected ? .bold : .medium))
                        .foregroundStyle(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.textSecondary)
                }
            }
            .buttonStyle(.plain)
            .position(x: pos.x, y: pos.y)
            .transition(.scale.combined(with: .opacity))
        }
    }

    private func townPositions(for region: CapeCodRegion, in size: CGSize) -> [CGPoint] {
        let w = size.width
        let h = size.height

        switch region {
        case .upperCape:
            return [
                CGPoint(x: w * 0.10, y: h * 0.48),  // Bourne
                CGPoint(x: w * 0.12, y: h * 0.78),  // Falmouth
                CGPoint(x: w * 0.24, y: h * 0.48),  // Sandwich
                CGPoint(x: w * 0.24, y: h * 0.72),  // Mashpee
            ]
        case .midCape:
            return [
                CGPoint(x: w * 0.38, y: h * 0.60),  // Barnstable
                CGPoint(x: w * 0.46, y: h * 0.62),  // Yarmouth
                CGPoint(x: w * 0.50, y: h * 0.42),  // Dennis
            ]
        case .lowerCape:
            return [
                CGPoint(x: w * 0.58, y: h * 0.50),  // Harwich
                CGPoint(x: w * 0.62, y: h * 0.28),  // Brewster
                CGPoint(x: w * 0.72, y: h * 0.50),  // Chatham
                CGPoint(x: w * 0.70, y: h * 0.28),  // Orleans
            ]
        case .outerCape:
            return [
                CGPoint(x: w * 0.77, y: h * 0.20),  // Eastham
                CGPoint(x: w * 0.82, y: h * 0.12),  // Wellfleet
                CGPoint(x: w * 0.88, y: h * 0.15),  // Truro
                CGPoint(x: w * 0.92, y: h * 0.28),  // Provincetown
            ]
        }
    }
}

// MARK: - Cape Cod Shape

/// Simplified Cape Cod peninsula silhouette.
struct CapeCodShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        var path = Path()

        // Cape Cod is roughly an arm flexing — start from canal area (upper cape)
        // and curve up through outer cape to Provincetown hook
        path.move(to: CGPoint(x: w * 0.05, y: h * 0.55))

        // Upper Cape — south shore
        path.addCurve(
            to: CGPoint(x: w * 0.30, y: h * 0.65),
            control1: CGPoint(x: w * 0.12, y: h * 0.70),
            control2: CGPoint(x: w * 0.20, y: h * 0.68)
        )

        // Mid Cape — south shore
        path.addCurve(
            to: CGPoint(x: w * 0.55, y: h * 0.55),
            control1: CGPoint(x: w * 0.38, y: h * 0.62),
            control2: CGPoint(x: w * 0.48, y: h * 0.58)
        )

        // Lower Cape — elbow
        path.addCurve(
            to: CGPoint(x: w * 0.72, y: h * 0.40),
            control1: CGPoint(x: w * 0.62, y: h * 0.52),
            control2: CGPoint(x: w * 0.68, y: h * 0.46)
        )

        // Outer Cape — forearm going up
        path.addCurve(
            to: CGPoint(x: w * 0.85, y: h * 0.15),
            control1: CGPoint(x: w * 0.76, y: h * 0.32),
            control2: CGPoint(x: w * 0.82, y: h * 0.22)
        )

        // Provincetown hook
        path.addCurve(
            to: CGPoint(x: w * 0.92, y: h * 0.30),
            control1: CGPoint(x: w * 0.88, y: h * 0.10),
            control2: CGPoint(x: w * 0.95, y: h * 0.18)
        )

        // Return along north shore (bay side)
        path.addCurve(
            to: CGPoint(x: w * 0.70, y: h * 0.25),
            control1: CGPoint(x: w * 0.90, y: h * 0.32),
            control2: CGPoint(x: w * 0.78, y: h * 0.28)
        )

        // North shore mid cape
        path.addCurve(
            to: CGPoint(x: w * 0.35, y: h * 0.42),
            control1: CGPoint(x: w * 0.58, y: h * 0.22),
            control2: CGPoint(x: w * 0.45, y: h * 0.35)
        )

        // Canal area — north
        path.addCurve(
            to: CGPoint(x: w * 0.05, y: h * 0.55),
            control1: CGPoint(x: w * 0.22, y: h * 0.48),
            control2: CGPoint(x: w * 0.10, y: h * 0.50)
        )

        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationStack {
        AreaPickerView(
            selectedRegions: .constant(["midCape"]),
            selectedTowns: .constant(["Dennis"])
        )
    }
}
