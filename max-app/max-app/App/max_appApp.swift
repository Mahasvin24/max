//
//  max_appApp.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/7/26.
//

import SwiftUI

@main
struct max_appApp: App {
    // Hoisted here (not inside the popover content) because the menu bar
    // icon's systemImage needs to reflect live blink status, and Scene.body's
    // label closure can't reach into state owned only inside MenuBarExtra's
    // content closure. Monitoring starts from BlinkTrackerViewModel.init()
    // itself, not from this Scene's lifecycle — it must keep running whether
    // or not the popover is open.
    @State private var blinkTrackerViewModel = BlinkTrackerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        MenuBarExtra("Max — Eye Care", systemImage: blinkTrackerViewModel.menuBarIconName) {
            BlinkTrackerMenuBarScreen(viewModel: blinkTrackerViewModel)
        }
        .menuBarExtraStyle(.window)
    }
}
