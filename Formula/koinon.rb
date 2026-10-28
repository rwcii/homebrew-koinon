class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.6.0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "e3aa99bacf6812f1d214de3fb7f0dd7d76510e03ffddd33fd65c9f7c530a970e"
    sha256 cellar: :any_skip_relocation, monterey: "f23375627e20e2c7bc47d434e71abce117894256eb456aad32adb0cb3c904e10"
    sha256 cellar: :any_skip_relocation, arm64_linux: "1514a7cb513569eb4bc18a083573b7c75d114ba66356664c46adbdb2df3423b5"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1594758e99e84b25e801eba3876442e5f8133579ac88d23254dbd77619e0a131"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.6.0/koinon-darwin-arm64"
      sha256 "b596d45574ea95b904edb9131628a2c95de76f248f3d7bd31febe9662378de6a"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.6.0/koinon-darwin-amd64"
      sha256 "cad5c9d81667eb81dc7dbbc33c76e8d57bfe7861fa3e8d6c4e047dcd3aa1ad77"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.6.0/koinon-linux-arm64"
      sha256 "f845a9037e4e9e706d1cb7c0b462254a38c505aa5a9151cf8cec8d3fd64f57dc"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.6.0/koinon-linux-amd64"
      sha256 "e6f1bbb9fa9309f5896d6b5d59ff56fd9de72e57db1d9b60f899191c7cc90861"
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
