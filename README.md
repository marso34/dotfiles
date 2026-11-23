# Dotfiles

macOS + Windows(WSL2) 설정

| 경로 | 내용 |
| --- | --- |
| `.config/` | macOS 설정 + 공유 설정(`git`, `gh`) |
| `Brewfile`, `Brewfiles/`, `.macos`, `bootstrap.sh` | macOS 전용 |
| `wsl/` | WSL2(Ubuntu) 개발 환경 |
| `windows/` | Windows 기본 앱 제거, GUI 앱(winget), `.wslconfig` |

<br>

# macOS


## Install 

```sh
git clone --recursive https://github.com/marso34/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

chmod +x bootstrap.sh
chmod +x .macos
./bootstrap.sh          # 기본 프로파일(full)로 설치
./.macos
```

<br>

## 설치 프로파일

| 프로파일 | 설치 범위 |
| --- | --- |
| `personal` | 공통 앱 + 개인용 앱 + 폰트 |
| `work` | 공통 앱 + 업무/개발용 앱 + 폰트 |
| `full` | 공통 앱 + 업무 + 개인용 앱 + 폰트 (기본값) |
| `ci` | brew 포뮬러만 (cask · 폰트 · App Store 전부 스킵) |

프로파일은 **인자 → 환경변수 → 기본값(`full`)** 순

```sh
# 1) 인자로 지정
./bootstrap.sh work

# 2) 환경변수로 지정
DOTFILES_PROFILE=work ./bootstrap.sh
```

> `bootstrap.sh`는 받은 프로파일을 `HOMEBREW_DOTFILES_PROFILE`로 변환해 `brew bundle`에 전달.

> Mac App Store 앱(`Brewfiles/Brewfile.mas`)은 `ci`를 제외한 모든 프로파일에서 best-effort로 설치

<br>

## Brewfile

`Brewfile`이 프로파일 값(`DOTFILES_PROFILE`)에 따라 아래 파일들을 분기 로드. `bootstrap.sh`가 알아서 처리하므로 직접 건드릴 필요가 없음

| 파일 | 내용 |
| --- | --- |
| `Brewfiles/Brewfile.fonts` | 폰트 |
| `Brewfiles/Brewfile.common` | 공통 앱 (cask) |
| `Brewfiles/Brewfile.work` | 업무/개발용 앱 |
| `Brewfiles/Brewfile.personal` | 개인용 앱 |
| `Brewfiles/Brewfile.mas` | Mac App Store 앱 (bootstrap이 별도 설치) |


```sh
# 특정 프로파일로 직접 설치
HOMEBREW_DOTFILES_PROFILE=work brew bundle install --file Brewfile
```

<br>

<details>
  <summary>brewfile</summary>

  ```ruby
  # brewfile 생성
  brew bundle dump
  # 지정된 이름으로 brewfile 생성
  brew bundle dump --file='name'

  # brefile 설치
  brew bundle install
  # 특정 이름 brewfile 설치
  brew bundle install --file name
  ```
</details>

<br>

# Windows (WSL2)

Windows는 화면(브라우저, IDE UI)만 담당하고 코드 저장 · 빌드 · 실행 · Docker는 전부 WSL2 Ubuntu 안에서 처리

## Install

```powershell
# 1) 관리자 PowerShell — 설치 후 재부팅
wsl --install
# 특정 배포판으로 설치
wsl --install -d Ubuntu-24.04
```

재부팅 후 Ubuntu가 열리면 사용자 이름 · 비밀번호 생성

```sh
# 2) WSL(Ubuntu) 안에서
git clone https://github.com/marso34/dotfiles.git ~/.dotfiles
~/.dotfiles/wsl/install.sh          # 기본 프로파일(full)로 설치
```

```powershell
# 3) PowerShell — wsl.conf, .wslconfig 적용
wsl --shutdown
```

이후 SSH 키 등록, 원격 SSH 변경 등 남은 작업은 `install.sh` 마지막에 출력

> 프로파일은 macOS와 동일 (`personal` | `work` | `full` | `ci`), 인자 → `DOTFILES_PROFILE` → `full` 순

> WSL에서는 서브모듈(zsh 플러그인, p10k)이 필요 없으므로 `--recursive` 없이 클론

> `install.sh`는 apt 기반 배포판(Ubuntu, Debian) 기준


<br>

## 설치 내용

| 위치 | 내용 | 파일 |
| --- | --- | --- |
| WSL | apt 패키지 | `wsl/apt-packages.txt` |
| WSL | gh(공식 apt 저장소), SDKMAN, uv, nvm(+Node LTS), act | `wsl/install.sh` |
| WSL | Claude Code, Codex (`work` · `full`) | `wsl/install.sh` |
| WSL | `/etc/wsl.conf`: `systemd=true`, `appendWindowsPath=false` | `wsl/install.sh` |
| WSL | `~/.gitconfig` → macOS 설정 include + WSL 덮어쓰기 | `wsl/.gitconfig` |
| WSL | `~/.bashrc` 끝에 source 한 줄 추가 (Ubuntu 기본 `.bashrc` 유지) | `wsl/.bashrc` |
| Windows | 기본 앱 제거 (날씨, 뉴스, 지도, 피드백 허브, Xbox, Clipchamp) | `windows/remove-apps.txt` |
| Windows | GUI 앱 (`winget configure`) | `windows/apps.ps1`, `windows/winget/*.winget` |
| Windows | `%UserProfile%\.wslconfig` (mirrored 네트워크 등) | `windows/.wslconfig` |

| 프로파일 | winget 파일 (Brewfile 대응) |
| --- | --- |
| `personal` | `common` + `personal` |
| `work` | `common` + `work` |
| `full` | `common` + `work` + `personal` |
| `ci` | 없음 (Windows 단계 전체 스킵) |

> 앱 목록 변경: 설치는 `windows/winget/*.winget`, 제거는 `windows/remove-apps.txt`(Appx 패키지 이름, 한 줄에 하나)를 수정. Xbox 로그인 · Game Bar 관련 패키지는 게임에 필요할 수 있어 주석으로 유지

```powershell
# Windows 앱만 다시 정리/설치 (PowerShell)
powershell -NoProfile -ExecutionPolicy Bypass -File \\wsl.localhost\<배포판>\home\<user>\.dotfiles\windows\apps.ps1 work
```

> UNC 경로 실행이 실행 정책에 막히면 `windows` 폴더를 Windows 로컬로 복사 후 실행 (`install.sh`는 `%TEMP%`로 복사해 실행)

<br>

## 참고

- **Docker**: Windows의 Docker Desktop(`work`)을 사용하고 WSL 안에는 Docker Engine을 설치하지 않음. WSL 연동은 기본 배포판에 자동 적용 (`install.sh`가 현재 배포판을 기본으로 지정)
  - 첫 실행 시 약관 동의, `Settings > General > Start Docker Desktop when you sign in` 켜기
  - 직원 250명 초과 또는 매출 1천만 달러 초과 기업의 업무용은 유료 구독 필요
- **코드 위치**: `~/dev/{personal,work,etc}` (WSL 파일시스템). `/mnt/c` 아래는 느리고 bind mount 성능도 나쁨
- **gh**: `config.yml`만 링크. WSL에는 키링이 없어 `hosts.yml`에 토큰이 평문 저장될 수 있으므로 저장소에 링크하지 않음
- **Windows PATH**: `appendWindowsPath=false`라 `code`(VS Code), Docker 자격 증명 도우미만 `wsl/.bashrc`에서 추가, `open .` → 탐색기

<br>

## 추후 작업

- [ ] 폰트 설치 (D2Coding, Pretendard, IBM Plex Mono, 나눔고딕코딩, JetBrains Mono) — winget에 없는 폰트는 다운로드 스크립트 필요
- [ ] Windows Terminal 설정 — fragment(`%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\`)로 Ubuntu 프로필 글꼴 · 색 구성 지정 (폰트 작업 이후)
