//
//  APIClient.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/13/26.
//

import Foundation

/// Every call the backend exposes, in one place.
///
/// Endpoints are grouped into namespaces that mirror the backend's routers, so
/// there is a 1:1 map between a Python file and a Swift namespace:
///
///   `APIClient.System`  ->  backend/main.py
///   `APIClient.Chat`    ->  backend/routers/chat.py
///
/// Callers (view models) only ever use those namespaces. The transport below is
/// private so URLs and HTTP verbs cannot leak into the rest of the app.
nonisolated struct APIClient {

    // MARK: - Namespace: System (backend/main.py)

    enum System {
        /// `GET /health`
        static func health() async throws -> Status {
            try await APIClient.request(.get, "/health")
        }

        /// Non-throwing convenience for the "is the backend up?" check.
        static func isHealthy() async -> Bool {
            do {
                return try await health().status == "ok"
            } catch {
                print("Health check failed: \(error.localizedDescription)")
                return false
            }
        }
    }

    // MARK: - Namespace: Chat (backend/routers/chat.py)

    enum Chat {
        private static let conversationsPath = "/conversations"
        private static let messagesPath = "/messages"

        private static func conversationId(_ id: Int) -> [URLQueryItem] {
            [URLQueryItem(name: "conversation_id", value: String(id))]
        }

        /// `GET /conversations` — every conversation, newest first.
        static func allConversations() async throws -> ConversationList {
            try await APIClient.request(.get, conversationsPath)
        }

        /// `DELETE /conversations?conversation_id=`
        @discardableResult
        static func deleteConversation(conversationId id: Int) async throws -> Status {
            try await APIClient.request(.delete, conversationsPath, query: conversationId(id))
        }

        /// `GET /messages?conversation_id=` — the messages of one conversation.
        static func messages(conversationId id: Int) async throws -> [MessageResponse] {
            try await APIClient.request(.get, messagesPath, query: conversationId(id))
        }

        /// One item out of the server's streamed reply to `POST /messages`:
        /// either another slice of assistant text, or the final saved
        /// message once the full reply — and the db row it was written to —
        /// are known.
        enum StreamEvent {
            case chunk(String)
            case done(MessageResponse)
        }

        /// `POST /messages`, streamed — the agent's reply arrives piece by
        /// piece over Server-Sent Events instead of as one JSON body.
        ///
        /// Pass `Conversation()` (id `-1`) to start a new conversation; the
        /// backend creates it and titles it for you. The `.done` event's
        /// `conversationId` reflects the row actually written, which is the
        /// only place a caller learns the id for a conversation that was new.
        ///
        /// Throws `APIError.requestFailed(statusCode: 404, ...)` if the
        /// conversation no longer exists.
        static func streamMessage(conversation: Conversation, content: String) -> AsyncThrowingStream<StreamEvent, Error> {
            AsyncThrowingStream { continuation in
                let task = Task {
                    do {
                        guard let url = URL(string: "\(Constants.API.baseURL)\(messagesPath)") else {
                            throw APIError.invalidURL
                        }
                        var req = URLRequest(url: url)
                        req.httpMethod = APIClient.Method.post.rawValue
                        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

                        let encoder = JSONEncoder()
                        encoder.keyEncodingStrategy = .convertToSnakeCase
                        do {
                            req.httpBody = try encoder.encode(Message(conversation: conversation, content: content))
                        } catch {
                            throw APIError.encodingFailed(underlyingError: error)
                        }

                        let bytes: URLSession.AsyncBytes
                        let response: URLResponse
                        do {
                            (bytes, response) = try await URLSession.shared.bytes(for: req)
                        } catch {
                            throw APIError.connectionFailed
                        }

                        guard let httpResponse = response as? HTTPURLResponse else {
                            throw APIError.requestFailed(statusCode: -1, message: nil)
                        }
                        guard (200...299).contains(httpResponse.statusCode) else {
                            throw APIError.requestFailed(statusCode: httpResponse.statusCode, message: nil)
                        }

                        try await parseSSE(bytes) { name, payload in
                            guard name == "done" else {
                                continuation.yield(.chunk(payload))
                                return
                            }
                            guard let data = payload.data(using: .utf8) else {
                                throw APIError.decodingFailed(underlyingError: APIError.invalidURL)
                            }
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            do {
                                continuation.yield(.done(try decoder.decode(MessageResponse.self, from: data)))
                            } catch {
                                throw APIError.decodingFailed(underlyingError: error)
                            }
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
                continuation.onTermination = { _ in task.cancel() }
            }
        }

        /// Splits a byte stream into SSE events per the spec: `event:`/`data:`
        /// lines accumulate, a blank line closes the event out. Multiple
        /// `data:` lines within one event join with `\n`, matching how the
        /// backend frames a piece that itself contains a newline.
        ///
        /// Deliberately doesn't use `AsyncBytes.lines`: that view was found to
        /// swallow the blank lines this format depends on to mark where one
        /// event ends and the next begins, silently merging every event in
        /// the response into one. Splitting the raw bytes on a literal `"\n\n"`
        /// sideskips that — and is exactly what `sse_format`'s per-line
        /// `data:` prefixing on the backend is for: a blank line *inside* a
        /// piece's own text can never produce a bare `\n\n`, because even an
        /// empty line gets re-prefixed with `data: ` before it goes out.
        private static func parseSSE(
            _ bytes: URLSession.AsyncBytes,
            onEvent: (_ name: String?, _ payload: String) throws -> Void
        ) async throws {
            let terminator: [UInt8] = [0x0A, 0x0A] // "\n\n"
            var buffer: [UInt8] = []

            func handle(_ blockBytes: some Collection<UInt8>) throws {
                guard !blockBytes.isEmpty else { return }
                let block = String(decoding: blockBytes, as: UTF8.self)

                var eventName: String?
                var dataLines: [String] = []
                for line in block.split(separator: "\n", omittingEmptySubsequences: false) {
                    if let name = line.sseField("event") {
                        eventName = name
                    } else if let data = line.sseField("data") {
                        dataLines.append(data)
                    }
                }
                guard !dataLines.isEmpty else { return }
                try onEvent(eventName, dataLines.joined(separator: "\n"))
            }

            for try await byte in bytes {
                buffer.append(byte)
                while let range = buffer.firstRange(of: terminator) {
                    try handle(buffer[..<range.lowerBound])
                    buffer.removeSubrange(..<range.upperBound)
                }
            }
            try handle(buffer) // trailing event with no final blank line, if any
        }
    }

    // MARK: - Transport

    enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    /// Builds the URL, sends the request, checks the status code, decodes the body.
    private static func request<Input: Encodable, Output: Decodable>(
        _ method: Method,
        _ path: String,
        query: [URLQueryItem] = [],
        body: Input?
    ) async throws -> Output {

        // url (URLComponents percent-encodes query values for us)
        guard var components = URLComponents(string: "\(Constants.API.baseURL)\(path)") else {
            throw APIError.invalidURL
        }
        if !query.isEmpty { components.queryItems = query }
        guard let url = components.url else { throw APIError.invalidURL }

        // request
        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        if let body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            do {
                req.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.encodingFailed(underlyingError: error)
            }
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        // send
        let result: Data
        let response: URLResponse
        do {
            (result, response) = try await URLSession.shared.data(for: req)
        } catch {
            throw APIError.connectionFailed
        }

        // status code check
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed(statusCode: -1, message: nil)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            // FastAPI puts a useful reason (e.g. 422 validation detail) in the body
            throw APIError.requestFailed(
                statusCode: httpResponse.statusCode,
                message: String(data: result, encoding: .utf8)
            )
        }

        // decode
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(Output.self, from: result)
        } catch {
            throw APIError.decodingFailed(underlyingError: error)
        }
    }

    /// Same as above, for requests without a body.
    private struct EmptyBody: Encodable {}
    private static func request<Output: Decodable>(
        _ method: Method,
        _ path: String,
        query: [URLQueryItem] = []
    ) async throws -> Output {
        try await request(method, path, query: query, body: EmptyBody?.none)
    }
}

private extension StringProtocol {
    /// Pulls the value out of an SSE line shaped `field: value` (or
    /// `field:value`). Per spec, at most one leading space after the colon
    /// is stripped — no other trimming — so a piece's own leading/trailing
    /// whitespace survives the trip.
    func sseField(_ name: String) -> String? {
        guard hasPrefix("\(name):") else { return nil }
        let rest = dropFirst(name.count + 1)
        return String(rest.first == " " ? rest.dropFirst() : rest)
    }
}
