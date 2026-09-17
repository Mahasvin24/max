//
//  max_appApp.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/7/26.
//

import SwiftUI

@main
struct max_appApp: App {
    // One app-owned timer survives opening and closing the popover.
    @State private var breakTimerViewModel = BreakTimerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .tint(Color.accentColor)
        }
        .defaultSize(width: 1024, height: 670)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .commands { MaxCommands() }

        // Keep a bare template image label and the existing bundle identifier.
        // macOS owns its rendering; diagnostics are documented in AGENT.md.
        MenuBarExtra("Max", image: "LogoMark") {
            BreakTimerMenuBarScreen(viewModel: breakTimerViewModel)
        }
        .menuBarExtraStyle(.window)
    }
}
