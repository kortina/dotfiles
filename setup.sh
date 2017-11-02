#!/usr/bin/env bash
set -e
echo "##### $(basename $BASH_SOURCE) #####"

echo "You should see a bunch of ✅ emoji when this script finishes."

./setup-gitconfig.sh
./setup-symlinks.sh
./setup-homebrew.sh
./setup-deps.sh
./vscode/setup-vscode.sh
./setup-osx.sh

source "./.bash_defs.sh"
show_success "✅ ✅ ✅  Finished setup.sh."
show_success "🎉 🎉 🎉  Party Time."

echo "You may still need to setup YouCompleteMe by running:"
echo "cd .vim/plugged/YouCompleteMe/ && ./install.py --tern-completer; cd -"

vim +PlugInstall +qall
