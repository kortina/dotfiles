#!/usr/bin/osascript
# via:
# https://github.com/Ptujec/LaunchBar/blob/master/Notifications/Dismiss%20all%20notifications.lbaction/Contents/Scripts/default.applescript

tell application "System Events"
	try
		set _groups to groups of UI element 1 of scroll area 1 of group 1 of window "Notification Center" of application process "NotificationCenter"
		
		repeat with _group in _groups
			
			set _actions to actions of _group
			
			repeat with _action in _actions
				if description of _action is in {"Schlie¤en", "Alle entfernen", "Close", "Clear All"} then
					perform _action
					
				end if
			end repeat
			
		end repeat
		
	end try
end tell