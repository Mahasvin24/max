//
//  ThinkingIndicator.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: LogoSpinner, Text — no third-party code.
//

import SwiftUI

/// Shown while a reply is in flight. The backend round trip is several seconds,
/// so the transcript needs to show that something is happening.
///
/// The spinning brandmark carries the motion now. The text used to pulse its
/// opacity as well; that was dropped when the mark arrived, because two competing
/// animations on one small row reads as busy rather than as alive. Under Reduce
/// Motion neither animates and the label alone does the work — see LogoSpinner.
struct ThinkingIndicator: View {
    var body: some View {
        HStack(spacing: AppSpacing.s) {
            LogoSpinner(size: 16)
                .foregroundStyle(Color.textSecondary)

            Text("Thinking…")
                .font(AppFont.message)
                .foregroundStyle(Color.textSecondary)

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Waiting for a reply")
    }
}

#Preview {
    ThinkingIndicator()
        .padding()
        .frame(width: 560)
}
