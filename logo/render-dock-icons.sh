#!/bin/sh
# Render the native mask once for runtime NSApplication.applicationIconImage.
set -eu
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
icon_tool="$(xcode-select -p)/../Applications/Icon Composer.app/Contents/Executables/ictool"
for mode in Light Dark; do
  rendition=Default
  if [ "$mode" = Dark ]; then rendition=Dark; fi
  directory="$repo_root/max-app/max-app/Assets.xcassets/DockIcon$mode.imageset"
  mkdir -p "$directory"
  "$icon_tool" "$repo_root/max-app/max-app/AppIcon.icon" --export-image \
    --output-file "$directory/icon.png" --platform macOS \
    --rendition "$rendition" --width 1024 --height 1024 --scale 1
  cat > "$directory/Contents.json" <<'JSON'
{
  "images": [{ "filename": "icon.png", "idiom": "universal" }],
  "info": { "author": "xcode", "version": 1 }
}
JSON
done
