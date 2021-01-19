#!/usr/bin/env bash
set -e

# config:
remote="git@github.com:kortina/_notebook.git"
path="$HOME/Google-Drive/_notebook"
secs="300" # at most push to github every 5 minutes

# run:
gitwatch -s "$secs" -r "$remote" "$path"