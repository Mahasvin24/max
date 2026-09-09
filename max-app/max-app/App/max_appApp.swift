//
//  max_appApp.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/7/26.
//

import SwiftUI

@main
struct max_appApp: App {
    // The menu bar item itself is owned by AppDelegate (NSStatusItem, not
    // SwiftUI's MenuBarExtra — see AppDelegate.swift for why). This just reads
    // the shared BlinkTrackerViewModel back out to hand to ContentView, so
    // EyeCareDebugScreen can pause/resume it around its own capture session.
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(blinkTrackerViewModel: appDelegate.blinkTrackerViewModel)
        }
    }
}
