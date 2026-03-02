import SwiftUI

struct MessageBubbleView: View {
    let message: JarvisMessage

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                if message.isThinking {
                    thinkingContent
                } else {
                    Text(message.text)
                        .font(.body)
                        .textSelection(.enabled)
                        .foregroundStyle(textColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if message.role != .user {
                Spacer(minLength: 60)
            }
        }
    }

    @ViewBuilder
    private var thinkingContent: some View {
        HStack(spacing: 4) {
            if !message.text.isEmpty {
                Text(message.text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ThinkingDotsView()
        }
    }

    private var backgroundColor: Color {
        switch message.role {
        case .user:
            return .blue.opacity(0.2)
        case .assistant:
            return Color(nsColor: .controlBackgroundColor).opacity(0.8)
        case .error:
            return .red.opacity(0.15)
        }
    }

    private var textColor: Color {
        switch message.role {
        case .error:
            return .red
        default:
            return .primary
        }
    }
}

// MARK: - Thinking Dots Animation

struct ThinkingDotsView: View {
    @State private var phase = 0

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 5, height: 5)
                    .opacity(phase == index ? 1 : 0.3)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    phase = (phase + 1) % 3
                }
            }
        }
    }
}
