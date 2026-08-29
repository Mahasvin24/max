//
//  Schemas.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/13/26.
//

import Foundation

//
// Mirrors backend/schemas.py. Conformances are split on purpose:
// types we only ever receive are Decodable, types we only ever send are Encodable.
// The snake_case <-> camelCase mapping is handled by the key strategies in APIClient.
//

/// backend: `Conversation` — sent inside a message body, received in lists.
nonisolated struct Conversation: Codable, Equatable, Identifiable {
    /// Sentinel the backend uses to mean "create a new conversation".
    static let newId = -1

    var conversationId: Int = newId
    var title: String = ""
    var createdAt: String = ""
    var updatedAt: String = ""

    var id: Int { conversationId }
    var isNew: Bool { conversationId == Self.newId }
}

/// backend: `ConversationList` — response of `GET /all-conversations`.
nonisolated struct ConversationList: Decodable {
    var conversations: [Conversation] = []
    var count: Int = 0
}

/// backend: `Message` — request body of `POST /messages`.
nonisolated struct Message: Encodable {
    var conversation: Conversation
    var content: String
}

/// backend: `MessageResponse` — one row of the `messages` table.
nonisolated struct MessageResponse: Decodable, Identifiable {
    var conversationId: Int
    var id: Int
    var role: String
    var content: String
    var createdAt: String

    /// Views branch on this instead of comparing the raw `role` string in several places.
    var isFromUser: Bool { role == "user" }
}

/// backend: the `{"status": "ok"}` payloads (`GET /health`, `DELETE /conversations`).
nonisolated struct Status: Decodable {
    var status: String
}
