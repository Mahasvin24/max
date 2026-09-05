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
            Text(content.renderingMarkdown)
                .messageTextStyle()
            Spacer(minLength: 0)
        }
    }
}

private extension String {
    /// Parses the model's reply as Markdown (bold, italics, inline code,
    /// links, code blocks) for display. Falls back to the raw string — rather
    /// than an empty bubble — on the rare input `AttributedString` can't
    /// parse at all.
    var renderingMarkdown: AttributedString {
        // AttributedString's Markdown parser is CommonMark-only: raw inline
        // HTML like `<br>` (which the model sometimes emits inside table
        // cells) isn't interpreted and would otherwise show up as literal
        // text. Swap it for a real newline before parsing.
        let normalized = replacingOccurrences(
            of: #"<br\s*/?>"#, with: "\n",
            options: [.regularExpression, .caseInsensitive]
        )
        return (try? AttributedString(
            markdown: normalized,
            options: .init(interpretedSyntax: .full)
        )) ?? AttributedString(normalized)
    }
}

#Preview {
    AssistantMessageView(content: """
    Tokyo. It has been the capital since 1868, when the emperor moved the court there from Kyoto.

    A **bold** claim, some *emphasis*, and `inline code`:

    ```python
    def reverse(head):
        prev = None
        return prev
    ```
    """)
    .padding()
    .frame(width: 560)
}
