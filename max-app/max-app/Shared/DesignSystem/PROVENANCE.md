# Component provenance

Every view/component file starts with a `Provenance:` line so it is always visible
where the code came from. Three states:

- `HAND-BUILT` — written here from scratch. Should be the exception, not the rule.
- `VENDORED — <source>, <license>` — copied in essentially unchanged.
- `ADAPTED — <source>, <license>` — copied in and modified. The header lists what changed.

Files also carry a `Built from:` line naming the stock SwiftUI components they compose,
because reusing Apple's components counts as reuse and should be just as visible.

When replacing a HAND-BUILT file with vendored or adapted code, update the header in the
same commit — the headers are the record of whether we're actually reusing or quietly
rebuilding.

## Sources in use

| Source | License | Used for |
|---|---|---|
| Apple SwiftUI | — | all structural components |
| OpenAI Apps SDK UI design tokens | MIT | colour values in `Assets.xcassets` |
| [gluonfield/enchanted](https://github.com/gluonfield/enchanted) | Apache-2.0 | composer, floating icon button |
| [gonzalezreal/swift-markdown-ui](https://github.com/gonzalezreal/swift-markdown-ui) | MIT | assistant reply Markdown/table rendering |

Attribution and the full Apache-2.0 text live in `THIRD_PARTY/`. Apache-2.0 section
4(b) requires stating changes, which is what each adapted file's `Changes from the
original` block is for — keep it accurate when editing those files.

swift-markdown-ui is a live SPM package dependency, not a vendored/adapted copy — the
first case of "reuse" taking that form here. There's no corresponding file under
`THIRD_PARTY/` for it the way there is for enchanted's Apache-2.0 text; its license is
tracked by Xcode's own Package Dependencies license report instead. It pulls in two further packages transitively, both resolved automatically, not
vendored: [swiftlang/swift-cmark](https://github.com/swiftlang/swift-cmark) (the GFM
parser, BSD-2-Clause) and [gonzalezreal/NetworkImage](https://github.com/gonzalezreal/NetworkImage)
(image loading for Markdown images, MIT).
