#!/usr/bin/env bash
# stdin: path<TAB>scope<TAB>payload. stdout: branch<TAB>payload, each main
# checkout followed by its linked worktrees (same scope); others keep input order.

resolve_repo() {
  local dir=$1 gitdir
  repo= linked=
  until [ -e "$dir/.git" ]; do
    [ -n "$dir" ] || return 0
    dir=${dir%/*}
  done
  cd -P -- "$dir" 2>/dev/null || return 0
  if [ -f .git ]; then
    read -r _ gitdir <.git
    case $gitdir in
    */.git/worktrees/*)
      cd -P -- "${gitdir%/.git/worktrees/*}" 2>/dev/null || return 0
      linked=1
      ;;
    esac
  fi
  repo=$PWD
}

while IFS= read -r line; do
  resolve_repo "${line%%$'\t'*}"
  printf '%s\t%s\t%s\n' "$repo" "$linked" "$line"
done | awk '
  BEGIN { FS = OFS = "\t" }
  {
    n++
    linked[n] = $2
    row[n] = $0
    sub(/^[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t/, "", row[n])
    if ($1 == "") next
    group[n] = $4 SUBSEP $1
    if (!linked[n]) has_main[group[n]] = 1
  }
  END {
    for (i = 1; i <= n; i++) {
      g = group[i]
      if (g == "") { print "", row[i]; continue }
      if ((g in shown) || (linked[i] && (g in has_main))) continue
      shown[g] = 1
      for (j = i; j <= n; j++) if (group[j] == g && !linked[j]) print "", row[j]
      m = 0
      for (j = 1; j <= n; j++) if (group[j] == g && linked[j]) wt[++m] = j
      for (k = 1; k <= m; k++) {
        branch = (g in has_main) ? (k < m ? "├─ " : "└─ ") : ""
        print branch, row[wt[k]]
      }
    }
  }'
