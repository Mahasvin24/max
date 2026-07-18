//
//  Constants.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/7/26.
//

import Foundation
import SwiftUI

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
    static let userNameString = "Mahasvin"
    
    // API
    struct API {
        static let baseURL = "http://127.0.0.1:8000"
        static let GET = "GET"
        static let POST = "POST"
        static let PUT = "PUT"
        static let PATCH = "PATCH"
        static let DELETE = "DELETE"
    }
    
    // one time use
    static let chatPlaceholderString = "Type / for skills"
    static let plusIconString = "plus"
    static let micIconString = "mic"
    static let sendIconString = "arrow.up.circle.fill"

    // Design tokens
    struct Design {
        // colors
        static let surfaceColor = Color("SurfacePanel")
        static let borderColor = Color("BorderSubtle")
        static let userBubbleColor = Color("BubbleUser")

        // corner radii
        static let boxCornerRadius: CGFloat = 20
        static let bubbleCornerRadius: CGFloat = 16

        // spacing / sizing
        static let bottomBarHeight: CGFloat = 44
        static let iconSize: CGFloat = 16
        static let maxContentWidth: CGFloat = 700
    }
}
