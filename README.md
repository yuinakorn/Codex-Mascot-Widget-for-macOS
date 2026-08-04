# 🤖 OpenAI Codex Mascot Widget for macOS

> **Live Rate Limit Monitor & Pixel Desktop Companion for ChatGPT Codex & OpenAI API**

![macOS](https://img.shields.io/badge/platform-macOS%2013.0%2B-blue.svg)
![Swift](https://img.shields.io/badge/swift-5.9-orange.svg)
![AppKit](https://img.shields.io/badge/framework-SwiftUI%20%7C%20AppKit-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**OpenAI Codex Mascot Widget** is a lightweight native macOS application designed for real-time rate limit monitoring of **ChatGPT Codex (OpenAI)**. It features an animated pixel robot mascot styled in a **Periwinkle Blue / Cloud Terminal (`#426EEB`)** theme that lives on your Desktop and Menu Bar.

---

## 🌟 Key Features

- 🤖 **16x16 Blue Cloud Pixel Mascot**: Features the custom Blue Cloud Robot pixel mascot with dynamic walking, blinking, sweating, exhausted, and sleeping animations.
- 🖥️ **Draggable Desktop Companion**: Floating transparent desktop window that can be freely dragged anywhere across your displays.
- 📌 **Native Menu Bar Integration**: Displays live usage percentage and status right on your macOS Menu Bar (powered by rock-solid Native `NSPopover` with zero flicker).
- ⚡ **Live Probe & ChatGPT Auth Integration**: Automatically detects `~/.codex/auth.json` (ChatGPT Plus OAuth tokens) or custom OpenAI API Keys to query live usage (`wham/usage` API).
- 🔝 **Always On Top Control**: Easily toggle whether the floating mascot stays on top of all application windows or rests on the normal desktop layer.
- 🔄 **Reset Credit Tracker**: Real-time tracking of available quota Reset Credits (`Available Reset Credits`) and exact formatted reset times (e.g. `Sun 2:27 AM`).
- 🛡️ **Single Instance Protection**: Built-in process guard prevents duplicate menu bar icons or instance collisions when launching from Finder.
- 🚀 **macOS DMG Installer & Auto-Start**: Includes scripts for `.dmg` installer packaging and LaunchAgent auto-start setup.

---

## 🎭 Mascot Emotions & States

The mascot dynamically changes its color palette, facial expression, and animation based on your **Weekly Rate Limit Usage Percentage**:

| 🟢 Happy (0% - 49%) | 🟦 Neutral (50% - 79%) | 🟠 Sweating (80% - 94%) | 🔴 Exhausted (95%+) | 💤 Sleeping (Offline) |
| :---: | :---: | :---: | :---: | :---: |
| ![Happy](imgs/mascot_happy.png) | ![Neutral](imgs/mascot_neutral.png) | ![Sweating](imgs/mascot_sweating.png) | ![Exhausted](imgs/mascot_exhausted.png) | ![Sleeping](imgs/mascot_sleeping.png) |

### Emotion Breakdown:

1. 🟢 **Happy State (0% - 49% Usage):**
   - **Body Theme:** Periwinkle Purple-Blue (`#7063D9`)
   - **Animation:** Cheerful walking animation, soft leg stepping, periodic eye blinking every 3.5s, and a gentle ambient glow aura.
2. 🟦 **Neutral State (50% - 79% Usage):**
   - **Body Theme:** Deep Indigo Blue (`#4255F5`)
   - **Animation:** Active walking frame shift with attentive cyan screen text `> _` and an indigo ambient glow.
3. 🟠 **Sweating State (80% - 94% Usage):**
   - **Body Theme:** Amber Warning (`#F59E06`)
   - **Animation:** Animated **cyan pixel sweat drop 💦** bouncing next to head, amber screen highlights, and high-usage warning glow.
4. 🔴 **Exhausted State (95%+ Usage):**
   - **Body Theme:** Crimson Red (`#F04545`)
   - **Animation:** Flashing **red exclamation mark `!`** bouncing over the mascot's head with red alert glow.
5. 💤 **Sleeping State (Offline / Token Expired):**
   - **Body Theme:** Dim Lavender Grey (`#807A9E`)
   - **Animation:** Mascot screen switches to closed eyes `v v` while animated **`Z` `z` `z...` 😴** text floats gently upward.

---

## 🔑 Prerequisites & Authentication

Before running the widget, make sure your machine can authenticate:

### Method 1: Using Codex CLI / ChatGPT OAuth (Recommended)
If you log in via **Codex CLI**, the widget will automatically discover your session credentials:
1. Log in via Codex CLI:
   ```bash
   codex login
   ```
2. The widget will automatically read `~/.codex/auth.json` to monitor your **ChatGPT Plus / Pro** limits.

### Method 2: Custom OpenAI API Key
If you don't use Codex CLI, open Widget Settings ⚙️ and enter your **OpenAI API Key** (`sk-...`).

---

## 🛠️ Build & Running

### Run Locally (Development)
```bash
./run.sh
```

### Build Production App Bundle & DMG
```bash
# Build release app and create installer DMG
./build_dmg.sh
```

### Install as Production LaunchAgent (Auto-Start on Boot)
```bash
chmod +x install_production.sh
./install_production.sh
```

---

## 🛑 Uninstallation

To cleanly stop the background service and remove the LaunchAgent registration:
```bash
./uninstall_production.sh
```

---

## ⚙️ Widget Popover Controls

Clicking the Menu Bar icon or Desktop Mascot opens the control card:
- **Quota Active & User Email:** Displays subscription tier (`ChatGPT Plus`), user email, and available **Reset Credits**.
- **Weekly limit (7-day window) Bar:** Displays live usage % and formatted reset timestamp (e.g. `Resets Sun 2:27 AM`).
- **Toggle Mascot Button:** Shows or hides the floating desktop mascot window.
- ⚙️ **Settings Panel:**
  - **Always On Top:** Toggle mascot floating window layer (Floating Top vs Normal Desktop).
  - **OpenAI API Key:** Optional custom API key input.
  - **Probe Model:** Select model used for API probes.
  - **Refresh Frequency:** Adjust probe frequency (`30 sec`, `60 sec`, `3 min`, `5 min`, `15 min`).

---

## 💻 Tech Stack

- **Language:** Swift 5.9
- **Frameworks:** SwiftUI, AppKit (`NSStatusItem`, `NSPopover`, `NSWindow`, `NSHostingView`)
- **Graphics Engine:** Pure Swift 16x16 Canvas Vector Pixel Renderer
- **Networking:** Native URLSession (ChatGPT `wham/usage` API & OpenAI Chat Completions)
- **Deployment:** macOS LaunchAgent (`launchd`), `.dmg` Disk Image (`hdiutil`)

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
# Codex-Mascot-Widget-for-macOS
