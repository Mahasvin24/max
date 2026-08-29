//
//  ConversationRow.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: Text, .contextMenu — no third-party code.

import SwiftUI

/// One row in the Recents list.
struct ConversationRow: View {
    let conversation: Conversation
    var onDelete: () -> Void

    /// The backend occasionally stores an empty title, so fall back rather than
    /// rendering a blank row.
    private var displayTitle: String {
        let trimmed = conversation.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Conversation \(conversation.conversationId)" : trimmed
    }

    var body: some View {
        Text(displayTitle)
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
            .contextMenu {
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            }
    }
}

#Preview {
    List {
        ConversationRow(conversation: Conversation(conversationId: 1, title: "Centering a div in CSS", createdAt: "", updatedAt: "")) {}
        ConversationRow(conversation: Conversation(conversationId: 2, title: "", createdAt: "", updatedAt: "")) {}
    }
    .listStyle(.sidebar)
    .frame(width: 240, height: 160)
}
