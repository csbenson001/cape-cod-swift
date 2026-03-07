import SwiftUI

struct VoiceAssistantView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ConversationViewModel()
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Background
            Color.capeCod.deepNavy
                .ignoresSafeArea()

            VStack(spacing: CodSpacing.xl) {
                Spacer()

                // Status Text
                Text(statusText)
                    .codTextStyle(.subtitle)
                    .foregroundStyle(.white.opacity(0.8))

                // Transcribed Text
                if !viewModel.inputText.isEmpty {
                    Text(viewModel.inputText)
                        .codTextStyle(.body)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, CodSpacing.xl)
                }

                // Response
                if let lastAssistant = viewModel.messages.last(where: { $0.role == .assistant }) {
                    ScrollView {
                        Text(lastAssistant.content)
                            .codTextStyle(.body)
                            .foregroundStyle(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CodSpacing.xl)
                    }
                    .frame(maxHeight: 200)
                }

                Spacer()

                // Voice Button
                voiceButton

                // Close
                Button("Done") {
                    viewModel.stopListening()
                    dismiss()
                }
                .codTextStyle(.body)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.bottom, CodSpacing.xl)
            }
        }
    }

    private var statusText: String {
        if viewModel.isProcessing { return "Thinking..." }
        if viewModel.isListening { return "Listening..." }
        return "Tap to speak"
    }

    private var voiceButton: some View {
        Button {
            Task {
                if viewModel.isListening {
                    await viewModel.toggleListening()
                    if !viewModel.inputText.isEmpty {
                        await viewModel.sendMessage()
                    }
                } else {
                    await viewModel.toggleListening()
                }
            }
        } label: {
            ZStack {
                // Pulse rings
                if viewModel.isListening {
                    Circle()
                        .fill(Color.capeCod.oceanBlue.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseScale)

                    Circle()
                        .fill(Color.capeCod.oceanBlue.opacity(0.08))
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulseScale * 0.9)
                }

                // Main button
                Circle()
                    .fill(viewModel.isListening ? Color.capeCod.cranberry : Color.capeCod.oceanBlue)
                    .frame(width: 80, height: 80)

                Image(systemName: viewModel.isListening ? "stop.fill" : "mic.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .onChange(of: viewModel.isListening) { _, listening in
            if listening {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulseScale = 1.15
                }
            } else {
                withAnimation { pulseScale = 1.0 }
            }
        }
    }
}

#Preview {
    VoiceAssistantView()
}
