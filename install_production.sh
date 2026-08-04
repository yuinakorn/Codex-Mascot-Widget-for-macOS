#!/bin/bash
set -e

APP_NAME="OpenAI Codex Mascot Widget"
APP_BUNDLE="$APP_NAME.app"
INSTALL_DIR="/Applications"

echo "🚀 Installing $APP_NAME..."

# Build release binary
swift build -c release

# Create App Bundle
APP_PATH="$INSTALL_DIR/$APP_BUNDLE"

# Remove old installation
if [ -d "$APP_PATH" ]; then
    echo "🗑️  Removing previous installation..."
    rm -rf "$APP_PATH"
fi

mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

cp ".build/release/CodexMascotWidget" "$APP_PATH/Contents/MacOS/CodexMascotWidget"

if [ -f "/tmp/AppIcon.icns" ]; then
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
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

echo ""
echo "======================================================="
echo "✅ $APP_NAME installed successfully!"
echo "📂 Location: $APP_PATH"
echo "🚀 Launch from Applications or run:"
echo "   open \"$APP_PATH\""
echo "======================================================="
