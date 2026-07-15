//
//  ContentView.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/7/26.
//

import SwiftUI

struct ContentView: View {
    private enum Page {
        case home
        case productivity
        case settings
    }
    
    @State private var selected: Page = .home
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selected) {
                // chat
                Label(Constants.chatString, systemImage: Constants.chatIconString)
                    .tag(Page.home)
                
                // productivity
                Label(Constants.productivityString, systemImage: Constants.productivityIconString)
                    .tag(Page.productivity)
                
                // settings
                Label(Constants.settingsString, systemImage: Constants.settingsIconString)
                    .tag(Page.settings)
            }
            .listStyle(.sidebar)
        } detail: {
            switch selected {
            case .home:
                HomeView()
                    .frame(minWidth: 500, minHeight: 300)
            case .productivity:
                ProductivityView()
                    .frame(minWidth: 500, minHeight: 300)
            case .settings:
                SettingsView()
                    .frame(minWidth: 500, minHeight: 300)
            }
        }
    }
}

#Preview {
    ContentView()
}
