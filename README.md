# Dotfiles

Mac Settings


## Install 

```sh
git clone --recursive https://github.com/marso34/dotfiles ~/.dotfiles
cd ~/.dotfiles

chmod +x bootstrap.sh
./bootstrap.sh
```

## Brewfile

```ruby
#...

# Brewfile에서 필요한 파일의 주석 지우고 실행
eval(File.read(File.expand_path("Brewfiles/Brewfile.cask")))
# eval(File.read(File.expand_path("Brewfiles/Brewfile.mas")))
# eval(File.read(File.expand_path("Brewfiles/Brewfile.personal")))
```

<br>

<details>
  <summary>brewfile</summary>

  ```ruby
  # brewfile 생성
  brew bundle dump --describe # --describe 자동 주석
  # 지정된 이름으로 brewfile 생성
  brew bundle dump --describe --file='name'

  # brefile 설치
  brew bundle install
  # 특정 이름 brewfile 설치
  brew bundle install --file name
  ```
</details>



