#!/usr/bin/env bash

sel="$({ sesh list -t --icons; find ~/vinted -mindepth 1 -maxdepth 1 -type d 2>/dev/null; } | fzf-tmux -p 80%,70% \
  --no-sort --ansi \
  --border=rounded --border-label ' ⚡ sessions ' --border-label-pos 3 \
  --prompt '  ' \
  --header '↵ connect · ⇥ move · esc close' \
  --bind 'tab:down,btab:up' \
  --preview-window 'right:55%,border-left' \
  --preview 'sesh preview {}')" || exit 0

[ -n "$sel" ] && exec sesh connect "$sel"
