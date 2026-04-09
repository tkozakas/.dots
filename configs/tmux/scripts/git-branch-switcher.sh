#!/usr/bin/env bash

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Not in a git repository"
    exit 1
fi

current_branch=$(git branch --show-current)

branch=$(git branch -a | \
  sed 's/^[* ] //' | \
  sed 's/remotes\/origin\///' | \
  sort -u | \
  grep -v "HEAD" | \
  fzf --prompt="Switch to branch: " \
      --height=80% \
      --layout=reverse \
      --border=rounded \
      --header="Current: $current_branch" \
      --preview='git log --oneline --graph --color=always --max-count=30 {}' \
      --preview-window=right:60%:wrap)

if [[ -z $branch ]]; then
    exit 0
fi

if git show-ref --verify --quiet "refs/heads/$branch"; then
    git checkout "$branch"
else
    git checkout -b "$branch" "origin/$branch" 2>/dev/null || git checkout "$branch"
fi

echo "Switched to branch: $branch"
