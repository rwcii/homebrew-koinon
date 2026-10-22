class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.4.0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "37b04fec1a8e1570dfc95c76e82ed986e132b099c5033f023c6b859bc4e807ee"
    sha256 cellar: :any_skip_relocation, monterey: "3964d1397cd1fbaeddacb81aae9ebec6b18473dee453142fa09b9620cbff6eef"
    sha256 cellar: :any_skip_relocation, arm64_linux: "0164da48e26518c4516b3d71d04bf57d4f4cf7a84213ff8e07281e764b95a6ad"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "dc192efa6747dbf463743c0e76e79fe91c0172cf2a624994128ac8795e25dea2"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.0/koinon-darwin-arm64"
      sha256 "cd08347d09f95b09f5f272d51b6989c945108a78a6e2f2f5d33f89a547411762"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.0/koinon-darwin-amd64"
      sha256 "56d930612fd39ff49a5795f5b296d42378b2b3fc4f86b18287013440a3201bd4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.0/koinon-linux-arm64"
      sha256 "b5a486fed4c15705bdf3730bae84d83d85bf076819cd6e5fec70b3144cf330ed"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.0/koinon-linux-amd64"
      sha256 "095e163478748a1613e364772d560b3c791f1597bbd9738e071621f3f1d44c9d"
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
