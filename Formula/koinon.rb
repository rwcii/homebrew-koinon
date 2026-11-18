class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.13.0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "f84aa9c1871c8d3cae4efb349695847ec2e7b71448ba2657caf3e2bd06a85551"
    sha256 cellar: :any_skip_relocation, monterey: "3a5ce1a5444d617e11b73615d26843040f4de908b94f2da1c1dfc4520d449e79"
    sha256 cellar: :any_skip_relocation, arm64_linux: "6f207c71fe8a16380db32dc16b768c5f5398949154fbcfe82279ed8e30a63058"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a9079a935e12b1d5ed4aed2fb6544ddcc78094cabd9e35b632589527ae5983b3"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.0/koinon-darwin-arm64"
      sha256 "9b9c44d234fa8b553f6ccd7307a0c12b3b4dc99215b3730002194477238dbf09"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.0/koinon-darwin-amd64"
      sha256 "69e125d126f42176d60d1804c0ea223ea858d32d2eebc046d4ceda065e193abf"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.0/koinon-linux-arm64"
      sha256 "888aa8eb5fa7c828c4574679cb8ecc1b00506dc29ef6a7284a2ed365494aba21"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.0/koinon-linux-amd64"
      sha256 "3bc06d3d4af2308ff475f86b9545ed5807eeb52935894585b62f512d8cb7c5ea"
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
