// Provenance: HAND-BUILT. Built from: ButtonStyle, EnvironmentValues.
import SwiftUI

struct IconButtonStyle: ButtonStyle {
    var size: CGFloat = AppSpacing.iconButtonSize
    var foreground: Color = .textSecondary

    func makeBody(configuration: Configuration) -> some View {
        IconButtonBody(configuration: configuration, size: size, foreground: foreground)
    }

    private struct IconButtonBody: View {
        let configuration: Configuration
        let size: CGFloat
        let foreground: Color
        @Environment(\.isEnabled) private var isEnabled
        @State private var isHovered = false

        var body: some View {
            configuration.label
                .font(AppFont.toolbarIcon)
                .foregroundStyle(foreground)
                .frame(width: size, height: size)
                .background(isEnabled && (isHovered || configuration.isPressed)
                            ? Color.surfaceHover : .clear,
                            in: .rect(cornerRadius: AppRadius.control))
                .contentShape(.rect)
                .opacity(isEnabled ? (configuration.isPressed ? 0.65 : 1) : 0.45)
                .onHover { isHovered = $0 }
        }
    }
}

extension ButtonStyle where Self == IconButtonStyle {
    static var icon: IconButtonStyle { IconButtonStyle() }
}
