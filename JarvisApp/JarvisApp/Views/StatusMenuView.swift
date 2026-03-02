import SwiftUI

struct StatusMenuView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 4) {
            // Status indicator
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

            Divider()

            Button("Show/Hide Panel") {
                NSApp.delegate.flatMap { $0 as? AppDelegate }?.togglePanel()
            }
            .keyboardShortcut("j", modifiers: [.command, .shift])

            Button("New Conversation") {
                appState.newConversation()
            }

            Divider()

            Button("Quit Jarvis") {
                AppState.shared.stopBackend()
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(4)
    }

    private var statusColor: Color {
        switch appState.assistantState {
        case .idle: return .green
        case .listening: return .orange
        case .thinking: return .blue
        case .speaking: return .purple
        case .error: return .red
        }
    }

    private var statusText: String {
        switch appState.assistantState {
        case .idle: return "Ready"
        case .listening: return "Listening..."
        case .thinking: return "Thinking..."
        case .speaking: return "Speaking..."
        case .error(let msg): return "Error: \(msg)"
        }
    }
}
