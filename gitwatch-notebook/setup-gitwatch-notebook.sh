#!/usr/bin/env bash
set -e

# set -o verbose
echo "##### $(basename $BASH_SOURCE) #####"

DOTFILES_ROOT="`pwd`"
source "$HOME/dotfiles/_setup_defs.sh"


# ensure this exists:
install_dir="$HOME/src"
test -e $install_dir || mkdir -p $install_dir

cd $install_dir

# clone gitwatch if it doesn't exist:
test -e "$install_dir/gitwatch" || \
git clone https://github.com/gitwatch/gitwatch.git --depth=1
cd gitwatch
# install:
install -b gitwatch.sh /usr/local/bin/gitwatch

# install deps:
brew_install fswatch
brew_install coreutils


# TODO: create a launch agent
# like: https://github.com/kortina/dotfiles/tree/master/s3screenshots
