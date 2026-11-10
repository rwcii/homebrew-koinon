class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.10.1"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "444ff31a7558993b7fcade30fe60e9537bf9c35a327c47dbf36cdfe701b7038b"
    sha256 cellar: :any_skip_relocation, monterey: "fafab5e4460d7816c9057ba6c74ab718701496b9c49b4cdb9000c8a155e246b3"
    sha256 cellar: :any_skip_relocation, arm64_linux: "840628ae51178993277b3e8cbd36d397c466e162f0e74882005118c8dff2090f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "126527ac54cf3480f2c8d847448ed0c42e736a26bc495c1c0fcebc58bd0703d1"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.10.1/koinon-darwin-arm64"
      sha256 "67135200963259715392912bd663fd2dfe776be8d8c922e95d4793385da919a5"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.10.1/koinon-darwin-amd64"
      sha256 "f1ff4e1b6375d06f27cec06190924f2bdf0479564dcfa484a64cb3008434fc0c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.10.1/koinon-linux-arm64"
      sha256 "f22ba821a62e46b6d76b4f8dcf0a77e6f0f44984fdbc16511516cba630e61788"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.10.1/koinon-linux-amd64"
      sha256 "fb72628ec5b8599a2c81f11c779f1c55fe3fbe910ff644baaeb05f1d072e1158"
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
