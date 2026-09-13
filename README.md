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

## Package ownership

Every tool has exactly one owner per OS. A tool never appears in two package managers — that is how version drift and shadowed binaries happen.

| What | macOS | Linux |
|---|---|---|
| CLI tools (tmux, nvim, git, fzf, lazygit, ...) | homebrew | nix (`linux.packages`) |
| GUI apps | homebrew casks (`darwin.casks`) | nix (`linux.packages`) |
| Tap-distributed tools (omp) | homebrew (`darwin.brews`) | nix |
| Tools brew does not ship, or that must be identical on every OS (sesh, fonts, bitwarden-cli) | nix (`common.packages`) | nix (`common.packages`) |
| Config files | nix home-manager symlinks (`xdgLinks` / `homeLinks`) | same |
| GUI app settings (plist-based) | `make dump` snapshots into `configs/`, seed-imported by `hooks` on fresh machines | n/a |
| Base system (kernel, drivers, login) | macOS | distro package manager (pacman) |

Decision rules:

1. **macOS: brew first.** Mature bottles, first on `PATH`. Reach for nix only when brew has no formula or the tool must match Linux bit-for-bit.
2. **Linux: nix first.** The whole user space (browser, WM stack, apps) comes from `linux.packages`, so the setup is identical on any distro; pacman owns only what nix cannot — kernel, drivers, base system.
3. **`common.packages` means "same everywhere"** — if it matters that macOS and Linux run the same build, it goes there and nix owns it on both.
4. **PATH encodes the policy**: brew paths first, `~/.nix-profile/bin` appended last, so nix fills gaps without shadowing brew.

All four lists live in [`config.json`](config.json); `nix/home.nix` turns `casks`/`brews` into idempotent `brew install` activation steps and `packages` into home-manager packages.
