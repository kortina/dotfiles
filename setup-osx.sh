#!/usr/bin/env bash

# format clock in menubar
defaults write com.apple.menuextra.clock DateFormat 'EEE MMM d  h:mm a'

# require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# some changes (eg, menubar) require this restart:
killall SystemUIServer
