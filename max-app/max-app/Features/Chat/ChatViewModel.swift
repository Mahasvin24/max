//
//  ChatViewModel.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/15/26.
//

import Foundation

@Observable
class ChatViewModel {
    // data
    var conversationList: ConversationList = ConversationList()
    var conversation: Conversation = Conversation()
    var messages: [MessageResponse] = []

    // status monitoring
    enum FetchStatus {
        case notStarted
        case fetching
        case success
        case failed
    }
    private(set) var conversationListStatus: FetchStatus = .notStarted

    /// True while a reply is in flight. The round trip is several seconds, so the
    /// UI has to say something or it reads as broken.
    private(set) var isSending = false

    /// Last failure, in a form the UI can show. Nil when the last call succeeded.
    private(set) var lastError: String?

    /// Counts down from 0 to hand out ids for locally-echoed messages that
    /// don't have a server-assigned one yet. Must be unique per pending
    /// message, not a fixed sentinel: `messages` is diffed by `id`
    /// (`MessageResponse: Identifiable`), and two rows sharing one id — e.g.
    /// two user turns both hardcoded to `-1` — makes SwiftUI's `ForEach`
    /// lose track of which view belongs to which row, which is what caused
    /// bubbles to render blank on scroll.
    private var nextLocalID = 0
    private func makeLocalID() -> Int {
        nextLocalID -= 1
        return nextLocalID
    }

    func dismissError() {
        lastError = nil
    }

    func refresh() async {
        conversation = Conversation()
        messages = []
        await fetchAllConversations()
    }

    //
    // API calls. Endpoints/verbs live in APIClient.Chat — this layer only
    // decides what to do with the result.
    //

    func fetchAllConversations() async {
        conversationListStatus = .fetching
        do {
            conversationList = try await APIClient.Chat.allConversations()
            conversationListStatus = .success
        } catch {
            conversationListStatus = .failed
            lastError = error.localizedDescription
        }
    }

    func deleteConversation(id: Int) async {
        do {
            try await APIClient.Chat.deleteConversation(conversationId: id)
        } catch {
            lastError = error.localizedDescription
            return
        }
        if conversation.conversationId == id {
            conversation = Conversation() // we just deleted what we were looking at
            messages = []
        }
        await fetchAllConversations() // update conversation list
    }

    func fetchConversation(id: Int) async {
        let response: [MessageResponse]
        do {
            response = try await APIClient.Chat.messages(conversationId: id)
        } catch {
            lastError = error.localizedDescription
            return
        }

        guard let newConvo = conversationList.conversations.first(where: { $0.conversationId == id }) else {
            lastError = "Conversation \(id) is no longer in the list."
            return
        }
        conversation = newConvo
        messages = response
    }

    func sendMessage(text: String) async {
        // Echoed locally rather than re-fetched from the server: the user's
        // turn shows immediately, and the assistant's turn is appended once
        // its first piece of text actually arrives (until then `isSending`
        // alone carries the "waiting" state, via ThinkingIndicator).
        let isNew = conversation.isNew
        let pendingConversationId = conversation.conversationId

        isSending = true
        lastError = nil
        defer { isSending = false }

        messages.append(MessageResponse(
            conversationId: pendingConversationId, id: makeLocalID(),
            role: "user", content: text, createdAt: ""
        ))

        var assistantIndex: Int?

        do {
            for try await event in APIClient.Chat.streamMessage(conversation: conversation, content: text) {
                switch event {
                case .chunk(let piece):
                    if let index = assistantIndex {
                        messages[index].content += piece
                    } else {
                        isSending = false // swap the "thinking" dots for the growing reply
                        assistantIndex = messages.count
                        messages.append(MessageResponse(
                            conversationId: pendingConversationId, id: makeLocalID(),
                            role: "assistant", content: piece, createdAt: ""
                        ))
                    }
                case .done(let response):
                    if let index = assistantIndex {
                        messages[index] = response
                    } else {
                        messages.append(response) // model returned no content at all
                    }
                    // Only known here: the conversation this reply actually landed
                    // in, with its real (server-assigned) id. Update our copy so a
                    // second message in the same conversation doesn't ask the
                    // backend to create *another* new conversation.
                    if isNew {
                        await fetchAllConversations()
                        if let updated = conversationList.conversations.first(where: { $0.conversationId == response.conversationId }) {
                            conversation = updated
                        }
                    }
                }
            }
        } catch {
            lastError = error.localizedDescription
        }
    }
}
