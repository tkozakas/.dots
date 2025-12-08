#!/usr/bin/env bash
# Advanced session manager with fuzzy finding and preview

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # Find directories and show preview
    selected=$(find ~/vinted ~/Documents ~/.dotfiles-work -mindepth 1 -maxdepth 1 -type d 2>/dev/null | \
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

# Create session if it doesn't exist
if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
    tmux send-keys -t "$selected_name" "nvim ." C-m
fi

# Switch to session
if [[ -z $TMUX ]]; then
    # Not in tmux, attach to session
    tmux attach-session -t "$selected_name"
else
    # In tmux, switch client
    tmux switch-client -t "$selected_name"
fi
