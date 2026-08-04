# 🤖 Task: Build OpenAI Codex Mascot Widget for macOS

Please build a native macOS application named **OpenAI Codex Mascot Widget** inspired by the architecture of `Claude-Mascot-Widget-for-macOS`. 

This application monitors **OpenAI API / Codex / ChatGPT rate limits & billing credit grants** in real-time, featuring a draggable desktop pixel mascot and a rock-solid Menu Bar companion.

---

## 🏗️ Technical Architecture & Requirements

### 1. Technology Stack
- **Language:** Swift 5.9 (Swift Package Manager / AppKit + SwiftUI)
- **Menu Bar Component:** Native `NSStatusItem` + `NSPopover` with `popover.animates = false` (100% ZERO bounce/flicker)
- **Desktop Companion:** Transparent, borderless `NSWindow` with draggable support and `Always On Top` level toggle
- **Single Instance Protection:** Guard in `applicationWillFinishLaunching` using `NSRunningApplication` to prevent duplicate menu bar icons

---

## ⚡ OpenAI API Probing & Billing Integration

### 1. Minimal Rate Limit Probe API Call
`POST https://api.openai.com/v1/chat/completions`
- **Headers:**
  - `Authorization: Bearer <OpenAI API Key / Token>`
  - `Content-Type: application/json`
- **Body:**
  ```json
  {
    "model": "gpt-4o-mini",
    "max_tokens": 1,
    "messages": [{ "role": "user", "content": "hi" }]
  }
