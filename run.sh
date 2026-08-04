#!/bin/bash
echo "🚀 Building OpenAI Codex Mascot Widget..."
swift build
if [ $? -eq 0 ]; then
    echo "✨ Build Successful! Launching OpenAI Codex Mascot Widget..."
    ./.build/debug/CodexMascotWidget
else
    echo "❌ Build Failed."
fi
