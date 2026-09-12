# .dots

Personal dotfiles managed declaratively via nix home-manager. Works on macOS and Arch Linux.

Semi-stolen, semi-handcrafted, aggressively vibe coded.

## Stack

| Area | Base | Custom |
|---|---|---|
| nvim | [LazyVim](https://github.com/LazyVim/LazyVim) | ANSI 16-color rendering, oil.nvim, unified Space-Space search (C-g cycles smart/files/grep), JetBrains-style `gd`, copilot ghost text |
| tmux | [Oh my tmux!](https://github.com/gpakosz/.tmux) | `C-a` prefix, vim-navigator, [sesh](https://github.com/joshmedeski/sesh) session picker (`C-f`), tab picker (`w`), dwindle splits (`Enter`, `o`) |
| terminal | alacritty | classic dark Tango palette — single source of truth for all ANSI-rendered tools |
| theme | Tango everywhere | tmux, lazygit, k9s, fzf pickers, omp (`terminal` theme) pin the same hex values |
| wm | AeroSpace (brew cask) | config-version 2, auto-reload |
| shell | zsh + zinit | minimal prompt, shared fzf style via `FZF_DEFAULT_OPTS` |

Configs live in [`configs/`](configs/); `config.json` maps them to symlinks/packages per OS.
A work overlay repo (`~/.dots-work`) layers on top and shadows same-named links (notably `.omp/agent`).

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
