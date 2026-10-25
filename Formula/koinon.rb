class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.4.3"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "b1925b1309c17d60e8b7e8b71d14e29a34f6a01474e068d3dd43ea769bf41a24"
    sha256 cellar: :any_skip_relocation, monterey: "e4601ce088082bd7e9bd5bcd7cb56e35cbcf95cb858fe5e61cb2dfd2e0acf936"
    sha256 cellar: :any_skip_relocation, arm64_linux: "aaace77562e83ddf9d9164999910dd32f51e2cfb160a1845fbc6745f32f215c2"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8f85f2e8b5b6d9a3c66360059b1ce6f07530f612597edfe44a8ff1e5fc29b26d"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.3/koinon-darwin-arm64"
      sha256 "710d0ef16e76fdb387830be92d45e18906932b174f5af5ac32e3e6ba51e39ed5"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.3/koinon-darwin-amd64"
      sha256 "668a1a6aafc41d15b4acad48bd6498343a308d6419cf9f7ddb04a59fb0b3ea55"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.3/koinon-linux-arm64"
      sha256 "ad46593617a0f35a6cef651fe4317a6eb7751d8d82acb5e89a503acd2004f980"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.3/koinon-linux-amd64"
      sha256 "36e3ffa9cb817beb8e6f83e10b16aa84477cca9d73993261928186baa8d26348"
    end
  end

  def install
    bin.install Dir["koinon-*"].first => "koinon"
  end

  def caveats
    <<~EOS
      Install the daemon and set up your agents with this formula's binary:
        #{opt_bin}/koinon install --agent claude --agent codex
      The install links its binary to #{opt_bin}/koinon. To upgrade, run brew update,
      then brew upgrade koinon: the daemon restarts on the new version. An installation
      made by v0.3.0 or earlier has a copy instead; after this upgrade, run
      #{opt_bin}/koinon install once. A macOS --system install keeps a copy; upgrade
      it with #{opt_bin}/koinon install --system.
    EOS
  end

  test do
    assert_match "\"version\": \"v#{version}\"", shell_output("#{bin}/koinon version")
  end
end
