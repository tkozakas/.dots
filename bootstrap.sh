#!/bin/bash
set -e

NIX_DAEMON_SH=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
NIX_USER_SH="$HOME/.nix-profile/etc/profile.d/nix.sh"

if ! command -v nix >/dev/null 2>&1; then
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
  if   [ -e "$NIX_DAEMON_SH" ]; then . "$NIX_DAEMON_SH"
  elif [ -e "$NIX_USER_SH"   ]; then . "$NIX_USER_SH"
  fi
fi

case "$(uname -s)" in
  Linux)  CONFIG=linux  ;;
  Darwin) CONFIG=darwin ;;
  *) echo "unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

cd "$(dirname "$0")"
nix --option warn-dirty false run ".#home-manager" -- switch --flake ".#${CONFIG}" -b backup --impure 2>&1 \
  | grep -vE "unknown setting|deprecated alias"
