# Dotfiles

Mac Settings


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
