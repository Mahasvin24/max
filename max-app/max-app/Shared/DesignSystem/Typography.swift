// Provenance: HAND-BUILT. Built from: Font, ViewModifier.
import SwiftUI

/// Explicit sizes keep the reading scale consistent across native macOS controls.
enum AppFont {
    static let chatDesign: Font.Design = .rounded
    static let messageSize: CGFloat = 15
    static let message = Font.system(size: messageSize, design: chatDesign)
    static let greeting = Font.system(size: 38, weight: .medium, design: chatDesign)
    static let introduction = Font.system(size: 14, design: chatDesign)
    static let chatCaption = Font.system(size: 12, design: chatDesign)
    static let sidebar = Font.system(size: 14)
    static let sidebarHeader = Font.system(size: 22, weight: .semibold)
    static let sidebarSectionHeader = Font.system(size: 12, weight: .medium)
    static let caption = Font.system(size: 12)
    static let toolbarIcon = Font.system(size: 16)
    static let segment = Font.system(size: 13, weight: .medium, design: chatDesign)
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
