#!/bin/bash

PANE_WIDTH=65

toggle_opencode() {
    opencode_pane=$(tmux list-panes -F '#{pane_id} #{pane_current_command}' | grep "opencode" | awk '{print $1}')
    if [[ -n "$opencode_pane" ]]; then
        tmux kill-pane -t "$opencode_pane"
    else
        tmux split-window -h -l "$PANE_WIDTH" -c "#{pane_current_path}" "opencode"
    fi
}

toggle_opencode
