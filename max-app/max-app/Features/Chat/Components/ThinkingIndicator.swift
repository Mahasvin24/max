//
//  ThinkingIndicator.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: Text, animation — no third-party code.

import SwiftUI

/// Shown while a reply is in flight. The backend round trip is several seconds,
/// so the transcript needs to show that something is happening.
struct ThinkingIndicator: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dimmed = false

    var body: some View {
        HStack {
            Text("Thinking…")
                .font(AppFont.message)
                .foregroundStyle(.secondary)
                .opacity(dimmed ? 0.45 : 1)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                    value: dimmed
                )
            Spacer(minLength: 0)
        }
        .onAppear { dimmed = true }
        .accessibilityLabel("Waiting for a reply")
    }
}

#Preview {
    ThinkingIndicator()
        .padding()
        .frame(width: 560)
}
