#!/bin/bash

PANE_WIDTH=30
HIDDEN_WINDOW="opencode"

current_window=$(tmux display-message -p '#{window_id}')
current_path=$(tmux display-message -p '#{pane_current_path}')

visible_pane=$(tmux list-panes -F "#{pane_id} #{pane_title}" | grep "OPENCODE" | awk '{print $1}')
hidden_window=$(tmux list-windows -F "#{window_name} #{window_id}" | grep "^${HIDDEN_WINDOW} " | awk '{print $2}')

if [ -n "$visible_pane" ]; then
    tmux break-pane -d -s "$visible_pane" -n "$HIDDEN_WINDOW"
elif [ -n "$hidden_window" ]; then
    hidden_pane=$(tmux list-panes -t "$HIDDEN_WINDOW" -F "#{pane_id}" | head -1)
    tmux join-pane -h -s "$hidden_pane" -t "$current_window" -l "$PANE_WIDTH%"
else
    tmux split-window -h -p "$PANE_WIDTH" -c "$current_path" "printf '\033]2;OPENCODE\033\\' && opencode"
fi
