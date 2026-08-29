//
//  SidebarView.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: List(selection:), Section, Label, .confirmationDialog, .listStyle(.sidebar).

import SwiftUI

/// Navigation sidebar. Takes conversations and closures, so it previews without
/// a view model or a running backend.
///
/// On macOS 26 the sidebar picks up floating Liquid Glass automatically from
/// `NavigationSplitView` — there is no glass modifier here by design.
struct SidebarView: View {
    let conversations: [Conversation]
    @Binding var selection: Int?
    var onNewChat: () -> Void
    var onDelete: (Conversation) -> Void

    /// Set while a delete is awaiting confirmation. One piece of state for the whole
    /// list rather than one per row, so rows can't disagree about what's being deleted.
    @State private var pendingDeletion: Conversation?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            List(selection: $selection) {
                Section {
                    Button(action: onNewChat) {
                        Label("New Chat", systemImage: "square.and.pencil")
                    }
                    .buttonStyle(.plain)

                    // Placeholders: present in the layout, deliberately inert for now.
                    Label("Scheduled", systemImage: "clock")
                        .foregroundStyle(.secondary)
                        .help("Not built yet")
                    Label("Plugins", systemImage: "puzzlepiece.extension")
                        .foregroundStyle(.secondary)
                        .help("Not built yet")
                } footer: {
                    // `.listSectionSpacing` is iOS-only; a clear spacer footer is the
                    // macOS-native way to add extra air before the next section.
                    Color.clear.frame(height: AppSpacing.l)
                }

                Section("Recents") {
                    ForEach(conversations) { conversation in
                        ConversationRow(conversation: conversation) {
                            pendingDeletion = conversation
                        }
                        .tag(conversation.conversationId)
                    }
                }
        }
            .listStyle(.sidebar)
            .font(AppFont.sidebar)
            .scrollContentBackground(.hidden)
        }
        .background(Color.surfaceSecondary)
        .confirmationDialog(
            "Delete this conversation?",
            isPresented: Binding(get: { pendingDeletion != nil },
                                 set: { if !$0 { pendingDeletion = nil } }),
            presenting: pendingDeletion
        ) { conversation in
            Button("Delete", role: .destructive) { onDelete(conversation) }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("This action cannot be undone.")
        }
    }
}

#Preview {
    @Previewable @State var selection: Int? = 1
    SidebarView(
        conversations: [
            Conversation(conversationId: 1, title: "Centering a div in CSS", createdAt: "", updatedAt: ""),
            Conversation(conversationId: 2, title: "Recursion explained briefly", createdAt: "", updatedAt: ""),
            Conversation(conversationId: 3, title: "", createdAt: "", updatedAt: "")
        ],
        selection: $selection,
        onNewChat: {},
        onDelete: { _ in }
    )
    .frame(width: 330, height: 400)
}
