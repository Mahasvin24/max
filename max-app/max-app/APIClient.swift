//
//  APIClient.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/13/26.
//

import Foundation

struct APIClient {
    
    // generic api request
    func request<Input: Encodable, Output: Decodable>(path: String, action: String, body: Input?) async throws -> Output {
        
        // url
        guard let url = URL(string: "\(Constants.baseURL)\(path)") else {
            throw APIError.invalidURL
        }
        
        // create request
        var req = URLRequest(url: url)
        req.httpMethod = action
        
        if let body {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            req.httpBody = try encoder.encode(body)
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let d
    }
}
