#!/usr/bin/env bash

app_path="/Applications/vscode"

test -e $app_path \
    || echo "ERROR: you must symlink /Applications/vscode to Code or Code Insiders"

test -e $app_path &&  ln -s /Applications/vscode/Contents/Resources/app/bin/code /usr/local/bin/code
