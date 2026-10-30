class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.8.0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "5f6c034cfb5d4c3ea717500fbc7051df5d637a19acecf272747c81b234b4d5a6"
    sha256 cellar: :any_skip_relocation, monterey: "7a50baa926fcdbb499e4e221eab21d3e8367b3b20e3bb5f3dd71ab289fd12f54"
    sha256 cellar: :any_skip_relocation, arm64_linux: "af14e10c599f28031e561a18278236624a3a9aa02ab2c99f995085e1405c6b60"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "bfb976f1cb2b01191adf0d0caa2e01d5a46c6735462329892af64449dd8538b4"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.8.0/koinon-darwin-arm64"
      sha256 "47a5301d3a0fbb8508166b89f5e105b5ac2e4827eaa7f5bbb805cd695662afe3"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.8.0/koinon-darwin-amd64"
      sha256 "79d7e58fd0699773dd05d548a5bf058e65f414fb06ff971a65b3593d8265d3a8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.8.0/koinon-linux-arm64"
      sha256 "74c5897782a6fcd90a01505102866365b6c430eac94c6f9a8d20c33484cd8611"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.8.0/koinon-linux-amd64"
      sha256 "fd7f413982c2f554cbd90600cd60c15f990fb66fe29091c478fee3dd704c14ed"
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
