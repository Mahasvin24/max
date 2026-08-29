//
//  Spacing.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: plain constants — no third-party code.

import SwiftUI

/// One spacing scale for the whole app, on the platform's 8pt rhythm.
/// Use these instead of literals so spacing stays consistent as the UI grows.
enum AppSpacing {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 32

    /// Chat content stops widening past this, so lines stay readable on a wide window.
    static let readableWidth: CGFloat = 720

    /// Left/right inset shared by every sidebar row — New Chat, Scheduled, Plugins,
    /// Recents, and each conversation title — so they line up with "Max" in the
    /// header (which sits at its own AppSpacing.l padding, in SidebarView.header).
    ///
    /// `leading` here is set well below that l (16) on purpose: `.listStyle(.sidebar)`
    /// appears to reserve its own baseline leading space — for selection/disclosure
    /// chrome — on top of whatever `.listRowInsets` asks for, so matching `l` exactly
    /// still left the rows visibly indented past "Max". This value is a strong first
    /// correction, not a measured one — nudge it (further negative pulls rows further
    /// left) while watching the sidebar #Preview live; that's faster than another
    /// round trip through chat for a number only you can see landing correctly.
    static let sidebarRowInsets = EdgeInsets(top: xs, leading: -2, bottom: xs, trailing: l)   // ← nudge `leading` here (more negative = further left)
}

/// Corner radii. Named by role rather than by number.
enum AppRadius {
    static let composer: CGFloat = 22
    static let bubble: CGFloat = 18
}
