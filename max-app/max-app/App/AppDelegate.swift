//
//  AppDelegate.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: NSStatusItem, NSPopover, NSHostingController — no third-party code.
//
//  Replaces an earlier SwiftUI MenuBarExtra scene: MenuBarExtra was in the
//  compiled binary (verified via `strings`/`nm` on the built dylib — the code
//  was genuinely there) but never showed a status item, even after a full
//  clean rebuild. Rather than keep guessing at a SwiftUI-internal cause,
//  switched to the older, more battle-tested NSStatusItem API — notably the
//  same choice oxremy/BlinkMore (this feature's prior art) already made for
//  exactly this menu bar icon.
//

import AppKit
import Observation
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    /// Owned here, not by max_appApp's @State — AppDelegate is created once by
    /// @NSApplicationDelegateAdaptor before the App's own body ever runs, so
    /// this is the actual source of truth; max_appApp reads it back out via
    /// `appDelegate.blinkTrackerViewModel` to hand to ContentView.
    let blinkTrackerViewModel = BlinkTrackerViewModel()

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setUpStatusItem()
        observeIconChanges()
    }

    private func setUpStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = statusIcon()
            button.target = self
            button.action = #selector(togglePopover(_:))
        }

        let popover = NSPopover()
        popover.behavior = .transient
        let hosting = NSHostingController(rootView: BlinkTrackerMenuBarScreen(viewModel: blinkTrackerViewModel))
        hosting.sizingOptions = [.preferredContentSize]   // track the SwiftUI content's own size
        popover.contentViewController = hosting

        self.statusItem = item
        self.popover = popover
    }

    private func statusIcon() -> NSImage? {
        let image = NSImage(systemSymbolName: blinkTrackerViewModel.menuBarIconName, accessibilityDescription: "Eye Care")
        image?.isTemplate = true   // adapts to light/dark menu bar and the highlight state
        return image
    }

    /// @Observable doesn't push updates into imperative AppKit code on its
    /// own — this re-subscribes after every change so the status icon reacts
    /// live to blinkStatus flipping (see BlinkTrackerViewModel.menuBarIconName).
    private func observeIconChanges() {
        withObservationTracking {
            _ = blinkTrackerViewModel.menuBarIconName
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.statusItem?.button?.image = self?.statusIcon()
                self?.observeIconChanges()
            }
        }
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
