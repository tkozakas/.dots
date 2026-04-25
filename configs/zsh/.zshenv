# ── Secrets ────────────────────────────────────────────────────────────────────
[[ -f ~/.config/secrets ]] && source ~/.config/secrets

# ── Paths ─────────────────────────────────────────────────────────────────────
typeset -U path
export PATH="$HOME/go/bin:$HOME/.local/bin:$HOME/.local/bin/git-scripts:$HOME/.cargo/bin:$HOME/.bun/bin:$HOME/.dots:$PATH"

export BUN_INSTALL="$HOME/.bun"
export EDITOR="nvim"

# Make opencode pick up the active theme via the current-theme symlink.
export OPENCODE_TUI_CONFIG="$HOME/.config/current-theme/tui.json"

# ── History ───────────────────────────────────────────────────────────────────
export HISTFILE=~/.zsh_history
export HISTSIZE=50000
export SAVEHIST=100000

# ── Tool Config ───────────────────────────────────────────────────────────────
export DIRENV_LOG_FORMAT=""
export FZF_DEFAULT_OPTS='--height 40% --tmux bottom,40% --layout reverse --border=none'
