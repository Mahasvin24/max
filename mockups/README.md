# Max — logo explorations

[Open the visual gallery](index.html).

The initial five studies cover two rotational marks, two blob avatars, and one wildcard. A sixth direction, Vortex, follows the user's bottom-left reference more closely. The visual direction follows the app's charcoal surfaces, off-white controls, and soft rounded shapes. Max's purpose—helping you achieve goals and accompanying your growth—informs the themes of blooming, steady momentum, companionship, and a path toward a goal.

| Concept | Direction | Meaning and proposed motion |
| --- | --- | --- |
| [Vortex](07-vortex.png) | Rotational · 6-fold | Six slender curved arms sweep around an open center, inspired by the bottom-left supplied reference. Spin while thinking, then draw the arms inward to form a dot. |
| [Orbit Bloom](01-orbit-bloom.png) | Rotational · 5-fold | A small bloom suggests growth; five petals give the mark a gentle rotating rhythm. Pull the petals inward to close into a dot. |
| [Soft Pulse](02-soft-pulse.png) | Rotational · 4-fold | A soft four-lobed pulse suggests steady momentum. Rotate while thinking, then round the valleys and shrink into a dot. |
| [Pebble](03-pebble.png) | Blob avatar · calm | A calm companion with an attentive face. Let it breathe and blink while waiting, then fade its face and round it into a dot. |
| [Mochi](04-mochi.png) | Blob avatar · playful | A playful little companion with an M-shaped body. Rock and blink while thinking, then tuck in its feet and compress into a dot. |
| [Waypoint](05-waypoint.png) | Wildcard · growth & goals | A rising path cups a small goal dot: progress with support. Draw the path forward while thinking, then retract it into the dot. |

## Choosing a direction

**Orbit Bloom** is the first direction to try for a rotating loading indicator. **Pebble** is the first to try for a more personal companion identity. **Soft Pulse** has the simplest proposed transition to a dot because it starts as one connected solid shape. **Waypoint** ties most directly to supported progress toward a goal.

## From image to animation

These PNGs show the resting concepts; they are not animated files or production vector masters. The generated files have alpha transparency and are best viewed against the app's dark background, as in the gallery.

For exact rotational symmetry, construct one petal, lobe, or arm and repeat it at equal angles in SVG or SwiftUI: 60 degrees for Vortex, 72 degrees for Orbit Bloom, 90 degrees for Soft Pulse. Raster generation gives a visual study, not a guarantee of mathematically identical segments. Morph the geometry into a circle before reducing its size, so the collapsed state remains a clean dot.

For the avatars, fade facial features before rounding the silhouette. For Waypoint, retract the path into the goal dot. With Reduce Motion enabled, use a short opacity transition to the final dot instead of spinning or morphing.

## Bonus alternate

[06-murmur-alternate.png](06-murmur-alternate.png) preserves an additional conversational M monogram explored before the growth-and-goals context arrived. Its rounded line could draw on while thinking and retract toward a round cap.

All images were created using the built-in image generation tool. The complete prompt set is in [PROMPTS.md](PROMPTS.md).
