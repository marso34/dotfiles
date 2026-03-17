#!/usr/bin/env zsh

set -e
trap 'printf "\n❌ 오류 발생: %s 줄 %d\n" "$BASH_COMMAND" "$LINENO"' ERR

# 변수 설정
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")" && pwd)}"
HOME_DIR="${HOME_DIR:-$HOME}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
DOC_DIR="${DOC_DIR:-$HOME/Documents}"

main() {
    # 디렉터리 생성
    ensure_dir

    # Git 서브모듈 초기화
    ensure_submodules

    # 필수 프로그램 설치
    ensure_has_rosetta
    ensure_has_homebrew
    ensure_has_oh_my_zsh
    ensure_has_sdkman

    # Brewfile 설치
    install_brewfile

    # 심볼릭 링크 생성
    make_symlinks

    # iTerm2 설정 폴더 지정
    setup_iterm2

    printf '\n✅ Bootstrap 완료!\n'
}

# 명령어가 시스템에 존재하는지 확인
bin_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 디렉터리 생성 함수
ensure_dir() {
    dir=(
        "Dev/personal"
        "Dev/company"
        "Dev/etc"
        "Bruno"
        "Obsidian"
    )

    for d in "${dir[@]}"; do
        dest="$DOC_DIR/$d"

        if [ ! -d "$dest" ]; then
            mkdir -p "$dest"
            printf '📁 Created directory %s\n' "$dest"
        fi
    done
}

# Git 서브모듈 초기화
ensure_submodules() {
    printf '📂 Checking git submodules... '
    git -C "$DOTFILES_DIR" submodule update --init --recursive
    printf 'done\n'
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

# SDKMAN! 설치
ensure_has_sdkman() {
    printf '☕ Checking for SDKMAN! ... '
    [[ -d "$HOME/.sdkman" ]] && printf 'found\n' || {
        printf 'installing\n'
        zsh -o nullglob <(curl -s "https://get.sdkman.io")
    }
}

# Brewfile 설치
install_brewfile() {
    echo "🔄 Update..."
    brew update

    echo "📦 Brewfile installation..."
    brew bundle install --file "$DOTFILES_DIR/Brewfile"
}

# 심볼릭 링크를 강제로 생성하는 함수 (기존 링크를 덮어씀)
make_symlink() {
    src="$1"
    dest="$2"

    ln -sf "$src" "$dest"
    printf '🔗 Linked %s → %s\n' "$src" "$dest"
}

# 심볼릭 링크를 만드는 함수
make_symlinks() {
    # ~/.config에 링크 - "디렉터리" (추가 시 여기에 추가)
    config_links=(
        "gh"
        "karabiner"
    )

    # 홈 디렉터리 링크 — "디렉터리:파일명" (추가 시 여기에 추가)
    home_links=(
        "git:.gitconfig"
        "zsh:.zshenv"
    )

    # config 디렉터리 링크 (디렉터리 내 모든 파일에 대해)
    for name in "${config_links[@]}"; do
        mkdir -p "$HOME_DIR/.config/$name"
        for file in "$DOTFILES_DIR/.config/$name"/*; do
            make_symlink "$file" "$HOME_DIR/.config/$name/$(basename "$file")"
        done
    done

    # 홈 디렉터리 링크 (디렉터리:파일명 - 지정한 파일만)
    for entry in "${home_links[@]}"; do
        dir="${entry%%:*}"
        file="${entry##*:}"
        make_symlink "$DOTFILES_DIR/.config/$dir/$file" "$HOME_DIR/$file"
    done
}

# iTerm2 설정 폴더 지정 (plist 심링크 대신, 앱 실행 중 충돌 방지)
setup_iterm2() {
    printf '🖥️  Setting up iTerm2 preferences folder... '
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/.config/iTerm2"
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    printf 'done\n'
}

# main 함수 실행
main

# # clone git repository (obsidian)
# clone_git_repo() {
#     # 클론할 리포지토리 URL
#     REPO_URL="https://github.com/사용자명/리포지토리명.git"

#     # 클론할 디렉토리 (선택 사항: 기본적으로 리포지토리명으로 클론됨)
#     TARGET_DIR="repo-directory"

#     # 이미 디렉토리가 존재하면 삭제 (주의: 데이터 손실 가능)
#     if [ -d "$TARGET_DIR" ]; then
#         echo "Removing existing directory: $TARGET_DIR"
#         rm -rf "$TARGET_DIR"
#     fi

#     # 리포지토리 클론
#     echo "Cloning repository..."
#     git clone "$REPO_URL" "$TARGET_DIR"

#     echo "Repository cloned successfully!"
# }
