# dotfiles
Mac Settings && Brewfile && .zshrc

<br>

## 맥 초기 세팅 명령어 

```
# 맥 독 최근 앱 개수
defaults write com.apple.dock show-recents -bool true; defaults write com.apple.dock show-recent-count -int 5; killall Dock

# 런치패드 아이콘 크기 조절
defaults write com.apple.dock springboard-columns -int 8
defaults write com.apple.dock springboard-rows -int 5
killall Dock

# 독 자동 가리기 속도
defaults write com.apple.dock autohide -bool true && defaults write com.apple.dock autohide-delay -float 0 && defaults write com.apple.dock autohide-time-modifier -float 0.02 && killall Dock

# 키보드 입력 속도 (일단 사용 안 함)
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1

# 키보드 입력 속도 초기화
defaults write -g ApplePressAndHoldEnabled -bool true
defaults write -g InitialKeyRepeat -int 25
defaults write -g KeyRepeat -int 6
```

<br>

## Brewfile

```
# brewfile 생성
# --describe 자동 주석
ㅊ

# 지정된 이름으로 brewfile 생성
brew bundle dump --describe --file='name'

# brefile 설치
brew bundle install

# 특정 이름 brewfile 설치
$ brew bundle install --file name
```
