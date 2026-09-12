#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
  selected=$1
else
  open_windows=$(tmux list-windows -F '#{window_name}')
  selected=$({
    echo "[New Tab]"
    echo "[Close Current Window]"
    {
      [[ -d "$HOME/.dots" ]] && echo "$HOME/.dots"
      [[ -d "$HOME/work" ]] && find -L "$HOME/work" -mindepth 1 -maxdepth 1 -type d
      [[ -d "$HOME/Documents" ]] && find -L "$HOME/Documents" -mindepth 1 -maxdepth 1 -type d
    } | while read -r dir; do
      name=$(basename "$dir" | sed 's/^\.//')
      if grep -qx "$name" <<<"$open_windows"; then
        echo "● $dir"
      else
        echo "  $dir"
      fi
    done
  } | fzf-tmux -p 70%,60% \
    --select-1 --exit-0 --no-sort --ansi \
    --border=rounded --border-label ' ⌂ projects ' --border-label-pos 3 \
    --prompt '  ' \
    --header '↵ open tab · ● already open · esc close' \
    --bind 'tab:down,btab:up' \
    --preview-window 'right:50%,border-left' \
    --preview 'd=$(echo {} | sed "s/^[● ] *//"); if [ -d "$d" ]; then cd "$d" && { git status -sb 2>/dev/null | head -5; echo; ls -A1 | head -30; } else echo; fi')
  selected=$(echo "$selected" | sed 's/^[● ] *//')
fi

if [[ -z $selected ]]; then
  exit 0
fi

if [[ "$selected" == "[New Tab]" ]]; then
  tmux new-window -n "home-$(date +%s)" -c "$HOME"
  exit 0
fi

if [[ "$selected" == "[Close Current Window]" ]]; then
  tmux kill-window
  exit 0
fi

selected_name=$(basename "$selected" | sed 's/^\.//')

if tmux list-windows -F '#{window_name}' | grep -qx "$selected_name"; then
  [[ "$selected_name" == "$(tmux display-message -p '#{window_name}')" ]] && exit 0
  tmux select-window -t "$selected_name"
else
  tmux new-window -n "$selected_name" -c "$selected"
fi
