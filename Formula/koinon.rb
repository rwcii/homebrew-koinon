class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.13.1"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "f53ec46a3bcfa293bac549b08f0c2b4066dc66e6ce840f3b359e27e458dee9a9"
    sha256 cellar: :any_skip_relocation, monterey: "d14419a7b9222a9ad530bfb5f1d5e501e0b258666a825a9af21188092c9261f0"
    sha256 cellar: :any_skip_relocation, arm64_linux: "0f377aaf169cff82595d1bd8d4d72ff2e67c93003e4d4c6199ece57c4139baea"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "532da5564616fcdc041dc84431e121f304c918b5c56f9c34e6e903a9a27eefdc"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.1/koinon-darwin-arm64"
      sha256 "4d0d271554912526dedcc348b0e620537efb7e696041cd98327df3008327e506"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.1/koinon-darwin-amd64"
      sha256 "38df91cdc22d680efebac0351abf3d531f9d75672cfc263b1e96417581d61bda"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.1/koinon-linux-arm64"
      sha256 "d0ad6b06c770e91bbb20fc7383020261ac47460ec4a30001d2a43f53879fd00d"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.1/koinon-linux-amd64"
      sha256 "3e7576f1f324c7397200553ab85c7444d12e19290b1972e58db587797f5486a8"
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
