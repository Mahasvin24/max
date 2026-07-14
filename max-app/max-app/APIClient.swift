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
        
        guard let url = URL(string: "\(Constants.baseURL)\(path)") else {
            throw APIError.invalidURL
        }
        
    }
}
