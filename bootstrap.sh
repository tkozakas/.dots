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

case "$(uname -s)" in
  Linux)  CONFIG=linux  ;;
  Darwin) CONFIG=darwin ;;
  *) echo "unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

cd "$(dirname "$0")"

# Move existing non-symlink config targets aside so home-manager can take over.
TS=$(date +%s)
JQ_EXPR='((.common.xdgLinks // {}) + (.["'"$CONFIG"'"].xdgLinks // {}) | keys[] | "\(env.HOME)/.config/\(.)"),
((.common.homeLinks // {}) + (.["'"$CONFIG"'"].homeLinks // {}) | keys[] | "\(env.HOME)/\(.)")'
while IFS= read -r path; do
  if [ -e "$path" ] && [ ! -L "$path" ]; then
    mv "$path" "$path.pre-dots-$TS"
    echo "moved aside: $path -> $path.pre-dots-$TS"
  fi
done < <(nix --option warn-dirty false run nixpkgs#jq -- -r "$JQ_EXPR" config.json)

nix --option warn-dirty false run ".#home-manager" -- switch --flake ".#${CONFIG}" -b backup --impure 2>&1 \
  | grep -vE "unknown setting|deprecated alias"
