# ── Source Config ─────────────────────────────────────────────────────────────
[[ -f ~/.zshfn ]] && source ~/.zshfn

# ── Zinit ─────────────────────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

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
eval "$(direnv hook zsh)"
eval "$(mise activate zsh)"

# ── Keybindings ───────────────────────────────────────────────────────────────
bindkey '^R' fzf-history-widget
bindkey '^T' fzf-file-widget
bindkey '\ec' fzf-cd-widget

# ── External Sources ──────────────────────────────────────────────────────────
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
[[ -f "${DEVTOOLS_PATH:-$HOME/vinted/dev-tools}/bin/shell_function.sh" ]] && \
  source "${DEVTOOLS_PATH:-$HOME/vinted/dev-tools}/bin/shell_function.sh"
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
