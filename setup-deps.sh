#!/usr/bin/env bash
set -e

DOTFILES_ROOT="`pwd`"

# make sure git submodules are up to date
cd $DOTFILES_ROOT && git submodule update --init

########################################
# libs
########################################
brew install bash-completion
brew install ctags
brew install python
brew install tmux
brew install languagetool
brew install youtube-dl

xcode-select --install

########################################
# virtualbox
########################################
brew tap phinze/homebrew-cask
brew install brew-cask
brew cask install virtualbox

########################################
# docker
########################################
brew install boot2docker
brew install docker

########################################
# pip
########################################

if ! command -v pip >/dev/null 2>&1; then
    echo "installing pip"
    easy_install pip
fi
pip install flake8
pip install ipython
pip install git+git://github.com/Lokaltog/powerline
pip install nose-run-line-number


########################################
# node modules
########################################
npm install -g livedown

########################################
# misc
########################################
if ! test -d /opt/boxen/bakpak;
    echo "installing bakpak"
    # legacy location, lots of deps remaining on this:
    mkdir -p /opt/boxen
    sudo chown kortina:staff /opt/boxen
    git clone https://github.com/kortina/bakpak.git /opt/boxen/bakpak
fi

########################################
# various symlinks
########################################
ln -s "/System/Library/CoreServices/Screen Sharing.app" "/Applications/Screen Sharing.app":

# TODO: remaining from boxen
# libs
# include java
# include vim
# include git
# include hub
# include alfred
# include bash
# include caffeine
# include dropbox
# include spotify
# include virtualbox
# include vlc
