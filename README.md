# Dotfiles

Mac Settings

<br>

## Install 

```sh
# mkdir ~/Documents/dev

git clone --recursive https://github.com/marso34/dotfiles ~/.dotfiles
cd ~/.dotfiles

chmod +x bootstrap.sh
./bootstrap.sh
```

## Brewfile

```sh
# brewfile 생성
# --describe 자동 주석
brew bundle dump --describe

# 지정된 이름으로 brewfile 생성
brew bundle dump --describe --file='name'

# brefile 설치
brew bundle install

# 특정 이름 brewfile 설치
brew bundle install --file name
```
