class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.9.2"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "becf9d26fa1654bca180687e6ea80be78b0382003ad793ad80e770b6d23621bc"
    sha256 cellar: :any_skip_relocation, monterey: "7046ae919687b3a67364431842fbd80f2620781aa72d760bff5a6be914ed7775"
    sha256 cellar: :any_skip_relocation, arm64_linux: "1ac0313f3b3f9d9b5a1fdfbf53b9599c6982d664ba5f178f9fa80522989d7e90"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "50ce8e8e0c7b8488e24fcc56621d6fe81320896436a2bb37a3c09a9cb0a51799"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.9.2/koinon-darwin-arm64"
      sha256 "9af861553eb666631218de93d54e3e2ea9da636de3918a240dc0da5b6168c9b3"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.9.2/koinon-darwin-amd64"
      sha256 "1a163ca19576e37f7571e4135191df61f4236f05f7dfd7c54b3dd853e75d36c8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.9.2/koinon-linux-arm64"
      sha256 "bd19c5fb78116afbccd8a3191385a545c075d7ca3c63d69c37650d94c66d1f13"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.9.2/koinon-linux-amd64"
      sha256 "8968271a43c5b847c916a38ced849e9b2e014e0cf38ea883928612eaae172efa"
    end
  end

  def install
    bin.install Dir["koinon-*"].first => "koinon"
  end

  # Each command has its own line: the expanded opt_bin path would break a wrapped sentence.
  # koinon install --plan reads this machine and prints only the steps that it still needs;
  # it changes nothing (#551). Homebrew keeps the person's PATH, where the agents' CLIs are,
  # in HOMEBREW_PATH. When the plan cannot run or check everything, the fixed steps show. A
  # current installation has no steps, so it shows the plan's sentence alone (#561).
  def caveats
    plan = begin
      require "open3"
      out, _err, status = Open3.capture3({ "PATH" => ENV.fetch("HOMEBREW_PATH", ENV.fetch("PATH", "")) },
                                         "#{opt_bin}/koinon", "install", "--plan")
      out if status.success? && !out.strip.empty?
    rescue StandardError
      nil
    end
    current = "The Koinon installation is current."
    done = plan&.strip == current
    text = if done
      "#{current}\n"
    elsif plan
      "The steps that this installation needs:\n#{plan.lines.map { |line| "  #{line}" }.join}"
    else
      fixed = <<~EOS
        Install the daemon; at a terminal it offers to set up each agent it finds:
          #{opt_bin}/koinon install
        Set the maintainer secret for the dashboard login:
          #{opt_bin}/koinon maintainer secret set
        Set up an agent family later with its command:
          #{opt_bin}/koinon install --agent claude
          #{opt_bin}/koinon install --agent codex
          #{opt_bin}/koinon install --agent agy
          #{opt_bin}/koinon install --agent opencode
          #{opt_bin}/koinon install --agent grok
      EOS
      if OS.mac?
        fixed += <<~EOS
          A --system install keeps a copy. Upgrade it after each brew upgrade with:
            #{opt_bin}/koinon install --system
        EOS
      end
      fixed
    end
    unless done
      text += <<~EOS
        Check again after these steps:
          #{opt_bin}/koinon install --plan
      EOS
    end
    text + <<~EOS

      To upgrade:
        brew update
        brew upgrade koinon
        koinon version
      The install links its binary to the formula's opt path, so the daemon restarts
      on the newly linked binary. The restart ends the dashboard login; for a new link:
        koinon dashboard
    EOS
  end

  test do
    assert_match "\"version\": \"v#{version}\"", shell_output("#{bin}/koinon version")
  end
end
