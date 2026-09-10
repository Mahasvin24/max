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

    /// Left/right inset shared by every row in BOTH sidebar Lists — New Chat,
    /// Scheduled, Plugins (SidebarView.pinnedActions, its own non-scrolling List) and
    /// Recents/each conversation title (the scrolling List below it) — so all of
    /// them, icon rows and bare-text rows alike, share one left edge with "Max" in
    /// the header (its own AppSpacing.l padding, in SidebarView.header).
    ///
    /// There was a brief period where New Chat/Scheduled/Plugins were plain views
    /// instead of List rows (to make Recents independently scrollable without a
    /// second List) and needed a different, larger inset (`l`) to compensate for not
    /// having List's hidden baseline space. That's no longer the case — they're a
    /// second List now, not a plain VStack, specifically so they could go back to
    /// sharing this exact value instead of approximating it. If they ever become
    /// plain views again, re-derive rather than reusing this number as-is.
    ///
    /// (There was also a text-matching variant here briefly — aligning Recents with
    /// New Chat's *text* instead of New Chat's *icon* — based on a misreading of
    /// "recents text isn't aligned with the sidebar buttons" as being about the label
    /// text specifically. It wasn't: the original ask was for Max/Recents/the buttons
    /// to share one vertical line as whole units, which means the icon edge. That
    /// variant put Recents and every conversation title 34pt right of everything
    /// else. Reverted — don't reintroduce a second inset for this.)
    ///
    /// `leading` here is set well below `l` (16) on purpose: `.listStyle(.sidebar)`
    /// appears to reserve its own baseline leading space — for selection/disclosure
    /// chrome — on top of whatever `.listRowInsets` asks for, so matching `l` exactly
    /// still left the rows visibly indented past "Max". This value is a first
    /// correction, not a measured one — nudge it (more positive pulls rows right,
    /// more negative pulls them left) while watching the sidebar #Preview live;
    /// that's faster than another round trip through chat for a number only you can
    /// see landing correctly.
    static let sidebarRowInsets = EdgeInsets(top: xs, leading: 4, bottom: xs, trailing: l)   // ← nudge `leading` here (more positive = further right)

    /// Width of the icon column in New Chat / Scheduled / Eye Care.
    static let sidebarIconColumnWidth: CGFloat = 26

    /// Height of one row in SidebarView.pinnedActions (New Chat / Scheduled /
    /// Eye Care). That List sizes itself via an explicit `.frame(height:)` of
    /// `sidebarRowHeight * row count` rather than `.fixedSize(vertical: true)` —
    /// `List` on macOS doesn't reliably report a usable intrinsic height for
    /// `.fixedSize` to hug, and was observed collapsing to zero height (the
    /// whole row group invisible) instead of hugging its 3 rows. This number is
    /// a first estimate (14pt row font + `sidebarRowInsets`' 4pt top/bottom),
    /// not a measured one — nudge it while watching the sidebar #Preview live
    /// if rows clip or extra empty space shows up below Eye Care.
    static let sidebarRowHeight: CGFloat = 28
}

/// Corner radii. Named by role rather than by number.
enum AppRadius {
    /// Deliberately larger than the composer will ever be tall — SwiftUI clamps a
    /// RoundedRectangle's radius to half its shortest side, so this always renders
    /// as a full capsule/pill regardless of how many lines the composer grows to.
    static let composer: CGFloat = 999
    static let bubble: CGFloat = 18
    /// Cards inside the menu bar panel. Note this must be passed to SurfacePanel
    /// explicitly — SurfacePanel defaults to `composer` (999), which renders any
    /// panel as a full capsule. That default is why the break-timer popover used
    /// to look like a giant pill.
    static let panelCard: CGFloat = 10
}
