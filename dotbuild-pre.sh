#!/usr/bin/env bash
set -e

DOTFILES_ROOT="`pwd`"

# make sure git submodules are up to date
cd $DOTFILES_ROOT && git submodule update 

# other directories and things to link
# link_file "$DOTFILES_ROOT/vim"
