class Koinon < Formula
  desc "Shared coordination and memory for local agent sessions"
  homepage "https://github.com/rwcii/koinon"
  license "MIT"

  bottle do
    root_url "https://github.com/rwcii/koinon/releases/download/v0.9.1"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "785156b8600ed9b233d3f8e3f5027f59c4ecb1d8b7e179da750a98626913c6b7"
    sha256 cellar: :any_skip_relocation, monterey: "4174caae311525405b8479c8a5afa3186aaa2bd28d63d7f979f3a1e58b15c309"
    sha256 cellar: :any_skip_relocation, arm64_linux: "f9604812d897d72a2e7aa674dd15030f399013cc27ff0cf91a6dd62566b6f541"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ae1d5acd46b48e1c55073ecbddec2009a404c9d401be5c8146ef5229351f1d45"
  end

  on_macos do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.9.1/koinon-darwin-arm64"
      sha256 "c840f2b583f18a39f1b76cc78ee94a58f9830f2a9fea594c49c8f2fa0841b391"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.9.1/koinon-darwin-amd64"
      sha256 "a31a6634acbbdd5fb1631a21236923e388e428974b07ba48c99f0b2c297b9ba3"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/rwcii/koinon/releases/download/v0.9.1/koinon-linux-arm64"
      sha256 "f9f768d074bd74dadc85cf5931041a4c38b1bb7b3b2a9a87978d064d1ce26713"
    end
    on_intel do
      url "https://github.com/rwcii/koinon/releases/download/v0.9.1/koinon-linux-amd64"
      sha256 "7b223e98ebd468e5e1f9705021b640a8dd876f45a97c2b9cd2e4a453549a9ff1"
    end
  end

  def install
    bin.install Dir["koinon-*"].first => "koinon"
  end

  # Each command has its own line: the expanded opt_bin path would break a wrapped sentence.
  # koinon install --plan reads this machine and prints only the steps that it still needs;
  # it changes nothing (#551). Homebrew keeps the person's PATH, where the agents' CLIs are,
  # in HOMEBREW_PATH. When the plan cannot run or check everything, the fixed steps show. A
  # current installation has no steps, so it shows the plan's sentence alone (#561).
  def caveats
    plan = begin
      require "open3"
      out, _err, status = Open3.capture3({ "PATH" => ENV.fetch("HOMEBREW_PATH", ENV.fetch("PATH", "")) },
                                         "#{opt_bin}/koinon", "install", "--plan")
      out if status.success? && !out.strip.empty?
    rescue StandardError
      nil
    end
    current = "The Koinon installation is current."
    done = plan&.strip == current
    text = if done
      "#{current}\n"
    elsif plan
      "The steps that this installation needs:\n#{plan.lines.map { |line| "  #{line}" }.join}"
    else
      fixed = <<~EOS
        Install the daemon; at a terminal it offers to set up each agent it finds:
          #{opt_bin}/koinon install
        Set the maintainer secret for the dashboard login:
          #{opt_bin}/koinon maintainer secret set
        Set up an agent family later with its command:
          #{opt_bin}/koinon install --agent claude
          #{opt_bin}/koinon install --agent codex
          #{opt_bin}/koinon install --agent agy
          #{opt_bin}/koinon install --agent opencode
          #{opt_bin}/koinon install --agent grok
      EOS
      if OS.mac?
        fixed += <<~EOS
          A --system install keeps a copy. Upgrade it after each brew upgrade with:
            #{opt_bin}/koinon install --system
        EOS
      end
      fixed
    end
    unless done
      text += <<~EOS
        Check again after these steps:
          #{opt_bin}/koinon install --plan
      EOS
    end
    text + <<~EOS

      To upgrade:
        brew update
        brew upgrade koinon
        koinon version
      The install links its binary to the formula's opt path, so the daemon restarts
      on the newly linked binary. The restart ends the dashboard login; for a new link:
        koinon dashboard
    EOS
  end

  test do
    assert_match "\"version\": \"v#{version}\"", shell_output("#{bin}/koinon version")
  end
end
