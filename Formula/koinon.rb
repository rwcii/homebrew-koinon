class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.5.0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "303be2c2495b40cfb8473a881c5e46958dd9f65d71aa7c3e0bdfa6ec414282e3"
    sha256 cellar: :any_skip_relocation, monterey: "0c5cff581c65699a007dce2632d5353ffbe294a1d40bce988cbec66b9fbd8911"
    sha256 cellar: :any_skip_relocation, arm64_linux: "6d1cb34c5d47655e694ef813393e8fff8f47c1121402c6e951123a6cf5e5f3c6"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d24aa65092416d6c43e3128716f315cf1575cb267b4f1dbaa57df73549953f7d"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.5.0/koinon-darwin-arm64"
      sha256 "a8469adceccddf3cb4326f81e17589664163e06efe71b8867e2b6cb7539c72e0"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.5.0/koinon-darwin-amd64"
      sha256 "30c503d2d1a90c9da980c0e30a5b9e5577f864cdf333dfe89ed071a09b4d072c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.5.0/koinon-linux-arm64"
      sha256 "9af34638e9b8230cf2d9bd33d358628650fab979200d3af47cf50d1a5dcbb09c"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.5.0/koinon-linux-amd64"
      sha256 "5735be56d949c6280cc4c8a19968be19743e0b10ff554b4d3950c21213af91de"
    end
  end

  def install
    bin.install Dir["koinon-*"].first => "koinon"
  end

  # Each command has its own line: the expanded opt_bin path would break a wrapped sentence.
  def caveats
    text = <<~EOS
      Install the daemon and set up your agents with this formula's binary:
        #{opt_bin}/koinon install --agent claude --agent codex

      To upgrade:
        brew update
        brew upgrade koinon
        koinon version
      The install links its binary to the formula's opt path, so the daemon restarts
      on the newly linked binary. The restart ends the dashboard login; for a new link:
        koinon dashboard

      An installation made by v0.3.0 or earlier has a copy. After this upgrade, run once:
        #{opt_bin}/koinon install
    EOS
    if OS.mac?
      text += <<~EOS

        A --system install keeps a copy. Upgrade it after each brew upgrade with:
          #{opt_bin}/koinon install --system
      EOS
    end
    text
  end

  test do
    assert_match "\"version\": \"v#{version}\"", shell_output("#{bin}/koinon version")
  end
end
