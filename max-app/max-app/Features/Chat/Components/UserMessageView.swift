//
//  UserMessageView.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: Text, HStack — no third-party code.

import SwiftUI

/// A message the user sent: a bubble, aligned trailing, never full width.
struct UserMessageView: View {
    let content: String

    var body: some View {
        HStack {
            Spacer(minLength: AppSpacing.xxl)
            Text(content)
                .messageTextStyle()
                .padding(.horizontal, AppSpacing.l)
                .padding(.vertical, AppSpacing.m)
                .background(Color.bubbleUser, in: .rect(cornerRadius: AppRadius.bubble))
        }
    }
}

#Preview {
    VStack(spacing: AppSpacing.l) {
        UserMessageView(content: "What is the capital of Japan?")
        UserMessageView(content: "A longer message, to check that the bubble wraps and stops well short of the full width of the window rather than stretching across it.")
    }
    .padding()
    .frame(width: 560)
}
