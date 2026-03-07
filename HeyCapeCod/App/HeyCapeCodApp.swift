import SwiftUI
import SwiftData

@main
struct HeyCapeCodApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environment(appState)
            .preferredColorScheme(appState.preferredColorScheme)
            .onAppear {
                // Configure UserProfileManager with SwiftData context
                if let container = try? ModelContainer(for: UserProfile.self) {
                    let context = ModelContext(container)
                    UserProfileManager.shared.configure(with: context)

                    // Load profile for current user if authenticated
                    if let user = AuthManager.shared.currentUser {
                        UserProfileManager.shared.loadProfile(for: user)
                    }
                }
            }
        }
    }
}
