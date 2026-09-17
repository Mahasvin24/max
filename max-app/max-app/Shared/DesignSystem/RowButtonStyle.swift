// Provenance: HAND-BUILT. Built from: ButtonStyle, EnvironmentValues.
import SwiftUI

/// Shared row treatment for navigation actions and recent conversations.
struct RowButtonStyle: ButtonStyle {
    var isSelected = false
    var isFocused = false

    func makeBody(configuration: Configuration) -> some View {
        RowBody(configuration: configuration, isSelected: isSelected, isFocused: isFocused)
    }

    private struct RowBody: View {
        let configuration: Configuration
        let isSelected: Bool
        let isFocused: Bool
        @Environment(\.isEnabled) private var isEnabled
        @State private var isHovered = false

        var body: some View {
            configuration.label
                .font(AppFont.sidebar)
                .labelStyle(.titleAndIcon)
                .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, minHeight: AppSpacing.sidebarRowHeight, alignment: .leading)
                .padding(.horizontal, AppSpacing.m)
                .background(background, in: .rect(cornerRadius: AppRadius.row))
                .overlay {
                    if isFocused {
                        RoundedRectangle(cornerRadius: AppRadius.row)
                            .strokeBorder(Color.textSecondary, lineWidth: 1)
                    }
                }
                .contentShape(.rect)
                .opacity(isEnabled ? 1 : 0.5)
                .onHover { isHovered = $0 }
        }

        private var background: Color {
            if isSelected { return .surfaceSelected }
            return isEnabled && (isHovered || configuration.isPressed) ? .surfaceHover : .clear
        }
    }
}

