import AppKit
import UserNotifications

/// Configures app-wide appearance, Dock icon, and notification presentation.
@MainActor
final class AppIconDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        // Foreground notifications are handed to the delegate. Explicitly ask
        // macOS for a banner so the reminder remains visible even when Max is
        // the active app.
        UNUserNotificationCenter.current().delegate = self
        NSApp.appearance = NSAppearance(named: .darkAqua)
        guard let image = NSImage(named: "DockIconDark") else { return }
        NSApp.applicationIconImage = image
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
