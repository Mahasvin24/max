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

    /// Left/right inset for rows still living inside the Recents `List` — the
    /// "Recents" header and each conversation title (see ConversationRow). New Chat/
    /// Scheduled/Plugins used to share this too, back when they were List rows; they
    /// aren't anymore (see `pinnedActionInsets`) — don't reuse this for them, it reads
    /// as way too far left outside a List.
    ///
    /// (There was a text-matching variant here briefly — aligning Recents with New
    /// Chat's *text* instead of New Chat's *icon* — based on a misreading of "recents
    /// text isn't aligned with the sidebar buttons" as being about the label text
    /// specifically. It wasn't: the original ask was for Max/Recents/the buttons to
    /// share one vertical line as whole units, which means the icon edge. That
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

    /// Left/right inset for New Chat/Scheduled/Plugins (SidebarView.pinnedActions) —
    /// plain views, not List rows, ever since Recents became independently
    /// scrollable. Matches `l`, the same margin `header` uses for "Max": that was
    /// always the real target these rows aligned to — `sidebarRowInsets`'s smaller,
    /// stranger-looking numbers only exist to counteract List's own hidden indent,
    /// which doesn't apply here. Using `sidebarRowInsets` on a plain view is exactly
    /// the "super far left" regression from moving these out of the List — use this
    /// one instead.
    static let pinnedActionInsets = EdgeInsets(top: xs, leading: l, bottom: xs, trailing: l)

    /// Width of the icon column in New Chat / Scheduled / Plugins.
    static let sidebarIconColumnWidth: CGFloat = 26
}

/// Corner radii. Named by role rather than by number.
enum AppRadius {
    /// Deliberately larger than the composer will ever be tall — SwiftUI clamps a
    /// RoundedRectangle's radius to half its shortest side, so this always renders
    /// as a full capsule/pill regardless of how many lines the composer grows to.
    static let composer: CGFloat = 999
    static let bubble: CGFloat = 18
}
