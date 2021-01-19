#!/usr/bin/env bash
set -e

# config:
remote="git@github.com:kortina/_notebook.git"
path="$HOME/Google-Drive/_notebook"

# run:
gitwatch -r "$remote" "$path"