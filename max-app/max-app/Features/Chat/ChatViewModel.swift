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
    
    // status monitoring
    enum FetchStatus {
        case notStarted
        case fetching
        case success
        case failed
    }
    private(set) var conversationsStatus: FetchStatus = .notStarted
    

    
}
