import Foundation
import SwiftUI
import os

/// Central state machine for the Jarvis app.
@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    enum AssistantState: Equatable {
        case idle
        case listening
        case thinking
        case speaking
        case error(String)
    }

    @Published var assistantState: AssistantState = .idle
    @Published var messages: [JarvisMessage] = []
    @Published var isPanelVisible = false
    @Published var currentToolName: String?

    let nodeBridge = NodeBridge()
    private let logger = Logger(subsystem: "com.deenaik.JarvisApp", category: "AppState")

    /// Tracks the request ID for the currently pending query
    private var pendingRequestId: String?
    /// Index of the thinking indicator message (so we can replace it)
    private var thinkingMessageIndex: Int?

    private init() {
        nodeBridge.onResponse = { [weak self] response in
            self?.handleResponse(response)
        }
    }

    func startBackend() {
        nodeBridge.start()
    }

    func stopBackend() {
        nodeBridge.stop()
    }

    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Add user message
        messages.append(.userMessage(trimmed))

        // Add thinking indicator
        let thinkingMsg = JarvisMessage.thinking()
        messages.append(thinkingMsg)
        thinkingMessageIndex = messages.count - 1

        // Update state
        assistantState = .thinking
        currentToolName = nil

        // Send to Node.js
        let request = IPCRequest.query(text: trimmed)
        pendingRequestId = request.id
        nodeBridge.send(request)
    }

    func newConversation() {
        messages.removeAll()
        assistantState = .idle
        currentToolName = nil
        pendingRequestId = nil
        thinkingMessageIndex = nil
        nodeBridge.send(.newConversation())
    }

    func togglePanel() {
        isPanelVisible.toggle()
    }

    // MARK: - Response Handling

    private func handleResponse(_ response: IPCResponse) {
        switch response.type {
        case .ready:
            logger.info("Backend ready")

        case .tool_start:
            currentToolName = response.toolName
            // Update thinking indicator text
            if let idx = thinkingMessageIndex, idx < messages.count {
                messages[idx].text = "Using \(response.toolName ?? "tool")..."
            }

        case .tool_result:
            // Just update the thinking indicator
            if let idx = thinkingMessageIndex, idx < messages.count {
                let status = (response.success ?? false) ? "done" : "failed"
                messages[idx].text = "\(response.toolName ?? "tool") \(status)"
            }

        case .response:
            // Remove thinking indicator and add real response
            removeThinkingIndicator()
            if let text = response.text {
                messages.append(.assistantMessage(text))
            }
            assistantState = .idle
            currentToolName = nil
            pendingRequestId = nil

        case .error:
            removeThinkingIndicator()
            let errorText = response.message ?? "Unknown error"
            messages.append(.error(errorText))
            assistantState = .error(errorText)
            pendingRequestId = nil
        }
    }

    private func removeThinkingIndicator() {
        if let idx = thinkingMessageIndex, idx < messages.count, messages[idx].isThinking {
            messages.remove(at: idx)
        }
        thinkingMessageIndex = nil
    }
}
