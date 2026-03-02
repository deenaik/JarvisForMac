import Foundation

struct JarvisMessage: Identifiable, Equatable {
    let id: UUID
    let role: Role
    var text: String
    let timestamp: Date
    var isThinking: Bool

    enum Role: Equatable {
        case user
        case assistant
        case error
    }

    init(role: Role, text: String, isThinking: Bool = false) {
        self.id = UUID()
        self.role = role
        self.text = text
        self.timestamp = Date()
        self.isThinking = isThinking
    }

    static func userMessage(_ text: String) -> JarvisMessage {
        JarvisMessage(role: .user, text: text)
    }

    static func assistantMessage(_ text: String) -> JarvisMessage {
        JarvisMessage(role: .assistant, text: text)
    }

    static func thinking() -> JarvisMessage {
        JarvisMessage(role: .assistant, text: "", isThinking: true)
    }

    static func error(_ text: String) -> JarvisMessage {
        JarvisMessage(role: .error, text: text)
    }
}
