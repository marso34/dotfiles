if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path : Dotfiles, oh-my-zsh, pluggins
export DOTFILES=$HOME/.dotfiles
export CONFIG="$DOTFILES/.config"
export ZSH="$HOME/.oh-my-zsh"
export ZSH_PLUGINS="$CONFIG/zsh/plugins"

HIST_STAMPS="yyyy-mm-dd"

ZSH_CUSTOM="$CONFIG/zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

[[ ! -f $CONFIG/zsh/.p10k.zsh ]] || source $CONFIG/zsh/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export PATH="$JAVA_HOME/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk@17/include"
