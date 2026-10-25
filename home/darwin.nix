{ config, lib, dotsRoot, ... }:

let
  link = p: {
    source = config.lib.file.mkOutOfStoreSymlink "${dotsRoot}/${p}";
    force = true;
  };
in
{
  home.file = {
    ".aerospace.toml" = link "configs/aerospace/.aerospace.toml";
    "Library/Application Support/Code/User/settings.json" = link "configs/vscode/settings.json";
  };

  home.activation.brewBundle = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    BREW=""
    [ -x /opt/homebrew/bin/brew ] && BREW=/opt/homebrew/bin/brew
    [ -z "$BREW" ] && [ -x /usr/local/bin/brew ] && BREW=/usr/local/bin/brew
    if [ -z "$BREW" ]; then
      /bin/bash -c "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
      [ -x /opt/homebrew/bin/brew ] && BREW=/opt/homebrew/bin/brew
      [ -z "$BREW" ] && [ -x /usr/local/bin/brew ] && BREW=/usr/local/bin/brew
    fi
    if [ -n "$BREW" ]; then
      for F in "$HOME/.dots/Brewfile" "$HOME/.dots-work/Brewfile"; do
        if [ -f "$F" ]; then
          $DRY_RUN_CMD "$BREW" bundle install --file="$F" --no-upgrade || echo "warning: brew bundle failed for $F" >&2
        fi
      done
    else
      $VERBOSE_ECHO "homebrew unavailable; skipped brew bundle"
    fi
  '';

  home.activation.macosDefaults = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    /usr/bin/defaults read com.raycast.macos >/dev/null 2>&1 || $DRY_RUN_CMD /usr/bin/defaults import com.raycast.macos $HOME/.dots/configs/raycast/settings.plist
    $DRY_RUN_CMD /usr/bin/defaults write com.apple.spaces spans-displays -bool true
  '';
}
