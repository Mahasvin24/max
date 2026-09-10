# max-app (macOS, SwiftUI)

## Prefer SwiftUI over AppKit

When both can do the job, use the SwiftUI-native API. Reach for AppKit only when
SwiftUI genuinely can't express it — and when you do, say why in a comment.

Note that "the SwiftUI version isn't working" is usually not that reason. In the
menu bar case below, `MenuBarExtra` and a hand-rolled `NSStatusItem` failed
*identically*, because the fault was downstream of both. Swapping to AppKit cost
a rewrite and bought nothing. Before switching frameworks, confirm the framework
is actually the variable.

## The menu bar icon

Read this before touching `MenuBarExtra` in `App/max_appApp.swift`.

### How macOS 26 actually renders menu bar items

A third-party menu bar item is **not drawn by your app**. The app owns no
status-level window at all — Control Center draws it, and the OS gates it **per
bundle identifier** under System Settings > Menu Bar > "Allow in the Menu Bar".

That indirection is the whole trap: when the per-bundle-ID state goes bad, every
signal inside the app still reports success (`isVisible == true`, valid frame,
non-nil image) while nothing appears. It reads exactly like an OS bug, and it
isn't one.

**We hit this.** Bundle ID `mahasvin.max-app` was listed in that pane and toggled
**ON**, yet never rendered. Toggling it off/on didn't help. `killall
ControlCenter` didn't help. Renaming to `com.mahasvin.max-app` fixed it
instantly. If the icon ever vanishes again, suspect that state first — and don't
rewrite this in AppKit, which fails the same way.

### How to diagnose it

Don't eyeball the menu bar; on a notched Mac you can't tell "suppressed" from
"pushed behind the notch". Measure instead:

- Enumerate menu-bar-level windows with `CGWindowListCopyWindowInfo` and count
  the ones owned by the **Control Center** pid. Each third-party icon adds
  exactly one. Launch and kill the app and diff the list — that's a yes/no with
  no interpretation.
- Then bisect with a throwaway single-file `MenuBarExtra` app, flipping one
  variable per run. When we did this, sandbox, `LSUIElement`, `WindowGroup`, and
  the 26.4 deployment target all came back clean. What pinned it was giving the
  known-good throwaway app the *suspect bundle ID* and watching it go dark,
  while the same app under a fresh ID worked.

Worth knowing so you don't chase them: a full menu bar, the notch, and menu bar
managers (boringNotch, Hidden Bar are both installed on this machine) are the
usual suspects and were **not** involved — the probe icon rendered fine in that
same space.

### `MenuBarExtra` label rules

The `label:` must be a bare `Text`, `Image`, or `Label`. `MenuBarExtra` renders
it into an `NSStatusItem` button, and that path only understands those few view
types — an `HStack` wrapping an icon and text yields an item with **nothing to
draw**. A debugging pass left exactly that in place as a "test", which caused
the symptom it was meant to test for. Use the `systemImage:` shorthand.

### Custom artwork

Menu bar icons are normally **template images**: macOS discards the color and
uses only the alpha channel, drawing the silhouette black on a light menu bar,
white on a dark one, and inverting it while the popover is open.

- Template (default, recommended): asset catalog > Render As > **Template
  Image**, then `MenuBarExtra("Max", image: "MenuBarIcon")`. Because only alpha
  survives, the source art must be a **flat monochrome silhouette** — gradients,
  multiple colors, and fine interior detail all collapse.
- Full color: Render As > **Original Image**. This is allowed, but the icon then
  won't adapt to light/dark, won't invert when open, and can sit oddly against
  macOS 26's translucent/tinted menu bar. Only worth it for a mark that's
  genuinely recognizable in color.

The shipped icon (`Assets.xcassets/MenuBarIcon.imageset`) is a six-petal mark
whose hub is a real negative-space cutout, done with an SVG `<mask>`. That's the
right way to express interior detail here, since template rendering would erase
any color-based separation.

Two things worth knowing about that asset, both verified rather than assumed:

- **`actool` compiles SVG `<mask>` fine.** The cutout survives into `Assets.car`.
  Xcode's SVG support is limited enough that this was worth checking, but it
  works — no need to pre-flatten the mask into an even-odd path.
- `Contents.json` needs both `"preserves-vector-representation": true` and
  `"template-rendering-intent": "template"`. Confirm with a throwaway tool that
  loads the *built* app's asset (`Bundle(path:).image(forResource:)`) and checks
  `isTemplate == true` and that the reps include an `_NSSVGImageRep`. Rendering
  it tinted onto light and dark swatches offline is a much faster way to check
  the artwork than squinting at a 33pt menu bar.

Strip Claude Design's C2PA `<metadata>` block before committing — it was 8.9KB
of base64 on a 1.1KB icon.

SF Symbols are template automatically. Ship vector (PDF/SVG) so it scales, or
@1x/@2x/@3x PNGs. For sizing, measure rather than assume: macOS 26's menu bar is
taller than the classic 24pt one. Measured on this machine, the bar is 33pt tall
and our item's slot is 32×33pt, so a glyph around 18pt sits comfortably inside
it with padding. Re-measure with `CGWindowListCopyWindowInfo` if it looks off.
