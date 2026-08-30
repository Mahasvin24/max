//
//  SidebarView.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: List(selection:), Section, .confirmationDialog, .listStyle(.sidebar),
//  .listRowInsets, .selectionDisabled. Row content (icon + text) is a plain HStack
//  rather than Label — see the note on row(_:systemImage:) for why.

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

    /// New Chat / Scheduled / Plugins row content. `Label` was dropped here: its
    /// icon+text size follows the ambient font, and that font isn't reliably honored
    /// under `.listStyle(.sidebar)` on macOS — this puts the size on the Text/Image
    /// directly, so it actually changes when AppFont.sidebar changes.
    private func row(_ title: String, systemImage: String) -> some View {
        HStack(spacing: AppSpacing.s) {
            Image(systemName: systemImage)
                .font(AppFont.sidebar)                          // ← icon size
                .frame(width: AppSpacing.sidebarIconColumnWidth, alignment: .center)
            Text(title)
                .font(AppFont.sidebar)                           // ← row text size
        }
    }

    /// Wordmark row at the top of the sidebar, with the search/notification actions
    /// from the reference layout. No dropdown chevron — nothing sits behind "Max" yet.
    private var header: some View {
        // Tweak sizes in Typography.swift, not here. The icons below intentionally
        // use AppFont.segment (14pt) rather than AppFont.toolbarIcon, so they stay
        // independent of the gear button in ContentView's toolbar — though segment
        // is really named for the Chat/Work pill, so it's a borrowed token, not a
        // dedicated one. Give the sidebar its own constant if this starts to bite.
        HStack(spacing: AppSpacing.m) {                    // ← gap: Max ↔ Spacer ↔ icons
            Text(Constants.maxString)
                .font(AppFont.sidebarHeader)                // ← "Max" text size/weight
                .foregroundStyle(.primary)

            Spacer(minLength: 0)

            // Inert placeholders, matching the reference layout.
            Button {} label: {
                Image(systemName: "magnifyingglass")
                    .font(AppFont.segment)              // ← search icon size (borrowed from the pill's font, see note above)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help("Search — not built yet")
            .accessibilityLabel("Search")

            Button {} label: {
                Image(systemName: "bell")
                    .font(AppFont.segment)              // ← bell icon size (borrowed from the pill's font, see note above)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help("Notifications — not built yet")
            .accessibilityLabel("Notifications")
        }
        .padding(.horizontal, AppSpacing.l)                 // ← row's left/right margin
        .padding(.top, AppSpacing.l)                        // ← gap above "Max" (below traffic lights)
        .padding(.bottom, AppSpacing.s)                     // ← gap below "Max" (above New Chat)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            List(selection: $selection) {
                // Every row below sets its own font and its own .listRowInsets
                // (AppSpacing.sidebarRowInsets) rather than trusting what it inherits
                // from the List — see the note on `row(_:systemImage:)` above.
                Section {
                    Button(action: onNewChat) {
                        row("New Chat", systemImage: "square.and.pencil")
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(AppSpacing.sidebarRowInsets)

                    // Placeholders: present in the layout, deliberately inert for now.
                    row("Scheduled", systemImage: "clock")
                        .foregroundStyle(.secondary)
                        .help("Not built yet")
                        .listRowInsets(AppSpacing.sidebarRowInsets)
                    row("Plugins", systemImage: "puzzlepiece.extension")
                        .foregroundStyle(.secondary)
                        .help("Not built yet")
                        .listRowInsets(AppSpacing.sidebarRowInsets)
                } footer: {
                    // `.listSectionSpacing` is iOS-only; a clear spacer footer is the
                    // macOS-native way to add extra air before the next section.
                    Color.clear.frame(height: AppSpacing.xxl)
                }

                Section {
                    // A plain row rather than Section's `header:` slot: a header gets
                    // its own system-controlled indent, separate from row insets, so
                    // it wouldn't line up with everything else no matter what we set
                    // above. `.selectionDisabled()` keeps it from highlighting like a
                    // clickable conversation.
                    Text("Recents")
                        .font(AppFont.sidebarSectionHeader)
                        .foregroundStyle(.secondary)
                        .listRowInsets(AppSpacing.sidebarRowInsets)
                        .selectionDisabled()

                    ForEach(conversations) { conversation in
                        ConversationRow(conversation: conversation) {
                            pendingDeletion = conversation
                        }
                        .tag(conversation.conversationId)
                    }
                }
        }
            .listStyle(.sidebar)
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
