import AppKit

/// Applies the app's dark appearance and Dock icon before launch completes.
@MainActor
final class AppIconDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.appearance = NSAppearance(named: .darkAqua)
        guard let image = NSImage(named: "DockIconDark") else { return }
        NSApp.applicationIconImage = image
    }
}
