# .dots

Personal dotfiles managed declaratively via nix home-manager. Works on Arch Linux and macOS.

Semi-stolen, semi-handcrafted.

All configurations are in the [`configs/`](configs/) directory.

## Install

```bash
git clone git@github.com:tkozakas/.dots.git ~/.dots && ~/.dots/bootstrap.sh
```

## Usage

| Target | Description |
|---|---|
| `make install` | Apply current locked package versions (use after editing config) |
| `make update` | Bump flake.lock to latest, then apply (use to get newer package versions) |
| `make check` | Verify the flake builds without applying |
| `make fmt` | Format nix files |
| `make news` | Read pending home-manager news |
| `make rollback` | Undo last generation |
| `make clean` | GC old generations |
