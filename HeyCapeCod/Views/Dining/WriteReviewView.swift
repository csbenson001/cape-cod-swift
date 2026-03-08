import SwiftUI

/// Review submission form with star ratings, menu item ratings, tags, and text feedback.
/// Powers the feedback loop that improves recommendations over time.
struct WriteReviewView: View {
    @Environment(\.dismiss) private var dismiss

    let targetId: String
    let targetName: String
    let targetType: ReviewTarget
    var menuItems: [MenuItem] = []

    @State private var overallRating = 0
    @State private var reviewTitle = ""
    @State private var reviewBody = ""
    @State private var selectedTags: Set<ReviewTag> = []
    @State private var menuItemRatings: [String: Int] = [:]
    @State private var isSubmitting = false
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CodSpacing.sectionSpacing) {
                    // Overall rating
                    overallRatingSection

                    Divider()

                    // Menu item ratings (for restaurants)
                    if !menuItems.isEmpty {
                        menuRatingSection
                        Divider()
                    }

                    // Tags
                    tagSection

                    // Written review
                    textReviewSection

                    // Submit
                    submitButton
                }
                .padding(.horizontal, CodSpacing.screenEdge)
                .padding(.vertical, CodSpacing.lg)
            }
            .background(Color.capeCod.background)
            .navigationTitle("Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.capeCod.oceanBlue)
                }
            }
            .overlay {
                if showSuccess {
                    successOverlay
                }
            }
        }
    }

    // MARK: - Overall Rating

    private var overallRatingSection: some View {
        VStack(spacing: CodSpacing.md) {
            Text("How was \(targetName)?")
                .codTextStyle(.sectionTitle)

            HStack(spacing: CodSpacing.md) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        withAnimation(CodAnimation.quick) { overallRating = star }
                        CodHaptic.selection()
                    } label: {
                        Image(systemName: star <= overallRating ? "star.fill" : "star")
                            .font(.system(size: 36))
                            .foregroundStyle(star <= overallRating ? Color.capeCod.sandbarYellow : Color.capeCod.driftwood.opacity(0.3))
                    }
                    .codAccessibleButton("\(star) star\(star == 1 ? "" : "s")")
                }
            }

            if overallRating > 0 {
                Text(ratingLabel)
                    .codTextStyle(.body)
                    .foregroundStyle(Color.capeCod.textSecondary)
            }
        }
    }

    private var ratingLabel: String {
        switch overallRating {
        case 1: "Not great"
        case 2: "Could be better"
        case 3: "It was okay"
        case 4: "Really good!"
        case 5: "Amazing!"
        default: ""
        }
    }

    // MARK: - Menu Item Ratings

    private var menuRatingSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Rate What You Tried")
                .codTextStyle(.sectionTitle)

            Text("Your ratings help others know what to order")
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.textSecondary)

            ForEach(menuItems) { item in
                HStack(spacing: CodSpacing.md) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .codTextStyle(.body)
                        if let price = item.formattedPrice {
                            Text(price)
                                .codTextStyle(.label)
                                .foregroundStyle(Color.capeCod.textSecondary)
                        }
                    }

                    Spacer()

                    HStack(spacing: CodSpacing.xs) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                withAnimation(CodAnimation.quick) {
                                    menuItemRatings[item.id] = star
                                }
                                CodHaptic.selection()
                            } label: {
                                Image(systemName: star <= (menuItemRatings[item.id] ?? 0) ? "star.fill" : "star")
                                    .font(.system(size: 16))
                                    .foregroundStyle(
                                        star <= (menuItemRatings[item.id] ?? 0)
                                            ? Color.capeCod.sandbarYellow
                                            : Color.capeCod.driftwood.opacity(0.3)
                                    )
                            }
                        }
                    }
                }
                .padding(CodSpacing.sm)
                .background(Color.capeCod.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.sm, style: .continuous))
            }
        }
    }

    // MARK: - Tags

    private var tagSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("What stood out?")
                .codTextStyle(.sectionTitle)

            FlowLayout(spacing: CodSpacing.sm) {
                ForEach(ReviewTag.allCases) { tag in
                    Button {
                        withAnimation(CodAnimation.quick) {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        }
                        CodHaptic.selection()
                    } label: {
                        HStack(spacing: CodSpacing.xs) {
                            Image(systemName: tag.icon)
                                .font(.system(size: 12))
                            Text(tag.displayName)
                                .codTextStyle(.label)
                        }
                        .padding(.horizontal, CodSpacing.md)
                        .padding(.vertical, CodSpacing.sm)
                        .background(selectedTags.contains(tag) ? Color.capeCod.oceanBlue : Color.capeCod.surfaceElevated)
                        .foregroundStyle(selectedTags.contains(tag) ? .white : Color.capeCod.textPrimary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(CodButtonPressStyle(variant: .ghost))
                }
            }
        }
    }

    // MARK: - Text Review

    private var textReviewSection: some View {
        VStack(alignment: .leading, spacing: CodSpacing.md) {
            Text("Tell us more (optional)")
                .codTextStyle(.sectionTitle)

            TextField("Review title", text: $reviewTitle)
                .codTextStyle(.body)
                .padding(CodSpacing.md)
                .background(Color.capeCod.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))

            TextEditor(text: $reviewBody)
                .codTextStyle(.body)
                .frame(minHeight: 100)
                .padding(CodSpacing.sm)
                .scrollContentBackground(.hidden)
                .background(Color.capeCod.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
        }
    }

    // MARK: - Submit

    private var submitButton: some View {
        CodButton(
            isSubmitting ? "Submitting..." : "Submit Review",
            variant: .primary,
            icon: "paperplane.fill",
            isFullWidth: true
        ) {
            submitReview()
        }
        .disabled(overallRating == 0 || isSubmitting)
    }

    private func submitReview() {
        isSubmitting = true
        CodHaptic.tap()

        Task {
            let profile = UserProfileManager.shared.currentProfile
            let itemRatings = menuItemRatings.compactMap { (itemId, rating) -> MenuItemRating? in
                guard let item = menuItems.first(where: { $0.id == itemId }) else { return nil }
                return MenuItemRating(menuItemId: itemId, menuItemName: item.name, rating: rating, comment: nil)
            }

            let review = Review(
                id: UUID().uuidString,
                userId: profile?.uid ?? "anonymous",
                userName: profile?.displayName ?? "Guest",
                targetId: targetId,
                targetType: targetType,
                rating: overallRating,
                title: reviewTitle,
                body: reviewBody,
                visitDate: nil,
                createdAt: .now,
                menuItemRatings: itemRatings,
                tags: Array(selectedTags),
                helpfulCount: 0,
                reportCount: 0
            )

            do {
                try await ReviewService.shared.submitReview(review)
                if !itemRatings.isEmpty {
                    try await ReviewService.shared.submitMenuItemRatings(itemRatings, restaurantId: targetId)
                }
            } catch {
                // Store locally for later sync
                print("⚠️ Review stored locally: \(error.localizedDescription)")
            }

            isSubmitting = false
            CodHaptic.success()

            withAnimation(CodAnimation.spring) {
                showSuccess = true
            }

            try? await Task.sleep(for: .seconds(1.5))
            dismiss()
        }
    }

    // MARK: - Success Overlay

    private var successOverlay: some View {
        VStack(spacing: CodSpacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.capeCod.duneGrass)

            Text("Thanks for your review!")
                .codTextStyle(.sectionTitle)

            Text("Your feedback helps improve recommendations for everyone")
                .codTextStyle(.body)
                .foregroundStyle(Color.capeCod.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(CodSpacing.xxl)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .padding(CodSpacing.xxl)
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Flow Layout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: ProposedViewSize(width: bounds.width, height: bounds.height), subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

#Preview {
    WriteReviewView(
        targetId: "test",
        targetName: "The Lobster Pot",
        targetType: .restaurant,
        menuItems: BundledRestaurants.all.first?.menuHighlights ?? []
    )
}
