#!/bin/bash

PANE_WIDTH=65
PANE_TITLE="opencode"

toggle_opencode() {
    opencode_pane=$(tmux list-panes -F '#{pane_id} #{pane_title}' | grep "$PANE_TITLE" | awk '{print $1}')
    if [[ -n "$opencode_pane" ]]; then
        tmux kill-pane -t "$opencode_pane"
    else
        tmux split-window -h -l "$PANE_WIDTH" "opencode"
        tmux select-pane -T "$PANE_TITLE"
    fi
}

toggle_opencode
