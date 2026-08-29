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
    static let greeting = Font.system(size: 28, weight: .medium)
    /// Sidebar rows and secondary chrome. SF Symbols in a Label scale with this
    /// automatically, so bumping this one value grows the row icons too.
    static let sidebar = Font.system(size: 17)
    /// Small supporting text.
    static let caption = Font.system(size: 12)
    /// Toolbar app name.
    static let toolbarTitle = Font.system(size: 16, weight: .semibold)
    /// Toolbar symbol buttons.
    static let toolbarIcon = Font.system(size: 16, weight: .regular)
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
