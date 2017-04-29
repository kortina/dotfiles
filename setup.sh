#!/usr/bin/env bash
set -e
echo "##### $(basename $BASH_SOURCE) #####"

./setup-symlinks.sh
./setup-homebrew.sh
./setup-deps.sh
./setup-osx.sh
