class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.10.3"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "944b3ddb0ba4e9e2b5bdad0409dcb1dc160992e12f4ef1fbbc23c70e09ae51d2"
    sha256 cellar: :any_skip_relocation, monterey: "5868074788e2e591c6fb77481e9d473e516eeeb40d2250f81cbfaca830def07a"
    sha256 cellar: :any_skip_relocation, arm64_linux: "cf3eb6f9fd97c9f76210a4205364b8f35e62a00a7d63b4baaf33b209633d9f28"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "cc445bbed1a3ebd3dae804af5e5e047d1e4141a9beaddb614379c574d064b310"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.10.3/koinon-darwin-arm64"
      sha256 "5fe6537d2ff9683c66e3b9554a018a2b1133c207014b8923caa1d91071a034e3"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.10.3/koinon-darwin-amd64"
      sha256 "a723d30b6150f71eee7f29dc6b266842b65cd9f930a4dc19d0f6c2717e432c60"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.10.3/koinon-linux-arm64"
      sha256 "843c118b2790a3fe83b0301187f8c77a15543383fe6597228b49ae23e810abf7"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.10.3/koinon-linux-amd64"
      sha256 "76e01b2d4027fbbeae4fd4586719a9c9d29fe561558727d2e8384f3fd0a48007"
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
