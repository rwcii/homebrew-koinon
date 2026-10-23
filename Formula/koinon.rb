class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.4.1"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "fdd49e45b65edf5f4408a7ddb88d2cc39c476b609f60738a64b2a37960f66dcc"
    sha256 cellar: :any_skip_relocation, monterey: "43a1b02528ad2157015d746c7283d1acab0b23bd2f54839118f2b4c926bd13db"
    sha256 cellar: :any_skip_relocation, arm64_linux: "fed44b51b7d555f3ac5900b020311e4ca65462809c6a94c6e7fbec3caa90a310"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "6fe72b5330238f65b310393ac11f73ffa8343f3eed3c91cb67de16803b047359"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.1/koinon-darwin-arm64"
      sha256 "a30018757d8831498ba741b14c60d08813f3e2333c33092cbc841ab1f43bec6b"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.1/koinon-darwin-amd64"
      sha256 "dfc7a0e0e444982c5b3f4558203a0a204a20139440c9ac689d8883b2d5e17a36"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.1/koinon-linux-arm64"
      sha256 "05a64906c36481fe08d43e0ddac6b0163db5062df1cfd95bb216a59e797d0b9e"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.1/koinon-linux-amd64"
      sha256 "d6c4c0020ef39141280b15643c3d6321c4892483f904a266beb1fa7b1143cc42"
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
