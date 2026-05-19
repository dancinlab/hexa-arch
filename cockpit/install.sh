#!/usr/bin/env bash
# install.sh — build the Demiurge cockpit and install it as
# /Applications/demiurge.app (the `hx install demiurge` → `demiurge
# install` path; see ../bin/demiurge).
#
# Steps: release build → procedural app icon (.icns) → assemble the
# .app bundle (Info.plist bakes DEMIURGE_REPO via LSEnvironment so the
# installed app still finds ../exports/**) → copy to /Applications.
#
# @D g_swift_native: SwiftPM + Apple tooling (sips / iconutil) only.
set -euo pipefail

COCKPIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$COCKPIT_DIR/.." && pwd)"
APP="/Applications/demiurge.app"
cd "$COCKPIT_DIR"

echo "[demiurge install] (1/4) release build…"
swift build -c release --product CockpitApp
BIN=".build/release/CockpitApp"
[ -x "$BIN" ] || { echo "[demiurge install] ERROR: build produced no binary"; exit 1; }

echo "[demiurge install] (2/4) app icon…"
mkdir -p AppIcon
swift AppIcon/generate-icon.swift AppIcon/icon-1024.png
ICONSET="$(mktemp -d)/AppIcon.iconset"
mkdir -p "$ICONSET"
for s in 16 32 128 256 512; do
  d=$(( s * 2 ))
  sips -z "$s" "$s" AppIcon/icon-1024.png --out "$ICONSET/icon_${s}x${s}.png"     >/dev/null
  sips -z "$d" "$d" AppIcon/icon-1024.png --out "$ICONSET/icon_${s}x${s}@2x.png"  >/dev/null
done
iconutil -c icns "$ICONSET" -o AppIcon/AppIcon.icns
rm -rf "$(dirname "$ICONSET")"

echo "[demiurge install] (3/4) assemble .app bundle…"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN"               "$APP/Contents/MacOS/demiurge"
cp AppIcon/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>               <string>Demiurge</string>
  <key>CFBundleDisplayName</key>        <string>Demiurge</string>
  <key>CFBundleExecutable</key>         <string>demiurge</string>
  <key>CFBundleIdentifier</key>         <string>lab.dancin.demiurge</string>
  <key>CFBundleIconFile</key>           <string>AppIcon</string>
  <key>CFBundlePackageType</key>        <string>APPL</string>
  <key>CFBundleShortVersionString</key> <string>0.0.2</string>
  <key>CFBundleVersion</key>            <string>0.0.2</string>
  <key>LSMinimumSystemVersion</key>     <string>13.0</string>
  <key>NSHighResolutionCapable</key>    <true/>
  <key>LSEnvironment</key>
  <dict>
    <key>DEMIURGE_REPO</key><string>${REPO_DIR}</string>
  </dict>
</dict>
</plist>
PLIST

echo "[demiurge install] (4/4) installed → $APP"
echo "[demiurge install]   DEMIURGE_REPO baked = $REPO_DIR"
echo "[demiurge install]   launch: open $APP   (or: demiurge run)"
