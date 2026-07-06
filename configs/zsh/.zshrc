# ── Source Config ─────────────────────────────────────────────────────────────
[[ -f ~/.zshfn ]] && source ~/.zshfn

# ── Shell Options ─────────────────────────────────────────────────────────────
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# ── Zinit ─────────────────────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# Distinct prompt marker so my shell input stands out from pi/agent output.
MNML_USER_CHAR='λ'
zinit light subnixr/minimal

# Turbo-loaded plugins (load after prompt renders)
zinit wait lucid light-mode for \
  Aloxaf/fzf-tab \
  zsh-users/zsh-completions \
  atload"_zsh_autosuggest_start" zsh-users/zsh-autosuggestions \
  zsh-users/zsh-history-substring-search \
  atinit"zicompinit; zicdreplay" zdharma-continuum/fast-syntax-highlighting

# ── Vi Mode ───────────────────────────────────────────────────────────────────
bindkey -v
export KEYTIMEOUT=1

zle-line-init() { zle reset-prompt }
zle-keymap-select() { zle reset-prompt }
zle -N zle-line-init
zle -N zle-keymap-select

# ── Tool Activation ───────────────────────────────────────────────────────────
eval "$(zoxide init zsh --cmd cd)"
eval "$(mise activate zsh)"

# ── External Sources ──────────────────────────────────────────────────────────
source <(fzf --zsh 2>/dev/null)
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
[[ -f ~/.dots-work/zshrc ]] && source ~/.dots-work/zshrc
export PATH="$HOME/.local/bin:$PATH"
