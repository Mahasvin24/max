//
//  NotificationService.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: UNUserNotificationCenter — no third-party code.
//
//  Thin wrapper over local notifications, shared by anything that needs to post
//  one (currently BlinkTrackerViewModel, for both the blink warning and the
//  20-20-20 break reminder) — one namespace per concern, matching APIClient and
//  Constants rather than each feature calling UNUserNotificationCenter directly.
//
//  Gentle nudges only: a local notification, never a full-screen takeover — see
//  Constants.BlinkTracker and BlinkTrackerViewModel for why.
//

import UserNotifications

enum NotificationService {
    private static var authorizationRequested = false

    /// Requests notification authorization once per app run. Safe to call
    /// repeatedly — the actual system prompt only appears the first time.
    static func requestAuthorizationIfNeeded() async {
        guard !authorizationRequested else { return }
        authorizationRequested = true
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    static func postBlinkWarning() {
        post(
            identifier: "blink-warning",
            title: "Blink more",
            body: "Your blink rate has been low for a while — this can dry out your eyes. A few deliberate blinks help."
        )
    }

    static func postBreakReminder() {
        post(
            identifier: "break-reminder",
            title: "20-20-20 break",
            body: "Look at something about 20 feet away for 20 seconds."
        )
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
