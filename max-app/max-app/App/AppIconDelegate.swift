import AppKit

/// Keeps the running app's Dock icon in step with system appearance.
@MainActor
final class AppIconDelegate: NSObject, NSApplicationDelegate {
    private var appearanceObservation: NSKeyValueObservation?

    func applicationDidFinishLaunching(_ notification: Notification) {
        updateIcon()
        appearanceObservation = NSApp.observe(\.effectiveAppearance, options: [.new]) { [weak self] _, _ in
            Task { @MainActor [weak self] in
                self?.updateIcon()
            }
        }
    }

    private func updateIcon() {
        let dark = NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
        guard let image = NSImage(named: dark ? "DockIconDark" : "DockIconLight") else { return }
        // SwiftUI has no Dock icon API. Explicit AppKit assignment also avoids
        // macOS's separate icon-style preference overriding system Dark mode.
        // These assets already include the native mask, unlike full-bleed Logo.
        NSApp.applicationIconImage = image
    }
}
