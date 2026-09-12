#!/usr/bin/env bash

sel="$(tmux list-windows -a -F '#{session_name}:#{window_index} │ #{window_name}#{?window_zoomed_flag, ,}#{?pane_synchronized, ,} · #{window_panes}p' | fzf-tmux -p 70%,60% \
  --no-sort --ansi --delimiter ' │ ' \
  --border=rounded --border-label '  tabs ' --border-label-pos 3 \
  --prompt '  ' \
  --header '↵ jump · ⇥ move · esc close' \
  --bind 'tab:down,btab:up' \
  --preview-window 'right:60%,border-left' \
  --preview 'tmux capture-pane -ep -t {1}')" || exit 0

[ -n "$sel" ] && exec tmux switch-client -t "${sel%% │ *}"
