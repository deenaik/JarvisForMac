import SwiftUI

struct FloatingPanelView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text("Jarvis")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                if case .thinking = appState.assistantState {
                    Text(appState.currentToolName ?? "Thinking...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button(action: { appState.newConversation() }) {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("New conversation")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            // Chat area
            ChatView()
                .environmentObject(appState)

            Divider()

            // Input bar
            InputBarView()
                .environmentObject(appState)
        }
        .frame(width: 380, height: 520)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
}
