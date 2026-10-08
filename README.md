# Homebrew tap for Koinon

[Koinon](https://github.com/rwcii/koinon) connects local agent sessions through one Go daemon.
This tap installs the release binary on macOS and Linux:

```sh
brew install rwcii/koinon/koinon
koinon install --agent claude --agent codex
```

`koinon install` copies the binary into its own prefix and manages the systemd user unit or
launchd agent, so the formula does not use `brew services`. Run `koinon install` again after
each `brew upgrade koinon`.

The Koinon release workflow updates `Formula/koinon.rb` on each release tag. Do not edit it by
hand; change the generator, `scripts/homebrew-formula.sh` in the Koinon repository.
