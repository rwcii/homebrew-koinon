class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.10.2"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "ec611ee9e8fe1aefe8776325336e48ee4d932280bff0f2cba5e5da781ae546b8"
    sha256 cellar: :any_skip_relocation, monterey: "3c28726cd1e51f0db0f189083716bdf664153c1acae5e07114a3501197486daa"
    sha256 cellar: :any_skip_relocation, arm64_linux: "39c376707abbaa339011dab118d92a40d5a78d30d7b96ed5350054eb5f3946c4"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8f5cea6fcdeacb7ad6c855c723d9eec70a11fc28bbd8923e86b984070601e0d8"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.10.2/koinon-darwin-arm64"
      sha256 "95eb1c196f9c004465f3e738c7cbd3e2077d671dd60b2e88855676cbf8bc250c"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.10.2/koinon-darwin-amd64"
      sha256 "4303cfdec2b5dd775f2b54f3f9a9cf15c4e52b936a0ea39ed276512c6caafd6b"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.10.2/koinon-linux-arm64"
      sha256 "a8677e4cfb4033d64697cf978f4863de84469ce0415789635e1aa045b6625fac"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.10.2/koinon-linux-amd64"
      sha256 "9d53b7b60dd0d2f9e9065e912ec1c2ad8eb8c15a179848bd16aaba01bd8accc5"
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
