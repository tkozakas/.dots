#!/usr/bin/env bash

tab=$'\t'
sel="$(tmux list-windows -a -F "#{pane_current_path}${tab}#{session_name}${tab}#{session_name}:#{window_index}${tab}#{window_name}#{?window_zoomed_flag, ,}#{?pane_synchronized, ,} · #{window_panes}p" |
  ~/.tmux/scripts/nest-worktrees.sh |
  awk '
    BEGIN { FS = "\t" }
    { n++; branch[n] = $1; target[n] = $2; label[n] = $3; if (length($2) > width) width = length($2) }
    END { for (i = 1; i <= n; i++) printf "%s\t%-" width "s │ %s%s\n", target[i], target[i], branch[i], label[i] }' |
  fzf-tmux -p 70%,60% \
    --no-sort --ansi --delimiter '\t' --with-nth 2 --accept-nth 1 \
    --border=rounded --border-label '  tabs ' --border-label-pos 3 \
    --prompt '  ' \
    --header '↵ jump · ⇥ move · esc close' \
    --bind 'tab:down,btab:up' \
    --preview-window 'right:60%,border-left' \
    --preview 'tmux capture-pane -ep -t {1}')" || exit 0

[ -n "$sel" ] && exec tmux switch-client -t "$sel"
