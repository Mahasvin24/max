// Provenance: HAND-BUILT. Built from: ScrollView, LazyVStack, Button, FocusState.
import SwiftUI

struct SidebarView: View {
    let conversations: [Conversation]
    let selection: Int?
    var status: ChatViewModel.FetchStatus = .success
    var onNewChat: () -> Void
    var onSelect: (Int) -> Void
    var onDelete: (Conversation) -> Void
    var onToggleSidebar: () -> Void
    var onRetry: () -> Void

    @State private var pendingDeletion: Conversation?
    @FocusState private var focusedID: Int?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(Constants.maxString).font(AppFont.sidebarHeader)
                Spacer()
                Button("Hide sidebar", systemImage: "sidebar.left", action: onToggleSidebar)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.icon)
                    .help("Hide sidebar")
            }
            .padding(.horizontal, AppSpacing.xl)
            .frame(height: 72)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Button(action: onNewChat) {
                            Label("New chat", systemImage: "square.and.pencil")
                        }
                        .buttonStyle(RowButtonStyle(isSelected: selection == nil,
                                                          isFocused: focusedID == Conversation.newId))
                        .focused($focusedID, equals: Conversation.newId)
                        .accessibilityAddTraits(selection == nil ? .isSelected : [])
                        .id(Conversation.newId)

                        unavailableRow("Scheduled", systemImage: "clock")
                        unavailableRow("Plugins", systemImage: "puzzlepiece.extension")

                        Text("Recents")
                            .font(AppFont.sidebarSectionHeader)
                            .foregroundStyle(Color.textSecondary)
                            .padding(.horizontal, AppSpacing.m)
                            .padding(.top, AppSpacing.xl)
                            .padding(.bottom, AppSpacing.s)

                        ForEach(conversations) { conversation in
                            ConversationRow(
                                conversation: conversation,
                                isSelected: selection == conversation.id,
                                isFocused: focusedID == conversation.id,
                                onSelect: { onSelect(conversation.id) },
                                onDelete: { pendingDeletion = conversation }
                            )
                            .focused($focusedID, equals: conversation.id)
                            .id(conversation.id)
                        }

                        if conversations.isEmpty {
                            if status == .fetching {
                                ProgressView().controlSize(.small).padding(AppSpacing.m)
                            } else if status == .failed {
                                Button("Retry loading chats", action: onRetry)
                                    .font(AppFont.caption)
                                    .buttonStyle(.plain)
                                    .padding(AppSpacing.m)
                            } else {
                                Text("Your chats will appear here.")
                                    .font(AppFont.caption)
                                    .foregroundStyle(Color.textSecondary)
                                    .padding(AppSpacing.m)
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.s)
                    .padding(.bottom, AppSpacing.l)
                }
                .onChange(of: focusedID) { _, id in
                    if let id { proxy.scrollTo(id) }
                }
            }
            .onMoveCommand(perform: moveSelection)

            HStack(spacing: AppSpacing.m) {
                Text(String(Constants.userNameString.prefix(1)))
                    .font(AppFont.caption)
                    .frame(width: 30, height: 30)
                    .background(Color.surfaceSelected, in: .circle)
                    .accessibilityHidden(true)
                Text(Constants.userNameString).font(AppFont.caption)
                Spacer()
            }
            .padding(AppSpacing.l)
        }
        .foregroundStyle(Color.textPrimary)
        .background(Color.surfaceSecondary)
        .confirmationDialog("Delete this conversation?", isPresented: Binding(
            get: { pendingDeletion != nil },
            set: { if !$0 { pendingDeletion = nil } }
        ), presenting: pendingDeletion) { conversation in
            Button("Delete", role: .destructive) { onDelete(conversation) }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("This action cannot be undone.")
        }
    }

    private func unavailableRow(_ title: String, systemImage: String) -> some View {
        Button {} label: { Label(title, systemImage: systemImage) }
            .buttonStyle(RowButtonStyle())
            .disabled(true)
            .help("\(title) — not available yet")
    }

    private func moveSelection(_ direction: MoveCommandDirection) {
        guard direction == .up || direction == .down else { return }
        let ids = [Conversation.newId] + conversations.map(\.id)
        let current = ids.firstIndex(of: focusedID ?? selection ?? Conversation.newId) ?? 0
        let index = min(max(current + (direction == .down ? 1 : -1), 0), ids.count - 1)
        focusedID = ids[index]
        ids[index] == Conversation.newId ? onNewChat() : onSelect(ids[index])
    }
}

#Preview {
    SidebarView(conversations: [Conversation(conversationId: 1, title: "Planning a focused morning")],
                selection: nil, onNewChat: {}, onSelect: { _ in }, onDelete: { _ in },
                onToggleSidebar: {}, onRetry: {})
        .frame(width: 228, height: 620)
        .preferredColorScheme(.dark)
}
