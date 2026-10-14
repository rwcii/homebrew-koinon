class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.2.1/koinon-darwin-arm64"
      sha256 "0dd9945819b951013de4a926af5d8c6c2ebf62d25488442ad23ce93f69e7471c"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.2.1/koinon-darwin-amd64"
      sha256 "04cc2dc6a0797fc3863ddf314049039a329b61f6cc0d5382a8df05cd3e6e64d9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.2.1/koinon-linux-arm64"
      sha256 "5711f97c5120766ccc50bc60d6b5fb8f2f293a7741cb6af8f6f3e39d17afea76"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.2.1/koinon-linux-amd64"
      sha256 "9d66431288e8c7d1acc70bbd03b0cf5f562ebb52ed5b4efd0a627529d40be554"
    end
  end

  def install
    bin.install Dir["koinon-*"].first => "koinon"
  end

  def caveats
    <<~EOS
      Install the daemon and set up your agents with this formula's binary:
        #{opt_bin}/koinon install --agent claude --agent codex
      After each brew upgrade, run #{opt_bin}/koinon install again. It copies the
      new binary into its own prefix and restarts the daemon. A bare koinon install
      can run the copy already installed in ~/.local/bin, which changes nothing.
    EOS
  end

  test do
    assert_match "\"version\": \"v#{version}\"", shell_output("#{bin}/koinon version")
  end
end
