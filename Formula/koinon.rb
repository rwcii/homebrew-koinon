class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.12.0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "fcc9ff178f6366f98eb18f25ecf9ff3928c513b6dd3ac44db36d7292d358513f"
    sha256 cellar: :any_skip_relocation, monterey: "13bb43521d68e01b233091e626cd4c076d8f318e92f770c4dcfc46b4401d04bd"
    sha256 cellar: :any_skip_relocation, arm64_linux: "4f7c70492ce984adf64f1afea624cd681deadb17da39651a801a0b682ed5cc17"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "eaf9646f1bd45e1c6684dfb6f33badd72e31b23ccb0e28cc53185365554134f8"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.12.0/koinon-darwin-arm64"
      sha256 "d6d0a69f0447088720ef69f0ce2303a2b6e6e83c5021292bd46a90f684decfb2"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.12.0/koinon-darwin-amd64"
      sha256 "08bd2abc1a775a1b86044dc2abcfceb7dd681372b87dc889608184e8edf83194"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.12.0/koinon-linux-arm64"
      sha256 "9d929c93d30f48a09ef41acc8663dcddb2d0c9d34d1ee308752602882ba1b439"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.12.0/koinon-linux-amd64"
      sha256 "463fa3622f7055cfe78be31cd8175466755c5dfadcb610d55c34b3277742cd38"
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
