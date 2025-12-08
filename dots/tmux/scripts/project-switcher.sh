#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$({
        echo "[New Tab]"
        echo "[Close Current Window]"
        [[ -d "$HOME/.dots" ]] && echo "$HOME/.dots"
        [[ -d "$HOME/vinted" ]] && find "$HOME/vinted" -mindepth 1 -maxdepth 1 -type d
        [[ -d "$HOME/Documents" ]] && find "$HOME/Documents" -mindepth 1 -maxdepth 1 -type d
    } | fzf --select-1 --exit-0)
fi

if [[ -z $selected ]]; then
    exit 0
fi

# Handle special actions
if [[ "$selected" == "[New Tab]" ]]; then
    timestamp=$(date +%s)
    window_name="home-$timestamp"
    tmux new-window -n "$window_name" -c "$HOME"
    tmux send-keys -t "$window_name" "nvim ." C-m
    exit 0
fi

if [[ "$selected" == "[Close Current Window]" ]]; then
    tmux kill-window
    exit 0
fi

selected_name=$(basename "$selected" | sed 's/^\.//')

if tmux list-windows -F '#{window_name}' | grep -q "^${selected_name}$"; then
    CURRENT_WINDOW_NAME=$(tmux display-message -p '#{window_name}')

    if [ "$selected_name" = "$CURRENT_WINDOW_NAME" ]; then
        exit 0
    else
        tmux select-window -t "$selected_name"
    fi
else
    tmux new-window -n "$selected_name" -c "$selected"
    tmux send-keys -t "$selected_name" "nvim ." C-m
fi
