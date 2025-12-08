#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/vinted ~/Documents ~/.dots -mindepth 1 -maxdepth 1 -type d 2>/dev/null | \
      fzf --prompt="Select project (session): " \
          --height=60% \
          --layout=reverse \
          --border=rounded \
          --preview='ls -la {} | head -20' \
          --preview-window=right:50%:wrap)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _ | tr - _)

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
    tmux send-keys -t "$selected_name" "nvim ." C-m
fi

if [[ -z $TMUX ]]; then
    tmux attach-session -t "$selected_name"
else
    tmux switch-client -t "$selected_name"
fi
