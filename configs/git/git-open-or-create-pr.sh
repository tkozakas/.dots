#!/bin/bash
set -e

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: Not a git repository." >&2
  exit 1
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')

if [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ]; then
  echo "Error: Cannot create PR from default branch: $CURRENT_BRANCH" >&2
  exit 1
fi

git push --set-upstream origin "$CURRENT_BRANCH" >/dev/null 2>&1

OPEN_PR_COUNT=$(gh pr list --head "$CURRENT_BRANCH" --state open --limit 1 --json url --jq 'length')

if [ "$OPEN_PR_COUNT" -eq 0 ]; then
  gh pr create --fill --web </dev/null
else
  gh pr view --web
fi
