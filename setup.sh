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

source "./_setup_defs.sh"
show_success "✅ ✅ ✅  Finished setup.sh."
show_success "🎉 🎉 🎉  Party Time."

vim +PlugInstall +qall
