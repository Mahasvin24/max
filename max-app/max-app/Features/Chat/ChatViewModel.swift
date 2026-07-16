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
    var allConversations: ConversationList = ConversationList(conversations: [], count: 0)
    var currentConversationId = -1
    var conversation: [MessageResponse] = []
    
    
    // status monitoring
    enum FetchStatus {
        case notStarted
        case fetching
        case success
        case failed
    }
    private(set) var conversationsStatus: FetchStatus = .notStarted
    
    // RENAME to a better name later
    func reset() {
        currentConversationId = -1
        conversation = []
    }
    
    //
    // GET /all-conversations
    //
    func getAllConversations() async {
        conversationsStatus = .fetching
        do {
            allConversations = try await APIClient.request(
                action: Constants.API.GET, path: "/all-conversations"
            )
            conversationsStatus = .success
        } catch {
            print(error)
            conversationsStatus = .failed
        }
    }
    
    //
    // GET /conversations
    //
    func getConversation(id: Int) async {
        conversationsStatus = .fetching
        do {
            allConversations = try await APIClient.request(
                action: Constants.API.GET, path: "/conversations"
            )
            currentConversationId = id
            conversationsStatus = .success
        } catch {
            print(error)
            conversationsStatus = .failed
        }
    }
}
