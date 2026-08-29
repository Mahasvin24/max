//
//  IconButton.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: ButtonStyle, EnvironmentValues — no third-party code.

import SwiftUI

/// Style for a compact symbol button.
///
/// A ButtonStyle rather than a ViewModifier because only a style can react to the
/// pressed state.
struct IconButtonStyle: ButtonStyle {
    var size: CGFloat = 28

    func makeBody(configuration: Configuration) -> some View {
        IconButtonBody(configuration: configuration, size: size)
    }

    private struct IconButtonBody: View {
        let configuration: Configuration
        let size: CGFloat
        @Environment(\.isEnabled) private var isEnabled
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        var body: some View {
            configuration.label
                .font(.body)
                .frame(width: size, height: size)
                .contentShape(.rect)
                .opacity(isEnabled ? (configuration.isPressed ? 0.5 : 1) : 0.35)
                .scaleEffect(configuration.isPressed && !reduceMotion ? 0.92 : 1)
                .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
        }
    }
}

extension ButtonStyle where Self == IconButtonStyle {
    static var icon: IconButtonStyle { IconButtonStyle() }
}
