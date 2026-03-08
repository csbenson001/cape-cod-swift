import Foundation
import StoreKit

/// Manages StoreKit 2 subscriptions for Hey Cape Cod Premium.
///
/// Products:
/// - `capecod_monthly` — $4.99/month
/// - `capecod_annual` — $29.99/year (save 50%)
///
/// Handles purchasing, restoring, transaction listening, Family Sharing,
/// and server-side receipt verification.
@Observable
final class SubscriptionManager {
    static let shared = SubscriptionManager()

    // MARK: - Product IDs

    static let monthlyID = "capecod_monthly"
    static let annualID = "capecod_annual"
    static let productIDs: Set<String> = [monthlyID, annualID]

    // MARK: - Public State

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var isSubscribed = false
    private(set) var currentSubscription: Product.SubscriptionInfo.Status?
    private(set) var expirationDate: Date?
    private(set) var isLoading = false
    private(set) var purchaseError: String?

    var monthlyProduct: Product? { products.first { $0.id == Self.monthlyID } }
    var annualProduct: Product? { products.first { $0.id == Self.annualID } }

    // MARK: - Private

    private var updateListenerTask: Task<Void, Never>?

    private init() {
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: Self.productIDs)
            products = storeProducts.sorted { $0.price < $1.price }
            await updateSubscriptionStatus()
            print("🛒 Loaded \(products.count) products")
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    @discardableResult
    func purchase(_ product: Product) async throws -> Transaction? {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus()
            await transaction.finish()

            // Update user profile
            if let profile = UserProfileManager.shared.currentProfile {
                profile.isPremium = true
                profile.subscriptionProductId = product.id
                profile.originalTransactionId = String(transaction.originalID)
                if let expirationDate = transaction.expirationDate {
                    profile.premiumExpiresAt = expirationDate
                }
                UserProfileManager.shared.saveProfile()
            }

            // Verify with backend
            await verifyWithServer(transaction)

            print("🛒 Purchased \(product.id)")
            return transaction

        case .userCancelled:
            return nil

        case .pending:
            purchaseError = "Purchase is pending approval."
            return nil

        @unknown default:
            return nil
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        try? await AppStore.sync()
        await updateSubscriptionStatus()
        print("🛒 Restored purchases. Subscribed: \(isSubscribed)")
    }

    // MARK: - Subscription Status

    func updateSubscriptionStatus() async {
        var activeSubs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.productType == .autoRenewable {
                    activeSubs.insert(transaction.productID)

                    if let expires = transaction.expirationDate {
                        expirationDate = expires
                    }
                }
            }
        }

        purchasedProductIDs = activeSubs
        isSubscribed = !activeSubs.isEmpty

        // Sync to profile
        if let profile = UserProfileManager.shared.currentProfile {
            profile.isPremium = isSubscribed
            if let expires = expirationDate {
                profile.premiumExpiresAt = expires
            }
            if !isSubscribed {
                profile.subscriptionProductId = nil
                profile.premiumExpiresAt = nil
            }
            UserProfileManager.shared.saveProfile()
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if let transaction = try? self?.checkVerified(result) {
                    await self?.updateSubscriptionStatus()
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw SubscriptionError.verificationFailed(error.localizedDescription)
        case .verified(let value):
            return value
        }
    }

    // MARK: - Server Verification

    private func verifyWithServer(_ transaction: Transaction) async {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: appStoreReceiptURL) else {
            return
        }

        let receiptString = receiptData.base64EncodedString()

        struct VerifyRequest: Encodable {
            let receipt: String
            let productId: String
            let transactionId: String
        }

        let request = VerifyRequest(
            receipt: receiptString,
            productId: transaction.productID,
            transactionId: String(transaction.originalID)
        )

        do {
            let _: EmptyVerifyResponse = try await APIClient.shared.post("subscriptions/verify", body: request)
            print("🛒 Server verification complete")
        } catch {
            print("⚠️ Server verification failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers

    var annualSavingsPercent: Int {
        guard let monthly = monthlyProduct, let annual = annualProduct else { return 0 }
        let monthlyAnnualized = monthly.price * 12
        let savings = (monthlyAnnualized - annual.price) / monthlyAnnualized * 100
        return (savings as NSDecimalNumber).intValue
    }

    var currentPlanName: String {
        if purchasedProductIDs.contains(Self.annualID) { return "Annual" }
        if purchasedProductIDs.contains(Self.monthlyID) { return "Monthly" }
        return "Free"
    }
}

private struct EmptyVerifyResponse: Codable {}

// MARK: - Errors

enum SubscriptionError: LocalizedError {
    case verificationFailed(String)
    case purchaseFailed(String)

    var errorDescription: String? {
        switch self {
        case .verificationFailed(let msg): "Verification failed: \(msg)"
        case .purchaseFailed(let msg): "Purchase failed: \(msg)"
        }
    }
}
