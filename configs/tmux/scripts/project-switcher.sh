#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
  selected=$1
else
  open_windows=$'\n'$(tmux list-windows -F '#{window_name}')$'\n'
  selected=$({
    printf '[New Tab]\t[New Tab]\n'
    printf '[Close Current Window]\t[Close Current Window]\n'
    {
      [[ -d "$HOME/.dots" ]] && echo "$HOME/.dots"
      [[ -d "$HOME/work" ]] && find -L "$HOME/work" -mindepth 1 -maxdepth 1 -type d | sort
      [[ -d "$HOME/Documents" ]] && find -L "$HOME/Documents" -mindepth 1 -maxdepth 1 -type d | sort
    } | while read -r dir; do
      name=${dir##*/}
      mark=" "
      [[ $open_windows == *$'\n'"${name#.}"$'\n'* ]] && mark="●"
      printf '%s\t\t%s\t%s\n' "$dir" "$dir" "$mark"
    done | ~/.tmux/scripts/nest-worktrees.sh | awk '
      BEGIN { FS = "\t" }
      { name = $2; if ($1 != "") sub(/.*\//, "", name); print $2 "\t" $3 " " $1 name }'
  } | fzf-tmux -p 70%,60% \
    --select-1 --exit-0 --no-sort --ansi --delimiter '\t' --with-nth 2 --accept-nth 1 \
    --border=rounded --border-label ' ⌂ projects ' --border-label-pos 3 \
    --prompt '  ' \
    --header '↵ open tab · ● already open · esc close' \
    --bind 'tab:down,btab:up' \
    --preview-window 'right:50%,border-left' \
    --preview 'd={1}; if [ -d "$d" ]; then cd "$d" && { git status -sb 2>/dev/null | head -5; echo; ls -A1 | head -30; } else echo; fi')
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
