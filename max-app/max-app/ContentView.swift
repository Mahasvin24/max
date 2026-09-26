// Provenance: HAND-BUILT. Built from: HSplitView, toolbar, focusedSceneValue.
import AppKit
import SwiftUI

/// Window-local state and feature wiring. The break timer lives at app scope.
struct ContentView: View {
    @State private var viewModel = ChatViewModel()
    @State private var draft = ""
    @State private var sidebarVisible = true
    @State private var focusRequest = 0

    var body: some View {
        HSplitView {
            if sidebarVisible {
                SidebarView(
                    conversations: viewModel.conversationList.conversations,
                    selection: viewModel.conversation.isNew ? nil : viewModel.conversation.id,
                    status: viewModel.conversationListStatus,
                    onNewChat: newChat,
                    onSelect: selectConversation,
                    onDelete: { conversation in
                        Task { await viewModel.deleteConversation(id: conversation.id) }
                    },
                    onToggleSidebar: toggleSidebar,
                    onRetry: { Task { await viewModel.fetchAllConversations() } }
                )
                .frame(minWidth: AppSpacing.sidebarMinimum,
                       idealWidth: AppSpacing.sidebarWidth,
                       maxWidth: AppSpacing.sidebarMaximum)
                .background(InitialSplitPosition(position: AppSpacing.sidebarWidth))
            }

            VStack(spacing: 0) {
                WorkspaceHeader(sidebarVisible: sidebarVisible, onToggleSidebar: toggleSidebar)
                ChatScreen(viewModel: viewModel, text: $draft, focusRequest: focusRequest)
            }
            .frame(minWidth: 580, maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.surface)
        }
        .frame(minWidth: AppSpacing.windowMinimumWidth, minHeight: AppSpacing.windowMinimumHeight)
        .background(Color.surface)
        .containerBackground(Color.surface, for: .window)
        .foregroundStyle(Color.textPrimary)
        .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        .focusedSceneValue(\.newChat, newChat)
        .focusedSceneValue(\.toggleMaxSidebar, toggleSidebar)
        .task { await viewModel.fetchAllConversations() }
    }

    private func newChat() {
        viewModel.startNewChat()
        draft = ""
        focusRequest += 1
    }

    private func selectConversation(_ id: Int) {
        guard id != viewModel.conversation.id else { return }
        draft = ""
        Task { await viewModel.fetchConversation(id: id) }
    }

    private func toggleSidebar() { sidebarVisible.toggle() }
}

/// `HSplitView` does not expose its divider position. Its flexible frame also
/// treats `idealWidth` as a fallback rather than an initial width, so set the
/// native divider once while leaving the sidebar resizable afterward.
private struct InitialSplitPosition: NSViewRepresentable {
    let position: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> SplitPositionProbe {
        let probe = SplitPositionProbe()
        probe.onMoveToWindow = { [weak coordinator = context.coordinator] probe in
            Task { @MainActor in
                coordinator?.apply(position: position, from: probe)
            }
        }
        return probe
    }

    func updateNSView(_ probe: SplitPositionProbe, context: Context) {
        Task { @MainActor in
            context.coordinator.apply(position: position, from: probe)
        }
    }

    final class Coordinator {
        private var hasAppliedPosition = false

        func apply(position: CGFloat, from probe: NSView) {
            guard !hasAppliedPosition else { return }

            var ancestor = probe.superview
            while let view = ancestor {
                if let splitView = view as? NSSplitView, splitView.subviews.count > 1 {
                    splitView.setPosition(position, ofDividerAt: 0)
                    hasAppliedPosition = true
                    return
                }
                ancestor = view.superview
            }
        }
    }
}

private final class SplitPositionProbe: NSView {
    var onMoveToWindow: ((SplitPositionProbe) -> Void)?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard window != nil else { return }
        onMoveToWindow?(self)
    }
}

#Preview {
    ContentView().preferredColorScheme(.dark).frame(width: 1024, height: 670)
}

struct WorkspaceHeader: View {
    let sidebarVisible: Bool
    var onToggleSidebar: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.l) {
            if !sidebarVisible {
                Button("Show sidebar", systemImage: "sidebar.left", action: onToggleSidebar)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.icon)
                    .help("Show sidebar")
                Text("Max").font(AppFont.sidebar)
            }
            Spacer()
            HStack(spacing: AppSpacing.xs) {
                Text("Chat")
                    .foregroundStyle(Color.textPrimary)
                    .padding(.horizontal, AppSpacing.m)
                    .padding(.vertical, AppSpacing.s)
                    .background(Color.surfaceSelected, in: .rect(cornerRadius: AppRadius.control))
                    .accessibilityAddTraits(.isSelected)
                Button("Tools") {}.disabled(true).help("Tools — not available yet")
                    .padding(.horizontal, AppSpacing.m)
            }
            .font(AppFont.segment)
            .buttonStyle(.plain)
            .foregroundStyle(Color.textSecondary)
            .padding(AppSpacing.xs)
            .background(Color.surfaceSecondary, in: .rect(cornerRadius: AppRadius.row))

            Button("Settings", systemImage: "gearshape") {}
                .labelStyle(.iconOnly)
                .buttonStyle(.icon)
                .disabled(true)
                .help("Settings — not available yet")
        }
        .padding(.horizontal, AppSpacing.xl)
        .frame(height: 60)
    }

}
