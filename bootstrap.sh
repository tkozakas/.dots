#!/bin/bash
set -e

NIX_INSTALLER_VERSION=v3.17.3
NIX_DAEMON_SH=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
NIX_USER_SH="$HOME/.nix-profile/etc/profile.d/nix.sh"

if ! command -v nix >/dev/null 2>&1; then
  curl -fsSL "https://install.determinate.systems/nix/tag/${NIX_INSTALLER_VERSION}" | sh -s -- install --no-confirm
  if   [ -e "$NIX_DAEMON_SH" ]; then . "$NIX_DAEMON_SH"
  elif [ -e "$NIX_USER_SH"   ]; then . "$NIX_USER_SH"
  fi
fi

cd "$(dirname "$0")"
exec make install
