#!/usr/bin/env bash
set -e
echo "##### $(basename $BASH_SOURCE) #####"

DOTFILES_ROOT="`pwd`"
DONT_SYMLINK=("." ".." ".git" ".gitmodules")

for f in `ls -a | grep "^\." | grep -v "\.swp$"`; do 
    if [ "$f" = "." ] \
        || [ "$f" = ".." ] \
        || [ "$f" = ".git" ] \
        || [ "$f" = ".gitmodules" ]; then 
            echo "skipping symlink $f"
    else
        SYM_FILE="$HOME/$f"
        TARG_FILE="$DOTFILES_ROOT/$f"
        if test -h "$SYM_FILE" || ! test -e "$SYM_FILE"; then
            # no file or another symlink exists. OK TO OVERWRITE 
            echo "ln -fs $TARG_FILE $SYM_FILE"
            ln -fs "$TARG_FILE" "$SYM_FILE"
        else
            echo -e "\nABORT: $SYM_FILE exists and is not a link."
            exit 1
        fi
    fi
done
