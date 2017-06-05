#!/usr/bin/env bash
set -e
echo "##### $(basename $BASH_SOURCE) #####"

./setup-gitconfig.sh
./setup-symlinks.sh
./setup-homebrew.sh
./setup-deps.sh
./setup-osx.sh

echo "✅ ✅ ✅"
echo "🎉 🎉 🎉"

echo "You may still need to setup YouCompleteMe by running:"
echo "cd .vim/plugged/YouCompleteMe/ && ./install.py --tern-completer; cd -"
