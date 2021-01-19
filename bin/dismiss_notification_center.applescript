#!/usr/bin/osascript
# via:
# https://apple.stackexchange.com/questions/408019/dismiss-macos-big-sur-notifications-with-keyboard
activate application "NotificationCenter"
tell application "System Events"
    tell process "Notification Center"
        set theWindow to group 1 of UI element 1 of scroll area 1 of window "Notification Center"
        # click theWindow
        set theActions to actions of theWindow
        repeat with theAction in theActions
            if description of theAction is "Close" then
                tell theWindow
                    perform theAction
                end tell
                exit repeat
            end if
        end repeat
    end tell
end tell