# .dots

Personal dotfiles managed declaratively via nix home-manager. Works on macOS and Arch Linux.

Semi-stolen, semi-handcrafted, aggressively vibe coded.

Configs live in [`configs/`](configs/); [`home/`](home/) maps them to symlinks/packages per OS (`common.nix`, `linux.nix`, `darwin.nix`). macOS apps come from the [`Brewfile`](Brewfile), language runtimes from mise.

## Install

```bash
git clone git@github.com:tkozakas/.dots.git ~/.dots && ~/.dots/bootstrap.sh
```

## Usage

```bash
make install   # apply config
make update    # bump flake.lock and apply
make rollback  # revert to previous home-manager generation
make clean     # wipe profile history and run nix gc
make doctor    # show status and undeclared brew packages
make prune     # remove undeclared brew packages
```

Apps installed outside Homebrew make `brew bundle` fail on their cask; adopt them once with `brew install --cask --adopt <cask>`.
