// Provenance: HAND-BUILT. Built from: Button, contextMenu.
import SwiftUI

struct ConversationRow: View {
    let conversation: Conversation
    var isSelected = false
    var isFocused = false
    var onSelect: () -> Void
    var onDelete: () -> Void

    private var displayTitle: String {
        let title = conversation.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return title.isEmpty ? "Conversation \(conversation.id)" : title
    }

    var body: some View {
        Button(displayTitle, action: onSelect)
            .buttonStyle(RowButtonStyle(isSelected: isSelected, isFocused: isFocused))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .help(displayTitle)
            .contextMenu {
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            }
    }
}
