import SwiftUI
import StoreKit

// MARK: - Data Models

struct FeedbackItem: Codable, Identifiable {
    let id: UUID
    var category: FeedbackCategory
    var subject: String
    var description: String
    var relatedFeature: String?
    var rating: Int?
    var email: String?
    var status: FeedbackStatus
    var submittedAt: Date

    init(
        id: UUID = UUID(),
        category: FeedbackCategory,
        subject: String,
        description: String,
        relatedFeature: String? = nil,
        rating: Int? = nil,
        email: String? = nil,
        status: FeedbackStatus = .submitted,
        submittedAt: Date = Date()
    ) {
        self.id = id
        self.category = category
        self.subject = subject
        self.description = description
        self.relatedFeature = relatedFeature
        self.rating = rating
        self.email = email
        self.status = status
        self.submittedAt = submittedAt
    }
}

enum FeedbackCategory: String, Codable, CaseIterable {
    case bugReport = "Bug Report"
    case dataCorrection = "Data Correction"
    case featureRequest = "Feature Request"
    case generalFeedback = "General Feedback"
    case compliment = "Compliment"

    var icon: String {
        switch self {
        case .bugReport: return "ladybug"
        case .dataCorrection: return "exclamationmark.triangle"
        case .featureRequest: return "lightbulb.fill"
        case .generalFeedback: return "bubble.left.fill"
        case .compliment: return "heart.fill"
        }
    }

    var color: Color {
        switch self {
        case .bugReport: return Color.capeCod.lobsterRed
        case .dataCorrection: return Color.capeCod.sunsetOrange
        case .featureRequest: return Color.capeCod.oceanBlue
        case .generalFeedback: return Color.capeCod.driftwood
        case .compliment: return Color.capeCod.cranberry
        }
    }
}

enum FeedbackStatus: String, Codable, CaseIterable {
    case submitted = "Submitted"
    case underReview = "Under Review"
    case implemented = "Implemented"
    case noted = "Noted"

    var color: Color {
        switch self {
        case .submitted: return Color.capeCod.oceanBlue
        case .underReview: return Color.capeCod.sunsetOrange
        case .implemented: return Color.capeCod.duneGrass
        case .noted: return Color.capeCod.driftwood
        }
    }

    var icon: String {
        switch self {
        case .submitted: return "paperplane.fill"
        case .underReview: return "eye.fill"
        case .implemented: return "checkmark.circle.fill"
        case .noted: return "bookmark.fill"
        }
    }
}

// MARK: - Feature Vote Model

struct FeatureVoteItem: Identifiable {
    let id: String
    let title: String
    let icon: String
    let description: String
}

// MARK: - Feedback Manager

@Observable
final class FeedbackManager {
    static let shared = FeedbackManager()

    private let feedbackKey = "com.heycapecod.feedback.items"
    private let votesKey = "com.heycapecod.feedback.votes"
    private let votedFeaturesKey = "com.heycapecod.feedback.votedFeatures"

    var feedbackItems: [FeedbackItem] = []
    var featureVotes: [String: Int] = [:]
    var votedFeatureIDs: Set<String> = []

    private init() {
        loadFeedback()
        loadVotes()
    }

    // MARK: - Feedback CRUD

    func submitFeedback(_ item: FeedbackItem) {
        feedbackItems.insert(item, at: 0)
        saveFeedback()
    }

    func deleteFeedback(_ item: FeedbackItem) {
        feedbackItems.removeAll { $0.id == item.id }
        saveFeedback()
    }

    // MARK: - Feature Voting

    func toggleVote(for featureID: String) {
        if votedFeatureIDs.contains(featureID) {
            votedFeatureIDs.remove(featureID)
            featureVotes[featureID, default: 0] -= 1
            if featureVotes[featureID, default: 0] <= 0 {
                featureVotes.removeValue(forKey: featureID)
            }
        } else {
            votedFeatureIDs.insert(featureID)
            featureVotes[featureID, default: 0] += 1
        }
        saveVotes()
    }

    func hasVoted(for featureID: String) -> Bool {
        votedFeatureIDs.contains(featureID)
    }

    func voteCount(for featureID: String) -> Int {
        featureVotes[featureID, default: 0]
    }

    // MARK: - Persistence

    private func saveFeedback() {
        guard let data = try? JSONEncoder().encode(feedbackItems) else { return }
        UserDefaults.standard.set(data, forKey: feedbackKey)
    }

    private func loadFeedback() {
        guard let data = UserDefaults.standard.data(forKey: feedbackKey),
              let items = try? JSONDecoder().decode([FeedbackItem].self, from: data) else { return }
        feedbackItems = items
    }

    private func saveVotes() {
        UserDefaults.standard.set(featureVotes, forKey: votesKey)
        let votedArray = Array(votedFeatureIDs)
        UserDefaults.standard.set(votedArray, forKey: votedFeaturesKey)
    }

    private func loadVotes() {
        if let votes = UserDefaults.standard.dictionary(forKey: votesKey) as? [String: Int] {
            featureVotes = votes
        }
        if let voted = UserDefaults.standard.stringArray(forKey: votedFeaturesKey) {
            votedFeatureIDs = Set(voted)
        }
    }
}

// MARK: - App Sections for "Related Feature"

private let appSections = [
    "Home",
    "Explore / Map",
    "Tours",
    "Dining",
    "Weather & Tides",
    "Traffic & Bridge",
    "Events",
    "Beach Conditions",
    "Stories",
    "Voice Assistant",
    "Chat",
    "Profile / Settings",
    "Other"
]

// MARK: - Feature Vote Data

private let potentialFeatures: [FeatureVoteItem] = [
    FeatureVoteItem(id: "beach_cam", title: "Live Beach Cam Integration", icon: "video.fill", description: "Watch real-time beach conditions from webcams"),
    FeatureVoteItem(id: "tide_pool", title: "Tide Pool Finder", icon: "drop.fill", description: "Discover the best tide pools at low tide"),
    FeatureVoteItem(id: "bingo", title: "Cape Cod Bingo Card", icon: "square.grid.3x3.fill", description: "Fun scavenger hunt across the Cape"),
    FeatureVoteItem(id: "waitlist", title: "Restaurant Waitlist Alerts", icon: "bell.badge.fill", description: "Get notified when your table is ready"),
    FeatureVoteItem(id: "fishing", title: "Fishing Report & Spots", icon: "fish.fill", description: "Daily fishing conditions and top spots"),
    FeatureVoteItem(id: "trivia", title: "Cape Cod Trivia Quiz", icon: "questionmark.bubble.fill", description: "Test your Cape Cod knowledge"),
    FeatureVoteItem(id: "kayak", title: "Kayak & SUP Rental Finder", icon: "figure.water.fitness", description: "Find nearby paddling rentals"),
    FeatureVoteItem(id: "pet_beach", title: "Pet-Friendly Beach Guide", icon: "pawprint.fill", description: "Beaches that welcome your furry friend"),
    FeatureVoteItem(id: "sunset", title: "Sunset Countdown Timer", icon: "sunset.fill", description: "Never miss golden hour again"),
    FeatureVoteItem(id: "bucket_list", title: "Cape Cod Bucket List Builder", icon: "checklist", description: "Create and track your Cape Cod must-dos"),
]

// MARK: - Feedback View

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showNewFeedbackForm = false
    @State private var expandedSection: FeedbackSection? = .submitFeedback

    private var manager: FeedbackManager { FeedbackManager.shared }

    enum FeedbackSection: Hashable {
        case submitFeedback
        case pastSubmissions
        case featureVoting
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.sectionSpacing) {
                headerSection
                    .staggered(index: 0)

                submitFeedbackSection
                    .staggered(index: 1)

                pastSubmissionsSection
                    .staggered(index: 2)

                featureVotingSection
                    .staggered(index: 3)

                quickActionsSection
                    .staggered(index: 4)
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.tabBarClearance)
        }
        .background(Color.capeCod.background)
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showNewFeedbackForm) {
            NavigationStack {
                FeedbackFormView(manager: manager)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.capeCod.oceanBlue, Color.capeCod.seafoam],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("We'd Love Your Feedback")
                .codTextStyle(.sectionTitle)

            Text("Help us make Hey Cape Cod even better. Your ideas and reports shape the future of this app.")
                .codTextStyle(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.capeCod.textSecondary)
                .padding(.horizontal, CodSpacing.md)
        }
        .padding(.top, CodSpacing.lg)
    }

    // MARK: - Submit Feedback

    private var submitFeedbackSection: some View {
        VStack(spacing: CodSpacing.md) {
            sectionHeader(title: "Submit Feedback", icon: "square.and.pencil")

            Button {
                CodHaptic.tap()
                showNewFeedbackForm = true
            } label: {
                HStack(spacing: CodSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.capeCod.oceanBlue.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.capeCod.oceanBlue)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("New Feedback")
                            .codTextStyle(.cardTitle)
                        Text("Report a bug, suggest a feature, or share your thoughts")
                            .codTextStyle(.caption)
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.capeCod.driftwood)
                }
                .padding(CodSpacing.cardPadding)
                .background(Color.capeCod.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
                .adaptiveCardStyle()
            }
            .buttonStyle(CodButtonPressStyle(variant: .ghost))
        }
    }

    // MARK: - Past Submissions

    private var pastSubmissionsSection: some View {
        VStack(spacing: CodSpacing.md) {
            sectionHeader(title: "Past Submissions", icon: "clock.arrow.circlepath")

            if manager.feedbackItems.isEmpty {
                emptyStateCard(
                    icon: "tray",
                    message: "No feedback submitted yet. Tap above to share your first thought!"
                )
            } else {
                ForEach(manager.feedbackItems.prefix(5)) { item in
                    FeedbackItemRow(item: item, onDelete: {
                        withAnimation(CodAnimation.spring) {
                            manager.deleteFeedback(item)
                        }
                    })
                }

                if manager.feedbackItems.count > 5 {
                    Text("\(manager.feedbackItems.count - 5) more submissions")
                        .codTextStyle(.caption)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }

    // MARK: - Feature Voting

    private var featureVotingSection: some View {
        VStack(spacing: CodSpacing.md) {
            sectionHeader(title: "Vote for Features", icon: "hand.thumbsup.fill")

            Text("Which features should we build next? Your votes help us prioritize.")
                .codTextStyle(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(sortedFeatures) { feature in
                FeatureVoteRow(
                    feature: feature,
                    voteCount: manager.voteCount(for: feature.id),
                    hasVoted: manager.hasVoted(for: feature.id),
                    onVote: {
                        withAnimation(CodAnimation.quick) {
                            manager.toggleVote(for: feature.id)
                        }
                        CodHaptic.selection()
                    }
                )
            }
        }
    }

    private var sortedFeatures: [FeatureVoteItem] {
        potentialFeatures.sorted { manager.voteCount(for: $0.id) > manager.voteCount(for: $1.id) }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(spacing: CodSpacing.md) {
            sectionHeader(title: "Quick Actions", icon: "bolt.fill")

            QuickActionButton(
                icon: "star.fill",
                title: "Rate Us on App Store",
                subtitle: "A 5-star review goes a long way",
                color: Color.capeCod.sandbarYellow
            ) {
                CodHaptic.tap()
                requestAppStoreReview()
            }

            QuickActionButton(
                icon: "square.and.arrow.up",
                title: "Tell a Friend",
                subtitle: "Share Hey Cape Cod with someone",
                color: Color.capeCod.oceanBlue
            ) {
                CodHaptic.tap()
                shareApp()
            }

            QuickActionButton(
                icon: "person.3.fill",
                title: "Join Our Community",
                subtitle: "Connect with fellow Cape lovers",
                color: Color.capeCod.seafoam
            ) {
                CodHaptic.tap()
                if let url = URL(string: "https://heycapecod.com/community") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: CodSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.capeCod.oceanBlue)
            Text(title)
                .codTextStyle(.sectionTitle)
            Spacer()
        }
        .codAccessibleHeader(title)
    }

    private func emptyStateCard(icon: String, message: String) -> some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(Color.capeCod.driftwood.opacity(0.4))
            Text(message)
                .codTextStyle(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(CodSpacing.xl)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }

    private func requestAppStoreReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }
        SKStoreReviewController.requestReview(in: scene)
    }

    private func shareApp() {
        let text = "Check out Hey Cape Cod — the ultimate Cape Cod travel app!"
        let url = URL(string: "https://apps.apple.com/app/hey-cape-cod/id0000000000")!
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        rootVC.present(activityVC, animated: true)
    }
}

// MARK: - Feedback Item Row

private struct FeedbackItemRow: View {
    let item: FeedbackItem
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            HStack(spacing: CodSpacing.sm) {
                Image(systemName: item.category.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(item.category.color)

                Text(item.subject)
                    .codTextStyle(.cardTitle)
                    .lineLimit(1)

                Spacer()

                statusBadge
            }

            Text(item.description)
                .codTextStyle(.caption)
                .lineLimit(2)

            HStack {
                Text(item.category.rawValue)
                    .codTextStyle(.label)
                    .foregroundStyle(item.category.color)

                Spacer()

                Text(item.submittedAt, style: .relative)
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.driftwood)
            }
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: item.status.icon)
                .font(.system(size: 10))
            Text(item.status.rawValue)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(item.status.color)
        .padding(.horizontal, CodSpacing.sm)
        .padding(.vertical, 3)
        .background(item.status.color.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - Feature Vote Row

private struct FeatureVoteRow: View {
    let feature: FeatureVoteItem
    let voteCount: Int
    let hasVoted: Bool
    let onVote: () -> Void

    var body: some View {
        HStack(spacing: CodSpacing.md) {
            Image(systemName: feature.icon)
                .font(.system(size: 20))
                .foregroundStyle(hasVoted ? Color.capeCod.oceanBlue : Color.capeCod.driftwood)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .codTextStyle(.cardTitle)
                Text(feature.description)
                    .codTextStyle(.caption)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: onVote) {
                VStack(spacing: 2) {
                    Image(systemName: hasVoted ? "arrow.up.circle.fill" : "arrow.up.circle")
                        .font(.system(size: 22))
                        .foregroundStyle(hasVoted ? Color.capeCod.oceanBlue : Color.capeCod.driftwood)
                        .scaleEffect(hasVoted ? 1.1 : 1.0)

                    if voteCount > 0 {
                        Text("\(voteCount)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(hasVoted ? Color.capeCod.oceanBlue : Color.capeCod.driftwood)
                    }
                }
            }
            .buttonStyle(.plain)
            .codAccessibleButton(
                "\(hasVoted ? "Remove vote for" : "Vote for") \(feature.title)",
                hint: "\(voteCount) votes"
            )
        }
        .padding(CodSpacing.cardPadding)
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
        .adaptiveCardStyle()
    }
}

// MARK: - Quick Action Button

private struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CodSpacing.md) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .codTextStyle(.cardTitle)
                    Text(subtitle)
                        .codTextStyle(.caption)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.capeCod.driftwood)
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .adaptiveCardStyle()
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
        .codAccessibleButton(title, hint: subtitle)
    }
}

// MARK: - Feedback Form View

struct FeedbackFormView: View {
    @Environment(\.dismiss) private var dismiss
    var manager: FeedbackManager

    @State private var selectedCategory: FeedbackCategory = .generalFeedback
    @State private var subject = ""
    @State private var descriptionText = ""
    @State private var relatedFeature: String?
    @State private var rating: Int?
    @State private var email = ""
    @State private var showRelatedFeaturePicker = false
    @State private var isSubmitting = false

    private var canSubmit: Bool {
        !subject.trimmingCharacters(in: .whitespaces).isEmpty &&
        !descriptionText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.lg) {
                categoryPicker
                subjectField
                descriptionField
                relatedFeatureSelector
                ratingSelector
                emailField
                submitButton
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.xxl)
        }
        .background(Color.capeCod.background)
        .navigationTitle("New Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }
        }
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("CATEGORY")
                .codTextStyle(.label)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CodSpacing.sm) {
                    ForEach(FeedbackCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            category: category,
                            isSelected: selectedCategory == category,
                            onTap: {
                                withAnimation(CodAnimation.quick) {
                                    selectedCategory = category
                                }
                                CodHaptic.selection()
                            }
                        )
                    }
                }
                .padding(.horizontal, 1)
            }
        }
        .padding(.top, CodSpacing.md)
    }

    // MARK: - Subject Field

    private var subjectField: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("SUBJECT")
                .codTextStyle(.label)

            TextField("Brief summary of your feedback", text: $subject)
                .codTextStyle(.body)
                .padding(CodSpacing.cardPadding)
                .background(Color.capeCod.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous)
                        .stroke(Color.capeCod.cardBorder, lineWidth: 1)
                )
        }
    }

    // MARK: - Description Field

    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("DESCRIPTION")
                .codTextStyle(.label)

            TextEditor(text: $descriptionText)
                .codTextStyle(.body)
                .frame(minHeight: 120)
                .scrollContentBackground(.hidden)
                .padding(CodSpacing.sm)
                .background(Color.capeCod.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous)
                        .stroke(Color.capeCod.cardBorder, lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if descriptionText.isEmpty {
                        Text("Tell us more about your feedback...")
                            .codTextStyle(.body)
                            .foregroundStyle(Color.capeCod.driftwood.opacity(0.5))
                            .padding(.horizontal, CodSpacing.sm + 4)
                            .padding(.vertical, CodSpacing.sm + 8)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    // MARK: - Related Feature

    private var relatedFeatureSelector: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("RELATED FEATURE")
                .codTextStyle(.label)

            Text("Optional: which part of the app is this about?")
                .codTextStyle(.caption)

            Button {
                showRelatedFeaturePicker.toggle()
            } label: {
                HStack {
                    Text(relatedFeature ?? "Select a section...")
                        .codTextStyle(.body)
                        .foregroundStyle(relatedFeature != nil ? Color.capeCod.textPrimary : Color.capeCod.driftwood.opacity(0.5))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.capeCod.driftwood)
                        .rotationEffect(.degrees(showRelatedFeaturePicker ? 180 : 0))
                }
                .padding(CodSpacing.cardPadding)
                .background(Color.capeCod.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous)
                        .stroke(Color.capeCod.cardBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            if showRelatedFeaturePicker {
                relatedFeatureList
                    .transition(.codScale)
            }
        }
        .animation(CodAnimation.quick, value: showRelatedFeaturePicker)
    }

    private var relatedFeatureList: some View {
        VStack(spacing: 0) {
            ForEach(appSections, id: \.self) { section in
                Button {
                    withAnimation(CodAnimation.quick) {
                        relatedFeature = section
                        showRelatedFeaturePicker = false
                    }
                    CodHaptic.selection()
                } label: {
                    HStack {
                        Text(section)
                            .codTextStyle(.body)
                            .foregroundStyle(Color.capeCod.textPrimary)
                        Spacer()
                        if relatedFeature == section {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.capeCod.oceanBlue)
                        }
                    }
                    .padding(.horizontal, CodSpacing.cardPadding)
                    .padding(.vertical, CodSpacing.sm + 2)
                }
                .buttonStyle(.plain)

                if section != appSections.last {
                    Divider()
                        .padding(.leading, CodSpacing.cardPadding)
                }
            }
        }
        .background(Color.capeCod.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous)
                .stroke(Color.capeCod.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Rating

    private var ratingSelector: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("APP SATISFACTION")
                .codTextStyle(.label)

            Text("How would you rate your overall experience?")
                .codTextStyle(.caption)

            HStack(spacing: CodSpacing.md) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        withAnimation(CodAnimation.bouncy) {
                            rating = rating == star ? nil : star
                        }
                        CodHaptic.selection()
                    } label: {
                        Image(systemName: (rating ?? 0) >= star ? "star.fill" : "star")
                            .font(.system(size: 28))
                            .foregroundStyle(
                                (rating ?? 0) >= star
                                    ? Color.capeCod.sandbarYellow
                                    : Color.capeCod.driftwood.opacity(0.3)
                            )
                            .scaleEffect((rating ?? 0) >= star ? 1.1 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .codAccessibleButton("Rate \(star) star\(star == 1 ? "" : "s")")
                }

                Spacer()

                if let rating {
                    Text(ratingLabel(for: rating))
                        .codTextStyle(.caption)
                        .foregroundStyle(Color.capeCod.sandbarYellow)
                        .transition(.codScale)
                }
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous)
                    .stroke(Color.capeCod.cardBorder, lineWidth: 1)
            )
        }
    }

    private func ratingLabel(for value: Int) -> String {
        switch value {
        case 1: return "Needs Work"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Great"
        case 5: return "Amazing!"
        default: return ""
        }
    }

    // MARK: - Email

    private var emailField: some View {
        VStack(alignment: .leading, spacing: CodSpacing.sm) {
            Text("EMAIL (OPTIONAL)")
                .codTextStyle(.label)

            Text("Leave your email if you'd like us to follow up")
                .codTextStyle(.caption)

            TextField("your@email.com", text: $email)
                .codTextStyle(.body)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(CodSpacing.cardPadding)
                .background(Color.capeCod.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CodRadius.input, style: .continuous)
                        .stroke(Color.capeCod.cardBorder, lineWidth: 1)
                )
        }
    }

    // MARK: - Submit

    private var submitButton: some View {
        Button {
            submitFeedback()
        } label: {
            HStack(spacing: CodSpacing.sm) {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                    Text("Submit Feedback")
                }
            }
            .codTextStyle(.cardTitle)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                canSubmit
                    ? Color.capeCod.oceanBlue
                    : Color.capeCod.driftwood.opacity(0.3)
            )
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.button, style: .continuous))
        }
        .disabled(!canSubmit || isSubmitting)
        .buttonStyle(CodButtonPressStyle(variant: .primary))
        .codAccessibleButton("Submit Feedback", hint: canSubmit ? "Send your feedback" : "Fill in subject and description first")
        .padding(.top, CodSpacing.sm)
    }

    private func submitFeedback() {
        CodHaptic.tap()
        isSubmitting = true

        let item = FeedbackItem(
            category: selectedCategory,
            subject: subject.trimmingCharacters(in: .whitespaces),
            description: descriptionText.trimmingCharacters(in: .whitespaces),
            relatedFeature: relatedFeature,
            rating: rating,
            email: email.isEmpty ? nil : email.trimmingCharacters(in: .whitespaces),
            status: .submitted
        )

        // Simulate a brief network delay for polish
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            manager.submitFeedback(item)
            isSubmitting = false
            CodHaptic.success()
            dismiss()
        }
    }
}

// MARK: - Category Chip

private struct CategoryChip: View {
    let category: FeedbackCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CodSpacing.xs) {
                Image(systemName: category.icon)
                    .font(.system(size: 13))
                Text(category.rawValue)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(isSelected ? .white : category.color)
            .padding(.horizontal, CodSpacing.md)
            .padding(.vertical, CodSpacing.sm)
            .background(isSelected ? category.color : category.color.opacity(0.1))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .codAccessibleButton(
            category.rawValue,
            hint: isSelected ? "Currently selected" : "Double tap to select"
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FeedbackView()
    }
}

#Preview("Feedback Form") {
    NavigationStack {
        FeedbackFormView(manager: FeedbackManager.shared)
    }
}
