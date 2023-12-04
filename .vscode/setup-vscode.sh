#!/usr/bin/env bash
set -e
echo "##### $(basename $BASH_SOURCE) #####"

DOTFILES_ROOT="$HOME/dotfiles"
cd "$DOTFILES_ROOT"
source "$DOTFILES_ROOT/_setup_defs.sh"
# test -e "$VSCODE_APP" || brew cask install visual-studio-code

which code || { echo "No \`code\` binary on \$PATH. If you just installed VS Code, you may need to open a new terminal session."; exit 1; }

EXTENSIONS="$HOME/dotfiles/.vscode/extensions.txt"

# vscode files
vscode_dotfiles="$DOTFILES_ROOT/.vscode"
cd "$vscode_dotfiles"
code_dirs=(
    "$HOME/Library/Application Support/Code/User"
    "$HOME/Library/Application Support/Code - Insiders/User"
)

for code_dir in "${code_dirs[@]}"; do
    if [[ -e "$code_dir" ]]; then
        echo "code_dir dir: $code_dir"
        for f in `ls | grep "json\|snippets"`; do 
            SYM_FILE="$code_dir/$f"
            TARG_FILE="$vscode_dotfiles/$f"
            SYM_DIR="$code_dir"
            safely_symlink "$SYM_FILE" "$TARG_FILE" "$SYM_DIR"
        done
    fi
done

for VARIANT in "code" \
               "code-insiders"
do
    if hash $VARIANT 2>/dev/null; then
        extensions_installed=$($VARIANT --list-extensions)
        echo "Installing extensions for $VARIANT"
        for EXTENSION in `cat $EXTENSIONS`; do
            set +e
            already_installed="no"
            echo "$extensions_installed" | grep -q "$EXTENSION" && already_installed="yes"
            set -e
            echo "$EXTENSION already installed with code: $already_installed"
            [ $already_installed = "yes" ] || $VARIANT --install-extension $EXTENSION ;
        done;
    fi
done
