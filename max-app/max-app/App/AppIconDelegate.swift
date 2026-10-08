import AppKit
import UserNotifications

/// Configures app-wide appearance, Dock icon, menu-bar placement, and native
/// notification presentation while Max is in the foreground.
@MainActor
final class AppIconDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        migrateMenuBarItemPositionIfNeeded()
        UNUserNotificationCenter.current().delegate = self
        NSApp.appearance = NSAppearance(named: .darkAqua)
        guard let image = NSImage(named: "DockIconDark") else { return }
        NSApp.applicationIconImage = image
    }

    private func migrateMenuBarItemPositionIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: Constants.MenuBar.migrationDefaultsKey) else { return }

        // MenuBarExtra uses AppKit's first automatic autosave name, Item-0.
        // Give a newly registered Max item a visible initial position to the
        // right of Hidden Bar's divider. This runs once so later user dragging
        // or removal remains authoritative.
        defaults.set(
            Constants.MenuBar.initialPreferredPosition,
            forKey: Constants.MenuBar.preferredPositionDefaultsKey
        )
        defaults.set(true, forKey: Constants.MenuBar.visibilityDefaultsKey)
        defaults.set(true, forKey: Constants.MenuBar.migrationDefaultsKey)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
