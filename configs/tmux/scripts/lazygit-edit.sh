#!/usr/bin/env bash
# lazygit edit handler: open the file in the nvim we came from and close
# the lazygit surface, falling back gracefully per context.

file="$(realpath "$1" 2>/dev/null || echo "$1")"
line="${2:-}"

open_remote() {
  local server="$1"
  nvim --server "$server" --remote "$file" || return 1
  [ -n "$line" ] && nvim --server "$server" --remote-send "${line}G"
  nvim --server "$server" --remote-send ":DiffIfDirty<CR>"
}

if [ -n "$NVIM" ]; then
  nvim --server "$NVIM" --remote-send q
  open_remote "$NVIM"
  exit 0
fi

if [ -n "$TMUX" ]; then
  origin="$(tmux display-message -p -t '!' '#{pane_id}' 2>/dev/null)"
  sock="/tmp/nvim-tmux-${origin#%}"
  if [ -n "$origin" ] && [ -S "$sock" ] && open_remote "$sock"; then
    tmux select-pane -t '!'
    tmux kill-pane -t "$TMUX_PANE"
  else
    if [ -n "$line" ]; then
      tmux respawn-pane -k -t "$TMUX_PANE" "nvim +$line +DiffIfDirty $(printf %q "$file")"
    else
      tmux respawn-pane -k -t "$TMUX_PANE" "nvim +DiffIfDirty $(printf %q "$file")"
    fi
  fi
  exit 0
fi

if [ -n "$line" ]; then
  exec nvim +"$line" +DiffIfDirty "$file"
fi
exec nvim +DiffIfDirty "$file"
