#!/usr/bin/env bash
set -e
# set -o verbose
echo "##### $(basename $BASH_SOURCE) #####"

DOTFILES_ROOT="`pwd`"

# make sure git submodules are up to date
cd $DOTFILES_ROOT && git submodule update --init

########################################
# helpers
########################################
brew_install() {
    formula="$1"
    set +e
    test -z "$(brew ls --versions $formula)" && should_install="yes"
    set -e
    echo "should_install: $should_install"
    test -z "$should_install" || brew install $formula
    should_install=""
}

install_git_repo() {
    repo="$1"
    target_dir="$2"

    if ! test -d $target_dir; then
        echo "installing $repo"
        # legacy location, lots of deps remaining on this:
        git clone "$repo" "$target_dir"
        cd $target_dir
        git submodule update --init --recursive
        cd -
    fi

}

########################################
# libs
########################################
# xcode-select --install # must be install via app store now

brew_install git # so that it has completion
brew_install bash-completion
brew tap homebrew/completions
brew_install rails-completion
brew_install git-lfs
brew_install fzf
brew_install fswatch

brew_install ctags
brew_install heroku
brew_install python
brew_install tmux
brew_install languagetool
brew_install youtube-dl
brew_install ack
brew_install the_silver_searcher
brew_install rbenv
brew install reattach-to-user-namespace
brew tap caskroom/cask


########################################
# virtualbox
########################################
# brew cask install virtualbox

########################################
# java (for languagetool)
########################################
brew tap caskroom/versions
brew cask install java7
echo "NB: You may also need to install Java for El Capitan from:"
echo "https://support.apple.com/kb/DL1572?locale=en_US"

# caffeine replacement
brew cask install keepingyouawake
########################################
# docker
########################################
# brew_install boot2docker
# brew_install docker
# brew_install fig # pip install fig results in SSL cert errors
# echo "********************************"
# echo "  see for more docker setup steps:"
# echo "  http://viget.com/extend/how-to-use-docker-on-os-x-the-missing-guide"
# echo "********************************"


########################################
# pip
########################################

if ! command -v pip >/dev/null 2>&1; then
    echo "installing pip"
    easy_install pip
fi
pip install flake8
pip install ipython
pip install nose-run-line-number
pip install boto

########################################
# misc
########################################
SRC_DIR="$HOME/src"
test -e $SRC_DIR || mkdir -p $SRC_DIR
install_git_repo "git@github.com:kortina/bakpak.git" "$HOME/src/bakpak"
install_git_repo "git@github.com:/github/hub.git" "$HOME/src/hub"

test -e "$HOME/.teamocil" || mkdir -p "$HOME/.teamocil"

########################################
# various symlinks
########################################
test -L "/Applications/Screen Sharing.app" || ln -s "/System/Library/CoreServices/Screen Sharing.app" "/Applications/Screen Sharing.app"
test -L "$HOME/.bash_mac_private" || ln -s "$HOME/Dropbox/Apps/bash_mac_private" "$HOME/.bash_mac_private"
test -L "$HOME/.ses_conf_private" || ln -s "$HOME/Dropbox/Apps/ses_conf_private" "$HOME/.ses_conf_private"

########################################
# vim YCM
########################################
# brew_install cmake
# cd $HOME/dotfiles/.vim/bundle/YouCompleteMe
# git submodule update --init --recursive
# ./install.sh
# cd -

########################################
# xcode
########################################
# cd "$HOME/dotfiles/themes/tomorrow-theme/Xcode 4/"
# mkdir -p ~/Library/Developer/Xcode/UserData/FontAndColorThemes/
# cp *.dvtcolortheme ~/Library/Developer/Xcode/UserData/FontAndColorThemes/
# cd -

# cd XVim && test -e ../madeXVim || make && touch ../madeXVim && open XVim.xcodeproj; cd -

########################################
# node modules
########################################
brew_install node
npm list -g | grep -q livedown@ || sudo npm install -g livedown

npm list -g | grep -q eslint@ || sudo npm install -g eslint
npm list -g | grep -q eslint-plugin-react@ || sudo npm install -g eslint-plugin-react
npm list -g | grep -q eslint-plugin-flowtype@ || sudo npm install -g eslint-plugin-flowtype
npm list -g | grep -q babel-eslint@ || sudo npm install -g babel-eslint

########################################
# ruby gems
########################################
test -e ~/.gemrc && grep -q "no-document" ~/.gemrc || echo "gem: --no-document" >> ~/.gemrc
# TODO: swap for rbenv. test -e "$HOME/.rvm/bin/rvm" || curl -L https://get.rvm.io | bash -s stable --auto-dotfiles --autolibs=enable --rails
gem install git-up
gem install docker-sync
gem install cocoapods
gem install overcommit
gem install teamocil
gem install rubocop

########################################
# vim
########################################
vim +PlugInstall +qall
