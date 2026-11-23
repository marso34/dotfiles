# WSL 셸 설정 — ~/.bashrc 끝에서 source됨 (wsl/install.sh가 한 줄 추가)
# shellcheck disable=SC1090,SC1091  # 런타임에 생기는 파일들을 source
# Ubuntu 기본 ~/.bashrc(색상, 자동완성 등)는 그대로 두고 그 위에 덧붙임

case $- in
    *i*) ;;
    *) return ;;
esac

# install.sh가 생성하는 머신별 값 (WIN_HOME, WIN_SYSROOT, WIN_PROGRAMFILES)
[ -f "$HOME/.config/dotfiles/env.sh" ] && . "$HOME/.config/dotfiles/env.sh"

# --------- History --------- #
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T '
shopt -s histappend

# --------- PATH --------- #
# uv, Claude Code, Codex, act
export PATH="$HOME/.local/bin:$PATH"

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && . "$SDKMAN_DIR/bin/sdkman-init.sh"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# --------- Windows 연동 --------- #
# wsl.conf에서 appendWindowsPath=false → 필요한 Windows 경로만 뒤에 추가
if [ -n "${WIN_HOME:-}" ]; then
    _vscode_bin="$WIN_HOME/AppData/Local/Programs/Microsoft VS Code/bin"
    [ -d "$_vscode_bin" ] && export PATH="$PATH:$_vscode_bin"   # code .
    unset _vscode_bin
fi
if [ -n "${WIN_PROGRAMFILES:-}" ]; then
    # Docker Desktop 자격 증명 도우미(docker-credential-desktop.exe)
    _docker_bin="$WIN_PROGRAMFILES/Docker/Docker/resources/bin"
    [ -d "$_docker_bin" ] && export PATH="$PATH:$_docker_bin"
    unset _docker_bin
fi
if [ -n "${WIN_SYSROOT:-}" ]; then
    alias open='"$WIN_SYSROOT/explorer.exe"'   # open . → 탐색기
fi

# --------- Prompt --------- #
# git 브랜치 표시 (git 패키지에 포함된 스크립트)
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    . /usr/lib/git-core/git-sh-prompt
    PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[33m\]$(__git_ps1 " (%s)")\[\e[0m\]\$ '
fi
