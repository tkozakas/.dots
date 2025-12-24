# .dots

All configurations are in the [`configs/`](configs/) directory.

## Install

```bash
git clone git@github.com:tkozakas/.dots.git ~/.dots && ~/.dots/bootstrap.sh
```

## Tasks

```bash
task                              # Install (default)
task install                      # Setup dotfiles
task install -- --dry-run         # Preview changes
task install -- --distro arch     # Override distro
task uninstall                    # Remove symlinks
task benchmark                    # Test shell startup time
```
