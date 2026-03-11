import SwiftUI

struct ChatMemoryView: View {
    private var memoryManager: ChatMemoryManager { .shared }
    @State private var showingClearConfirmation = false

    var body: some View {
        List {
            enableSection
            privacyNotice
            if memoryManager.isEnabled {
                preferenceSections
                clearSection
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.capeCod.background)
        .navigationTitle("AI Memory")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Clear All Memory", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All", role: .destructive) {
                CodHaptic.tap()
                memoryManager.clearMemory()
            }
        } message: {
            Text("This will remove all saved preferences. This cannot be undone.")
        }
    }

    // MARK: - Enable Section

    private var enableSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { memoryManager.isEnabled },
                set: { newValue in
                    withAnimation(CodAnimation.gentle) {
                        memoryManager.isEnabled = newValue
                    }
                    CodHaptic.selection()
                }
            )) {
                HStack(spacing: CodSpacing.sm) {
                    Image(systemName: "brain")
                        .foregroundStyle(Color.capeCod.oceanBlue)
                    Text("Enable AI Memory")
                        .codTextStyle(.body)
                }
            }
            .toggleStyle(.capeCod)

            Text("When enabled, the assistant remembers your preferences to give better Cape Cod recommendations.")
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.textSecondary)
        } header: {
            Text("Memory")
        }
    }

    // MARK: - Privacy Notice

    private var privacyNotice: some View {
        Section {
            HStack(alignment: .top, spacing: CodSpacing.sm) {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(Color.capeCod.seafoam)
                    .font(.title3)

                Text("Your preferences are stored only on this device. Nothing is shared or uploaded.")
                    .codTextStyle(.caption)
                    .foregroundStyle(Color.capeCod.textSecondary)
            }
            .padding(.vertical, CodSpacing.xs)
        }
    }

    // MARK: - Preference Sections

    @ViewBuilder
    private var preferenceSections: some View {
        ForEach(MemoryCategory.allCases) { category in
            let prefs = memoryManager.preferences(for: category)
            if !prefs.isEmpty {
                Section {
                    PreferenceChipFlow(
                        category: category,
                        preferences: prefs,
                        onDelete: { value in
                            withAnimation(CodAnimation.quick) {
                                memoryManager.removePreference(category: category, value: value)
                            }
                            CodHaptic.tap()
                        }
                    )
                } header: {
                    Label(category.rawValue, systemImage: category.icon)
                }
            }
        }
    }

    // MARK: - Clear Section

    private var clearSection: some View {
        Section {
            Button(role: .destructive) {
                showingClearConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Clear All Memory")
                }
            }
            .disabled(memoryManager.totalPreferenceCount == 0)
        } footer: {
            if memoryManager.totalPreferenceCount > 0 {
                Text("\(memoryManager.totalPreferenceCount) saved preference\(memoryManager.totalPreferenceCount == 1 ? "" : "s") \u{00B7} Last updated \(memoryManager.memory.lastUpdated.formatted(.relative(presentation: .named)))")
                    .codTextStyle(.caption)
            }
        }
    }
}

// MARK: - Preference Chip Flow

private struct PreferenceChipFlow: View {
    let category: MemoryCategory
    let preferences: [String]
    let onDelete: (String) -> Void

    var body: some View {
        FlowLayout(spacing: CodSpacing.sm) {
            ForEach(preferences, id: \.self) { pref in
                PreferenceChip(text: pref) {
                    onDelete(pref)
                }
            }
        }
        .padding(.vertical, CodSpacing.xs)
    }
}

// MARK: - Preference Chip

private struct PreferenceChip: View {
    let text: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: CodSpacing.xs) {
            Text(text)
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.primaryText)

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(Color.capeCod.driftwood)
            }
            .codAccessibleButton("Remove \(text)")
        }
        .padding(.horizontal, CodSpacing.sm + 2)
        .padding(.vertical, CodSpacing.xs + 2)
        .background(Color.capeCod.oceanBlue.opacity(0.08))
        .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        ChatMemoryView()
    }
}
