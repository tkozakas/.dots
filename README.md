# .dots

```bash
git clone git@github.com:tkozakas/.dots.git ~/.dots && cd ~/.dots
go build -o dots . && ./dots install
```

## Commands

```bash
d install     # Setup: symlinks → packages → benchmark
d uninstall   # Cleanup: remove symlinks
d health      # Verify symlinks
d benchmark   # Test shell startup time
```

## Flags

```bash
--dry-run        # Preview changes
--distro <name>  # Override distro (arch, fedora, ubuntu)
```
