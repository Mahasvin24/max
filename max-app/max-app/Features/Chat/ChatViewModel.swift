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
    var currentConversationId = -1
    var conversation: [MessageResponse] = []
    
    // status monitoring
    enum FetchStatus {
        case notStarted
        case fetching
        case success
        case failed
    }
    private(set) var conversationListStatus: FetchStatus = .notStarted
    
    
    // RENAME to a better name later
    func reset() {
        currentConversationId = -1
        conversation = []
    }
    
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
    
    // Calls: GET /conversations
    func getConversation(id: Int) async {
        do {
            conversation = try await APIClient.request(
                action: Constants.API.GET, path: "/conversations"
            )
            currentConversationId = id
        } catch {
            print(error)
        }
    }
    
    //
    // POST /conversations
    //
    func createConversation() async {
        do {
            currentConversationId = try await APIClient.request(
                action: Constants.API.POST, path: "/conversations"
            )
        } catch {
            print(error)
        }
    }
    
    //
    // API calling helper
    //
    private func callAPI<Input: Encodable, Output: Decodable>(action: String, path: String, body: Input) async -> Output? {
        do {
            let res: Output = try await APIClient.request(
                action: action, path: path, body: body
            )
            return res
        } catch {
            print(error)
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
            print(error)
        }
        return nil
    }
    
}
