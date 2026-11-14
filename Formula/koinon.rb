class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.11.2"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "c99d519287bf94b7fa5e15aff1b89d59ff2b6126c5dc75bb110ae26c1a9ce023"
    sha256 cellar: :any_skip_relocation, monterey: "58393b7982a28317a03d7eb6d9de6fde40bb3c92f8e81a848bf9e470e18bb57b"
    sha256 cellar: :any_skip_relocation, arm64_linux: "87f04a9b745fa13bbc07b719b594cdaef724dbef60d6dea447da4ee077495ff9"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "6f39ab48039fb71bf441ab0d5a6b30b7035135203692bcf9aeb4c39afdaa1946"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.11.2/koinon-darwin-arm64"
      sha256 "20831599addbcb7214a2cc9241fda92880ff2f620425d69398d9fbed20009111"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.11.2/koinon-darwin-amd64"
      sha256 "28d28023a47731df702bdce94f7382067efa0c40fd02700530025639c4c8cc61"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.11.2/koinon-linux-arm64"
      sha256 "b92e9300e5aa6e688fd8118aca76097259f9f0716e46eaa093a0c549e35f69b5"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.11.2/koinon-linux-amd64"
      sha256 "7790df9d6fc5c6e3e909f9fae58eed94f54e3472aca6516bad3e07f8d3e0a1bb"
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
