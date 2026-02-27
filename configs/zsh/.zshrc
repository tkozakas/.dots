# ── Source Config ─────────────────────────────────────────────────────────────
[[ -f ~/.zshfn ]] && source ~/.zshfn

# ── Plugins ───────────────────────────────────────────────────────────────────
if [[ ! -d "${ZPLUG_HOME:-$HOME/.zplug}" ]]; then
  git clone https://github.com/zplug/zplug "${ZPLUG_HOME:-$HOME/.zplug}"
fi
source "${ZPLUG_HOME:-$HOME/.zplug}/init.zsh"

zplug "subnixr/minimal", as:theme, depth:1
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions", defer:2
zplug "zsh-users/zsh-completions", defer:2
zplug "zsh-users/zsh-history-substring-search", defer:2

! zplug check && zplug install

# ── Vi Mode ───────────────────────────────────────────────────────────────────
bindkey -v
export KEYTIMEOUT=1

zle-line-init() { zle reset-prompt }
zle-keymap-select() { zle reset-prompt }
zle -N zle-line-init
zle -N zle-keymap-select

# ── Load Plugins & Completions ────────────────────────────────────────────────
zplug load

autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qNmh+24) ]]; then
  compinit -i
else
  compinit -C -i
fi

# ── Keybindings ───────────────────────────────────────────────────────────────
bindkey '^R' fzf-history-widget
bindkey '^T' fzf-file-widget
bindkey '\ec' fzf-cd-widget

# ── Tool Activation ──────────────────────────────────────────────────────────
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
eval "$(mise activate zsh)"

# ── External Sources ──────────────────────────────────────────────────────────
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
[[ -f "${DEVTOOLS_PATH:-$HOME/vinted/dev-tools}/bin/shell_function.sh" ]] && \
  source "${DEVTOOLS_PATH:-$HOME/vinted/dev-tools}/bin/shell_function.sh"
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
