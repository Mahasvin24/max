//
//  Constants.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/7/26.
//

import Foundation

struct Constants {
    static let maxString = "Max"
    
    // Content View 
    static let chatString = "Chat"
    static let chatIconString = "message"
    static let productivityString = "Productivity"
    static let productivityIconString = "bolt.fill"
    static let settingsString = "Settings"
    static let settingsIconString = "gearshape.fill"
    
    // Chat page
    static let logoString = "Logo"
    
    // User Info (temporary structure)
    static let useNameString = "Mahasvin"
    
    // API
    struct API {
        static let baseURL = "http://127.0.0.1:8000"
        static let GET = "GET"
        static let POST = "POST"
        static let PUT = "PUT"
        static let PATCH = "PATCH"
        static let DELETE = "DELETE"
    }
}
