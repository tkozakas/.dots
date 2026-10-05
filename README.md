# .dots

Home-manager flake shared by Arch Linux and macOS.

```
bootstrap.sh   Makefile   flake.nix   Brewfile
home/          common.nix  linux.nix  darwin.nix
configs/       raw dotfiles, symlinked into $HOME
scripts/       helpers
```

An optional private overlay at `~/.dots-work` (`work.nix`, `Brewfile`) is loaded automatically when present.

## Ownership

- Nix (home-manager): every CLI tool (`home/common.nix`), Linux GUI/hyprland stack (`home/linux.nix`).
- Brewfile (macOS): casks, taps, brew services, gem build libs.
- mise: language runtimes and per-repo tools. Never declare go/node/ruby/python/java/rust in nix.
- Undeclared is not uninstalled: install never removes anything; only `make prune` does.

## Bootstrap

```
git clone https://github.com/tkozakas/.dots ~/.dots && ~/.dots/bootstrap.sh
```

## Daily

`make install`, `make check`, `make doctor` (lists drift), `make prune` (removes undeclared brew packages), `make update`, `make diff`, `make rollback`.

Apps installed outside Homebrew make `brew bundle` fail on their cask; adopt them once with `brew install --cask --adopt <cask>` (needs sudo).
