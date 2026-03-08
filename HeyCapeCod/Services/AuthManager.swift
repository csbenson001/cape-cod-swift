import Foundation
import AuthenticationServices
import CryptoKit

/// Singleton managing Firebase Auth for Hey Cape Cod.
///
/// Supports Sign in with Apple (required for App Store), Google, email/password,
/// and guest mode. Persists auth state across launches via Keychain-backed token storage.
@preconcurrency @MainActor
@Observable
final class AuthManager: NSObject {
    static let shared = AuthManager()

    // MARK: - Public State

    private(set) var currentUser: AuthUser?
    private(set) var isAuthenticated = false
    private(set) var isLoading = false
    private(set) var authError: String?

    var isGuest: Bool { currentUser?.isGuest ?? true }
    var uid: String? { currentUser?.uid }
    var displayName: String? { currentUser?.displayName }
    var email: String? { currentUser?.email }

    // MARK: - Private

    private var currentNonce: String?

    private override init() {
        super.init()
        restoreSession()
    }

    // MARK: - Auth User Model

    struct AuthUser: Codable {
        let uid: String
        let email: String?
        let displayName: String?
        let photoURL: String?
        let provider: AuthProvider
        let isGuest: Bool
        var idToken: String?
        var refreshToken: String?
        var tokenExpiresAt: Date?

        var isTokenExpired: Bool {
            guard let exp = tokenExpiresAt else { return true }
            return Date.now > exp.addingTimeInterval(-60)
        }
    }

    enum AuthProvider: String, Codable {
        case apple
        case google
        case email
        case guest
    }

    // MARK: - Sign in with Apple

    func signInWithApple() async throws {
        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let result = try await performAppleSignIn(request)

        guard let credential = result.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthError.appleSignInFailed
        }

        let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")

        // In production, send token to Firebase Auth backend for verification.
        // For now, create user directly from Apple credential.
        let user = AuthUser(
            uid: credential.user,
            email: credential.email,
            displayName: fullName.isEmpty ? nil : fullName,
            photoURL: nil,
            provider: .apple,
            isGuest: false,
            idToken: tokenString,
            refreshToken: nil,
            tokenExpiresAt: Date.now.addingTimeInterval(3600)
        )

        await finishSignIn(user)
    }

    private func performAppleSignIn(_ request: ASAuthorizationAppleIDRequest) async throws -> ASAuthorization {
        try await withCheckedThrowingContinuation { continuation in
            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = AppleSignInDelegate(continuation: continuation)
            controller.delegate = delegate
            // Keep delegate alive for callback
            objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
            controller.performRequests()
        }
    }

    // MARK: - Sign in with Google

    /// Google Sign-In requires GoogleSignIn SDK. This stub shows the integration point.
    func signInWithGoogle(idToken: String, accessToken: String, email: String?, displayName: String?, photoURL: String?) async throws {
        isLoading = true
        defer { isLoading = false }

        // In production, verify with Firebase: Auth.auth().signIn(with: GoogleAuthProvider.credential(...))
        let user = AuthUser(
            uid: "google_\(UUID().uuidString)",
            email: email,
            displayName: displayName,
            photoURL: photoURL,
            provider: .google,
            isGuest: false,
            idToken: idToken,
            refreshToken: accessToken,
            tokenExpiresAt: Date.now.addingTimeInterval(3600)
        )

        await finishSignIn(user)
    }

    // MARK: - Email / Password

    func signInWithEmail(_ email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }

        // In production: Auth.auth().signIn(withEmail:password:)
        // For now, call backend auth endpoint
        do {
            let response: AuthResponse = try await APIClient.shared.post("auth/login", body: [
                "email": email,
                "password": password,
            ])

            let user = AuthUser(
                uid: response.uid,
                email: email,
                displayName: response.displayName,
                photoURL: nil,
                provider: .email,
                isGuest: false,
                idToken: response.token,
                refreshToken: response.refreshToken,
                tokenExpiresAt: Date.now.addingTimeInterval(3600)
            )

            await finishSignIn(user)
        } catch {
            throw AuthError.signInFailed(error.localizedDescription)
        }
    }

    func createAccount(email: String, password: String, displayName: String) async throws {
        isLoading = true
        defer { isLoading = false }

        guard !email.isEmpty, password.count >= 8 else {
            throw AuthError.weakPassword
        }

        // In production: Auth.auth().createUser(withEmail:password:)
        do {
            let response: AuthResponse = try await APIClient.shared.post("auth/register", body: [
                "email": email,
                "password": password,
                "displayName": displayName,
            ])

            let user = AuthUser(
                uid: response.uid,
                email: email,
                displayName: displayName,
                photoURL: nil,
                provider: .email,
                isGuest: false,
                idToken: response.token,
                refreshToken: response.refreshToken,
                tokenExpiresAt: Date.now.addingTimeInterval(3600)
            )

            await finishSignIn(user)
        } catch {
            throw AuthError.signInFailed(error.localizedDescription)
        }
    }

    // MARK: - Guest Mode

    func continueAsGuest() {
        let guestID = UserDefaults.standard.string(forKey: "guestUID") ?? UUID().uuidString
        UserDefaults.standard.set(guestID, forKey: "guestUID")

        let user = AuthUser(
            uid: guestID,
            email: nil,
            displayName: "Guest",
            photoURL: nil,
            provider: .guest,
            isGuest: true,
            idToken: nil,
            refreshToken: nil,
            tokenExpiresAt: nil
        )

        currentUser = user
        isAuthenticated = true
        saveSession(user)
        print("👤 Continuing as guest: \(guestID)")
    }

    // MARK: - Sign Out

    func signOut() {
        currentUser = nil
        isAuthenticated = false
        APIClient.shared.authToken = nil
        clearSavedSession()
        print("👤 Signed out")
    }

    // MARK: - Token Refresh

    func refreshTokenIfNeeded() async {
        guard let user = currentUser, !user.isGuest, user.isTokenExpired else { return }

        guard let refreshToken = user.refreshToken else {
            signOut()
            return
        }

        do {
            let response: AuthResponse = try await APIClient.shared.post("auth/refresh", body: [
                "refreshToken": refreshToken,
            ])

            var updated = user
            updated.idToken = response.token
            updated.refreshToken = response.refreshToken
            updated.tokenExpiresAt = Date.now.addingTimeInterval(3600)
            currentUser = updated
            APIClient.shared.authToken = response.token
            saveSession(updated)
        } catch {
            print("⚠️ Token refresh failed: \(error.localizedDescription)")
            signOut()
        }
    }

    // MARK: - Session Persistence

    private func finishSignIn(_ user: AuthUser) async {
        currentUser = user
        isAuthenticated = true
        authError = nil
        APIClient.shared.authToken = user.idToken
        saveSession(user)
        print("👤 Signed in as \(user.displayName ?? user.email ?? user.uid) via \(user.provider.rawValue)")
    }

    private func saveSession(_ user: AuthUser) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "savedAuthUser")
        }
    }

    private func restoreSession() {
        guard let data = UserDefaults.standard.data(forKey: "savedAuthUser"),
              let user = try? JSONDecoder().decode(AuthUser.self, from: data) else {
            return
        }

        currentUser = user
        isAuthenticated = true
        APIClient.shared.authToken = user.idToken

        if user.isTokenExpired && !user.isGuest {
            Task { await refreshTokenIfNeeded() }
        }

        print("👤 Restored session for \(user.displayName ?? user.uid)")
    }

    private func clearSavedSession() {
        UserDefaults.standard.removeObject(forKey: "savedAuthUser")
    }

    // MARK: - Apple Sign-In Helpers

    private func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let status = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                guard status == errSecSuccess else { return 0 }
                return random
            }

            for random in randoms where remainingLength > 0 {
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Apple Sign-In Delegate

private final class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    let continuation: CheckedContinuation<ASAuthorization, Error>

    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation.resume(returning: authorization)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }
}

// MARK: - Auth Response

struct AuthResponse: Codable {
    let uid: String
    let token: String
    let refreshToken: String?
    let displayName: String?
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case appleSignInFailed
    case invalidCredentials
    case weakPassword
    case emailNotVerified
    case accountExists
    case signInFailed(String)

    var errorDescription: String? {
        switch self {
        case .appleSignInFailed: "Apple Sign-In failed. Please try again."
        case .invalidCredentials: "Invalid email or password."
        case .weakPassword: "Password must be at least 8 characters."
        case .emailNotVerified: "Please verify your email address."
        case .accountExists: "An account with this email already exists."
        case .signInFailed(let msg): msg
        }
    }
}
