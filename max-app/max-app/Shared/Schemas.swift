//
//  Schemas.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/13/26.
//

import Foundation

//
// maybe consider specifying which are encodable and whicch are decodable
// instead of just saying codable for everything (just for precision)
//

nonisolated struct Conversation: Codable {
    var conversationId: Int = -1
    var createdAt: String = ""
    var updatedAt: String = ""
}

nonisolated struct ConversationList: Codable {
    var conversations: [Conversation] = []
    var count: Int = 0
}

nonisolated struct Message: Codable {
    var conversationId: Int
    var content: String
}

nonisolated struct MessageResponse: Codable {
    var conversationId: Int
    var id: Int
    var role: String
    var content: String
    var createdAt: String
}

nonisolated struct Health: Codable {
    var status: String
}
