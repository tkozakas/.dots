#!/usr/bin/env bash
# Quick git branch switcher with preview

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Not in a git repository"
    exit 1
fi

# Get current branch
current_branch=$(git branch --show-current)

# Select branch with preview
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

# Switch to branch
if git show-ref --verify --quiet "refs/heads/$branch"; then
    # Local branch exists
    git checkout "$branch"
else
    # Try to checkout remote branch
    git checkout -b "$branch" "origin/$branch" 2>/dev/null || git checkout "$branch"
fi

echo "Switched to branch: $branch"
