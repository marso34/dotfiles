#!/bin/bash

set -e

main() {
    # 필수 프로그램 설치
    ensure_has_rosetta
    ensure_has_homebrew
    ensure_has_oh_my_zsh
    ensure_has_sdkman

    # Brewfile 설치
    install_brewfile

    # 심볼릭 링크 생성
    make_symlinks
}

# 명령어가 시스템에 존재하는지 확인
bin_exists() {
    command -v $1 >/dev/null 2>&1
}

# SDKMAN! 설치
ensure_has_sdkman() {
    printf '☕ Checking for SDKMAN! ... '
    [[ -d "$HOME/.sdkman" ]] && printf 'found\n' || {
        printf 'installing\n'
        curl -s "https://get.sdkman.io" | bash
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

# Homebrew 설치
ensure_has_homebrew() {
    printf '📦 Checking for homebrew... '
    bin_exists brew && printf 'found\n' || {
        printf 'installing\n'
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

# Brewfile 설치
install_brewfile() {
    echo "🔄 Update..."
    brew update

    echo "📦 Brewfile installation..."
    brew bundle install
}

# 심볼릭 링크를 생성하는 함수 (이미 존재하면 무시)
symlink_unless_present() {
    src="$1"
    dest="$2"

    ln -sf "$src" "$dest"
    echo "Linked -sf $src to $dest"
}

# 심볼릭 링크를 만드는 함수, 나중에 자동화
make_symlinks() {
    # ln -sf ~/.dotfiles/.config/gh/config.yml ~/.config/gh/config.yml
    # ln -sf ~/.dotfiles/.config/git/.gitconfig ~/.gitconfig
    # ln -sf ~/.dotfiles/.config/zsh/.zshenv ~/.zshenv

    mkdir -p "$DEST_DIR/.config/gh"

    symlink_unless_present "$DOTFILES_DIR/.config/gh/config.yml" "$DEST_DIR/.config/gh/config.yml"
    symlink_unless_present "$DOTFILES_DIR/.config/git/.gitconfig" "$DEST_DIR/.gitconfig"
    symlink_unless_present "$DOTFILES_DIR/.config/zsh/.zshenv" "$DEST_DIR/.zshenv"
}

# 참고
make_symlinks2() {
    # ignored=("".config ".local" ".git" ".gitignore" ".gitmodules")

    # .dotfiles 디렉토리에서 각 파일을 반복하며 심볼릭 링크를 생성
    # for dotfile in "$DOTFILES_DIR"/*; do
    #     filename=$(basename "$dotfile")
    #     if [[ " ${ignored[@]} " =~ " $filename " ]]; then
    #         continue
    #     fi
    #     dest="$DEST_DIR/$filename"
    #     symlink_unless_present "$dotfile" "$dest"
    # done

    # .config, .local, .local/share 디렉토리 처리
    # for each in ".config" ".local" ".local/share"; do
    #     dotfile_dir="$DOTFILES_DIR/$each"
    #     dest_dir="$DEST_DIR/$each"
    #     if [ ! -e "$dest_dir" ]; then
    #         ln -s "$dotfile_dir" "$dest_dir"
    #         echo "Linked $dotfile_dir to $dest_dir"
    #     else
    #         # 이미 존재하는 경우, 각 파일을 개별적으로 처리
    #         for dotfile in "$dotfile_dir"/*; do
    #             symlink_unless_present "$dotfile" "$dest_dir/$(basename "$dotfile")"
    #         done
    #     fi
    # done

    # bin 디렉토리 처리 (현재는 비어 있음)
    mkdir -p "$BIN_DIR"
    # 추가적인 바이너리 파일을 symlink하려면 이곳에 구현
}

# 변수 설정
DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$0")}"
DEST_DIR="${DEST_DIR:-$HOME}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

# main 함수 실행
main