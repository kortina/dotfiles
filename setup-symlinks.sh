#!/usr/bin/env bash
set -e
echo "##### $(basename $BASH_SOURCE) #####"

DOTFILES_ROOT="`pwd`"
DONT_SYMLINK=("." ".." ".git" ".gitmodules")

function safely_symlink() {
    sym_file="$1"
    targ_file="$2"
    sym_dir="$3"

    if test -h "$sym_file" || ! test -e "$sym_file"; then
        # no file or another symlink exists. OK TO OVERWRITE 
        echo "ln -fs $targ_file $sym_dir/"
        ln -fs "$targ_file" "$sym_dir/"
    else
        echo -e "\nABORT: $sym_file exists and is not a link."
        exit 1
    fi
}

# home directory dotfiles
for f in `ls -a | grep "^\." | grep -v "\.swp$" | grep -v "DS_Store"`; do 
    if [ "$f" = "." ] \
        || [ "$f" = ".." ] \
        || [ "$f" = ".git" ] \
        || [ "$f" = ".gitmodules" ]; then 
            echo "skipping symlink $f"
    else
        SYM_FILE="$HOME/$f"
        TARG_FILE="$DOTFILES_ROOT/$f"
        SYM_DIR="$HOME"
        safely_symlink "$SYM_FILE" "$TARG_FILE" "$SYM_DIR"
    fi
done

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
