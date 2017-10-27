#!/usr/bin/env bash
EXTENSIONS="$HOME/dotfiles/vscode/extensions.txt"

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
