# ── Paths ─────────────────────────────────────────────────────────────────────
typeset -U path
export PATH="$HOME/go/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.rd/bin:$HOME/.bun/bin:$HOME/.dots:$PATH"

export BUN_INSTALL="$HOME/.bun"
export EDITOR="nvim"

# ── History ───────────────────────────────────────────────────────────────────
export HISTFILE=~/.zsh_history
export HISTSIZE=50000
export SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# ── Shell Options ─────────────────────────────────────────────────────────────
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# ── Tool Config ───────────────────────────────────────────────────────────────
export FZF_DEFAULT_OPTS='--height 40% --tmux bottom,40% --layout reverse --border=none'
export MNML_USER_CHAR=''
