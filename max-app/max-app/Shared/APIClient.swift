//
//  APIClient.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/13/26.
//

import Foundation

struct APIClient {
    // health check
    static func checkConnectionHealth() async -> Bool {
        let res: Health
        do {
            res = try await request(
                action: Constants.API.GET, path: "/health"
            )
        } catch {
            print(error.localizedDescription)
            return false
        }
        return res.status == "ok"
    }
    
    // generic api request (has a body)
    static func request<Input: Encodable, Output: Decodable>(action: String, path: String, body: Input?) async throws -> Output {
        
        guard let url = URL(string: "\(Constants.API.baseURL)\(path)") else {
            throw APIError.invalidURL
        }
        
        // create request
        var req = URLRequest(url: url)
        req.httpMethod = action
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
        
        // make request
        let result: Data
        let response: URLResponse
        do {
            (result, response) = try await URLSession.shared.data(for: req)
        } catch {
            throw APIError.connectionFailed
        }
        
        // status code check
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIError.requestFailed(statusCode: statusCode)
        }
        
        // decode
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let obj: Output
        do {
            obj = try decoder.decode(Output.self, from: result)
        } catch {
            throw APIError.decodingFailed(underlyingError: error)
        }
        
        return obj
    }
    
    
    // generic api request (no body)
    private struct EmptyBody: Encodable {}
    static func request<Output: Decodable>(action: String, path: String) async throws -> Output {
        try await request(action: action, path: path, body: EmptyBody?.none)
    }
}
