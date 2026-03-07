import SwiftUI

@main
struct HeyCapeCodApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(appState)
                .preferredColorScheme(appState.preferredColorScheme)
        }
    }
}
