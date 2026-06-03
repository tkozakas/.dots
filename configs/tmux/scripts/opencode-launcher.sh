#!/bin/bash

PANE_WIDTH=80
PORT_FILE="/tmp/opencode-port"

free_port() {
  python3 -c 'import socket; s=socket.socket(); s.bind(("",0)); print(s.getsockname()[1]); s.close()'
}

OPENCODE_BIN="${OPENCODE_BIN:-$HOME/.nix-profile/bin/opencode}"
if [[ ! -x "$OPENCODE_BIN" ]]; then
  OPENCODE_BIN=$(command -v opencode)
fi

opencode_pane=$(tmux list-panes -F '#{pane_id} #{pane_start_command}' | grep "opencode" | awk '{print $1}')

if [[ -n "$opencode_pane" ]]; then
  tmux kill-pane -t "$opencode_pane"
  rm -f "$PORT_FILE"
else
  pane_path=$(tmux display-message -p '#{pane_current_path}')
  port=$(free_port)
  echo "$port" >"$PORT_FILE"
  tmux split-window -h -l "$PANE_WIDTH" -c "$pane_path" "$OPENCODE_BIN --port $port; rm -f $PORT_FILE"
fi
