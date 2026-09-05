tap "elgar328/nfd2nfc"
tap "peterldowns/tap"
# Run your GitHub Actions locally
brew "act"
# Emacs dependency management
brew "cask"
# Dependency manager for Cocoa projects
brew "cocoapods"
# Isolated development environments using Docker
brew "docker-compose"
# Play, record, convert, and stream audio and video
brew "ffmpeg"
# GitHub command-line tool
brew "gh"
# Distributed revision control system
brew "git"
# Open source programming language to build simple/reliable/efficient software
brew "go"
# Mac App Store command-line interface
brew "mas"
# Deep clean and optimize your Mac
brew "mole"
# Convert filesystem entry names from NFD to NFC for cross-platform compatibility
brew "nfd2nfc"
# Manage multiple Node.js versions
brew "nvm"
# OpenBSD freely-licensed SSH connectivity tools
brew "openssh"
# Interpreted, interactive, object-oriented programming language
brew "python@3.12"
# Extremely fast Python package installer and resolver, written in Rust
brew "uv"
# Sends magic packets to wake up network-devices
brew "wakeonlan"
# Feature-rich command-line audio/video downloader
brew "yt-dlp"
# Localias is a tool for developers to securely manage local aliases for development servers.
brew "peterldowns/tap/localias", trusted: true

# ── 프로파일 선택 ──
# 사용법: HOMEBREW_DOTFILES_PROFILE=personal|work|full|ci  (기본값: full)
#   personal → 공통 + 개인용 앱 + 폰트
#   work     → 공통 + 업무/개발용 앱 + 폰트
#   full     → 공통 + 업무 + 개인용 앱 + 폰트
#   ci       → brew 포뮬러만 (cask·폰트·mas 전부 스킵 — GUI/App Store 불가)
env_profile = ENV["HOMEBREW_DOTFILES_PROFILE"].to_s.strip
profile = env_profile.empty? ? "full" : env_profile

# 폰트
eval(File.read(File.expand_path("Brewfiles/Brewfile.fonts")))    if profile != "ci"
# 공통 앱 (cask)
eval(File.read(File.expand_path("Brewfiles/Brewfile.common")))   if profile != "ci"
# 프로파일별 cask
eval(File.read(File.expand_path("Brewfiles/Brewfile.work")))     if %w[work full].include?(profile)
eval(File.read(File.expand_path("Brewfiles/Brewfile.personal"))) if %w[personal full].include?(profile)

# Mac App Store(mas)는 bootstrap.sh가 별도 설치
