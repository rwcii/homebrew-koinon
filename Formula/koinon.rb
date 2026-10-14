class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.2.0/koinon-darwin-arm64"
      sha256 "3ad58956c58bf37743b3c534891d81ce839fd67a5fb2d9bac018eab302d3fab0"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.2.0/koinon-darwin-amd64"
      sha256 "5c9c622e2d030e3cc145b53d3d07735cb5a785f080627a851fcbfa736d05b4fe"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.2.0/koinon-linux-arm64"
      sha256 "32290236cc06d6772bbc16b608fe366620a3c6368bf604d9fed0c812d389a60d"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.2.0/koinon-linux-amd64"
      sha256 "3d082f17d1d72238cf33b90002c4f5629af6fbee338a28377f1cea27450f13a7"
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
