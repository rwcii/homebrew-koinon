class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.7.0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "bc175cfcb541fac8ec86b9dfdb775d8da524ff4e8541eb9289bff0539bf8af23"
    sha256 cellar: :any_skip_relocation, monterey: "3c3acd3337e9127313ba98f8ead183b9763465eea637187433f5ee8d6e6344dc"
    sha256 cellar: :any_skip_relocation, arm64_linux: "5200e9f22193fd87bd9eb95d300bf8246143796def2486dc64a7b3cd87f8837d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c37a0b474220573b7fc5524325b5647b39f5aafd6d84edf15fdc0d082f1ccc3c"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.7.0/koinon-darwin-arm64"
      sha256 "625c93317ebcaca47ff451607fba0b6272b5918255bb64ff83b1791984bc8502"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.7.0/koinon-darwin-amd64"
      sha256 "0b6dfe2c820c58e7a3e3f9b7553f74bbdce517c8311cd81f6f35991552408aa2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.7.0/koinon-linux-arm64"
      sha256 "fee4fba7049020c897bb1c8f40c425ea8c9fff2d07e32bb2ad0443d3cc1a6e75"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.7.0/koinon-linux-amd64"
      sha256 "3dcdfb13367da47c792922f33536cf79c095834dcdc508cfd7675cd35b31da75"
    end
  end

  def install
    bin.install Dir["koinon-*"].first => "koinon"
  end

  # Each command has its own line: the expanded opt_bin path would break a wrapped sentence.
  # koinon install --plan reads this machine and prints only the steps that it still needs;
  # it changes nothing (#551). Homebrew keeps the person's PATH, where the agents' CLIs are,
  # in HOMEBREW_PATH. When the plan cannot run or check everything, the fixed steps show.
  def caveats
    plan = begin
      require "open3"
      out, _err, status = Open3.capture3({ "PATH" => ENV.fetch("HOMEBREW_PATH", ENV.fetch("PATH", "")) },
                                         "#{opt_bin}/koinon", "install", "--plan")
      out if status.success? && !out.strip.empty?
    rescue StandardError
      nil
    end
    text = if plan
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
    text + <<~EOS
      Check again after these steps:
        #{opt_bin}/koinon install --plan

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
