#!/usr/bin/osascript
# via:
# https://apple.stackexchange.com/questions/408019/dismiss-macos-big-sur-notifications-with-keyboard

# define a function we can call recursively
on dismiss_notification_center(n)
    log "dismiss_notification_center: " & n
    set performedAction to false
    activate application "NotificationCenter"
    tell application "System Events"
        tell process "Notification Center"
            try
                # when there are no notifications, this may result in:
                # 'System Events got an error: Can’t get window "Notification Center" of process "Notification Center".'
                # This is our recursion base case.
                set theWindow to group 1 of UI element 1 of scroll area 1 of window "Notification Center"
            on error e
                # log the error to the console:
                log quoted form of e
                return
            end try
            # log theWindow

            set theActions to actions of theWindow
            repeat with theAction in theActions
                # log theAction
                # log description of theAction
                if description of theAction is in {"Close", "Clear All"} then
                    tell theWindow
                        perform theAction
                        set performedAction to true
                    end tell
                    exit repeat
                end if
            end repeat
        end tell
    end tell
    log "performedAction: " & performedAction
    if performedAction
        # for some reason, the loop doesn't close them all when grouped, so
        # we need to recurse. But, first we have to sleep to allow notif to re-appear:
        do shell script "/bin/sleep 3" # min sleep time that worked for me, and sometimes reminders take even longer
        dismiss_notification_center(n + 1)
    end if
end dismiss_notification_center

# first call to recursive function:
dismiss_notification_center(0)