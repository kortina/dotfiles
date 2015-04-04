#!/usr/bin/env bash
set -e
echo "##### $(basename $BASH_SOURCE) #####"

./setup-homebrew.sh
./setup-deps.sh
./setup-symlinks.sh
./setup-osx.sh
