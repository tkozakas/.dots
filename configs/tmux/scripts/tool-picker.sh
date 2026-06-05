#!/usr/bin/env bash

selected=$(printf 'lazygit\nk9s' | fzf --prompt="tool: " --layout=reverse --border=rounded)

[[ -z "$selected" ]] && exit 0

case "$selected" in
    lazygit) exec lazygit ;;
    k9s)     exec k9s ;;
esac
