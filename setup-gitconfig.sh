#!/bin/bash
# Creates a .gitconfig that includes the .gitconfig-shared, and asks you to set your name and email.
# via https://github.com/dcosson/dotfiles/blob/master/write_gitconfig.sh

set -e

if [ -e "$HOME/.gitconfig" ]; then
    echo "Exiting without writing ~/.gitconfig. Already exists!"
    exit 0
else
    echo ""
    echo "Set your gitconfig user name and email:"
    read -p "user.name: " user_name
    read -p "user.email: " user_email

    git config --global user.name "$user_name"
    git config --global user.email "$user_email"
    git config --global include.path "${HOME}/.gitconfig-shared"
fi

