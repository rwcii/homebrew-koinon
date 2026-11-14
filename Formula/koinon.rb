class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.11.0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "9a0a88d04c41ec97dffc09d6eae910edd53529aba5e1269d1ecbb37c81a9e67d"
    sha256 cellar: :any_skip_relocation, monterey: "6364b3e668e593f4f74a6a09173a81e51efa0a39f4af080de2ecdccbc1c3f374"
    sha256 cellar: :any_skip_relocation, arm64_linux: "173a0ae445fa1125f7056cd9eed3369a88825ad434d4030a447caa4ee64e8772"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d53ddb1a149bd0a5a1d92a0a753656e169fe009c993920fd3ed21d398e7a2116"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.11.0/koinon-darwin-arm64"
      sha256 "20aca6f2137f861198e6d74b3ee7f00773215d4d394328fadd599b2b37614838"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.11.0/koinon-darwin-amd64"
      sha256 "b8cfbb07901a7c1762bae0e71bef8f63f8169e0aab35c5c46fc3098cebb34954"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.11.0/koinon-linux-arm64"
      sha256 "39c2cd07f4fe80b04ae909b9289817f21e25ec1d5c64b8d2416ddd20db8b1a32"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.11.0/koinon-linux-amd64"
      sha256 "2dfea02447e02f7c6387f126abc7a156e060196ff4bdf9494812a4b6432e02f0"
    end
  end

  def install
    bin.install Dir["koinon-*"].first => "koinon"
  end

  # The caveats say first what the person must do, in the action line, then each command on
  # its own line: the expanded opt_bin path would break a wrapped sentence (PDR 003, Decision 6).
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
    action = "ACTION REQUIRED: to finish the Koinon installation, run these commands, in order:\n"
    about = "koinon install starts the daemon; at a terminal it offers to set up each agent it finds.\n"
    current = "The Koinon installation is current."
    done = plan&.strip == current
    text = if done
      "#{current} No action is required.\n"
    elsif plan
      steps = action + plan.lines.map { |line| "  #{line}" }.join
      steps += about if plan.lines.any? { |line| line.split[1] == "install" }
      steps
    else
      fixed = action + <<~EOS.gsub(/^/, "  ")
        #{opt_bin}/koinon install
        #{opt_bin}/koinon maintainer secret set
      EOS
      fixed += about + <<~EOS
        To set up an agent family later, run its command:
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
        Then make sure that no step is left:
          #{opt_bin}/koinon install --plan
      EOS
    end
    text + <<~EOS

      To upgrade Koinon later:
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
