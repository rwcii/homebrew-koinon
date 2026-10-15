class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.2.2"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "11ceed796cb241e027a73a40e5fe180fd33b240206f157190f475b1570d427fb"
    sha256 cellar: :any_skip_relocation, monterey: "b1447ce6600dd7291f7edf947273a43d441badf344b3ce6dadd21e2038867bf1"
    sha256 cellar: :any_skip_relocation, arm64_linux: "9e784e82e34e5b730b07ee4d4b0f126b95b8094d5edc3b209473485a4f69af00"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d99a3d40017ad697b3bdde65cd1240a93a991d8b10381ba27d8b084bc031813f"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.2.2/koinon-darwin-arm64"
      sha256 "bdab9e1fa09b07f9e29a0e8e69a99ac222d0097bb522fb978f2483b8a25a0a33"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.2.2/koinon-darwin-amd64"
      sha256 "e15bad939b2364573aa8e09e54804a2362798ac08b09b0c3f43f2993af395e59"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.2.2/koinon-linux-arm64"
      sha256 "936389d2748bdab836b8e71fb1094ee6ca57257640cfbafa9b0e5838cd314169"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.2.2/koinon-linux-amd64"
      sha256 "41654ac53c2673da753645d1499fc7a0a8d30988f7031882fe66875c1abc9ab7"
    end
  end

  def install
    bin.install Dir["koinon-*"].first => "koinon"
  end

  def caveats
    <<~EOS
      Install the daemon and set up your agents with this formula's binary:
        #{opt_bin}/koinon install --agent claude --agent codex
      To upgrade, run brew update before brew upgrade koinon, then run
      #{opt_bin}/koinon install again and check koinon version. The install copies
      the new binary into its own prefix and restarts the daemon. A bare koinon
      install can run the copy already installed in ~/.local/bin, which changes nothing.
    EOS
  end

  test do
    assert_match "\"version\": \"v#{version}\"", shell_output("#{bin}/koinon version")
  end
end
