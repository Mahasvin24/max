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
    
    //
    // GET /all-conversations
    //
    func getAllConversations() async {
        conversationListStatus = .fetching
        do {
            conversationList = try await APIClient.request(
                action: Constants.API.GET, path: "/all-conversations"
            )
            conversationListStatus = .success
        } catch {
            print(error)
            conversationListStatus = .failed
        }
    }
    
    //
    // GET /conversations
    //
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
    // API calling helpers
    //
    private func callAPI<Output: Decodable>(action: String, path: String, status: inout FetchStatus) async -> Output? {
        status = .fetching
        do {
            let res: Output = try await APIClient.request(
                action: action, path: path
            )
            status = .success
            return res
        } catch {
            print(error)
            status = .failed
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
