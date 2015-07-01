#!/usr/bin/env bash
set -e
echo "##### $(basename $BASH_SOURCE) #####"

DOTFILES_ROOT="`pwd`"

# make sure git submodules are up to date
cd $DOTFILES_ROOT && git submodule update --init

########################################
# libs
########################################
# xcode-select --install # must be install via app store now

brew install git # so that it has completion
brew install bash-completion
brew tap homebrew/completions
brew install rails-completion

brew install ctags
brew install heroku
brew install python
brew install tmux
brew install languagetool
brew install youtube-dl
brew install ack
brew install the_silver_searcher


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
brew install fig # pip install fig results in SSL cert errors
echo "********************************"
echo "  see for more docker setup steps:"
echo "  http://viget.com/extend/how-to-use-docker-on-os-x-the-missing-guide"
echo "********************************"


########################################
# pip
########################################

if ! command -v pip >/dev/null 2>&1; then
    echo "installing pip"
    easy_install pip
fi
pip install flake8
pip install ipython
pip list || grep -q "powerline-status" || pip install git+git://github.com/Lokaltog/powerline
pip install nose-run-line-number
pip install boto

########################################
# misc
########################################
BAKPAK_PARENT_DIR="$HOME/src"
BAKPAK_DIR="$BAKPAK_PARENT_DIR/bakpak"
if ! test -d $BAKPAK_DIR; then
    echo "installing bakpak"
    # legacy location, lots of deps remaining on this:
    test -e $BAKPAK_PARENT_DIR || mkdir -p $BAKPAK_PARENT_DIR
    git clone git@github.com:kortina/bakpak.git $BAKPAK_DIR
    cd $BAKPAK_DIR
    git submodule update --init --recursive
    cd -
fi

########################################
# various symlinks
########################################
test -L "/Applications/Screen Sharing.app" || ln -s "/System/Library/CoreServices/Screen Sharing.app" "/Applications/Screen Sharing.app"
test -L "$HOME/.bash_mac_private" || ln -s "$HOME/Dropbox/Apps/bash_mac_private" "$HOME/.bash_mac_private"
test -L "$HOME/.ses_conf_private" || ln -s "$HOME/Dropbox/Apps/ses_conf_private" "$HOME/.ses_conf_private"

########################################
# vim YCM
########################################
# brew install cmake
# cd $HOME/dotfiles/.vim/bundle/YouCompleteMe
# git submodule update --init --recursive
# ./install.sh
# cd -

########################################
# xcode
########################################
cd "$HOME/dotfiles/themes/tomorrow-theme/Xcode 4/"
mkdir -p ~/Library/Developer/Xcode/UserData/FontAndColorThemes/
cp *.dvtcolortheme ~/Library/Developer/Xcode/UserData/FontAndColorThemes/
cd -

cd XVim && test -e ../madeXVim || make && touch ../madeXVim; cd -

########################################
# node modules
########################################
brew install node
npm list -g | grep -q livedown || sudo npm install -g livedown
npm list -g | grep -q jsxhint || sudo npm install -g jsxhint

########################################
# ruby gems
########################################
test -e ~/.gemrc && grep -q "no-document" ~/.gemrc || echo "gem: --no-document" >> ~/.gemrc
test -e "$HOME/.rvm/bin/rvm" || curl -L https://get.rvm.io | bash -s stable --auto-dotfiles --autolibs=enable --rails
gem install git-up
gem install cocoapods

