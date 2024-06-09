# mac_settings
Mac Settings && Brewfile && .zshrc

<br>


## 맥북 초기 세팅 명령어 

```
# 맥 독 최근 앱 개수
defaults write com.apple.dock show-recents -bool true; defaults write com.apple.dock show-recent-count -int 5; killall Dock

# 런치패드 아이콘 크기 조절
defaults write com.apple.dock springboard-columns -int 8
defaults write com.apple.dock springboard-rows -int 5

# 런치패드 초기화
killall Dock

# 독 자동 가리기 속도
defaults write com.apple.dock autohide -bool true && defaults write com.apple.dock autohide-delay -float 0 && defaults write com.apple.dock autohide-time-modifier -float 0.02 && killall Dock
```

