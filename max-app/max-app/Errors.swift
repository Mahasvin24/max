//
//  Errors.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/13/26.
//

import Foundation

enum APIError: Error, LocalizedError {
    case connectionFailed
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed(underlyingError: Error)
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "Request failed: could not connect to backend."
        case .invalidURL:
            return "Request failed: url is invalid."
        case .requestFailed(let statusCode):
            return "Request failed with status code \(statusCode)"
        case .decodingFailed(let error):
            return "Request failed: failed to decode result. \(error)"
        }
    }
}
