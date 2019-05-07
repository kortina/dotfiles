#!/usr/bin/env bash
set -e

# set -o verbose
echo "##### $(basename $BASH_SOURCE) #####"

DOTFILES_ROOT="`pwd`"
source "$DOTFILES_ROOT/_setup_defs.sh"

# make sure git submodules are up to date
cd $DOTFILES_ROOT && git submodule update --init

########################################
# helpers
########################################
# These cache the output of the package lists,
# and then check packages against the caches.
# This dramatically speeds up run time.
BREW_LS=""
brew_install() {
    test -z "$BREW_LS" && BREW_LS=$(brew ls -1)
    formula="$1"
    set +e
    already_installed="no"
    echo "$BREW_LS" | grep -q $formula && already_installed="yes"
    set -e
    echo "$formula already installed with brew: $already_installed"
    [ $already_installed = "yes" ] || brew install $formula
}

CASK_LIST=""
cask_install() {
    test -z "$CASK_LIST" && CASK_LIST=$(brew cask list -1)
    pkg="$1"
    set +e
    already_installed="no"
    echo "$CASK_LIST" | grep -q "\b$pkg\b" && already_installed="yes"
    set -e
    echo "$pkg already installed with cask: $already_installed"
    [ $already_installed = "yes" ] || brew cask install $pkg
}

NPM_LIST_G=""
npm_install() {
    test -z "$NPM_LIST_G" && NPM_LIST_G=$(npm list -g)
    formula="$1"
    set +e
    already_installed="no"
    echo "$NPM_LIST_G" | grep -q "$formula@" && already_installed="yes"
    set -e
    echo "$formula already installed with npm: $already_installed"
    [ $already_installed = "yes" ] || npm install -g $formula
}

PIP_LIST=""
pip_install() {
    test -z "$PIP_LIST" && PIP_LIST=$(pip list)
    pkg="$1"
    set +e
    already_installed="no"
    echo "$PIP_LIST" | grep -q "\b$pkg\b" && already_installed="yes"
    set -e
    echo "$pkg already installed with pip: $already_installed"
    [ $already_installed = "yes" ] || pip install $pkg
}

GEM_LIST=""
gem_install() {
    test -z "$GEM_LIST" && GEM_LIST=$(gem list)
    pkg="$1"
    set +e
    already_installed="no"
    echo "$GEM_LIST" | grep -q "\b$pkg\b" && already_installed="yes"
    set -e
    echo "$pkg already installed with gem: $already_installed"
    [ $already_installed = "yes" ] || gem install $pkg
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

brew_install cmake
brew_install git # so that it has completion
brew_install bash-completion
brew_install rails-completion
brew_install git-lfs
brew_install fzf
brew_install fswatch

brew_install ctop
brew_install ctags
brew_install ffmpeg
# brew_install heroku

brew_install python
brew_install pyenv
eval "$(pyenv init -)"
test -e "$HOME/.pyenv/versions/3.7.0" || CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv install -v 3.7.0
# see: https://github.com/pyenv/pyenv/issues/530 for CFLAGS tip

brew_install jq
brew_install tmux
# brew_install languagetool
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
brew tap caskroom/versions # this is still a little slow
cask_install java

# caffeine replacement
test -e /Applications/KeepingYouAwake.app || brew cask install keepingyouawake
test -e /Applications/Cyberduck.app || brew cask install cyberduck

########################################
# pip
########################################

pip_install ansible
pip_install autopep8
pip_install black
pip_install boto
pip_install flake8
pip_install ipython
pip_install mock # python 2.7
pip_install nose
pip_install nose-run-line-number
pip_install pre-commit
pip_install watchdog
pip_install xlsx2csv

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
nodenv versions | grep -q "11\.9\.0" || nodenv install 11.9.0
nodenv global 11.9.0
nodenv rehash

npm_install eslint
npm_install eslint-plugin-react
npm_install eslint-plugin-flowtype
npm_install eslint-plugin-fin-eslint-flow-enforcement
npm_install babel-eslint
npm_install livedown
npm_install prettier
npm_install remark
npm_install remark-preset-lint-markdown-style-guide
npm_install remark-reference-links
npm_install reveal-md
npm_install stylelint
npm_install stylelint-config-recommended
npm_install typescript
npm_install tslint

########################################
# ruby gems
########################################
test -e ~/.gemrc && grep -q "no-document" ~/.gemrc || echo "gem: --no-document" >> ~/.gemrc
rbenv versions | grep -q "2\.3\.3" || rbenv install 2.3.3
rbenv global 2.3.3
rbenv rehash
# You may need to fix readline in irb by doing the following:
# xcode-select --install
# rbenv install -f 2.3.3 && RBENV_VERSION=2.3.3 gem pristine --all
gem_install docker-sync
gem_install cocoapods
gem_install overcommit
gem_install teamocil
gem_install rb-readline
gem_install rubocop


########################################
# vim
########################################
show_warning "You may still need to run\n vim +PlugInstall +qall"

show_success "Finished setup-deps.sh"
