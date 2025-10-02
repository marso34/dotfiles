if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path : config, oh-my-zsh, pluggins
export CONFIG="$HOME/.dotfiles/.config"
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$CONFIG/zsh"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# OpenSSH
export PATH="$(brew --prefix openssh)/bin:$PATH"

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/Sdk"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

# Docker Desktop
fpath=(/Users/thought/.docker/completions $fpath)

# --------- Zsh Options --------- #
HIST_STAMPS="yyyy-mm-dd"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

[[ ! -f $CONFIG/zsh/.p10k.zsh ]] || source $CONFIG/zsh/.p10k.zsh

# --- zsh pluggins ---

# zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
