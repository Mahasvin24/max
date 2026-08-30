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
        // Note: we could be more efficient by just creating the two messages as MessageResponse types
        // and appending that to the array. It's possibe then that we differ from server but I think
        // that it could still be fine.

        let isNew = conversation.isNew

        isSending = true
        lastError = nil
        defer { isSending = false }

        let res: MessageResponse
        do {
            res = try await APIClient.Chat.sendMessage(conversation: conversation, content: text)
        } catch {
            lastError = error.localizedDescription
            return
        }

        // update with the new data
        if isNew {
            await fetchAllConversations()
        }
        await fetchConversation(id: res.conversationId)
    }
}
