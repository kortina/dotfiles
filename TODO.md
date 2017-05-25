## Potential Things to Add

* https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard
* https://github.com/dcosson/dotfiles/blob/master/tmux.conf#L1-2
* http://vimawesome.com/

## create global keyboard shortcuts:

* http://hints.macworld.com/article.php?story=20131123074223584

    sudo osascript -e 'tell application "System Events" to set delay interval of screen saver preferences to 0'
    sudo osascript -e 'tell application "System Events" to set delay interval of screen saver preferences to 0'
    sudo osascript -e 'tell application "System Events" to set automatic login of security preferences to false'
    sudo osascript -e 'tell application "System Events" to set require password to wake of security preferences to true'
    sudo killall SystemUIServer

## Notes

Find process bound to port 7000

    lsof -i :7000

