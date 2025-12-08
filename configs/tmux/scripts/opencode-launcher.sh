#!/bin/bash
# OpenCode Launcher for tmux
# Ctrl+o: show/hide (preserves state)
# Ctrl+q: kill opencode

PANE_WIDTH=30
HIDDEN_WINDOW="opencode_hidden"

current_window=$(tmux display-message -p '#{window_id}')
current_path=$(tmux display-message -p '#{pane_current_path}')

# Check if opencode pane is visible in current window
visible_pane=$(tmux list-panes -F "#{pane_id} #{pane_title}" | grep "OPENCODE" | awk '{print $1}')

# Check if hidden opencode window exists
hidden_window=$(tmux list-windows -F "#{window_name} #{window_id}" | grep "^${HIDDEN_WINDOW} " | awk '{print $2}')

if [ -n "$visible_pane" ]; then
    # Opencode is visible - hide it
    tmux break-pane -d -s "$visible_pane" -n "$HIDDEN_WINDOW"
elif [ -n "$hidden_window" ]; then
    # Opencode is hidden - show it
    hidden_pane=$(tmux list-panes -t "$HIDDEN_WINDOW" -F "#{pane_id}" | head -1)
    tmux join-pane -h -s "$hidden_pane" -t "$current_window" -l "$PANE_WIDTH%"
else
    # No opencode running - start fresh
    tmux split-window -h -p "$PANE_WIDTH" -c "$current_path" "printf '\033]2;OPENCODE\033\\' && opencode"
fi
