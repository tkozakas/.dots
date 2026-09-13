# ── Secrets ────────────────────────────────────────────────────────────────────
[[ -f ~/.config/secrets ]] && source ~/.config/secrets

# ── Paths ─────────────────────────────────────────────────────────────────────
typeset -U path
export PATH="$HOME/go/bin:$HOME/.local/bin:$HOME/.local/bin/git-scripts:$HOME/.cargo/bin:$HOME/.bun/bin:$HOME/.rd/bin:$HOME/.dots:$PATH:$HOME/.nix-profile/bin"

export BUN_INSTALL="$HOME/.bun"
export EDITOR="nvim"

# ── History ───────────────────────────────────────────────────────────────────
export HISTFILE=~/.zsh_history
export HISTSIZE=50000
export SAVEHIST=100000

# ── Tool Config ───────────────────────────────────────────────────────────────
export DIRENV_LOG_FORMAT=""
export FZF_DEFAULT_OPTS="--height 40% --tmux bottom,40% --layout reverse --border=none \
--pointer '▌' --marker ' ' --info=inline-right --separator '─' \
--color 'bg:#1c1c1c,bg+:#3a3a3a,fg:#c0c0c0,fg+:#eeeeec,hl:#c4a000,hl+:#fce94f' \
--color 'border:#555753,label:#729fcf,prompt:#729fcf,pointer:#fce94f' \
--color 'info:#555753,separator:#3a3a3a,header:#555753,spinner:#c4a000'"
