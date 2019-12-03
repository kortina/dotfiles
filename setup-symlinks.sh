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
        SYM_FILE="$HOME/$f"
        TARG_FILE="$DOTFILES_ROOT/$f"
        SYM_DIR="$HOME"
        safely_symlink "$SYM_FILE" "$TARG_FILE" "$SYM_DIR"
    fi
done

# do not symlink the entire .ssh dir
# just the config file
f=".ssh/config"
SYM_FILE="$HOME/$f"
TARG_FILE="$DOTFILES_ROOT/$f"
SYM_DIR="$HOME/.ssh"
safely_symlink "$SYM_FILE" "$TARG_FILE" "$SYM_DIR"
