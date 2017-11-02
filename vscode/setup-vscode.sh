#!/usr/bin/env bash
set -e
echo "##### $(basename $BASH_SOURCE) #####"

DOTFILES_ROOT="$HOME/dotfiles"
source "$DOTFILES_ROOT/.bash_defs.sh"

EXTENSIONS="$HOME/dotfiles/vscode/extensions.txt"

# vscode files
vscode_dotfiles="$DOTFILES_ROOT/vscode"
cd "$vscode_dotfiles"
code_dirs=(
    "$HOME/Library/Application Support/Code/User"
    "$HOME/Library/Application Support/Source Graph" 
)

for code_dir in "${code_dirs[@]}"; do
    echo "code_dir dir: $code_dir"

    for f in `ls | grep json`; do 
        SYM_FILE="$code_dir/$f"
        TARG_FILE="$vscode_dotfiles/$f"
        SYM_DIR="$code_dir"
        safely_symlink "$SYM_FILE" "$TARG_FILE" "$SYM_DIR"
    done
done

for VARIANT in "code" \
               "code-insiders"
do
    if hash $VARIANT 2>/dev/null; then
        echo "Installing extensions for $VARIANT"
        for EXTENSION in `cat $EXTENSIONS`
        do
            $VARIANT --install-extension $EXTENSION
        done
    fi
done
