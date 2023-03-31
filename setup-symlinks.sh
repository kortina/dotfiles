#!/usr/bin/env bash
set -e
echo "##### $(basename $BASH_SOURCE) #####"

DOTFILES_ROOT="`pwd`"
source "$DOTFILES_ROOT/_setup_defs.sh"

# home directory dotfiles
for f in `ls -a | grep "^\." | grep -v "\.swp$" | grep -v "DS_Store"`; do 
    if [ "$f" = "." ] \
        || [ "$f" = ".." ] \
        || [ "$f" = ".git" ] \
        || [ "$f" = ".gitmodules" ] \
        || [ "$f" = ".ssh" ]; then 
            echo "skipping symlink $f"
    else
        SYM_DIR="$HOME"
        SYM_FILE="$SYM_DIR/$f"
        TARG_FILE="$DOTFILES_ROOT/$f"
        safely_symlink "$SYM_FILE" "$TARG_FILE" "$SYM_DIR"
    fi
done

# Symlink the Keybinding.dict file
f="DefaultKeyBinding.dict"
SYM_DIR="$HOME/Library/KeyBindings"
SYM_FILE="$SYM_DIR/$f"
TARG_FILE="$DOTFILES_ROOT/$f"
mkdir -p "$SYM_DIR"
safely_symlink "$SYM_FILE" "$TARG_FILE" "$SYM_DIR"