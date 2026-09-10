//
//  max_appApp.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/7/26.
//

import SwiftUI

@main
struct max_appApp: App {
    // Hoisted here so the popover content (BreakTimerMenuBarScreen) has a
    // stable, single BreakTimerViewModel instance to bind to — same pattern
    // as ContentView owning ChatViewModel, just at the App level since two
    // Scenes need to share this one.
    @State private var breakTimerViewModel = BreakTimerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        // SwiftUI-native menu bar item — see feedback_prefer_swiftui_over_ appkit.
        //
        // Two things were wrong when this wouldn't render:
        //
        // 1. The label must be a bare Text / Image / Label. MenuBarExtra draws its
        //    label into an NSStatusItem button, and that path only understands
        //    those few view types — an HStack wrapping them yields an item with
        //    nothing to draw. The systemImage: shorthand is the supported spelling.
        //
        // 2. The real blocker: macOS 26 renders third-party menu bar items out of
        //    the Control Center process and gates them per bundle identifier
        //    (System Settings > Menu Bar > "Allow in the Menu Bar"). The old
        //    identifier "mahasvin.max-app" was stuck in a state where it was
        //    listed and toggled ON yet never rendered — proven by giving a
        //    known-good throwaway menu bar app that same identifier and watching
        //    it go dark, while the same app under any other identifier worked.
        //    Renaming to "com.mahasvin.max-app" fixed it instantly. So: if the
        //    icon ever vanishes again, suspect that per-bundle-ID state, not this
        //    code — and don't reach for NSStatusItem, which fails identically.
        MenuBarExtra("Max", image: "MenuBarIcon") {
            BreakTimerMenuBarScreen(viewModel: breakTimerViewModel)
        }
        .menuBarExtraStyle(.window)
    }
}
