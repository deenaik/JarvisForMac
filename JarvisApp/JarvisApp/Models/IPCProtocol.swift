import Foundation

// MARK: - Requests (Swift → Node.js)

struct IPCRequest: Codable {
    let id: String
    let type: IPCRequestType
    var text: String?

    enum IPCRequestType: String, Codable {
        case query
        case new_conversation
    }

    static func query(text: String) -> IPCRequest {
        IPCRequest(id: UUID().uuidString, type: .query, text: text)
    }

    static func newConversation() -> IPCRequest {
        IPCRequest(id: UUID().uuidString, type: .new_conversation)
    }
}

// MARK: - Responses (Node.js → Swift)

struct IPCResponse: Codable {
    let id: String?
    let type: IPCResponseType
    var toolName: String?
    var step: Int?
    var success: Bool?
    var text: String?
    var totalSteps: Int?
    var toolCalls: Int?
    var message: String?

    enum IPCResponseType: String, Codable {
        case ready
        case tool_start
        case tool_result
        case response
        case error
    }
}
