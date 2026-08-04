cask "codex-mascot-widget" do
  version "1.0.0"
  sha256 "669d70dec7fff3c194d4711ce9137245fe9513261a3271871c038106df31a026"

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
