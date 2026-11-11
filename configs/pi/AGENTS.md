# Personal machine

- Dotfiles: `~/.dots` (public GitHub repo), applied by nix home-manager. Edit sources under `~/.dots/configs/<app>/`; `~/.config/*` and `~/.omp/agent/*` are symlinks into it.
- Apply with `make install`, validate with `make check`, bump `flake.lock` with `make update`.
- `~/.dots` is public: no secrets, tokens, hostnames, or employer details in it.
