#!/usr/bin/env bash
set -e
echo "##### $(basename $BASH_SOURCE) #####"

echo "You should see a bunch of ✅ emoji when this script finishes."
echo "You will need to install MesloLGS Font via https://github.com/romkatv/powerlevel10k#fonts"

./setup-gitconfig.sh
./setup-symlinks.sh
./setup-homebrew.sh
./setup-deps.sh
./vscode/setup-vscode.sh
./setup-osx.sh

source "./_setup_defs.sh"
echo "Install MesloLGS Font via https://github.com/romkatv/powerlevel10k#fonts"
show_success "✅ ✅ ✅  Finished setup.sh."
show_success "🎉 🎉 🎉  Party Time."

vim +PlugInstall +qall
