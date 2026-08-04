cask "codex-mascot-widget" do
  version "1.0.0"
  sha256 "aaf0eea48f535d2acd811f05063ead853381b3eeb79af88048265cf60c0e21e0"

  url "https://github.com/yuinakorn/Codex-Mascot-Widget-for-macOS/releases/download/v#{version}/OpenAICodexMascotWidget.dmg"
  name "OpenAI Codex Mascot Widget"
  desc "OpenAI Codex Mascot Widget for macOS"
  homepage "https://github.com/yuinakorn/Codex-Mascot-Widget-for-macOS"

  app "OpenAI Codex Mascot Widget.app"

  postflight do
    system_command "xattr",
                   args: ["-cr", "#{appdir}/OpenAI Codex Mascot Widget.app"],
                   sudo: false
  end
end
