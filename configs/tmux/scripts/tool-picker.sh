#!/usr/bin/env bash

OPENCODE_PORT=$(cat /tmp/opencode-port 2>/dev/null || echo 4096)

selected=$(printf 'lazygit\nk9s\nagent-monitor' | fzf --prompt="tool: " --layout=reverse --border=rounded)

[[ -z "$selected" ]] && exit 0

case "$selected" in
    lazygit)       exec lazygit ;;
    k9s)           exec k9s ;;
    agent-monitor) exec env OPENCODE_URL="http://localhost:$OPENCODE_PORT" agent-monitor ;;
esac
