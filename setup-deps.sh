#!/usr/bin/env bash
set -e

# set -o verbose
echo "##### $(basename $BASH_SOURCE) #####"

DOTFILES_ROOT="`pwd`"
source "$DOTFILES_ROOT/.bash_defs.sh"

# make sure git submodules are up to date
cd $DOTFILES_ROOT && git submodule update --init

########################################
# helpers
########################################
brew_install() {
    formula="$1"
    set +e
    already_installed="no"
    test -z "$(brew ls --versions $formula)" || already_installed="yes"
    set -e
    echo "$formula already installed with brew: $already_installed"
    [ $already_installed = "yes" ] || brew install $formula
}

npm_install() {
    formula="$1"
    set +e
    already_installed="no"
    npm list -g | grep -q "$formula@" && already_installed="yes"
    set -e
    echo "$formula already installed with npm: $already_installed"
    [ $already_installed = "yes" ] || npm install -g $formula
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

# 'fix' permissions on usr local setting current usr as owner
# assumes only one person, you, is using your machine
# sudo chown -R "`id -u -n`:admin" /usr/local
sudo chown -R $(whoami) $(brew --prefix)/* # need to do this on High Sierra instead of previous line


########################################
# libs
########################################
# xcode-select --install # must be install via app store now

brew_install CMake
brew_install git # so that it has completion
brew_install bash-completion
brew_install rails-completion
brew_install git-lfs
brew_install fzf
brew_install fswatch

brew_install ctop
brew_install ctags
brew_install ffmpeg
brew_install heroku

brew_install python
brew_install pyenv
eval "$(pyenv init -)"
test -e "$HOME/.pyenv/versions/3.7.0" || pyenv install 3.7.0

brew_install jq
brew_install tmux
brew_install languagetool
brew_install youtube-dl
brew_install the_silver_searcher # WAY faster than ack
brew_install rbenv
brew_install reattach-to-user-namespace
brew_install vim # need vim8 for ale
brew_install watchman
brew_install yarn
brew tap caskroom/cask


########################################
# java (for languagetool)
########################################
brew tap caskroom/versions
brew cask install java

# caffeine replacement
test -e /Applications/KeepingYouAwake.app || brew cask install keepingyouawake
test -e /Applications/Cyberduck.app || brew cask install cyberduck

########################################
# pip
########################################

pip install ansible
pip install autopep8
pip install boto
pip install flake8
pip install ipython
pip install mock # python 2.7
pip install nose
pip install nose-run-line-number
pip install watchdog
pip install xlsx2csv

########################################
# misc
########################################
SRC_DIR="$HOME/src"
test -e $SRC_DIR || mkdir -p $SRC_DIR
if [ "`id -u -n`" = "kortina" ] && [ ! -f "$HOME/.bash_mac_private" ]; then echo "~/.bash_mac_private does not exist. exiting."; exit 1; fi;

########################################
# various symlinks
########################################
test -L "/Applications/Screen Sharing.app" || ln -s "/System/Library/CoreServices/Screen Sharing.app" "/Applications/Screen Sharing.app"

########################################
# node modules
########################################
# brew_install node
brew_install nvm # instead of node

npm_install eslint
npm_install eslint-plugin-react
npm_install eslint-plugin-flowtype
npm_install babel-eslint
npm_install livedown
npm_install prettier
npm_install reveal-md
npm_install typescript
npm_install tslint

test -e $HOME/.nvm || mkdir -p $HOME/.nvm 

########################################
# ruby gems
########################################
test -e ~/.gemrc && grep -q "no-document" ~/.gemrc || echo "gem: --no-document" >> ~/.gemrc
rbenv versions | grep -q "2\.3\.3" || rbenv install 2.3.3
rbenv global 2.3.3
# You may need to fix readline in irb by doing the following:
# xcode-select --install
# rbenv install -f 2.3.3 && RBENV_VERSION=2.3.3 gem pristine --all
gem install docker-sync
gem install cocoapods
gem install overcommit
gem install teamocil
gem install rb-readline
gem install rubocop


########################################
# vim
########################################
show_warning "You may still need to run\n vim +PlugInstall +qall"

show_success "Finished setup-deps.sh"
