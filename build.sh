#!/bin/bash
set -e; cd "$(dirname "$0")"
swift build -c release
A=~/Applications/Pulse.app
rm -rf "$A"; mkdir -p "$A/Contents/MacOS"
cp .build/release/Pulse "$A/Contents/MacOS/Pulse"
cat > "$A/Contents/Info.plist" <<P
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Pulse</string><key>CFBundleDisplayName</key><string>Pulse</string>
<key>CFBundleIdentifier</key><string>com.tara.pulse</string><key>CFBundleExecutable</key><string>Pulse</string>
<key>CFBundlePackageType</key><string>APPL</string><key>CFBundleShortVersionString</key><string>1.0</string><key>CFBundleVersion</key><string>1</string>
<key>LSMinimumSystemVersion</key><string>14.0</string><key>LSUIElement</key><true/><key>NSHighResolutionCapable</key><true/>
</dict></plist>
P
codesign --force -s - "$A"
echo built
