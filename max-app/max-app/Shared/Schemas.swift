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
    let conversationId: Int
    let createdAt: String
    let updatedAt: String
}

nonisolated struct ConversationList: Codable {
    let conversations: [Conversation]
    let count: Int
}

nonisolated struct Message: Codable {
    let conversationId: Int
    let content: String
}

nonisolated struct MessageResponse: Codable {
    let conversationId: Int
    let id: Int
    let role: String
    let content: String
    let createdAt: String
}

nonisolated struct Health: Codable {
    let status: String
}
