//
//  NotificationService.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: UNUserNotificationCenter — no third-party code.
//
//  Owns reminder presentation for the 20-20-20 timer: a Notification Center
//  entry plus an app-owned alert that remains visible when system notification
//  presentation is suppressed.
//
//  AppKit is used for the alert because SwiftUI's window-opening action is an
//  environment value and isn't available to the app-owned background timer.
//

import AppKit
import UserNotifications

enum NotificationService {
    private static var authorizationRequested = false
    private static var isBreakReminderVisible = false

    /// Requests notification authorization once per app run. Safe to call
    /// repeatedly — the actual system prompt only appears the first time.
    static func requestAuthorizationIfNeeded() async {
        guard !authorizationRequested else { return }
        authorizationRequested = true
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    static func postBreakReminder() {
        post(
            identifier: "break-reminder",
            title: "20-20-20 break",
            body: "Look at something about 20 feet away for 20 seconds."
        )
        showBreakReminder()
    }

    /// Notification Center can suppress an otherwise valid notification because
    /// of per-app settings, Focus, or foreground presentation policy. The timer
    /// is an app-owned feature, so also show an app-owned alert that is guaranteed
    /// to be visible when the interval ends.
    private static func showBreakReminder() {
        guard !isBreakReminderVisible else { return }
        isBreakReminderVisible = true
        defer { isBreakReminderVisible = false }

        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Time for an eye break"
        alert.informativeText = "Look at something about 20 feet away for 20 seconds."
        alert.addButton(withTitle: "Got it")
        alert.runModal()
    }

    /// Fixed identifiers per category (not a fresh UUID each time) so a new post
    /// replaces the previous one of the same kind rather than piling up in
    /// Notification Center over a full day of running in the background.
    private static func post(identifier: String, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
