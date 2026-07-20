//
//  PressableIconButtonStyle.swift
//  max-app
//
//  Created by Mahasvin Shanmugapriya Manikandan on 7/19/26.
//

import SwiftUI

// Scales down on press for instant, tactile feedback (Apple Fluid Interfaces: respond on press, not release)
struct PressableIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(duration: 0.15), value: configuration.isPressed)
    }
}
