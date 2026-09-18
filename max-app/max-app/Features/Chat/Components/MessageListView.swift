// Provenance: HAND-BUILT. Built from: ScrollViewReader, ScrollView, LazyVStack.
import SwiftUI

struct MessageListView: View {
    let messages: [MessageResponse]
    var lastSubmittedMessageID: Int?
    var isAwaitingResponse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var followsLatest = true
    @State private var currentTurnHeight: CGFloat = 0
    @State private var firstMessageHasSettled = false

    private var currentTurnIndex: Int? {
        guard let lastSubmittedMessageID else { return nil }
        return messages.firstIndex { $0.id == lastSubmittedMessageID && $0.isFromUser }
    }

    var body: some View {
        GeometryReader { viewport in
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: AppSpacing.xxl) {
                        if let currentTurnIndex, let userID = lastSubmittedMessageID {
                            ForEach(messages.prefix(currentTurnIndex)) { message in
                                messageRow(message)
                            }
                            VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                                ForEach(messages[currentTurnIndex...]) { message in
                                    if currentTurnIndex == 0 && message.id == userID {
                                        messageRow(message)
                                            .offset(y: firstMessageHasSettled || reduceMotion ? 0
                                                : max(0, viewport.size.height - 120))
                                    } else {
                                        messageRow(message)
                                            .opacity(firstMessageHasSettled || currentTurnIndex > 0 || reduceMotion ? 1 : 0)
                                    }
                                }
                                if isAwaitingResponse {
                                    ThinkingIndicator()
                                        .opacity(firstMessageHasSettled || currentTurnIndex > 0 || reduceMotion ? 1 : 0)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, AppSpacing.l)
                            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { _, height in
                                currentTurnHeight = height
                            }
                            .id(userID)

                            // Leave room below a short reply so the new turn can sit at the top.
                            Color.clear.frame(height: max(0, viewport.size.height - currentTurnHeight
                                - AppSpacing.xxl * 2 - AppSpacing.l - 1))
                        } else {
                            ForEach(messages) { message in messageRow(message) }
                            if isAwaitingResponse { ThinkingIndicator() }
                        }
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
                    guard messages.last?.id != lastSubmittedMessageID else { return }
                    if followsLatest { proxy.scrollTo("latest-message", anchor: .bottom) }
                }
                .onChange(of: messages.last?.content) { _, _ in
                    if followsLatest { proxy.scrollTo("latest-message", anchor: .bottom) }
                }
                .task(id: lastSubmittedMessageID) {
                    guard let userID = lastSubmittedMessageID else {
                        currentTurnHeight = 0
                        return
                    }
                    currentTurnHeight = 0
                    followsLatest = true
                    await Task.yield()
                    if reduceMotion {
                        firstMessageHasSettled = true
                        proxy.scrollTo(userID, anchor: .top)
                    } else if currentTurnIndex == 0 {
                        proxy.scrollTo(userID, anchor: .top)
                        withAnimation(.easeInOut(duration: 0.4)) {
                            firstMessageHasSettled = true
                        }
                    } else {
                        firstMessageHasSettled = true
                        withAnimation(.easeInOut(duration: 0.4)) {
                            proxy.scrollTo(userID, anchor: .top)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func messageRow(_ message: MessageResponse) -> some View {
        if message.isFromUser {
            UserMessageView(content: message.content)
        } else {
            AssistantMessageView(content: message.content)
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
