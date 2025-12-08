# .dots

```bash
git clone git@github.com:tkozakas/.dots.git ~/.dots && cd ~/.dots
go build -o dots . && ./dots install
```

## Commands

```bash
d install     # 1. Setup: symlinks → packages → benchmark
d update      # 2. Sync: git pull → rebuild → install
d uninstall   # 3. Cleanup: remove symlinks
```

### Optional

```bash
d health      # Verify symlinks
d benchmark   # Test shell startup time
```

## Flags

```bash
--dry-run        # Preview changes
--distro <name>  # Override distro (arch, fedora, ubuntu)
```
