#!/usr/bin/env bash
set -e

# config:
remote="origin" # NB: this should be "origin" not something like "git@github.com:kortina/_notebook.git"
path="$HOME/gd/_notebook"
secs="300" # at most push to github every 5 minutes

# run:
gitwatch -s "$secs" -r "$remote" "$path"
