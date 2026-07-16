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
    var conversationList: ConversationList = ConversationList(conversations: [], count: 0)
    var conversationId = -1
    var conversation: [MessageResponse] = []
    
    // status monitoring
    enum FetchStatus {
        case notStarted
        case fetching
        case success
        case failed
    }
    private(set) var conversationListStatus: FetchStatus = .notStarted
    
    func refresh() async {
        conversationId = -1
        conversation = []
        await fetchAllConversations()
    }
    
    //
    // API Calls for ViewModel
    //
    
    // Calls: GET /all-conversations
    func fetchAllConversations() async {
        conversationListStatus = .fetching
        guard let list: ConversationList = await callAPI(
            action: Constants.API.GET,
            path: "/all-conversations",
        ) else {
            conversationListStatus = .failed
            return
        }
        conversationList = list
        conversationListStatus = .success
    }
    
    // Calls: POST /conversations
    func createConversation() async {
        guard let id: Int = await callAPI(
            action: Constants.API.POST, path: "/conversations"
        ) else {
            return
        }
        conversationId = id
    }
    
    // Calls: GET /conversations
    func fetchConversation() async {
        guard let convo: [MessageResponse] = await callAPI(
            action: Constants.API.GET,
            path: "/conversations",
            body: conversationId
        ) else {
            print("Failed to fetch conversation for id \(conversationId)")
            return
        }
        conversation = convo
    }
    
    // Calls: POST /messages
    func sendMessage(text: String) async {
        // start new convo if needed
        if conversationId == -1 {
            await createConversation()
        }
        
        // call API
        guard let message: MessageResponse = await callAPI(
            action: Constants.API.POST,
            path: "/messages",
            body: Message(conversationId: conversationId, content: text)
        ) else {
            print("Failed to send message")
            return
        }
        
        // refresh conversation log, server is source of truth
        await fetchConversation()
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
        }
        return nil
    }
    private func callAPI<Output: Decodable>(action: String, path: String) async -> Output? {
        do {
            let res: Output = try await APIClient.request(
                action: action, path: path
            )
            return res
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
