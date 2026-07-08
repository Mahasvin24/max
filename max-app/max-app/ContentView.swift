//
//  ContentView.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/7/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selected: Page = .home
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selected) {
                Label("Home", systemImage: "bubble")
                Label("Screen Time", systemImage: "hourglass")
                Label("Settings", systemImage: "gear")
            }
        } detail: {
            switch selected {
            case .home:
                Label("home", systemImage: "home")
            case .screenTime:
                Label("Screen Time", systemImage: "home")
            case .settings:
                Label("stuff", systemImage: "settings")
            }
        }
    }
}

enum Page {
    case home
    case screenTime
    case settings
}

#Preview {
    ContentView()
}
