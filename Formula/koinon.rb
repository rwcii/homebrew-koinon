class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.3.2"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "2f8196f01662b2eb2355077d58a7d42531e0707d27b7053856bbeba3b2176c67"
    sha256 cellar: :any_skip_relocation, monterey: "b0ce36c642eb4bd2630436ab7487489f94d59436b0ff396faa7064f578a9d509"
    sha256 cellar: :any_skip_relocation, arm64_linux: "48ff36f13ec6dd7a6f7fec84e7d54bf6353bee4df3ebea3ec9844b1e0e9d4bcf"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "3aafad6416a8e585b8a2c07b6fbe701abd2ca5fa976d5bbaaf92a58eaf10a243"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.2/koinon-darwin-arm64"
      sha256 "6175e30d20d55c80354bfbf7f7a0e026b15807aa61e574af3944dc15e9466759"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.2/koinon-darwin-amd64"
      sha256 "72ee06bb472cc87ce1ddb2813e23b453a1514ceae32d2a868fc380f6afdb5b37"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.2/koinon-linux-arm64"
      sha256 "893a53ab21613eaad5eae17209967de1c0eff988c6ac528812772cec65547048"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.2/koinon-linux-amd64"
      sha256 "2da122993e1afdba138aace20e9e60bd43f3c9ad645cd9d234dff3fc30c73630"
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
