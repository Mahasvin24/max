//
//  AppDelegate.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: NSStatusItem, NSPopover, NSHostingController — no third-party code.
//
//  Uses NSStatusItem rather than SwiftUI's MenuBarExtra — the same choice
//  oxremy/BlinkMore (this feature's original prior art) made for its menu bar
//  icon. (Diagnosed at length during development: on this machine, on this
//  macOS 26.4 build, neither MenuBarExtra nor NSStatusItem actually rendered
//  despite every internal AppKit signal reporting success — isVisible=true,
//  valid frame, non-nil icon, visible window — even down to a from-scratch
//  AppKit-only reproduction with zero SwiftUI. That matches a currently open,
//  unresolved macOS 26.4 bug independently affecting other menu bar apps
//  (Ice, Stats, CodexBar) — see their GitHub issue trackers. Nothing to fix on
//  our end; if the icon still doesn't render, that's this OS bug, not this code.)
//

import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    /// Owned here, not by max_appApp's @State — AppDelegate is created once by
    /// @NSApplicationDelegateAdaptor before the App's own body ever runs.
    let breakTimerViewModel = BreakTimerViewModel()

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setUpStatusItem()
    }

    private func setUpStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            let image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Eye Care")
            image?.isTemplate = true   // adapts to light/dark menu bar and the highlight state
            button.image = image
            button.target = self
            button.action = #selector(togglePopover(_:))
        }

        let popover = NSPopover()
        popover.behavior = .transient
        let hosting = NSHostingController(rootView: BreakTimerMenuBarScreen(viewModel: breakTimerViewModel))
        hosting.sizingOptions = [.preferredContentSize]   // track the SwiftUI content's own size
        popover.contentViewController = hosting

        self.statusItem = item
        self.popover = popover
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem?.button, let popover else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
