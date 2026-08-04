#!/bin/bash
set -e

echo "🚀 Building OpenAI Codex Mascot Widget Release..."
swift build -c release

STAGING_DIR="/tmp/codex_dmg_staging_dir"
DMG_FILE="$(pwd)/OpenAICodexMascotWidget.dmg"

rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

# Build App Bundle
APP_PATH="$STAGING_DIR/OpenAI Codex Mascot Widget.app"
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

cp ".build/release/CodexMascotWidget" "$APP_PATH/Contents/MacOS/CodexMascotWidget"

if [ -f "AppIcon.icns" ]; then
    cp "AppIcon.icns" "$APP_PATH/Contents/Resources/AppIcon.icns"
elif [ -f "/tmp/AppIcon.icns" ]; then
    cp "/tmp/AppIcon.icns" "$APP_PATH/Contents/Resources/AppIcon.icns"
fi

cat <<EOF > "$APP_PATH/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>CodexMascotWidget</string>
    <key>CFBundleIdentifier</key>
    <string>com.openai.codex.mascot.widget</string>
    <key>CFBundleName</key>
    <string>OpenAI Codex Mascot Widget</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon.icns</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# Create Applications shortcut inside DMG
ln -s /Applications "$STAGING_DIR/Applications"

# Create DMG Disk Image
rm -f "$DMG_FILE"
hdiutil create -volname "OpenAI Codex Mascot Widget" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_FILE"

rm -rf "$STAGING_DIR"

echo ""
echo "======================================================="
echo "✅ macOS DMG Installer Created Successfully!"
echo "📦 File: $DMG_FILE"
echo "======================================================="
