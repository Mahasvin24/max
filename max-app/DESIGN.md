# Max's dark UI foundation

The visual reference is **Soft sidebar · Deeper black**. Opaque neutral surfaces,
system typography, and continuous rounded corners keep the main window quiet.

Max is primarily a personal tool for Mahasvin. Optimize for his daily workflow
and keep controls and copy purposeful.

## Ownership and components

- `max_appApp` owns the break timer. Each `ContentView` owns its chat model,
  draft, sidebar visibility, and focus request.
- `HSplitView` owns native resizing. Sidebar rows are native buttons with one
  shared `RowButtonStyle`; selection, hover, focus, and disabled states are explicit.
  The sidebar starts at 230 pt and can be resized from 200 to 294 pt.
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
| Canvas | Surface | #181818 |
| Sidebar | SurfaceSecondary | #1D1D1D |
| Composer and cards | SurfaceElevated | #202020 |
| User message | BubbleUser | #202020 |
| Selection | SurfaceSelected | #303030 |
| Hover | SurfaceHover | #252525 |
| Border | BorderSubtle | #353535 |
| Primary text | TextPrimary | #E4E4E4 |
| Secondary text | TextSecondary | #A0A0A0 |
| Sidebar labels | SidebarForeground | #D4D4D4 |
| Primary action | AccentColor | #EDEDED |

Custom colors include high-contrast variants. Existing light values are retained
for future light-mode work; main window and popover currently prefer dark mode.
Disabled controls may be dimmer, but readable content uses the primary/secondary
text tokens. Links are underlined. Information never depends on color alone.

The approved Soft typography uses the rounded system design for the main chat:
a 38 pt medium greeting, 14 pt introduction, and 15 pt messages/input, including
Markdown. Code stays monospaced. The sidebar uses the default system sans:
14 pt regular rows with 34 pt row height and 2 pt between rows, plus a 22 pt
semibold wordmark.
Menu bar sizes remain separate. Surface radii must be explicit:
25 pt composer, 18 pt message bubbles, 11 pt rows, 10 pt popover cards.

## Identity

The approved vortex is used in the sidebar wordmark, welcome artwork, menu bar,
and indeterminate chat/loading states. `LogoMark` wraps the native `MaxVortex`
shape and inherits the surrounding foreground style; `LogoSpinner` respects
Reduce Motion. The timer's determinate progress bar continues to show elapsed
progress. The native app icon uses a black vortex on a full white background
in Default appearance and a off-white (#E9E9E9) vortex on charcoal (#181818) in Dark. macOS supplies its
outer mask; the artwork has no pre-rounded inset tile or transparent margin.

Geometry and regeneration commands live in [`../logo/README.md`](../logo/README.md).

## Interaction

- Command-Shift-N starts a chat in the focused window; Command-N retains the
  native New Window command. Control-Command-S toggles that window's sidebar.
- Up/down arrows navigate enabled sidebar rows when focus is in the sidebar.
- New chats center the personal greeting and orbital logo artwork in the space
  above the composer. The composer is the only starting action; there are no
  preset prompts or decorative capability labels in the input.
- Chat and Tools sit beside Settings in the top-right workspace header. Tools
  and Settings remain disabled until their features are implemented.
- Return sends; Shift-Return inserts a newline. Text remains editable during a
  response, but Send stays disabled until completion or failure.
- The native composer input starts at two lines, grows to six, then scrolls.
- A newly submitted message scrolls to the top of the conversation area. The
  reply appears beneath it; a flexible bottom inset preserves that position
  until the reply fills the available height. The first bubble rises into place;
  later turns animate their scroll. Reduce Motion keeps both transitions instant.
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
