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
    var conversation: [MessageResponse]? = []
    var currentConversationId = -1
    
    
    // status monitoring
    enum FetchStatus {
        case notStarted
        case fetching
        case success
        case failed
    }
    private(set) var conversationsStatus: FetchStatus = .notStarted
    
    func getAllConversations() async {
        conversationsStatus = .fetching
        do {
            allConversations = try await APIClient.request(
                path: "/all-conversations", action: Constants.API.GET
            )
            conversationsStatus = .success
        } catch {
            print(error)
            conversationsStatus = .failed
            return
        }
        conversationsStatus = .success
    }
}
