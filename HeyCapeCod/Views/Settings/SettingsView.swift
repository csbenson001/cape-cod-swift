import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTideStation: TideStation = .hyannis
    @State private var notificationsEnabled = true
    @State private var storyTriggersEnabled = true
    @State private var showingDesignSystem = false

    var body: some View {
        NavigationStack {
            List {
                // Appearance
                Section("Appearance") {
                    Picker("Theme", selection: Binding(
                        get: { appState.preferredColorScheme },
                        set: { appState.preferredColorScheme = $0 }
                    )) {
                        Text("System").tag(ColorScheme?.none)
                        Text("Light").tag(ColorScheme?.some(.light))
                        Text("Dark").tag(ColorScheme?.some(.dark))
                    }
                }

                // Location
                Section("Location & Stories") {
                    Picker("Tide Station", selection: $selectedTideStation) {
                        ForEach(TideStation.allCases) { station in
                            Text(station.name).tag(station)
                        }
                    }

                    Toggle("GPS Story Triggers", isOn: $storyTriggersEnabled)

                    Toggle("Notifications", isOn: $notificationsEnabled)
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://heycapecod.com")!) {
                        Text("Website")
                    }

                    Link(destination: URL(string: "https://heycapecod.com/privacy")!) {
                        Text("Privacy Policy")
                    }
                }

                // Developer
                #if DEBUG
                Section("Developer") {
                    Button("Design System Preview") {
                        showingDesignSystem = true
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingDesignSystem) {
                NavigationStack {
                    DesignSystemPreview()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
