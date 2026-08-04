cask "codex-mascot-widget" do
  version "1.0.0"
  sha256 "d76cfd23352bc17a0692db74660b28ddeb7351277bae2e76217dfe0f15fd9940"

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
