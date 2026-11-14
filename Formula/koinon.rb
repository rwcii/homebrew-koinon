class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.11.1"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "3163760d0d1827e347e3809459730909c35ca9b64379f212fd119ac82f0d2bc6"
    sha256 cellar: :any_skip_relocation, monterey: "6cd6e225d357526349eedb3858fbb3480543ee7a632eec999f65496344bc8196"
    sha256 cellar: :any_skip_relocation, arm64_linux: "0d0dcd70d492b1dc699b9e71dcbd101651ed5dde8e6f19680f327be7a8c92534"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "6e286f0cddeca2d07d204241d14fa473cddba3551cd6bda016e9ebb690d3d6e1"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.11.1/koinon-darwin-arm64"
      sha256 "f3b680ec73232120213c0736be153d034031617a9f626b7e42137812c4c1c586"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.11.1/koinon-darwin-amd64"
      sha256 "0d6e7737adf316366cb59423c4fb0c4a73b2782789701cc3cab913d590fca8c7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.11.1/koinon-linux-arm64"
      sha256 "c1776a5d8c9e8a5712dd0a81ec855a90f63d00d06051992c401d63879c451fc1"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.11.1/koinon-linux-amd64"
      sha256 "f9a16b463ae02d2ecfcf79cadca51875194c22cadc2844f4145600e3b4f6919e"
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
