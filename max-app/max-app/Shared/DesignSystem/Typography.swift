//
//  Typography.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: Font, ViewModifier — no third-party code.
//
//  One type scale for the app. Sizes are explicit rather than semantic (.body etc.)
//  because macOS semantic styles are ~13pt, which reads small next to the reference
//  UI. Defining them here keeps a single source of truth despite being fixed values.
//

import SwiftUI

enum AppFont {
    /// Message body and composer input.
    static let message = Font.system(size: 15)
    /// Large empty-state greeting.
    static let greeting = Font.system(size: 28, weight: .regular)
    /// New Chat / Scheduled / Plugins rows and every conversation title in Recents.
    /// Applied once, on SidebarView's List, and inherited by all of them — none of
    /// those rows set their own font. SF Symbols in a Label scale with this too,
    /// so bumping this one value grows the row icons as well as the text.
    static let sidebar = Font.system(size: 14)          // ← edit here for sidebar row size
    /// "Max" wordmark at the top of the sidebar. Used by SidebarView.header.
    static let sidebarHeader = Font.system(size: 20, weight: .semibold)   // ← edit here for "Max" size
    /// "Recents" section label.
    static let sidebarSectionHeader = Font.system(size: 15, weight: .medium)
    /// Small supporting text.
    static let caption = Font.system(size: 12)
    /// Toolbar symbol buttons — the gear in ContentView's toolbar AND the search/bell
    /// in SidebarView.header. Editing this moves all three at once; split it into
    /// separate constants if you want the sidebar icons to move independently.
    static let toolbarIcon = Font.system(size: 13, weight: .regular) // ← edit here for icon size
    /// Segmented control labels.
    static let segment = Font.system(size: 14, weight: .medium)
}

/// Body text of a chat message.
///
/// A ViewModifier rather than a custom view: it applies to any view, and keeps line
/// spacing and selection behaviour defined in exactly one place.
struct MessageTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.message)
            .lineSpacing(5)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
    }
}

extension View {
    func messageTextStyle() -> some View {
        modifier(MessageTextStyle())
    }
}
