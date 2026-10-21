class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.3.3"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "ad3dc81ea3f498c381fbd30726dfac42111a0b5e6b7b271f1b302ecedb192850"
    sha256 cellar: :any_skip_relocation, monterey: "3c969866c9f4ca2a393e4041770f73ff4a7b5c354909c8ce5df26bf0d242dddf"
    sha256 cellar: :any_skip_relocation, arm64_linux: "17553b4c364029d4a6801e50f65a64f3cecdaa177f895e94c600159dc6f3e4e4"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "60e66a008fcf0c28db94b186ced3ddfa98be74633b651edce850bdebddd5c7b0"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.3/koinon-darwin-arm64"
      sha256 "daa1e63e42bc31c2eff3ceca8a10ff5d1a91259d4fd4bb2dd2709d2c4ea3e87e"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.3/koinon-darwin-amd64"
      sha256 "9ba9c052e3f46ed9a6f5578f4a82b4ea91474d0158a56b09a22accfe81517bd1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.3/koinon-linux-arm64"
      sha256 "24ea6c5570bb4f24b1c74bd9ffcd6f71653dc6b3997c307e5da23a2b62244c67"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.3/koinon-linux-amd64"
      sha256 "e722b008cd71c1f5038d760085cc52105231452091f18b1513f2936f6bbcd010"
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
