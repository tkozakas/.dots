# .dots

```bash
git clone git@github.com:tkozakas/.dots.git ~/.dots && cd ~/.dots && go build -o dots . && ./dots install
```

## Commands

```bash
dots install     # 1. Setup: symlinks → packages → benchmark
dots update      # 2. Sync: git pull → rebuild → install
dots uninstall   # 3. Cleanup: remove symlinks
```

### Optional

```bash
dots health      # Verify symlinks
dots benchmark   # Test shell startup time
```

## Flags

```bash
--dry-run        # Preview changes
--distro <name>  # Override distro (arch, fedora, ubuntu)
```
