// Provenance: HAND-BUILT. Built from: ScrollViewReader, ScrollView, LazyVStack.
import SwiftUI

struct MessageListView: View {
    let messages: [MessageResponse]
    var isAwaitingResponse = false
    @State private var followsLatest = true

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: AppSpacing.xxl) {
                    ForEach(messages) { message in
                        if message.isFromUser {
                            UserMessageView(content: message.content)
                        } else {
                            AssistantMessageView(content: message.content)
                        }
                    }
                    if isAwaitingResponse { ThinkingIndicator() }
                    Color.clear.frame(height: 1).id("latest-message")
                }
                .frame(maxWidth: AppSpacing.readableWidth, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.top, AppSpacing.xxl)
                .padding(.bottom, AppSpacing.l)
            }
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentSize.height - geometry.contentOffset.y - geometry.containerSize.height < 80
            } action: { _, nearBottom in
                followsLatest = nearBottom
            }
            .onChange(of: messages.count) { _, _ in
                if followsLatest { proxy.scrollTo("latest-message", anchor: .bottom) }
            }
            .onChange(of: messages.last?.content) { _, _ in
                if followsLatest { proxy.scrollTo("latest-message", anchor: .bottom) }
            }
            .onChange(of: isAwaitingResponse) { _, waiting in
                if waiting {
                    followsLatest = true
                    proxy.scrollTo("latest-message", anchor: .bottom)
                }
            }
        }
    }
}

#Preview {
    MessageListView(messages: [
        MessageResponse(conversationId: 1, id: 1, role: "user",
                        content: "Help me plan a focused morning.", createdAt: ""),
        MessageResponse(conversationId: 1, id: 2, role: "assistant",
                        content: "Start with the outline. Give the first hour to the work that needs the most thought.", createdAt: "")
    ])
    .frame(width: 720, height: 460).background(Color.surface).preferredColorScheme(.dark)
}
