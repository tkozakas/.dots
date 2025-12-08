#!/bin/bash

set -e

REMOTE="origin"
DEFAULT_BASE_BRANCH="main"
PROTECTED_BRANCHES=("main" "master" "develop" "staging")

if [ -z "$1" ]; then
  echo "Error: No commit message provided."
  echo "Usage: ./git-squash-pr.sh \"Your new commit message\" [base_branch]"
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: Not a git repository."
  exit 1
fi

if ! git diff-index --quiet HEAD --; then
  echo "Error: Working directory is not clean. Please commit or stash your changes."
  exit 1
fi

NEW_COMMIT_MESSAGE="$1"
BASE_BRANCH="${2:-$DEFAULT_BASE_BRANCH}"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$CURRENT_BRANCH" == "$BASE_BRANCH" ]; then
  echo "Error: You are on the base branch ($BASE_BRANCH)."
  exit 1
fi

for branch in "${PROTECTED_BRANCHES[@]}"; do
  if [ "$CURRENT_BRANCH" == "$branch" ]; then
    echo "Error: Attempting to run on a protected branch ($CURRENT_BRANCH). Exiting for safety."
    exit 1
  fi
done

BACKUP_BRANCH="backup/${CURRENT_BRANCH}-$(date +%Y-%m-%d-%H%M%S)"

echo "Starting squash for branch '$CURRENT_BRANCH' against '$BASE_BRANCH'"

git branch "$BACKUP_BRANCH"
echo "Backup created at '$BACKUP_BRANCH'."

git fetch "$REMOTE" "$BASE_BRANCH"

MERGE_BASE=$(git merge-base "origin/$BASE_BRANCH" HEAD)

if [ -z "$MERGE_BASE" ]; then
  echo "Error: Could not find a common ancestor with 'origin/$BASE_BRANCH'."
  exit 1
fi

git reset --soft "$MERGE_BASE"

git commit -m "$NEW_COMMIT_MESSAGE"

echo "Pushing squashed branch to origin..."
git push --force-with-lease "$REMOTE" "$CURRENT_BRANCH"

echo "Success! Your branch has been squashed and pushed."
