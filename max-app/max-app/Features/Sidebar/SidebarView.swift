//
//  SidebarView.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: List(selection:), .confirmationDialog, .listStyle(.sidebar),
//  .listRowInsets, .selectionDisabled. Row content (icon + text) is a plain HStack
//  rather than Label — see the note on row(_:systemImage:) for why. Two separate
//  Lists, not one: pinnedActions (New Chat/Scheduled/Eye Care) is non-scrolling, the
//  Recents List below it scrolls independently — see the note on pinnedActions.

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
    var onEyeCare: () -> Void
    var onDelete: (Conversation) -> Void

    /// Set while a delete is awaiting confirmation. One piece of state for the whole
    /// list rather than one per row, so rows can't disagree about what's being deleted.
    @State private var pendingDeletion: Conversation?

    /// New Chat / Scheduled / Eye Care row content. `Label` was dropped here: its
    /// icon+text size follows the ambient font, and that font isn't reliably honored
    /// under `.listStyle(.sidebar)` on macOS — this puts the size on the Text/Image
    /// directly, so it actually changes when AppFont.sidebar changes.
    ///
    /// The icon's frame alignment is `.leading`, not `.center`: the row's own inset
    /// gives every row (icon or bare text) the same left edge for its *box*, but an
    /// SF Symbol glyph centered in a wider-than-it-needs column visually starts well
    /// right of that edge regardless of the row's own inset — the inset can't fix an
    /// offset that comes from the icon's own alignment, only leading can. `.frame`'s
    /// reserved width doesn't change with alignment, so this doesn't move the text
    /// that follows.
    ///
    /// The `.offset(x:)` below is a final ~1pt visual nudge on top of that — offset
    /// only shifts where the glyph is drawn, it isn't part of layout, so it moves
    /// the icon alone without touching the column width or the text's position.
    /// Adjust this number, not `sidebarIconColumnWidth`, if the icon needs to move
    /// again — the column width changes the icon-text gap, not the icon's own edge.
    private func row(_ title: String, systemImage: String) -> some View {
        HStack(spacing: AppSpacing.s) {
            Image(systemName: systemImage)
                .font(AppFont.sidebar)                          // ← icon size
                .frame(width: AppSpacing.sidebarIconColumnWidth, alignment: .leading)
                .offset(x: -1)                                   // ← icon-only nudge; +right / -left
            Text(title)
                .sidebarRowTextStyle()   // ← same text style as ConversationRow's title
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

    /// New Chat / Scheduled / Eye Care — a real `List`, same as Recents, not a plain
    /// VStack anymore: that was the actual ask ("exact same UI" as a conversation
    /// row), and it's also what several rounds of hand-tuned `.padding`/spacing on a
    /// plain view were only ever approximating — `.listRowInsets(sidebarRowInsets)`,
    /// the native hover highlight, and the row-to-row spacing all come back for free
    /// by being a List row again, the same way ConversationRow gets them.
    ///
    /// `.scrollDisabled(true)` + an explicit `.frame(height:)` (AppSpacing.sidebarRowHeight
    /// × row count) is what keeps this List from stretching to fill the sidebar
    /// the way List/ScrollView normally does, and lets the Recents List below do
    /// all the scrolling. This used to rely on `.fixedSize(vertical: true)`
    /// instead — that collapsed the whole List to zero height (all three rows
    /// invisible) rather than hugging its content, which is a known rough edge
    /// of List on macOS not reliably reporting an intrinsic height. The explicit
    /// height is a deliberate, more direct fix for that, not a style preference.
    private var pinnedActions: some View {
        List {
            Button(action: onNewChat) {
                row("New Chat", systemImage: "square.and.pencil")
                    .sidebarRowShape()
            }
            .buttonStyle(.plain)
            .listRowInsets(AppSpacing.sidebarRowInsets)

            // Placeholder: present in the layout, deliberately inert for now.
            row("Scheduled", systemImage: "clock")
                .foregroundStyle(.secondary)
                .sidebarRowShape()
                .help("Not built yet")
                .listRowInsets(AppSpacing.sidebarRowInsets)

            // Was a third inert placeholder ("Plugins") — repurposed as the
            // entry point to the Eye Care debug screen.
            Button(action: onEyeCare) {
                row("Eye Care", systemImage: "eye")
                    .sidebarRowShape()
            }
            .buttonStyle(.plain)
            .listRowInsets(AppSpacing.sidebarRowInsets)
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .frame(height: AppSpacing.sidebarRowHeight * 3)   // 3 rows: New Chat, Scheduled, Eye Care
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            pinnedActions

            // A second, independently-scrolling List: only Recents scrolls, since
            // pinnedActions above is its own non-scrolling List.
            List(selection: $selection) {
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
        onEyeCare: {},
        onDelete: { _ in }
    )
    .frame(width: 330, height: 400)
}
