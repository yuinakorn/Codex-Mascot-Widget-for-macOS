cask "codex-mascot-widget" do
  version "1.0.0"
  sha256 "707d37ead0f35f37e7936164f0f553a4e87d42da84e11ff847ce1b1624ff1510"

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
