// Provenance: HAND-BUILT. Built from: VStack, FocusState.
import SwiftUI

struct ChatScreen: View {
    let viewModel: ChatViewModel
    @Binding var text: String
    var focusRequest = 0
    @FocusState private var isComposerFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if let message = viewModel.lastError {
                ErrorBanner(message: message, onDismiss: viewModel.dismissError)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.s)
            }

            Group {
                if viewModel.isLoadingConversation {
                    ProgressView("Loading conversation…")
                        .font(AppFont.chatCaption)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.conversation.isNew && viewModel.messages.isEmpty {
                    EmptyChatView()
                } else {
                    MessageListView(messages: viewModel.messages,
                                    lastSubmittedMessageID: viewModel.lastSubmittedMessageID,
                                    isAwaitingResponse: viewModel.isAwaitingResponse)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ComposerView(text: $text, isSending: viewModel.isSending,
                         isLoading: viewModel.isLoadingConversation,
                         isFocused: $isComposerFocused, onSend: send)
                .frame(maxWidth: AppSpacing.readableWidth)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.xl)
                .padding(.top, AppSpacing.s)
        }
        .background(Color.surface)
        .onAppear { isComposerFocused = true }
        .onChange(of: focusRequest) { _, _ in isComposerFocused = true }
    }

    private func send() {
        let outgoing = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !outgoing.isEmpty, !viewModel.isSending, !viewModel.isLoadingConversation else { return }
        text = ""
        Task { await viewModel.sendMessage(text: outgoing) }
    }
}

struct ErrorBanner: View {
    let message: String
    var onDismiss: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.s) {
            Image(systemName: "exclamationmark.triangle")
                .accessibilityHidden(true)
            Text(message).font(AppFont.chatCaption).textSelection(.enabled)
            Spacer(minLength: 0)
            Button("Dismiss error", systemImage: "xmark", action: onDismiss)
                .labelStyle(.iconOnly).buttonStyle(.icon)
        }
        .foregroundStyle(Color.textPrimary)
        .padding(AppSpacing.m)
        .background(Color.surfaceElevated, in: .rect(cornerRadius: AppRadius.panelCard))
        .overlay(RoundedRectangle(cornerRadius: AppRadius.panelCard)
            .strokeBorder(Color.borderSubtle, lineWidth: 1))
        .accessibilityElement(children: .contain)
    }
}
