# Max vortex

The fixed vortex replaces the earlier dial-based logo lab. Its silhouette follows
[`mockups/07-vortex.png`](../mockups/07-vortex.png), the approved rounded six-arm
concept. Open [`index.html`](index.html) directly for the large preview, rotation,
collapse-to-dot motion, and actual-size samples on light and dark backgrounds.

## Assets

- [`max-vortex.svg`](max-vortex.svg): transparent, scalable master. Uses
  `currentColor` (black by default); inline it to inherit a surrounding text color.
- [`vortex.js`](vortex.js): the single source of geometry for both exports and the
  browser preview. No libraries or network requests are needed.

```swift
MaxVortex()
    .fill(.primary)
    .frame(width: 20, height: 20)

MaxVortex(collapse: isCollapsed ? 1 : 0)
    .fill(.primary)
    .frame(width: 64, height: 64)
    .animation(.easeInOut(duration: 0.65), value: isCollapsed)
```

Apply `.rotationEffect(...)` to rotate the entire mark. Callers should respect
Reduce Motion, as the browser preview does.

## Geometry and sizing

The image's six slightly different arms were aligned around their shared center,
averaged, and fitted with a smooth closed outline of 14 cubic Bézier segments.
That single tapered arm is repeated at exact 60-degree increments. The final mark
preserves the approved image's rounded ends, open center, curvature, and direction
while making rotational symmetry exact.

The viewBox is `-50 -50 100 100`; the center is `(0, 0)`. The drawn silhouette spans
approximately 95.23% of the square's width and 90.68% of its height. Its maximum
radius is 48 units, so it stays inside the square throughout a full rotation,
with 2 units of radial breathing room. There is no padded raster canvas or
size-dependent stroke width. At 16 px, the silhouette occupies approximately
15.24 × 14.51 px.

The collapse parameter interpolates the arm's control points toward a centered
circle, bringing all six arms together. At `collapse = 1`, the dot is 8% of the
bounding square's side. The SwiftUI shape remains centered in non-square frames.

## Rebuilding

After editing `vortex.js`, regenerate the checked-in SVG and the app's SwiftUI
source:

```sh
node logo/build.cjs
```

Check that exports match their source without rewriting them:

```sh
node logo/build.cjs --check
```

The standalone SVG, app SwiftUI source, menu-bar asset, and browser preview all use
the same geometry. The app's `LogoMark` wrapper draws `MaxVortex` directly;
`MenuBarExtra` uses the generated 18 pt template SVG.

The native app icon lives in `max-app/max-app/AppIcon.icon`. Its SVG is generated
by `build.cjs`; `icon.json` defines a white background with a black vortex for
Default appearance and a charcoal (#181818) background with an off-white (#E9E9E9) vortex for Dark.
The vortex layer uses a 0.76 scale. Let macOS apply the outer icon mask:
do not bake rounded corners or transparent outer padding into the artwork.
That double treatment caused a small inset tile with a thick surrounding frame.

The SwiftUI renderer creates full-bleed opaque PNG fallbacks in
`AppIcon.appiconset` and matching light/dark `Logo.imageset` images using the
same vortex scale. The standalone mark keeps its tighter 91–95% bounds.
The original reference JPEG remains in this folder for provenance; it is not
loaded by the preview or included in the exported logo.

## Verification

The SwiftUI source was compiled and rendered offscreen beside the approved image.
The outline was checked at 16–1024 px for centering, filling at least 90% of each
dimension, and staying inside its frame. A non-square frame and 101 collapse
states were checked as well. Exact Bézier extrema confirm the 48-unit maximum
radius, so continuous rotation cannot clip the mark.

### Running Dock icon appearance

macOS can keep the Default app icon even when system Dark mode is enabled,
because icon style is a separate preference. `AppIconDelegate` observes the
application's effective appearance and sets its Dock icon at launch and on
changes. `DockIconLight` and `DockIconDark` are native masked exports from
`AppIcon.icon`, regenerated with:

```sh
sh logo/render-dock-icons.sh
```

These runtime images include the native outer mask because AppKit displays them
directly. Keep the source icon background full-bleed. Finder and the icon shown
while the app is not running still follow macOS's icon-style preference.
