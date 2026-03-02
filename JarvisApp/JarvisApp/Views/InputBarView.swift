import SwiftUI

struct InputBarView: View {
    @EnvironmentObject var appState: AppState
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            // Mic button
            Button(action: micTapped) {
                Image(systemName: micIcon)
                    .font(.system(size: 16))
                    .foregroundStyle(micColor)
            }
            .buttonStyle(.plain)
            .help("Voice input")

            // Text field
            TextField("Ask Jarvis...", text: $inputText)
                .textFieldStyle(.plain)
                .font(.body)
                .focused($isInputFocused)
                .onSubmit {
                    sendMessage()
                }

            // Send button
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(canSend ? .blue : .secondary.opacity(0.5))
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
            .help("Send message")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .onAppear {
            isInputFocused = true
        }
    }

    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        appState.assistantState == .idle
    }

    private var micIcon: String {
        if case .listening = appState.assistantState {
            return "mic.fill"
        }
        return "mic"
    }

    private var micColor: Color {
        if case .listening = appState.assistantState {
            return .red
        }
        return .secondary
    }

    private func sendMessage() {
        guard canSend else { return }
        let text = inputText
        inputText = ""
        appState.sendMessage(text)
    }

    private func micTapped() {
        // Voice input handled in Phase E
    }
}
