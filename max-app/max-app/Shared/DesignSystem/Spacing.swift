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
}

/// Corner radii. Named by role rather than by number.
enum AppRadius {
    static let composer: CGFloat = 22
    static let bubble: CGFloat = 18
}
