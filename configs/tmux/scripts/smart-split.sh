#!/usr/bin/env bash
# Hyprland-dwindle style: split the focused pane 50/50 along its longer
# visual axis (terminal cells are ~2:1 tall, hence the width/2 comparison).

pane_w=$(tmux display-message -p '#{pane_width}')
pane_h=$(tmux display-message -p '#{pane_height}')
pane_path=$(tmux display-message -p '#{pane_current_path}')

if (( pane_w > pane_h * 2 )); then
  direction=-h
else
  direction=-v
fi

if [[ $# -gt 0 ]]; then
  tmux split-window "$direction" -c "$pane_path" "$@"
else
  tmux split-window "$direction" -c "$pane_path"
fi
