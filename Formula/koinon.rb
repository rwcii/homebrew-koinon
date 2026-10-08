class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.1.0/koinon-darwin-arm64"
      sha256 "67d0fa84aa4cbfa8a6d25a3758ef5a0f7247d33b03facead5b849f837faef728"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.1.0/koinon-darwin-amd64"
      sha256 "bc3931ae36eeca6b3473e7b3d81e27b9ca6bbb80ac12fdaea4250a2216cdf107"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.1.0/koinon-linux-arm64"
      sha256 "f96cc8ae60daf1306fce7bfcabbaee7f0b0985d677566c9c2f8c44d056e45d91"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.1.0/koinon-linux-amd64"
      sha256 "e9a8c57851a6bff8dcd3bc835a4855df3283afc442666cb305e6dd8b5f9fbe23"
    end
  end

  def install
    bin.install Dir["koinon-*"].first => "koinon"
  end

  def caveats
    <<~EOS
      Install the daemon and set up your agents:
        koinon install --agent claude --agent codex
      After each brew upgrade, run koinon install again. It copies the new binary
      into its own prefix and restarts the daemon.
    EOS
  end

  test do
    assert_match "\"version\": \"v#{version}\"", shell_output("#{bin}/koinon version")
  end
end
