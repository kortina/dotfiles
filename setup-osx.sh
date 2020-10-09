#!/usr/bin/env bash
#
# One good way to discover defaults paths / values is this:
#
#   defaults read > before
#   # 🧐 make some changes in System Preferences
#   defaults read > after
#   diff before after
#
set -e
echo "##### $(basename $BASH_SOURCE) #####"
DOTFILES_ROOT="`pwd`"

# allow touch id instead of password for sudo:
l="auth       sufficient     pam_tid.so"
f="/etc/pam.d/sudo"
t="/tmp/sudo"
grep -q pam_tid.so $f || (  echo "$l" > $t && cat "$f" >> $t && sudo mv $t $f  )

cp themes/fonts/* "$HOME/Library/Fonts/"

# format clock in menubar
defaults write com.apple.menuextra.clock DateFormat 'EEE MMM d  h:mm a'

# require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# speed up Mission Control / slow animations
# @see http://apple.stackexchange.com/questions/17929/how-can-i-disable-animation-when-switching-desktops-in-lion
defaults write com.apple.dock workspaces-swoosh-animation-off -bool YES
defaults write com.apple.dock expose-animation-duration -int 0
defaults delete com.apple.dock expose-animation-duration
defaults write -g NSWindowResizeTime -float 0.003

# tons of good stuff here:
# @see https://github.com/mathiasbynens/dotfiles/blob/master/.osx

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable Look up & data detectors: Tap with three fingers
defaults write com.apple.AppleMultitouchTrackpad ActuateDetents 0

# Disable Force Click and haptic feedback: Click then press firmly for Quick Look, Look up, and variable speed media controls.
defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed 1
defaults write -g com.apple.trackpad.forceClick 0
defaults write com.apple.preference.trackpad ForceClickSavedState 0

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# had to remove all of these in High Sierra due to error:
# defaults[95085:278887] Could not write domain com.apple.universalaccess; exiting
# Use scroll gesture with the Ctrl (^) modifier key to zoom
# defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
# defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
# Follow the keyboard focus while zoomed in
# defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1

# Set a fast delay until repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15

defaults write -g NSAutomaticCapitalizationEnabled -int 0
defaults write -g NSAutomaticDashSubstitutionEnabled -int 0
defaults write -g NSAutomaticPeriodSubstitutionEnabled -int 0
defaults write -g NSAutomaticQuoteSubstitutionEnabled -int 0
defaults write -g NSAutomaticSpellingCorrectionEnabled -int 0
defaults write -g WebAutomaticSpellingCorrectionEnabled -int 0

# disable swipe to go back in Chrome
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool FALSE

###############################################################################
# Terminal
###############################################################################
terminal_plist="$HOME/Library/Preferences/com.apple.Terminal.plist"
# check if theme is installed, if not, install it:
/usr/libexec/PlistBuddy \
    -c "Print :'Window Settings':'Tomorrow Night'" \
    "$terminal_plist"  &> /dev/null \
    || open -gj "$DOTFILES_ROOT/themes/tomorrow-theme/OS X Terminal/Tomorrow Night.terminal"

# use Tomorrow Night theme by default
defaults write com.apple.Terminal "Default Window Settings" "Tomorrow Night"
defaults write com.apple.Terminal "Startup Window Settings" "Tomorrow Night"
# false: Audible bell
/usr/libexec/PlistBuddy -c "Set :'Window Settings':'Tomorrow Night':Bell 0" "$terminal_plist"
# false: Visual bell > Only when sound is muted
# /usr/libexec/PlistBuddy -c "Set :'Window Settings':'Tomorrow Night':VisualBellOnlyWhenMuted 0" "$terminal_plist"
# true: Use option key as meta key
/usr/libexec/PlistBuddy -c "Set :'Window Settings':'Tomorrow Night':useOptionAsMetaKey 1" "$terminal_plist"

# delete all the builtin themes
# i'm not sure this actually works
for dt in "Basic" "Grass" "Homebrew" "Novel" "Ocean" "Pro" "Red Sands" "Silver Aerogel" "Solid Colors" "Tomorrow"; do 
    /usr/libexec/PlistBuddy \
        -c "Print :'Window Settings':'$dt'" \
        "$terminal_plist"  &> /dev/null \
        && /usr/libexec/PlistBuddy \
        -c "Delete :'Window Settings':'$dt'" \
        "$terminal_plist"
done;

###############################################################################
# Finder                                                                      #
###############################################################################

# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Finder: show hidden files by default
#defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
# defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Empty Trash securely by default
defaults write com.apple.finder EmptyTrashSecurely -bool true

# Show the ~/Library folder
chflags nohidden ~/Library

# Remove drop shadow from screenshots taken with `cmd+shift+4 space`
defaults write com.apple.screencapture disable-shadow -bool TRUE
# Undo:
# defaults write com.apple.screencapture disable-shadow -bool FALSE; killall SystemUIServer
# If you hold Option while clicking (after doing the Cmd-Shift-4, Space dance), the saved screenshot will not have the drop shadow.
# https://apple.stackexchange.com/questions/50860/how-do-i-take-a-screenshot-without-the-shadow-behind-it

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

# Wipe all (default) app icons from the Dock
defaults write com.apple.dock persistent-apps -array

# Don’t animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Don’t show Dashboard as a Space
defaults write com.apple.dock dashboard-in-overlay -bool true

# Reset Launchpad, but keep the desktop wallpaper intact
find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete

# Add iOS Simulator to Launchpad
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/iOS Simulator.app" "/Applications/iOS Simulator.app"

# Add a spacer to the left side of the Dock (where the applications are)
#defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
# Add a spacer to the right side of the Dock (where the Trash is)
#defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# Top left screen corner → 
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0
# Top right screen corner →
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
# Bottom left screen corner → Desktop
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0

###############################################################################
# Messages                                                                    #
###############################################################################

# Disable automatic emoji substitution (i.e. use plain text smileys)
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

# Disable smart quotes as it’s annoying for messages that contain code
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

# Turn volume level for alerts way down:
defaults write com.apple.sound.beep.volume -float 0.05

###############################################################################
# FSNotes
###############################################################################
# use Cmd+Delete for "delete text to beginning of line" you can change the "delete note" hotkey to Cmd+Shift+Delete
defaults write co.fluder.FSNotes NSUserKeyEquivalents -dict-add 'Delete' '@$\U0008';

###############################################################################
# Safari
###############################################################################

# stop show adds for websites on safari open
defaults write com.apple.Safari HomePage -string "about:blank" # Empty
defaults write com.apple.Safari NewTabBehavior -int 1 # Empty
defaults write com.apple.Safari NewWindowBehavior -int 1 # Empty


###############################################################################
# Kill affected applications                                                  #
###############################################################################

# some changes (eg, menubar) require:
killall SystemUIServer
# some changes (eg, animations) require:
killall Dock

echo "Done. Note that some of these changes require a logout/restart to take effect."