# .dots

Personal dotfiles managed declaratively via nix home-manager. Works on macOS and Arch Linux.

Semi-stolen, semi-handcrafted, aggressively vibe coded.

Configs live in [`configs/`](configs/); `config.json` maps them to symlinks/packages per OS.

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
```

CLI tools are owned by homebrew; nix owns symlinks, fonts, and nix-only packages (sesh).
