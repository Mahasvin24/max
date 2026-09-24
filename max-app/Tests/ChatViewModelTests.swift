import Foundation
import Testing
@testable import MaxChatState

@MainActor
struct ChatViewModelTests {
    private func model(_ source: TestStream) -> ChatViewModel {
        ChatViewModel(conversation: Conversation(conversationId: 42, title: "Test"), streamMessage: { _, _ in
            source.callCount += 1
            return source.stream
        })
    }

    @Test func emptyMessagesDoNotStartRequests() async {
        let source = TestStream()
        let model = model(source)
        await model.sendMessage(text: " \n ")
        #expect(source.callCount == 0)
        #expect(model.messages.isEmpty)
        #expect(!model.isSending)
    }

    @Test func waitingAndStreamingStayBusyUntilCompletion() async throws {
        let source = TestStream()
        let model = model(source)
        let task = Task { await model.sendMessage(text: " Hello ") }
        try await eventually { model.isAwaitingResponse }
        #expect(model.isSending)
        #expect(model.messages.first?.content == "Hello")
        #expect(model.lastSubmittedMessageID == model.messages.first?.id)
        await model.sendMessage(text: "Duplicate while waiting")
        #expect(source.callCount == 1)

        source.continuation.yield(.chunk(""))
        source.continuation.yield(.chunk("First"))
        try await eventually { model.messages.last?.content == "First" }
        #expect(!model.isAwaitingResponse)
        #expect(model.isSending)
        await model.sendMessage(text: "Duplicate while streaming")
        #expect(source.callCount == 1)
        source.continuation.yield(.chunk(" second"))
        source.continuation.yield(.done(response("First second")))
        source.continuation.finish()
        await task.value
        #expect(!model.isSending)
        #expect(!model.isAwaitingResponse)
        #expect(model.messages.count == 2)
        #expect(model.messages.last?.id == 100)
        #expect(model.messages.last?.content == "First second")
    }

    @Test func completionWithoutChunksReplacesWaiting() async throws {
        let source = TestStream()
        let model = model(source)
        let task = Task { await model.sendMessage(text: "Hello") }
        try await eventually { model.isAwaitingResponse }
        source.continuation.yield(.done(response("Complete response")))
        source.continuation.finish()
        await task.value
        #expect(model.messages.last?.content == "Complete response")
        #expect(!model.isAwaitingResponse)
        #expect(!model.isSending)
    }

    @Test func routedNewChatLoadsSelectedConversationHistory() async throws {
        let source = TestStream()
        let conversation = Conversation(conversationId: 42, title: "Existing conversation")
        let historyBeforeResponse = [
            MessageResponse(conversationId: 42, id: 1, role: "user", content: "Earlier question", createdAt: ""),
            MessageResponse(conversationId: 42, id: 2, role: "assistant", content: "Earlier answer", createdAt: ""),
            MessageResponse(conversationId: 42, id: 3, role: "user", content: "Follow-up", createdAt: "")
        ]
        var loadedConversationID: Int?
        let model = ChatViewModel(
            loadConversationList: { ConversationList(conversations: [conversation], count: 1) },
            loadMessages: { id in
                loadedConversationID = id
                return historyBeforeResponse
            },
            streamMessage: { _, _ in source.stream }
        )

        let task = Task { await model.sendMessage(text: "Follow-up") }
        try await eventually { model.isAwaitingResponse }
        source.continuation.yield(.conversation(42))
        try await eventually { model.messages.map(\.id) == [1, 2, 3] }
        #expect(model.conversation == conversation)
        #expect(model.isAwaitingResponse)
        source.continuation.yield(.chunk("Current answer"))
        source.continuation.yield(.done(
            MessageResponse(conversationId: 42, id: 4, role: "assistant",
                            content: "Current answer", createdAt: "")
        ))
        source.continuation.finish()
        await task.value

        #expect(loadedConversationID == 42)
        #expect(model.conversation == conversation)
        #expect(model.messages.map(\.id) == [1, 2, 3, 4])
        #expect(model.messages.map(\.content) ==
                ["Earlier question", "Earlier answer", "Follow-up", "Current answer"])
        #expect(model.lastSubmittedMessageID == 3)
    }

    @Test func failurePreservesPartialReplyAndUnlocksComposer() async throws {
        let source = TestStream()
        let model = model(source)
        let task = Task { await model.sendMessage(text: "Hello") }
        try await eventually { model.isAwaitingResponse }
        source.continuation.yield(.chunk("Partial"))
        source.continuation.finish(throwing: TestFailure.disconnected)
        await task.value
        #expect(model.messages.last?.content == "Partial")
        #expect(model.lastError != nil)
        #expect(!model.isSending)
        #expect(!model.isAwaitingResponse)
        model.dismissError()
        #expect(model.lastError == nil)
    }

    @Test func failureBeforeFirstChunkUnlocksComposer() async throws {
        let source = TestStream()
        let model = model(source)
        let task = Task { await model.sendMessage(text: "Hello") }
        try await eventually { model.isAwaitingResponse }
        source.continuation.finish(throwing: TestFailure.disconnected)
        await task.value
        #expect(model.messages.count == 1)
        #expect(model.lastError != nil)
        #expect(!model.isSending)
        #expect(!model.isAwaitingResponse)
    }

    @Test func lateReplyCannotOverwriteNewChat() async throws {
        let source = TestStream()
        let model = model(source)
        let task = Task { await model.sendMessage(text: "Old chat") }
        try await eventually { model.isAwaitingResponse }
        model.startNewChat()
        #expect(model.lastSubmittedMessageID == nil)
        source.continuation.yield(.chunk("Late text"))
        source.continuation.yield(.done(response("Late response")))
        source.continuation.finish()
        await task.value
        #expect(model.conversation.isNew)
        #expect(model.messages.isEmpty)
        #expect(model.lastError == nil)
        #expect(!model.isSending)
    }

    @Test func oldRequestCleanupCannotUnlockNewRequest() async throws {
        let old = TestStream()
        let current = TestStream()
        var calls = 0
        let model = ChatViewModel(conversation: Conversation(conversationId: 42), streamMessage: { _, _ in
            calls += 1
            return calls == 1 ? old.stream : current.stream
        })
        let oldTask = Task { await model.sendMessage(text: "Old") }
        try await eventually { model.isAwaitingResponse }
        model.startNewChat()
        let newTask = Task { await model.sendMessage(text: "New") }
        try await eventually { calls == 2 }
        old.continuation.finish(throwing: TestFailure.disconnected)
        await oldTask.value
        #expect(model.isSending)
        #expect(model.isAwaitingResponse)
        #expect(model.lastError == nil)
        #expect(model.messages.map(\.content) == ["New"])
        current.continuation.finish()
        await newTask.value
        #expect(!model.isSending)
    }

    private func response(_ content: String) -> MessageResponse {
        MessageResponse(conversationId: 42, id: 100, role: "assistant", content: content, createdAt: "")
    }

    private func eventually(_ condition: () -> Bool) async throws {
        let deadline = ContinuousClock.now + .seconds(2)
        while !condition() {
            guard ContinuousClock.now < deadline else { throw TestFailure.timedOut }
            try await Task.sleep(for: .milliseconds(1))
        }
    }
}

@MainActor
private final class TestStream {
    let stream: AsyncThrowingStream<APIClient.Chat.StreamEvent, Error>
    let continuation: AsyncThrowingStream<APIClient.Chat.StreamEvent, Error>.Continuation
    var callCount = 0

    init() {
        (stream, continuation) = AsyncThrowingStream.makeStream()
    }
}

private enum TestFailure: Error { case disconnected, timedOut }
