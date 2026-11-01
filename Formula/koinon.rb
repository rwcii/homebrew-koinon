class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.9.0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "d01d564308cb81b90533063ddb9fa3549e366b102f2b3a48fea3fc66dc5d3c20"
    sha256 cellar: :any_skip_relocation, monterey: "d59b07fa9341aaa9033bccb28f04f35827a9ef19892cf64a577ca23904e6505d"
    sha256 cellar: :any_skip_relocation, arm64_linux: "8cd7ac10d7b84318b6356c3b3dc8b1b1f4d667834899fb6a024f43ff1534c40a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "5493f66a4c5ff5fafb5844d69905f78c0debbd938b725f33d25edfeb09b01c18"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.9.0/koinon-darwin-arm64"
      sha256 "732b96bd0eb15702badce36a536b8ebd52d2afb297e443d41764b74e383c0510"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.9.0/koinon-darwin-amd64"
      sha256 "d1e72f777ee72bd582766c33c05ded1a3c00f6c4879efdf2e364f9a16e3cbaa4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.9.0/koinon-linux-arm64"
      sha256 "106e771bc3090f15c5316d918549df0f46bb284339c966592b55e333b4b3f687"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.9.0/koinon-linux-amd64"
      sha256 "ccf3e8dc80c1c26204410cf5f9b9e33bca153fb786da50a3a0973da9b71d337c"
    end
  end

  def install
    bin.install Dir["koinon-*"].first => "koinon"
  end

  # Each command has its own line: the expanded opt_bin path would break a wrapped sentence.
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
    current = "The Koinon installation is current."
    done = plan&.strip == current
    text = if done
      "#{current}\n"
    elsif plan
      "The steps that this installation needs:\n#{plan.lines.map { |line| "  #{line}" }.join}"
    else
      fixed = <<~EOS
        Install the daemon; at a terminal it offers to set up each agent it finds:
          #{opt_bin}/koinon install
        Set the maintainer secret for the dashboard login:
          #{opt_bin}/koinon maintainer secret set
        Set up an agent family later with its command:
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
        Check again after these steps:
          #{opt_bin}/koinon install --plan
      EOS
    end
    text + <<~EOS

      To upgrade:
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
