# dots

```bash
git clone git@github.com:tkozakas/.dots.git ~/.dots && cd ~/.dots && go build -o dots . && ./dots install
```

## Commands

```bash
dots install           # Full setup: symlinks + packages
dots link              # Create symlinks only
dots packages          # Install packages only
```

## Flags

```bash
--distro <name>        # Override distro detection (arch, fedora, ubuntu)
--dry-run              # Preview changes without applying
--config <path>        # Custom config file (default: dotfiles.yaml)
```

## Structure

```
.dots/
├── dotfiles.yaml      # Configuration
├── configs/           # All dotfiles (nvim, kitty, tmux, zsh, hypr, etc.)
├── cmd/               # CLI commands
└── internal/          # Go packages
```
