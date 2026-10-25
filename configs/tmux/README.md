# tmux

Base: [Oh my tmux!](https://github.com/gpakosz/.tmux) — `.tmux.conf` is upstream verbatim; all customization lives in `.tmux.conf.local`.

- `C-a` prefix (not `C-b`)
- Vim-style pane navigation (`C-hjkl`, nvim-aware)
- `C-f` sesh session picker (active sessions + ~/work projects)
- `w` fzf tab picker with pane preview; git worktree tabs nest under their main checkout's tab
- `n` project switcher, sorted, with git worktrees nested under their main checkout
- `g` lazygit, `k` k9s, `o` pi popup
