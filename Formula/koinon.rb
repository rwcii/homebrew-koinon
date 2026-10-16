class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.3.0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "30beebe8e3aadd1f90e7c707a490096f182138428d3be1bb43cc2f76675c317e"
    sha256 cellar: :any_skip_relocation, monterey: "1d8c954852d9b2ab01288f7a552d68b24fcb47589bc3960f0eb85de96b9c6b99"
    sha256 cellar: :any_skip_relocation, arm64_linux: "0ef8d2894dd2dff1cd2392bdac808187ac41085549db5a18bc95107781cb0d50"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c103d4c041be560a433a0683548d47cd8029a364a7972b17dbbe8ccc54e3e613"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.0/koinon-darwin-arm64"
      sha256 "d01da295ff4070c3f53d55c8c730d954aa93fc4a8dd2061e7f94aa57e8a88c53"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.0/koinon-darwin-amd64"
      sha256 "9b2dd41186871ad0ae8cf8cb20847024421310f0507cf72f5defff1d96830cb2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.0/koinon-linux-arm64"
      sha256 "c8b57287d50c3777170a60e365942ab2359ff3b53e3faa3c8a962894ba07769e"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.3.0/koinon-linux-amd64"
      sha256 "f9205fa4450c61ae2cd24eb11bb44fa256c676823a7a9aabef1e5891e14af05b"
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
