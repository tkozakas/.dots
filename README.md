# .dots

Dotfiles for macOS and Arch Linux, managed with nix home-manager.
Semi-stolen, semi-handcrafted, aggressively vibe coded.

```bash
git clone git@github.com:tkozakas/.dots.git ~/.dots && ~/.dots/bootstrap.sh
```

<details>
<summary><b>Layout</b></summary>

- [`configs/`](configs/) - the configs
- [`home/`](home/) - links them per OS (`common.nix`, `linux.nix`, `darwin.nix`)
- [`Brewfile`](Brewfile) - macOS apps
- mise - language runtimes

</details>

<details>
<summary><b>Usage</b></summary>

```bash
make install   # apply config
make update    # bump flake.lock and apply
make rollback  # previous generation
make clean     # wipe history, nix gc
make doctor    # status + undeclared brew packages
make prune     # remove undeclared brew packages
```

</details>

<details>
<summary><b>Homebrew gotcha</b></summary>

Apps installed outside Homebrew break `brew bundle`. Adopt them once:

```bash
brew install --cask --adopt <cask>
```

</details>
