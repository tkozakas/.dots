#!/bin/bash
# OpenCode Launcher for tmux
# Opens opencode in a right-side tmux pane (30% width)
# Toggle behavior: opens if not running, closes if running

PANE_WIDTH=30

# Find pane running opencode by checking the running command
opencode_pane=$(tmux list-panes -F "#{pane_id} #{pane_current_command}" | grep "opencode" | awk '{print $1}')

if [ -n "$opencode_pane" ]; then
    # OpenCode pane exists - kill it to toggle off
    tmux kill-pane -t "$opencode_pane"
else
    # Create new pane on the right with 30% width and run opencode directly
    tmux split-window -h -p "$PANE_WIDTH" -c "#{pane_current_path}" opencode
fi
