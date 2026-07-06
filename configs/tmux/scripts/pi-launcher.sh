#!/bin/bash
# Toggle a side pane running the pi (oh-my-pi) coding agent.

PANE_WIDTH=80

PI_BIN="${PI_BIN:-$HOME/.nix-profile/bin/pi}"
if [[ ! -x "$PI_BIN" ]]; then
  PI_BIN=$(command -v pi || command -v omp)
fi

if [[ -z "$PI_BIN" ]]; then
  tmux display-message "pi/omp not found on PATH"
  exit 0
fi

pi_pane=$(tmux list-panes -F '#{pane_id} #{pane_start_command}' | grep -E "/(pi|omp)( |$)" | awk '{print $1}')

if [[ -n "$pi_pane" ]]; then
  tmux kill-pane -t "$pi_pane"
else
  pane_path=$(tmux display-message -p '#{pane_current_path}')
  tmux split-window -h -l "$PANE_WIDTH" -c "$pane_path" "$PI_BIN"
fi
