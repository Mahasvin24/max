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
    
    func refresh() async {
        conversation = Conversation()
        messages = []
        await fetchAllConversations()
    }
    
    //
    // API Calls for ViewModel
    //
    
    // Calls: GET /all-conversations
    func fetchAllConversations() async {
        conversationListStatus = .fetching
        guard let response: ConversationList = await callAPI(
            action: Constants.API.GET,
            path: "/all-conversations",
        ) else {
            conversationListStatus = .failed
            print("Failed to fetch all conversations.")
            return
        }
        conversationList = response
        conversationListStatus = .success
    }
        
    // Calls: DELETE /conversations
    func deleteConversation(id: Int) async {
        guard let _: Status = await callAPI(
            action: Constants.API.DELETE,
            path: "/conversations?conversation_id=\(id)"
        ) else {
            print("Failed to delete conversation")
            return
        }
        await fetchAllConversations() // update conversation list
    }
    
    // Calls: GET /conversations
    func fetchConversation(id: Int) async {
        guard let response: [MessageResponse] = await callAPI(
            action: Constants.API.GET,
            path: "/conversations?conversation_id=\(id)",
        ) else {
            print("Failed to fetch conversation for id \(id).")
            return
        }
        
        guard let newConvo = conversationList.conversations.first(where: { $0.conversationId == id }) else {
            print("Unexpected: no error from fetchConversation(id: Int) but conversation not found in conversationList")
            return
        }
        conversation = newConvo
        messages = response
    }
    
    // Calls: POST /messages
    func sendMessage(text: String) async {
        // Note: we could be more efficient by just creating the two messages as MessageResponse types
        // and appending that to the array. It's possibe then that we differ from server but I think
        // that it could still be fine.
        
        let isNew = conversation == Conversation()
        
        // call API
        guard let res: MessageResponse = await callAPI(
            action: Constants.API.POST,
            path: "/messages",
            body: Message(conversation: conversation, content: text)
        ) else {
            print("Failed to send message.")
            return
        }
        
        // update with the new data
        if isNew {
            await fetchAllConversations()
        } else {
            await fetchConversation(id: res.conversationId)
        }
    }
    
    //
    // API calling helpers
    //
    private func callAPI<Input: Encodable, Output: Decodable>(action: String, path: String, body: Input) async -> Output? {
        do {
            let res: Output = try await APIClient.request(
                action: action, path: path, body: body
            )
            return res
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    private func callAPI<Output: Decodable>(action: String, path: String) async -> Output? {
        do {
            let res: Output = try await APIClient.request(
                action: action, path: path
            )
            return res
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
