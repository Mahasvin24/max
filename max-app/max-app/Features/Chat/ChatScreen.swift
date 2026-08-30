//
//  ChatScreen.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: Group, .safeAreaInset, .toolbar — no third-party code.

import SwiftUI

/// Container for the chat pane. Along with `ContentView`, one of only two places
/// that touch `ChatViewModel` — every component below this takes plain values.
struct ChatScreen: View {
    let viewModel: ChatViewModel
    @Binding var text: String

    private var isEmptyState: Bool {
        viewModel.conversation.isNew && viewModel.messages.isEmpty
    }

    var body: some View {
        Group {
            if isEmptyState {
                EmptyChatView(text: $text, isSending: viewModel.isSending, onSend: send)
            } else {
                MessageListView(messages: viewModel.messages, isSending: viewModel.isSending)
                    .safeAreaInset(edge: .bottom) {
                        ComposerView(text: $text, isSending: viewModel.isSending, onSend: send)
                            .frame(maxWidth: AppSpacing.readableWidth)
                            .padding(.horizontal, AppSpacing.xl)
                            .padding(.bottom, AppSpacing.l)
                    }
            }
        }
        .background(Color.surface)
        .safeAreaInset(edge: .top) {
            if let message = viewModel.lastError {
                ErrorBanner(message: message, onDismiss: viewModel.dismissError)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.top, AppSpacing.s)
            }
        }
        // No title in the toolbar: the conversation is already named in the sidebar,
        // and an empty bar is what makes the top strip read as continuous.
        .navigationTitle("")
        .toolbar(removing: .title)
    }

    private func send() {
        let outgoing = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !outgoing.isEmpty else { return }
        text = ""
        Task { await viewModel.sendMessage(text: outgoing) }
    }
}

/// Surfaces `APIError` text — including the backend's 404 detail — instead of
/// letting failures disappear into the console.
struct ErrorBanner: View {
    let message: String
    var onDismiss: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.s) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(AppFont.message)
                .lineLimit(2)
            Spacer(minLength: 0)
            Button(action: onDismiss) {
                Image(systemName: "xmark")
            }
            .buttonStyle(.icon)
            .accessibilityLabel("Dismiss error")
        }
        .padding(.horizontal, AppSpacing.m)
        .padding(.vertical, AppSpacing.s)
        .background(Color.surfaceElevated, in: .rect(cornerRadius: AppRadius.bubble))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.bubble)
                .stroke(Color.borderSubtle, lineWidth: 1)
        )
    }
}

#Preview {
    ErrorBanner(message: "Request failed with status code 404: Conversation 42 not found.") {}
        .padding()
        .frame(width: 560)
}
