#!/usr/bin/env bash
set -e
echo "##### $(basename $BASH_SOURCE) #####"

# format clock in menubar
defaults write com.apple.menuextra.clock DateFormat 'EEE MMM d  h:mm a'

# require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# speed up Mission Control / slow animations
# @see http://apple.stackexchange.com/questions/17929/how-can-i-disable-animation-when-switching-desktops-in-lion
defaults write com.apple.dock expose-animation-duration -int 0
defaults delete com.apple.dock expose-animation-duration

# some changes (eg, menubar) require:
killall SystemUIServer
# some changes (eg, animations) require:
killall Dock
