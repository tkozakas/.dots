[[ -f ~/.zshenv ]] && source ~/.zshenv
[[ -f ~/.zshalias ]] && source ~/.zshalias

if [[ ! -d "${ZPLUG_HOME:-$HOME/.zplug}" ]]; then
    git clone https://github.com/zplug/zplug "${ZPLUG_HOME:-$HOME/.zplug}"
fi

source "${ZPLUG_HOME:-$HOME/.zplug}/init.zsh"

zplug "subnixr/minimal", as:theme, depth:1
zplug "agkozak/zsh-z"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions", defer:2
zplug "zsh-users/zsh-completions", defer:2
zplug "zsh-users/zsh-history-substring-search", defer:2

! zplug check && zplug install

# Enable vi mode BEFORE loading plugins
bindkey -v
export KEYTIMEOUT=1

# Define zle-line-init and zle-keymap-select for vi mode cursor
function zle-line-init zle-keymap-select {
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

zplug load

autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qNmh+24) ]]; then
  compinit -i
else
  compinit -C -i
fi

# Restore fzf keybindings that vi mode overrides
bindkey '^R' fzf-history-widget
bindkey '^T' fzf-file-widget
bindkey '\ec' fzf-cd-widget


[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
{
  [[ -f "${DEVTOOLS_PATH:-$HOME/vinted/dev-tools}/bin/shell_function.sh" ]] && \
    source "${DEVTOOLS_PATH:-$HOME/vinted/dev-tools}/bin/shell_function.sh"
} &

wait

nvm() {
  unset -f nvm node npm
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

node() {
  unset -f nvm node npm
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  node "$@"
}

npm() {
  unset -f nvm node npm
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  npm "$@"
}

sdk() {
  unset -f sdk java gradle maven
  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
  sdk "$@"
}
