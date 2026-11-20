class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.13.3"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "de89d506d120deb853d196043d2d38d2269950974eeead2dbc3408d1f5e72d28"
    sha256 cellar: :any_skip_relocation, monterey: "7917b65be859860c0759179b145d31e71e71630c87460ba57236208fde921176"
    sha256 cellar: :any_skip_relocation, arm64_linux: "8b0f6e7ab9dcfda8d01e7d361d33fecc1685a1c9c29735915a664345fecf8185"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "964882167f97e81932ac793c29da5e3bf871eda0410139e036047d5105b08e8e"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.3/koinon-darwin-arm64"
      sha256 "c6909ae8ce5e62319882a88e28e9fb464aaaacf51648256f98418ea42c8787cb"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.3/koinon-darwin-amd64"
      sha256 "37c6c9e05e557d076f073ec5bb558ca3c1b4fbe80e4d679b5ac8deb2a4962dd4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.3/koinon-linux-arm64"
      sha256 "3023cb55ebabc7bf26b787bf860378b385123fb9e2dacb76ad0e96bc534009e4"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.13.3/koinon-linux-amd64"
      sha256 "cbf1176094132cfba27b2bbe0c4bcffb576e0bf6ffedffa79e058043d3f3f7f5"
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
