import SwiftUI

struct ThemePickerView: View {
    @State private var selectedTheme: AppTheme = ThemeManager.shared.currentTheme

    var body: some View {
        VStack(spacing: CodSpacing.lg) {
            headerSection

            VStack(spacing: CodSpacing.md) {
                ForEach(AppTheme.allCases) { theme in
                    themeCard(theme)
                }
            }
            .padding(.horizontal, CodSpacing.screenEdge)

            Spacer()
        }
        .background(Color.capeCod.background)
        .navigationTitle("App Theme")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CodSpacing.sm) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.capeCod.oceanBlue)
                .symbolEffect(.pulse, options: .repeating.speed(0.5))

            Text("Choose Your Vibe")
                .codTextStyle(.sectionTitle)

            Text("Colors change throughout the app")
                .codTextStyle(.caption)
                .foregroundStyle(Color.capeCod.textSecondary)
        }
        .padding(.top, CodSpacing.lg)
    }

    // MARK: - Theme Card

    private func themeCard(_ theme: AppTheme) -> some View {
        Button {
            withAnimation(CodAnimation.gentle) {
                selectedTheme = theme
                ThemeManager.shared.currentTheme = theme
            }
            CodHaptic.selection()
        } label: {
            HStack(spacing: CodSpacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(theme.palette.primary.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: theme.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(theme.palette.primary)
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.displayName)
                        .codTextStyle(.cardTitle)
                        .foregroundStyle(Color.capeCod.textPrimary)
                    Text(theme.subtitle)
                        .codTextStyle(.caption)
                        .foregroundStyle(Color.capeCod.textSecondary)
                }

                Spacer()

                // Preview dots
                HStack(spacing: 4) {
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(theme.previewColors[i])
                            .frame(width: 16, height: 16)
                    }
                }

                // Checkmark
                if selectedTheme == theme {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.capeCod.oceanBlue)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(CodSpacing.cardPadding)
            .background(Color.capeCod.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CodRadius.card, style: .continuous)
                    .strokeBorder(
                        selectedTheme == theme ? Color.capeCod.oceanBlue : Color.clear,
                        lineWidth: 2
                    )
            )
            .adaptiveCardStyle()
        }
        .buttonStyle(CodButtonPressStyle(variant: .ghost))
    }
}

#Preview {
    NavigationStack {
        ThemePickerView()
    }
}
