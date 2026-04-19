# .dots

Personal dotfiles managed declaratively via nix home-manager. Works on Arch Linux and macOS.

Semi-stolen, semi-handcrafted, aggresively vibe coded.

All configurations are in the [`configs/`](configs/) directory.

## Install

```bash
git clone git@github.com:tkozakas/.dots.git ~/.dots && ~/.dots/bootstrap.sh
```

## Usage

```bash
make install   # apply config
make update    # bump flake.lock and apply
```
