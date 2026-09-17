# Max's dark UI foundation

The visual reference is **Soft sidebar · Deeper black**. Opaque neutral surfaces,
system typography, and continuous rounded corners keep the main window quiet.

## Ownership and components

- `max_appApp` owns the break timer. Each `ContentView` owns its chat model,
  draft, sidebar visibility, and focus request.
- `HSplitView` owns native resizing. Sidebar rows are native buttons with one
  shared `RowButtonStyle`; selection, hover, focus, and disabled states are explicit.
  The sidebar prefers 220 pt and resizes between 200 and 260 pt.
- `ChatScreen` keeps one composer alive while its content switches between the
  empty state, loading, and transcript. Small components receive values and actions.
- `ChatViewModel` owns request state. Sending remains busy through stream completion;
  waiting ends at the first nonempty chunk. Request identities isolate late results
  after navigation. A stream closure is the only injected testing dependency.
- `MenuBarExtra`, the timer, notifications, and sleep/wake behavior retain their
  existing ownership. The popover's appearance override is local to its screen.

## Tokens

Use asset-catalog colors, `AppFont`, `AppSpacing`, and `AppRadius` in components.
Do not add a second theme manager or embed color literals in view code.

| Role | Asset | Dark value |
| --- | --- | --- |
| Canvas | Surface | #0C0C0C |
| Sidebar | SurfaceSecondary | #141414 |
| Composer and cards | SurfaceElevated | #202020 |
| User message | BubbleUser | #202020 |
| Selection | SurfaceSelected | #262626 |
| Hover | SurfaceHover | #252525 |
| Border | BorderSubtle | #353535 |
| Primary text | TextPrimary | #F1F1F1 |
| Secondary text | TextSecondary | #A0A0A0 |
| Primary action | AccentColor | #EDEDED |

Custom colors include high-contrast variants. Existing light values are retained
for future light-mode work; main window and popover currently prefer dark mode.
Disabled controls may be dimmer, but readable content uses the primary/secondary
text tokens. Links are underlined. Information never depends on color alone.

The system type scale is a 38 pt rounded greeting, 22 pt wordmark, 15 pt messages/input,
and 14 pt sidebar. Menu bar sizes remain separate. Surface radii must be explicit:
25 pt composer, 18 pt message bubbles, 11 pt rows, 10 pt popover cards.

## Interaction

- Command-Shift-N starts a chat in the focused window; Command-N retains the
  native New Window command. Control-Command-S toggles that window's sidebar.
- Up/down arrows navigate enabled sidebar rows when focus is in the sidebar.
- Three prompt cards offer planning, exploration, and writing starters. They fill
  and focus the draft, and disappear while text is present.
- Chat and Tools sit beside Settings in the top-right workspace header. Tools
  and Settings remain disabled until their features are implemented.
- Return sends; Shift-Return inserts a newline. Text remains editable during a
  response, but Send stays disabled until completion or failure.
- The native composer input starts at two lines, grows to six, then scrolls.
- Unbuilt features remain visibly disabled with tooltips. They perform no actions.

## Verification

Build the `max-app` Xcode scheme. Run the dependency-free chat-state tests with:

```sh
swift test --package-path max-app
```

The Swift package compiles the same model and transport sources as the app; it
introduces no additional runtime dependencies. Tests cover waiting, chunked and
unchunked completion, failures, duplicate sends, and obsolete responses.

For visual QA, inspect 1024 × 670 and 900 × 640 content sizes, collapsed sidebar,
long titles/drafts, Markdown, error/loading states, and increased contrast.
`ImageRenderer` cannot rasterize HSplitView or native text inputs; placeholders
from that renderer do not establish whether those controls work in a live window.
Use native app inspection for text editing, keyboard focus, window chrome,
divider resizing, and the popover switch.
