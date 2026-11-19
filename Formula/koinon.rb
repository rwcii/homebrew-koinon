class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.13.2"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "b07f99470f107fe382f2d8c1a4cf0ea5e6edf1c0de26571f0dd9a0bf91017fff"
    sha256 cellar: :any_skip_relocation, monterey: "8f2655b8f9dd416c0985e16e1cd3c8b3d5e8323d6404a9d2ce3421b47b7da762"
    sha256 cellar: :any_skip_relocation, arm64_linux: "f967c8e43a4fdb84fc41d017a9cd73b3293f5e1739e92568abfca24285d8cec9"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "34eafafa75eb152b83d17e985e52e8307a3078d5b76283bd5e39ea613721814e"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.2/koinon-darwin-arm64"
      sha256 "dd8240e5a1757878b0ee9739a2ccf55eacb3fd9a71f5fddbc6d765608e087e05"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.2/koinon-darwin-amd64"
      sha256 "23b6e3930f7d0aeed318a0018d72a5a3e4228f32b9b972ea8d83ac91c84e4de7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.2/koinon-linux-arm64"
      sha256 "3d6f2688e9ff05006ab3ef7292d15182fb6dc65de8b7f2045c2d1b887eb1bc87"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.2/koinon-linux-amd64"
      sha256 "62d48c42da7e58633b854d1ac27215372fe59051a7e2f181191a21b3e1f1e28b"
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
