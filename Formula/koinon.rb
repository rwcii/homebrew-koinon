class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.3.1"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "67ae95315eba27c892ffc227ccf2c848ea02e89418203486a6bd2337ca2ddd35"
    sha256 cellar: :any_skip_relocation, monterey: "efb8c38b82dad37f52a9c7b4087bc8bca0072f2420fab3e0c65656920c5a92cd"
    sha256 cellar: :any_skip_relocation, arm64_linux: "0ad6f285d60d59c352e2f9b9f409d953e3ddf23399e61c9ef420d5c33315c889"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "2ba5190afb920e1f929b5ddcb012d802f311c8b8d0fc778abca76695165ba599"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.1/koinon-darwin-arm64"
      sha256 "9d7e8ee3823e8b719f3282a0568c2424cb5d807ede6824b0afdf813f17cce03a"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.1/koinon-darwin-amd64"
      sha256 "283deced008b0670f7c2e1b030d7dbb70f4516703440024dcee1efa62ded8b17"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.1/koinon-linux-arm64"
      sha256 "9dc0630b3b52c3adc777931ea2bbf165379458d0b542df241ed4dac3775c8991"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.1/koinon-linux-amd64"
      sha256 "653ff3829c9c5e7bfce9a74f74133e8802a33e0a447b615fe790352defe5d6e6"
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
