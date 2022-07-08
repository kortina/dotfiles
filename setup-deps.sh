#!/usr/bin/env bash
set -e

# set -o verbose
echo "##### $(basename $BASH_SOURCE) #####"

DOTFILES_ROOT="`pwd`"
source "$DOTFILES_ROOT/_setup_defs.sh"

# make sure git submodules are up to date
cd $DOTFILES_ROOT && git submodule update --init

# 'fix' permissions on usr local setting current usr as owner
# assumes only one person, you, is using your machine
# sudo chown -R "`id -u -n`:admin" /usr/local
sudo chown -R $(whoami) $(brew --prefix)/* # need to do this on High Sierra instead of previous line

is_m1_mac=false
arch | grep -q arm64 && is_m1_mac=true
$is_m1_mac && ROSETTA_PREFIX="arch -x86_64"
$is_m1_mac && test ! -e /Library/Apple/usr/share/rosetta/rosetta && softwareupdate --install-rosetta

########################################
# libs
########################################
# xcode-select --install # must be install via app store now

brew_install bash
brew_install cmake
brew_install git # so that it has completion
brew_install bash-completion
brew_install rails-completion
brew_install git-lfs
brew_install fzf
brew_install fswatch
brew_install coreutils

brew_install ctop
brew_install ctags
brew_install ffmpeg
brew_install gh # github/gh/gh
# brew_install heroku
brew_install libmagic

brew_install python
brew_install pyenv
eval "$(pyenv init -)"
test -e "$HOME/.pyenv/versions/3.10.0" || pyenv install -v 3.10.0
pyenv global 3.10.0
pyenv rehash
# see: https://github.com/pyenv/pyenv/issues/530 for CFLAGS tip

brew_install openssl
brew_install jq
brew_install tmux
# brew_install languagetool
# brew_install youtube-dl # pip install yt-dlp instead
brew_install ripgrep
brew_install rbenv
brew_install reattach-to-user-namespace
brew_install vim # need vim8 for ale
brew_install watchman
brew_install zsh-syntax-highlighting

# image compression tools, via
# https://blog.daskepon.com/image-compression-tools-on-macos/
brew_install pngquant
brew_install jpegoptim

# cask installs
 brew install --cask syntax-highlight # quick look for code
 brew install --cask qlmarkdown # quick look for rendered markdown

########################################
# customize shell (for fast git status)
########################################
brew_install romkatv/gitstatus/gitstatus

_user="`id -u -n`" # get username
_shell="/usr/local/bin/bash"
_shell="/bin/zsh"
sudo chsh -s "$_shell" # set shell for root
sudo chsh -s "$_shell" "$_user" # set shell for $_user

########################################
# cask required for the following, kind of annoying so removing for now
########################################
# brew tap homebrew/cask-cask
# brew tap caskroom/versions 
# cask_install java # java (for languagetool)
# test -e /Applications/KeepingYouAwake.app || brew cask install keepingyouawake # caffeine replacement
# test -e /Applications/Cyberduck.app || brew cask install cyberduck

########################################
# pip
########################################

pip3 install --upgrade pip
pip_install ansible
pip_install autopep8
pip_install black
pip_install boto
pip_install boto3
pip_install flake8
pip_install ipdb
pip_install ipython
pip_install mock # python 2.7
pip_install nltk
pip_install nose
pip_install nose-run-line-number "git+https://github.com/kortina/nose-run-line-number.git@ak-python3-compatibility" # fork w py3 support
pip_install pre-commit
pip_install pytz
pip_install python-magic
pip_install screenplain
pip_install vimeo_downloader
pip_install watchdog
pip_install xlsx2csv
pip install -U yt-dlp

########################################
# misc
########################################
SRC_DIR="$HOME/src"
test -e $SRC_DIR || mkdir -p $SRC_DIR
if [ "`id -u -n`" = "kortina" ] && [ ! -f "$HOME/.bash_secrets" ]; then 
    show_error "~/.bash_secrets does not exist. exiting.";
    exit 1; 
fi;

########################################
# various symlinks
########################################
test -L "/Applications/Screen Sharing.app" || ln -s "/System/Library/CoreServices/Screen Sharing.app" "/Applications/Screen Sharing.app"

########################################
# node modules
########################################
which nodenv || brew_install nodenv # instead of node
eval "$(nodenv init -)"
nodenv versions | grep -q "11\.9\.0" || $ROSETTA_PREFIX nodenv install 11.9.0
nodenv global 11.9.0
nodenv rehash

npm_install eslint
npm_install eslint-plugin-react
npm_install eslint-plugin-flowtype
npm_install eslint-plugin-fin-eslint-flow-enforcement
npm_install babel-eslint
npm_install doctoc # generate markdown toc
npm_install h2m # tool for downlaoding webpage as md file
npm_install livedown
npm_install prettier
npm_install remark
npm_install remark-preset-lint-markdown-style-guide
npm_install remark-reference-links
npm_install remark-cli
npm_install remark-frontmatter
npm_install reveal-md
npm_install stylelint
npm_install stylelint-config-recommended
npm_install typescript
npm_install tslint
npm_install yarn

########################################
# ruby gems
########################################
test -e ~/.gemrc && grep -q "no-document" ~/.gemrc || echo "gem: --no-document" >> ~/.gemrc
# rbenv versions | grep -q "2\.3\.3" || rbenv install 2.3.3
# rbenv versions | grep -q "2\.3\.3" || RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl)" rbenv install 2.3.3
RUBY_CFLAGS=""
$is_m1_mac && M1_RUBY_CFLAGS="-Wno-error=implicit-function-declaration"
rbenv versions | grep -q "2\.7\.4" ||  RUBY_CFLAGS="$M1_RUBY_CFLAGS" rbenv install 2.7.4
eval "$(rbenv init -)"
rbenv global 2.7.4
rbenv rehash
# You may need to fix readline in irb by doing the following:
# xcode-select --install
# rbenv install -f 2.5.3 && RBENV_VERSION=2.5.3 gem pristine --all

gem_install rb-readline
gem_install rubocop


########################################
# vim
########################################
show_warning "-----------------------------------------------"
show_warning "You may still need to run the following:"
show_warning "vim +PlugInstall +qall"
show_warning "(which installs fzf)"
show_warning "and:"
show_warning "- Tomorrow Night Terminal Theme"
show_warning "- MesloLGS Fonts for powerlevel10k"
show_warning "- potentially git pull powerlevel10k submodule"
show_warning "-----------------------------------------------"

show_success "Finished setup-deps.sh"
