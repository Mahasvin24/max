import Foundation
import Observation

@MainActor
@Observable
final class ChatViewModel {
    typealias MessageStream = (Conversation, String) -> AsyncThrowingStream<APIClient.Chat.StreamEvent, Error>

    private(set) var conversationList = ConversationList()
    private(set) var conversation: Conversation
    private(set) var messages: [MessageResponse] = []
    private(set) var lastSubmittedMessageID: Int?

    enum FetchStatus { case notStarted, fetching, success, failed }
    private(set) var conversationListStatus: FetchStatus = .notStarted
    private(set) var isLoadingConversation = false
    private(set) var isSending = false
    private(set) var isAwaitingResponse = false
    private(set) var lastError: String?

    @ObservationIgnored private let streamMessage: MessageStream
    private var conversationRequestID = UUID()
    private var listRequestID = UUID()
    private var nextLocalID = 0

    init(conversation: Conversation = Conversation(),
         streamMessage: @escaping MessageStream = APIClient.Chat.streamMessage) {
        self.conversation = conversation
        self.streamMessage = streamMessage
    }

    func dismissError() { lastError = nil }

    /// Invalidates pending work before clearing the visible conversation.
    func startNewChat() {
        conversationRequestID = UUID()
        conversation = Conversation()
        messages = []
        lastSubmittedMessageID = nil
        isLoadingConversation = false
        isSending = false
        isAwaitingResponse = false
        lastError = nil
    }

    func fetchAllConversations() async {
        let requestID = UUID()
        let contextID = conversationRequestID
        listRequestID = requestID
        conversationListStatus = .fetching
        do {
            let list = try await APIClient.Chat.allConversations()
            guard listRequestID == requestID else { return }
            conversationList = list
            conversationListStatus = .success
            if let updated = list.conversations.first(where: { $0.id == conversation.id }) {
                conversation = updated
            }
        } catch {
            guard listRequestID == requestID else { return }
            conversationListStatus = .failed
            if conversationRequestID == contextID { lastError = error.localizedDescription }
        }
    }

    func deleteConversation(id: Int) async {
        let contextID = conversationRequestID
        do {
            try await APIClient.Chat.deleteConversation(conversationId: id)
        } catch {
            if conversationRequestID == contextID { lastError = error.localizedDescription }
            return
        }
        if conversation.id == id { startNewChat() }
        await fetchAllConversations()
    }

    func fetchConversation(id: Int) async {
        guard let selected = conversationList.conversations.first(where: { $0.id == id }) else {
            lastError = "This conversation is no longer available."
            return
        }
        startNewChat()
        conversation = selected
        isLoadingConversation = true
        let requestID = conversationRequestID
        defer {
            if conversationRequestID == requestID { isLoadingConversation = false }
        }
        do {
            let response = try await APIClient.Chat.messages(conversationId: id)
            guard conversationRequestID == requestID else { return }
            messages = response
        } catch {
            guard conversationRequestID == requestID else { return }
            lastError = error.localizedDescription
        }
    }

    func sendMessage(text: String) async {
        let outgoing = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !outgoing.isEmpty, !isSending, !isLoadingConversation else { return }
        let requestID = UUID()
        conversationRequestID = requestID
        let pendingConversation = conversation
        isSending = true
        isAwaitingResponse = true
        lastError = nil
        defer {
            if conversationRequestID == requestID {
                isSending = false
                isAwaitingResponse = false
            }
        }

        let userMessage = localMessage(role: "user", content: outgoing)
        messages.append(userMessage)
        lastSubmittedMessageID = userMessage.id
        var assistantIndex: Int?
        do {
            for try await event in streamMessage(pendingConversation, outgoing) {
                // The user can navigate while an old request is still finishing.
                guard conversationRequestID == requestID, !Task.isCancelled else { return }
                switch event {
                case .chunk(let piece):
                    guard !piece.isEmpty else { continue }
                    isAwaitingResponse = false
                    if let index = assistantIndex {
                        messages[index].content += piece
                    } else {
                        assistantIndex = messages.count
                        messages.append(localMessage(role: "assistant", content: piece))
                    }
                case .done(let response):
                    isAwaitingResponse = false
                    if let index = assistantIndex {
                        messages[index] = response
                    } else {
                        messages.append(response)
                    }
                    if pendingConversation.isNew {
                        // Keep the server ID even if refreshing the sidebar fails.
                        conversation = Conversation(conversationId: response.conversationId)
                        await fetchAllConversations()
                    }
                }
            }
        } catch {
            guard conversationRequestID == requestID, !Task.isCancelled else { return }
            lastError = error.localizedDescription
        }
    }

    private func localMessage(role: String, content: String) -> MessageResponse {
        // Unique negative IDs distinguish optimistic rows from server rows.
        nextLocalID -= 1
        return MessageResponse(conversationId: conversation.id, id: nextLocalID,
                               role: role, content: content, createdAt: "")
    }
}
