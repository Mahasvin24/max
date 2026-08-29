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
        /// `GET /all-conversations` — every conversation, newest first.
        static func allConversations() async throws -> ConversationList {
            try await APIClient.request(.get, "/all-conversations")
        }

        /// `GET /conversations?conversation_id=` — the messages of one conversation.
        ///
        /// Note the backend route is named `/conversations` but returns *messages*.
        static func messages(conversationId: Int) async throws -> [MessageResponse] {
            try await APIClient.request(
                .get, "/conversations",
                query: [URLQueryItem(name: "conversation_id", value: String(conversationId))]
            )
        }

        /// `DELETE /conversations?conversation_id=`
        @discardableResult
        static func deleteConversation(conversationId: Int) async throws -> Status {
            try await APIClient.request(
                .delete, "/conversations",
                query: [URLQueryItem(name: "conversation_id", value: String(conversationId))]
            )
        }

        /// `POST /messages` — send a message, get the agent's reply back.
        ///
        /// Pass `Conversation()` (id `-1`) to start a new conversation; the
        /// backend creates it and titles it for you.
        static func sendMessage(conversation: Conversation, content: String) async throws -> MessageResponse {
            try await APIClient.request(
                .post, "/messages",
                body: Message(conversation: conversation, content: content)
            )
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
