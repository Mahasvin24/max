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
                Label("Home", systemImage: "message")
                    .tag(Page.home)
                Label("Screen Time", systemImage: "hourglass")
                    .tag(Page.screenTime)
                Label("Settings", systemImage: "gearshape.fill")
                    .tag(Page.settings)
            }
        } detail: {
            switch selected {
            case .home:
                Label("home page", systemImage: "message")
            case .screenTime:
                Label("Screen Time page", systemImage: "hourglass")
            case .settings:
                Label("Settings page", systemImage: "gearshape.fill")
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
