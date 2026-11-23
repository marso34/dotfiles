#!/usr/bin/env bash
#
# WSL2(Ubuntu) 개발 환경 설치 — Windows 쪽(기본 앱 제거, GUI 앱, .wslconfig)도 여기서 처리
#
#   git clone https://github.com/marso34/dotfiles.git ~/.dotfiles
#   ~/.dotfiles/wsl/install.sh [personal|work|full|ci]
#
# 여러 번 실행해도 안전 (이미 설치된 것은 건너뜀)

set -Eeuo pipefail
trap 'printf "\n❌ 오류 발생: %s (줄 %d)\n" "$BASH_COMMAND" "$LINENO"' ERR

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
WSL_DIR="$DOTFILES_DIR/wsl"
WIN_DIR="$DOTFILES_DIR/windows"

# 설치 프로파일 (인자 > 환경변수 > 기본값) — macOS bootstrap.sh와 동일
PROFILE="${1:-${DOTFILES_PROFILE:-full}}"

case "$PROFILE" in
    personal|work|full|ci) ;;
    *)
        printf '❌ 알 수 없는 프로파일: %s (사용 가능: personal | work | full | ci)\n' "$PROFILE"
        exit 1
        ;;
esac

NVM_VERSION="v0.41.0"

# 설치 스크립트들이 ~/.bashrc에 PATH를 추가하지 않도록 미리 포함
export PATH="$HOME/.local/bin:$PATH"

main() {
    ensure_sudo
    ensure_dirs

    # 시스템 패키지
    install_apt
    install_gh
    check_no_docker_engine
    configure_wsl_conf

    # 링크 / 셸
    make_links

    # 언어, 개발 도구
    install_sdkman
    install_uv
    install_nvm
    install_act
    if has_work; then
        install_claude_code
        install_codex
    fi

    # Windows 쪽 (기본 앱 제거, GUI 앱, .wslconfig)
    setup_windows

    print_next_steps
}

# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

bin_exists() {
    command -v "$1" >/dev/null 2>&1
}

is_wsl() {
    grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null
}

has_work() {
    [[ "$PROFILE" == "work" || "$PROFILE" == "full" ]]
}

# INI 파일의 [section] key=value 설정 (섹션/키가 없으면 추가, 있으면 값 교체)
ini_set() {
    local file="$1" section="$2" key="$3" value="$4"

    sudo touch "$file"
    if ! grep -q "^\[$section\]" "$file"; then
        printf '\n[%s]\n%s=%s\n' "$section" "$key" "$value" | sudo tee -a "$file" >/dev/null
    elif sed -n "/^\[$section\]/,/^\[/p" "$file" | grep -q "^[[:space:]]*${key}[[:space:]]*="; then
        sudo sed -i "/^\[$section\]/,/^\[/ s|^[[:space:]]*${key}[[:space:]]*=.*|$key=$value|" "$file"
    else
        sudo sed -i "/^\[$section\]/a $key=$value" "$file"
    fi
}

# 기존 파일이 링크가 아니면 백업 후 링크
make_symlink() {
    local src="$1" dest="$2"

    mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" && ! -L "$dest" ]]; then
        mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
        printf '📦 Backed up %s\n' "$dest"
    fi
    ln -sfn "$src" "$dest"
    printf '🔗 Linked %s → %s\n' "$src" "$dest"
}

# ---------------------------------------------------------------------------
# steps
# ---------------------------------------------------------------------------

# sudo 비밀번호를 한 번만 묻고 스크립트가 끝날 때까지 유지
ensure_sudo() {
    printf '🔑 sudo 권한 확인...\n'
    sudo -v
    while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
}

ensure_dirs() {
    local d
    for d in "dev/personal" "dev/work" "dev/etc" ".local/bin" ".config/dotfiles"; do
        if [[ ! -d "$HOME/$d" ]]; then
            mkdir -p "$HOME/$d"
            printf '📁 Created directory %s\n' "$HOME/$d"
        fi
    done
}

install_apt() {
    local pkgs=()
    mapfile -t pkgs < <(grep -vE '^[[:space:]]*(#|$)' "$WSL_DIR/apt-packages.txt")

    printf '📦 apt packages (%d)...\n' "${#pkgs[@]}"
    sudo apt-get update -y
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${pkgs[@]}"
}

# GitHub CLI — Ubuntu 기본 저장소 버전이 오래되어 공식 apt 저장소 사용
install_gh() {
    printf '🐙 Checking for gh... '
    bin_exists gh && { printf 'found\n'; return; }
    printf 'installing\n'

    local keyring=/etc/apt/keyrings/githubcli-archive-keyring.gpg
    local tmp
    tmp="$(mktemp)"
    sudo mkdir -p -m 755 /etc/apt/keyrings
    wget -nv -O "$tmp" https://cli.github.com/packages/githubcli-archive-keyring.gpg
    sudo install -m 644 "$tmp" "$keyring"
    rm -f "$tmp"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=$keyring] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt-get update -y
    sudo apt-get install -y gh
}

# Docker는 Windows의 Docker Desktop을 사용 — WSL 안의 Engine/CLI는 충돌 원인
check_no_docker_engine() {
    local p
    for p in docker-ce docker.io docker-ce-cli; do
        if dpkg -s "$p" >/dev/null 2>&1; then
            printf '⚠️  WSL에 %s가 설치되어 있습니다. Docker Desktop과 충돌할 수 있어 제거를 권장합니다\n' "$p"
        fi
    done
}

configure_wsl_conf() {
    is_wsl || return 0

    printf '🐧 Configuring /etc/wsl.conf... '
    ini_set /etc/wsl.conf boot systemd true
    ini_set /etc/wsl.conf interop appendWindowsPath false
    printf 'done\n'
}

make_links() {
    # git: macOS 설정을 include하는 WSL용 설정
    make_symlink "$WSL_DIR/.gitconfig" "$HOME/.gitconfig"

    # gh: config.yml만 링크 (hosts.yml은 WSL에서 토큰이 평문으로 기록될 수 있음)
    make_symlink "$DOTFILES_DIR/.config/gh/config.yml" "$HOME/.config/gh/config.yml"

    # bash: Ubuntu 기본 ~/.bashrc는 유지하고 끝에 source 한 줄만 추가
    local line="[ -f \"$WSL_DIR/.bashrc\" ] && . \"$WSL_DIR/.bashrc\""
    touch "$HOME/.bashrc"
    if ! grep -qF "$line" "$HOME/.bashrc"; then
        printf '\n# dotfiles\n%s\n' "$line" >>"$HOME/.bashrc"
        printf '🔗 Added dotfiles source line to %s\n' "$HOME/.bashrc"
    fi
}

install_sdkman() {
    printf '☕ Checking for SDKMAN! ... '
    [[ -d "$HOME/.sdkman" ]] && { printf 'found\n'; return; }
    printf 'installing\n'
    curl -fsSL "https://get.sdkman.io?rcupdate=false" | bash
}

install_uv() {
    printf '🐍 Checking for uv... '
    bin_exists uv && { printf 'found\n'; return; }
    printf 'installing\n'
    curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
}

install_nvm() {
    printf '🟢 Checking for nvm... '
    if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
        printf 'found\n'
    else
        printf 'installing\n'
        curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | PROFILE=/dev/null bash
    fi

    # Node LTS (nvm은 set -u와 호환되지 않음)
    set +u
    # shellcheck disable=SC1091
    . "$HOME/.nvm/nvm.sh"
    if ! nvm ls --no-colors 'lts/*' >/dev/null 2>&1; then
        nvm install --lts
    fi
    set -u
}

# GitHub Actions 로컬 실행 (Brewfile 대응)
install_act() {
    printf '🎬 Checking for act... '
    bin_exists act && { printf 'found\n'; return; }
    printf 'installing\n'
    curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh \
        | bash -s -- -b "$HOME/.local/bin"
}

install_claude_code() {
    printf '🤖 Checking for Claude Code... '
    bin_exists claude && { printf 'found\n'; return; }
    printf 'installing\n'
    curl -fsSL https://claude.ai/install.sh | bash
}

install_codex() {
    printf '🤖 Checking for Codex... '
    bin_exists codex && { printf 'found\n'; return; }
    printf 'installing\n'
    curl -fsSL https://chatgpt.com/codex/install.sh | sh
}

# ---------------------------------------------------------------------------
# Windows
# ---------------------------------------------------------------------------

setup_windows() {
    if [[ "$PROFILE" == "ci" ]] || ! is_wsl; then
        printf '🪟 Windows 설정 건너뜀 (profile: %s, WSL: %s)\n' "$PROFILE" "$(is_wsl && echo yes || echo no)"
        return 0
    fi

    # appendWindowsPath=false라 Windows 프로그램은 절대 경로로 호출
    local win_sys cmd ps wsl_exe
    win_sys="$(wslpath -u 'C:\Windows')"
    cmd="$win_sys/System32/cmd.exe"
    ps="$win_sys/System32/WindowsPowerShell/v1.0/powershell.exe"
    wsl_exe="$win_sys/System32/wsl.exe"

    # Windows 환경변수
    # - 현재 폴더가 WSL 경로면 cmd.exe가 경고하므로 Windows 폴더에서 실행
    # - 한글 사용자명이 OEM 코드페이지(CP949)로 깨지지 않도록 UTF-8(65001)로 출력
    win_env() {
        (cd "$win_sys" && "$cmd" /d /c "chcp 65001 >nul & echo %$1%" 2>/dev/null | tr -d '\r') || true
    }

    local win_userprofile win_temp win_programfiles
    win_userprofile="$(win_env USERPROFILE)"
    win_temp="$(win_env TEMP)"
    win_programfiles="$(win_env ProgramFiles)"

    # 조회 실패 시 잘못된 경로에 쓰거나 지우지 않도록 중단
    local win_home win_temp_u win_programfiles_u
    win_home="$(wslpath -u "$win_userprofile" 2>/dev/null || true)"
    win_temp_u="$(wslpath -u "$win_temp" 2>/dev/null || true)"
    win_programfiles_u="$(wslpath -u "$win_programfiles" 2>/dev/null || true)"
    if [[ -z "$win_userprofile" || -z "$win_temp" || ! -d "$win_home" || ! -d "$win_temp_u" ]]; then
        printf '⚠️  Windows 경로 조회 실패 (USERPROFILE=%s, TEMP=%s) — Windows 설정 건너뜀\n' "$win_userprofile" "$win_temp"
        return 0
    fi

    # 머신별 값 → ~/.config/dotfiles/env.sh (저장소 밖, wsl/.bashrc가 읽음)
    cat >"$HOME/.config/dotfiles/env.sh" <<EOF
# wsl/install.sh가 생성 — 머신별 Windows 경로
export WIN_HOME="$win_home"
export WIN_SYSROOT="$win_sys"
export WIN_PROGRAMFILES="$win_programfiles_u"
EOF
    printf '📝 Wrote %s\n' "$HOME/.config/dotfiles/env.sh"

    # .wslconfig (다르면 백업 후 복사)
    local wslconfig="$win_home/.wslconfig"
    if [[ ! -f "$wslconfig" ]] || ! cmp -s "$WIN_DIR/.wslconfig" "$wslconfig"; then
        [[ -f "$wslconfig" ]] && cp "$wslconfig" "$wslconfig.bak.$(date +%Y%m%d%H%M%S)"
        cp "$WIN_DIR/.wslconfig" "$wslconfig"
        printf '📄 Copied .wslconfig → %s\n' "$wslconfig"
    fi

    # 현재 배포판을 기본으로 (Docker Desktop WSL 연동이 기본 배포판에 자동 적용됨)
    if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
        "$wsl_exe" --set-default "$WSL_DISTRO_NAME" >/dev/null 2>&1 \
            && printf '🐧 Default WSL distro: %s\n' "$WSL_DISTRO_NAME" \
            || printf '⚠️  기본 배포판 설정 실패 — PowerShell에서 wsl --set-default %s\n' "$WSL_DISTRO_NAME"
    fi

    # GUI 앱: \\wsl.localhost 경로에서 .ps1을 직접 실행하지 않고 Windows TEMP로 복사 후 실행
    local stage_win="$win_temp\\dotfiles-windows"
    local stage="$win_temp_u/dotfiles-windows"
    rm -rf "$stage"
    mkdir -p "$stage"
    cp -R "$WIN_DIR/." "$stage/"

    printf '🪟 Windows apps — 기본 앱 제거 + GUI 앱 설치 (best-effort, UAC 창이 뜰 수 있음)...\n'
    (cd "$win_sys" && "$ps" -NoProfile -ExecutionPolicy Bypass -File "$stage_win\\apps.ps1" "$PROFILE") \
        || printf '⚠️  일부 Windows 앱 설치 실패 — 건너뛰고 계속합니다 (다시 실행 가능)\n'
}

print_next_steps() {
    cat <<'EOF'

✅ WSL 설치 완료! 남은 수동 작업:

  1. PowerShell에서 `wsl --shutdown` 후 Ubuntu 다시 열기
     (wsl.conf, .wslconfig 적용)

  2. SSH 키 생성 및 GitHub 등록 (인증 + 커밋 서명)
       ssh-keygen -t ed25519
       gh auth login -p ssh -s admin:ssh_signing_key
         → "Upload your SSH public key" 에서 ~/.ssh/id_ed25519.pub 선택 (인증 키 등록)
       gh ssh-key add ~/.ssh/id_ed25519.pub --type signing

  3. dotfiles 원격을 SSH로 변경
       git -C ~/.dotfiles remote set-url origin git@github.com:marso34/dotfiles.git

  4. (work/full) Docker Desktop 실행 → 약관 동의
     → Settings > General > "Start Docker Desktop when you sign in" 켜기
EOF
}

main
