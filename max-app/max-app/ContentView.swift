//
//  ContentView.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: NavigationSplitView, .toolbar, ToolbarItem, .task.
//

import SwiftUI

/// App shell. Owns the view model and wires the sidebar to the chat pane.
struct ContentView: View {
    /// `@State`, not `let`: with `@Observable`, the view must own the instance so
    /// it survives re-initialisation of this struct.
    @State private var viewModel = ChatViewModel()
    @State private var draft = ""
    @State private var selection: Int?
    @State private var section = "Chat"
    /// Swaps the detail pane to EyeCareDebugScreen. Cleared whenever the user
    /// picks a conversation or starts a new chat, so those affordances still
    /// behave like "go to chat" even while Eye Care is showing.
    @State private var showingEyeCare = false

    /// Owned by max_appApp (needed for its menu bar icon), passed down only so
    /// EyeCareDebugScreen can pause/resume its duty-cycled monitoring around
    /// its own continuous session — ChatViewModel/ChatScreen never touch it.
    let blinkTrackerViewModel: BlinkTrackerViewModel

    var body: some View {
        NavigationSplitView {
            SidebarView(
                conversations: viewModel.conversationList.conversations,
                selection: $selection,
                onNewChat: newChat,
                onEyeCare: { showingEyeCare = true },
                onDelete: { conversation in
                    Task { await viewModel.deleteConversation(id: conversation.conversationId) }
                }
            )
            .navigationSplitViewColumnWidth(min: 270, ideal: 330, max: 450)
        } detail: {
            if showingEyeCare {
                EyeCareDebugScreen(blinkTrackerViewModel: blinkTrackerViewModel)
                    .frame(minWidth: 520, minHeight: 400)
            } else {
                ChatScreen(viewModel: viewModel, text: $draft)
                    .frame(minWidth: 520, minHeight: 400)
            }
        }
        .toolbar {
            // "Max" now lives in the sidebar's own header row, not here.
            ToolbarItem(placement: .principal) {
                // Inert for now — no Work mode behind it yet.
                SegmentedPill(options: ["Chat", "Work"], selection: $section)
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    // Placeholder: settings aren't built yet.
                } label: {
                    Image(systemName: "gearshape")
                        .font(AppFont.toolbarIcon)
                }
                .buttonStyle(.plain)
                .help("Settings — not built yet")
                .accessibilityLabel("Settings")
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .task { await viewModel.refresh() }
        .onChange(of: selection) { _, newValue in
            guard let newValue, newValue != viewModel.conversation.conversationId else { return }
            showingEyeCare = false
            Task { await viewModel.fetchConversation(id: newValue) }
        }
        .onChange(of: viewModel.conversation.conversationId) { _, newValue in
            // Keep the sidebar highlight in step when the model changes conversation
            // on its own — starting a new chat, or sending the first message.
            selection = viewModel.conversation.isNew ? nil : newValue
        }
    }


    private func newChat() {
        selection = nil
        draft = ""
        showingEyeCare = false
        Task { await viewModel.refresh() }
    }
}

#Preview {
    ContentView(blinkTrackerViewModel: BlinkTrackerViewModel())
}
