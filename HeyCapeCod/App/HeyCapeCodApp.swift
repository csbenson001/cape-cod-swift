import SwiftUI
import SwiftData

@main
struct HeyCapeCodApp: App {
    @State private var appState = AppState()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
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
                    configureApp()
                }

                if showSplash {
                    SplashScreenView {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
    }

    private func configureApp() {
        // Configure UserProfileManager with SwiftData context
        if let container = try? ModelContainer(for: UserProfile.self) {
            let context = ModelContext(container)
            UserProfileManager.shared.configure(with: context)

            if let user = AuthManager.shared.currentUser {
                UserProfileManager.shared.loadProfile(for: user)
            }
        }

        // Warm up caches for fast content loading
        ContentPrefetcher.shared.warmUpOnLaunch()
    }
}
