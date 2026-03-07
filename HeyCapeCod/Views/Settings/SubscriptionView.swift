import SwiftUI
import StoreKit

/// Premium upgrade screen with feature comparison, plan toggle, and purchase flow.
struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PlanType = .annual
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    private let subscriptionManager = SubscriptionManager.shared

    enum PlanType {
        case monthly, annual
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CodSpacing.lg) {
                // Hero
                heroSection

                // Feature Comparison
                featureComparison

                // Plan Selector
                planSelector

                // Subscribe Button
                subscribeButton

                // Free Trial Note
                freeTrialNote

                // Restore & Legal
                footerLinks
            }
            .padding(.horizontal, CodSpacing.screenEdge)
            .padding(.bottom, CodSpacing.xxl)
        }
        .background(Color.capeCod.background)
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .foregroundStyle(Color.capeCod.oceanBlue)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: CodSpacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.capeCod.sunsetOrange, Color.capeCod.oceanBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Hey Cape Cod Premium")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Color.capeCod.textPrimary)

            Text("Your complete Cape Cod companion — unlimited stories, voice conversations, offline access, and more.")
                .codTextStyle(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CodSpacing.lg)
        }
        .padding(.top, CodSpacing.lg)
    }

    // MARK: - Feature Comparison

    private var featureComparison: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Feature")
                    .codTextStyle(.label)
                Spacer()
                Text("Free")
                    .codTextStyle(.label)
                    .frame(width: 60)
                Text("Premium")
                    .codTextStyle(.label)
                    .foregroundStyle(Color.capeCod.sunsetOrange)
                    .frame(width: 72)
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.fog)

            Divider()

            featureRow("Voice Conversations", free: "3/day", premium: "Unlimited")
            featureRow("GPS Stories", free: "5/day", premium: "Unlimited")
            featureRow("Beach Conditions", free: true, premium: true)
            featureRow("Tide Charts", free: true, premium: true)
            featureRow("Traffic Updates", free: true, premium: true)
            featureRow("Offline Downloads", free: false, premium: true)
            featureRow("Ad-Free", free: false, premium: true)
            featureRow("Family Sharing", free: false, premium: true)
            featureRow("Priority Support", free: false, premium: true)
        }
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.card)
                .stroke(Color.capeCod.driftwood.opacity(0.2), lineWidth: 1)
        )
    }

    private func featureRow(_ name: String, free: Bool, premium: Bool) -> some View {
        HStack {
            Text(name)
                .codTextStyle(.body)
            Spacer()
            Image(systemName: free ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(free ? Color.capeCod.duneGrass : Color.capeCod.driftwood.opacity(0.4))
                .frame(width: 60)
            Image(systemName: premium ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(premium ? Color.capeCod.duneGrass : Color.capeCod.driftwood.opacity(0.4))
                .frame(width: 72)
        }
        .padding(.horizontal, CodSpacing.cardPadding)
        .padding(.vertical, CodSpacing.sm + 2)
        .background(Color.capeCod.surfaceElevated)
    }

    private func featureRow(_ name: String, free: String, premium: String) -> some View {
        HStack {
            Text(name)
                .codTextStyle(.body)
            Spacer()
            Text(free)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.capeCod.driftwood)
                .frame(width: 60)
            Text(premium)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.capeCod.duneGrass)
                .frame(width: 72)
        }
        .padding(.horizontal, CodSpacing.cardPadding)
        .padding(.vertical, CodSpacing.sm + 2)
        .background(Color.capeCod.surfaceElevated)
    }

    // MARK: - Plan Selector

    private var planSelector: some View {
        HStack(spacing: CodSpacing.md) {
            planCard(
                type: .monthly,
                title: "Monthly",
                price: subscriptionManager.monthlyProduct?.displayPrice ?? "$4.99",
                detail: "per month"
            )

            planCard(
                type: .annual,
                title: "Annual",
                price: subscriptionManager.annualProduct?.displayPrice ?? "$29.99",
                detail: "per year",
                badge: "Save \(subscriptionManager.annualSavingsPercent)%"
            )
        }
    }

    private func planCard(type: PlanType, title: String, price: String, detail: String, badge: String? = nil) -> some View {
        let isSelected = selectedPlan == type

        return VStack(spacing: CodSpacing.sm) {
            if let badge {
                Text(badge)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, CodSpacing.sm)
                    .padding(.vertical, 3)
                    .background(Color.capeCod.sunsetOrange)
                    .clipShape(Capsule())
            }

            Text(title)
                .codTextStyle(.cardTitle)

            Text(price)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.textPrimary)

            Text(detail)
                .codTextStyle(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding(CodSpacing.cardPadding)
        .background(isSelected ? Color.capeCod.oceanBlue.opacity(0.08) : Color.capeCod.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: CodRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: CodRadius.card)
                .stroke(isSelected ? Color.capeCod.oceanBlue : Color.capeCod.driftwood.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
        .onTapGesture { selectedPlan = type }
    }

    // MARK: - Subscribe Button

    private var subscribeButton: some View {
        Button {
            Task { await purchase() }
        } label: {
            Group {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Start Free Trial")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [Color.capeCod.oceanBlue, Color.capeCod.sunsetOrange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.button))
        }
        .disabled(isPurchasing)
    }

    // MARK: - Free Trial Note

    private var freeTrialNote: some View {
        VStack(spacing: CodSpacing.xs) {
            Text("7-day free trial, then auto-renews")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.capeCod.textSecondary)
            Text("Cancel anytime in Settings > Subscriptions")
                .font(.system(size: 11))
                .foregroundStyle(Color.capeCod.driftwood)
        }
    }

    // MARK: - Footer

    private var footerLinks: some View {
        VStack(spacing: CodSpacing.md) {
            Button("Restore Purchases") {
                Task { await subscriptionManager.restorePurchases() }
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Color.capeCod.oceanBlue)

            HStack(spacing: CodSpacing.lg) {
                Link("Terms of Use", destination: URL(string: "https://heycapecod.com/terms")!)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.capeCod.driftwood)

                Link("Privacy Policy", destination: URL(string: "https://heycapecod.com/privacy")!)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.capeCod.driftwood)
            }
        }
        .padding(.top, CodSpacing.sm)
    }

    // MARK: - Purchase Action

    private func purchase() async {
        isPurchasing = true
        defer { isPurchasing = false }

        let product: Product?
        switch selectedPlan {
        case .monthly: product = subscriptionManager.monthlyProduct
        case .annual: product = subscriptionManager.annualProduct
        }

        guard let product else {
            errorMessage = "Product not available. Please try again later."
            showError = true
            return
        }

        do {
            try await subscriptionManager.purchase(product)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    NavigationStack {
        SubscriptionView()
    }
}
