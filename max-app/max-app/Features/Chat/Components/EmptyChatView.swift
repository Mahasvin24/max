//
//  EmptyChatView.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: VStack, Text, ComposerView.

import SwiftUI

/// What you see before a conversation exists: a greeting with the composer
/// centered under it, rather than pinned to the bottom edge.
struct EmptyChatView: View {
    @Binding var text: String
    var isSending: Bool = false
    var onSend: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Text("Ready when you are, \(Constants.userNameString).")
                .font(AppFont.greeting)
                .foregroundStyle(.primary)

            ComposerView(text: $text, isSending: isSending, onSend: onSend)
                .frame(maxWidth: AppSpacing.readableWidth)
        }
        .padding(.horizontal, AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    @Previewable @State var text = ""
    EmptyChatView(text: $text) {}
        .frame(width: 720, height: 480)
}
