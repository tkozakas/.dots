#!/bin/bash
# git config --global core.hooksPath git
# This script runs before a push to check if the push is to main or master.
while read local_ref local_sha remote_ref remote_sha; do
  current_branch=${local_ref#refs/heads/}

  if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
    echo -e "ERROR: Direct push to the protected branch '$current_branch' is blocked by a global hook."
    echo "Push aborted. If you are absolutely sure this is what you want to do, use:"
    echo "  git push --no-verify"
    exit 1
  fi
done

exit 0
