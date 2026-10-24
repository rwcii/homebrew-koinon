class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.4.2"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "5831e7546bbbca0382c69b6942911abfa4b49a69a4c88d3138df414a645c8da2"
    sha256 cellar: :any_skip_relocation, monterey: "e0488ac83366fb0f5e0e2e31e55d300961ae8dc1afd347786403ba9085ccb71d"
    sha256 cellar: :any_skip_relocation, arm64_linux: "980d7f3183620a947c916021ac503e5dc1bd40dd2eb30a781c3d3554ea7ee840"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "6bacb24f6013fcf667c09f5f719dcc0a543eef5de2cff63eb199203c0ef3518f"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.2/koinon-darwin-arm64"
      sha256 "7828548f44f250adf49b1e56f328738a06e7df00f59dc8fc7f7fa9dc87e95eca"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.2/koinon-darwin-amd64"
      sha256 "3450e7f2d44586325e9d629412fe66f17f6da84a094a51ae6bfc80ce6f7a7038"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.2/koinon-linux-arm64"
      sha256 "83a1d3cdefa30262b4e4baae4fac79bd8e200f79f2c8f63c9ab33576700b6def"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.4.2/koinon-linux-amd64"
      sha256 "5d1e4640cf95bf6520b9b2a8a9ff5ed30bfe1d494bd535dced266ee334464f32"
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
