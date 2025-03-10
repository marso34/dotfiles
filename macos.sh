#!/bin/bash

# Dock 자동 숨김 (& 속도)
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.02

# Dock 최근 앱 개수
defaults write com.apple.dock show-recents -bool true  
defaults write com.apple.dock show-recent-count -int 5

# 런치패드 아이콘 크기 조절
defaults write com.apple.dock springboard-columns -int 8
defaults write com.apple.dock springboard-rows -int 5

# 키 반복 속도 증가
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 10

# Finder 설정: 확장자 항상 보이기
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# 변경 사항 적용
killall Dock
killall Finder

echo "✅ macOS 설정 완료!"
