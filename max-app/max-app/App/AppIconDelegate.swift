import AppKit

/// Configures app-wide appearance, Dock icon, and menu-bar placement.
@MainActor
final class AppIconDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        migrateMenuBarItemPositionIfNeeded()
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
}
