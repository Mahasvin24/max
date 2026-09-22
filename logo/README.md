# Max Logo Lab

This folder contains a dependency-free, browser-based construction tool for a
six-blade curved pinwheel mark based on the bottom-left reference.

`max-logo-candidate.svg` is a standalone snapshot of the lab's default study. It
is convenient for quick viewing, but the lab remains the editable source of
truth until the geometry is approved.

Open `index.html` directly, or serve the repository root and visit `/logo/`:

```sh
python3 -m http.server 8000
```

## Construction

The mark is not traced as a fixed silhouette. One exact circular-arc centerline
is drawn with a round stroke and copied six times around the center. The
SwiftUI exporter uses the standard non-inflecting cubic approximation of that
same arc. Its three main controls are independent by construction:

- **Curvature** is the arc's total turn angle. It changes the bend while keeping
  the centerline length and inner endpoint fixed.
- **Line length** is the centerline arc length. It does not change the turn angle
  or the inner endpoint's distance from the logo center.
- **Distance from center** is the radial distance from the logo center to the
  blade's inner centerline endpoint. It moves that anchor without changing the
  blade's length or bend.
- **Inner taper** narrows only the center-facing tip, then eases back to the full
  stroke thickness over the first portion of the blade. At zero, the original
  constant-width round stroke is preserved exactly.

At zero curvature, each blade's tangent is aligned with its radial anchor, so
the six straight blades point directly away from the center. Increasing
curvature transitions them into the pinwheel stance.

The SVG stores that centerline once and renders six references to it at exact
60° increments around `(50, 50)`. Changing one blade necessarily changes all
six, and rotating the complete mark by 60° maps every blade exactly onto the
next one.

- **Thickness** changes the round stroke width.
- **Blades** and **rotation** make it possible to test other symmetries without
  rebuilding the artwork.

The default is a close geometric study of the reference rather than a pixel
trace. The source JPEG should stay inspiration only; the generated mark is clean
vector geometry.

## Workflow

1. Tune the geometry while checking both the large preview and the actual-size
   16–128 px proof.
2. Compare light and dark treatments. The four color fields are deliberately
   editable because no final theme decision has been made yet.
3. Use **Copy settings** to save or discuss a candidate. The browser also stores
   the latest state locally.
4. Export a black transparent SVG for an Xcode template image, or a light/dark
   tile for an app icon study.
5. Export `MaxLogoMark.swift` when the geometry is approved. It uses the exact
   same Bézier points in a SwiftUI `Canvas`, remains sharp at every size, and can
   be rotated, scaled, trimmed, or animated without raster assets.

PNG output is rendered from the SVG at 16–1024 px. SVG should remain the master;
PNG is only for destinations that require raster images.

## Animation model

Every blade is its own SVG path (`.logo-blade`) inside a shared rotor group
(`.logo-rotor`). The motion studies demonstrate both whole-mark rotation and
per-blade sequencing. The exported SwiftUI view likewise draws blades in a loop,
which leaves a clear path to per-blade opacity, scale, phase, or rotation
animation later.
