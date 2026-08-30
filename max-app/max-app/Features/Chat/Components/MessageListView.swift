//
//  MessageListView.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: ScrollView, LazyVStack, ForEach, .scrollPosition.

import SwiftUI

/// The transcript. Stays flat and opaque on purpose: Liquid Glass belongs to the
/// floating layer above content, never behind dense text.
struct MessageListView: View {
    let messages: [MessageResponse]
    var isSending: Bool = false

    /// Drives "stick to the newest message" as the conversation grows past the
    /// height of the pane. Deliberately not paired with `defaultScrollAnchor(.bottom)`:
    /// that anchors a short transcript to the bottom edge, when it should begin at
    /// the top and fill downward.
    @State private var scrolledID: Int?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppSpacing.xl) {
                ForEach(messages) { message in
                    if message.isFromUser {
                        UserMessageView(content: message.content)
                    } else {
                        AssistantMessageView(content: message.content)
                    }
                }
                if isSending {
                    ThinkingIndicator()
                }
            }
            .frame(maxWidth: AppSpacing.readableWidth, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AppSpacing.xl)
            .padding(.top, AppSpacing.xxl)
            .padding(.bottom, AppSpacing.l)
            // Content starts at the top and fills downward; only once it outgrows
            // the pane does scrolling take over.
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .scrollPosition(id: $scrolledID, anchor: .bottom)
        .onChange(of: messages.count) { _, _ in
            scrolledID = messages.last?.id
        }
        .onChange(of: isSending) { _, sending in
            if sending { scrolledID = messages.last?.id }
        }
    }
}

#Preview {
    MessageListView(
        messages: [
            MessageResponse(conversationId: 1, id: 1, role: "user",
                            content: "What is the capital of Japan?", createdAt: ""),
            MessageResponse(conversationId: 1, id: 2, role: "assistant",
                            content: "Tokyo. It has been the capital since 1868.", createdAt: ""),
            MessageResponse(conversationId: 1, id: 3, role: "user",
                            content: "And before that?", createdAt: "")
        ],
        isSending: true
    )
    .frame(width: 620, height: 420)
}
