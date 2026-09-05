//
//  AssistantMessageView.swift
//  max-app
//
//  Provenance: HAND-BUILT
//  Built from: HStack — renders via MarkdownUI (gonzalezreal/swift-markdown-ui, MIT),
//  see Markdown/MarkdownTheme.swift.

import MarkdownUI
import SwiftUI

/// A message from Max: full width, no bubble, no avatar.
///
/// The asymmetry with `UserMessageView` is deliberate — it's what separates an
/// assistant transcript from a messenger conversation.
struct AssistantMessageView: View {
    let content: String

    var body: some View {
        HStack {
            Markdown(content)
                .markdownTheme(.max)
                .textSelection(.enabled)
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    AssistantMessageView(content: """
    Tokyo. It has been the capital since 1868, when the emperor moved the court there from Kyoto.

    A **bold** claim, some *emphasis*, and `inline code`:

    ```python
    def reverse(head):
        prev = None
        cur = head
        while cur:
            nxt = cur.next
            cur.next = prev
            prev, cur = cur, nxt
        return prev
    ```

    | Benefit | Why it matters |
    |---|---|
    | Speed | Generates boilerplate in seconds. |
    | Learning | Shows idiomatic patterns for unfamiliar APIs. |

    - Cuts boilerplate time
    - Speeds up prototyping
    """)
    .padding()
    .frame(width: 560)
}
