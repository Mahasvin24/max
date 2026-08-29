//
//  AssistantMessageView.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: Text, HStack — no third-party code.

import SwiftUI

/// A message from Max: full width, no bubble, no avatar.
///
/// The asymmetry with `UserMessageView` is deliberate — it's what separates an
/// assistant transcript from a messenger conversation.
struct AssistantMessageView: View {
    let content: String

    var body: some View {
        HStack {
            Text(content)
                .messageTextStyle()
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    AssistantMessageView(content: "Tokyo. It has been the capital since 1868, when the emperor moved the court there from Kyoto.")
        .padding()
        .frame(width: 560)
}
