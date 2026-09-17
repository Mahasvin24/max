// Provenance: HAND-BUILT. Built from: Font, ViewModifier.
import SwiftUI

/// Explicit sizes keep the reading scale consistent across native macOS controls.
enum AppFont {
    static let messageSize: CGFloat = 15
    static let message = Font.system(size: messageSize)
    static let greeting = Font.system(size: 38, weight: .regular, design: .rounded)
    static let introduction = Font.system(size: 14, weight: .regular)
    static let suggestionTitle = Font.system(size: 14, weight: .medium)
    static let sidebar = Font.system(size: 14)
    static let sidebarHeader = Font.system(size: 22, weight: .semibold)
    static let sidebarSectionHeader = Font.system(size: 12, weight: .medium)
    static let caption = Font.system(size: 12)
    static let toolbarIcon = Font.system(size: 16)
    static let segment = Font.system(size: 13, weight: .medium)
    static let panelSectionHeader = Font.system(size: 11, weight: .semibold)
    static let panelMetric = Font.system(size: 22, weight: .medium)
}

struct MessageTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFont.message)
            .foregroundStyle(Color.textPrimary)
            .lineSpacing(5)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
    }
}

extension View {
    func messageTextStyle() -> some View { modifier(MessageTextStyle()) }
}
