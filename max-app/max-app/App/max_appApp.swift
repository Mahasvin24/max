//
//  max_appApp.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/7/26.
//

import SwiftUI

@main
struct max_appApp: App {
    // The menu bar item (20-20-20 break reminder) is owned entirely by
    // AppDelegate — see AppDelegate.swift. Nothing here needs to reach it;
    // unlike the earlier camera-based blink tracker, the break timer has no
    // reason to coordinate with anything ContentView owns.
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
