//
//  BreakNotificationService.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: UNUserNotificationCenter — no third-party code.
//
//  Owns the native local notification used by the 20-20-20 timer.
//

import UserNotifications

@MainActor
enum BreakNotificationService {
    private static var authorizationRequested = false

    /// Requests authorization once per app run. macOS remembers the person's
    /// choice, so subsequent launches do not show the system prompt again.
    static func requestAuthorizationIfNeeded() async {
        guard !authorizationRequested else { return }
        authorizationRequested = true
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound]
        )
    }

    /// Uses one stable identifier so repeated breaks replace the previous
    /// notification instead of accumulating in Notification Center.
    static func postBreakNotification() {
        let content = UNMutableNotificationContent()
        content.title = "It's been 20 minutes. Take a break?"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "eye-break",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
