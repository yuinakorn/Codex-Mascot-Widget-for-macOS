#!/bin/bash

APP_NAME="OpenAI Codex Mascot Widget"
APP_BUNDLE="$APP_NAME.app"
INSTALL_DIR="/Applications"
BUNDLE_ID="com.openai.codex.mascot.widget"

echo "🗑️  Uninstalling $APP_NAME..."

# Kill running instances
pkill -f "CodexMascotWidget" 2>/dev/null || true

# Remove app bundle
if [ -d "$INSTALL_DIR/$APP_BUNDLE" ]; then
    rm -rf "$INSTALL_DIR/$APP_BUNDLE"
    echo "✅ Removed $INSTALL_DIR/$APP_BUNDLE"
else
    echo "⚠️  App not found at $INSTALL_DIR/$APP_BUNDLE"
fi

# Clear UserDefaults
defaults delete "$BUNDLE_ID" 2>/dev/null || true

echo ""
echo "======================================================="
echo "✅ $APP_NAME has been uninstalled."
echo "======================================================="
