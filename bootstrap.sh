#!/bin/bash

set -e

main() {
    make_symlinks
    ensure_has_rosetta
    ensure_has_homebrew
    ensure_has_oh_my_zsh
}

# 명령어가 시스템에 존재하는지 확인
bin_exists() {
    command -v $1 >/dev/null 2>&1
}

# Homebrew 설치
ensure_has_homebrew() {
    printf '📦 Checking for homebrew... '
    bin_exists brew && printf 'found\n' || {
        printf 'installing\n'
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        echo "🔄 Update..."
        brew update

        echo "📦 Brewfile installation..."
        brew bundle install
    }
}

# Apple Silicon에서 Rosetta 2 설치
ensure_has_rosetta() {
    printf '💻 Checking for Rosetta 2... '
    /usr/bin/pgrep -q oahd && printf 'found\n' || {
        printf 'installing\n'
        sudo softwareupdate --install-rosetta --agree-to-license
    }
}

# Oh My Zsh 설치
ensure_has_oh_my_zsh() {
    printf '💻 Checking for Oh My Zsh... '
    [[ -d "$HOME/.oh-my-zsh" ]] && printf 'found\n' || {
        printf 'installing\n'
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    }
}

# 심볼릭 링크를 생성하는 함수 (이미 존재하면 무시)
symlink_unless_present() {
    src="$1"
    dest="$2"

    if [ ! -e "$dest" ]; then
        ln -sf "$src" "$dest"
        echo "Linked -sf $src to $dest"
    else
        echo "$dest already exists! Skipping..."
    fi
}

# 심볼릭 링크를 만드는 함수, 나중에 자동화
make_symlinks() {
    # ln -sf ~/.dotfiles/.config/gh/config.yml ~/.config/gh/config.yml
    # ln -sf ~/.dotfiles/.config/git/.gitconfig ~/.gitconfig
    # ln -sf ~/.dotfiles/.config/zsh/.zshenv ~/.zshenv

    symlink_unless_present "$DOTFILES_DIR/.config/gh/config.yml" "$DEST_DIR/.config/gh/config.yml"
    symlink_unless_present "$DOTFILES_DIR/.config/git/.gitconfig" "$DEST_DIR/.gitconfig"
    symlink_unless_present "$DOTFILES_DIR/.config/zsh/.zshenv" "$DEST_DIR/.zshenv"
}

# 변수 설정
DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$0")}"
DEST_DIR="${DEST_DIR:-$HOME}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

# main 함수 실행
main