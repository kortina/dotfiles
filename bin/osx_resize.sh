#!/usr/bin/env bash
# Desired dimensions
usage() {
  echo "Usage: $0 [dimensions]"
  echo "Dimensions can be in pixeles, eg 1024x768"
  echo "Or one of these shortcuts:"
  echo "full, half-left, half-right"
}
dimensions="$1"
if [ "$dimensions" = "" ]
then
    usage; exit
fi

width=""
height=""
menubar_offset="24"
full_height="(item 4 of b) - $menubar_offset"
strategy_3=""

if [ "$dimensions" = "full" ]; then
    x="0" # item 1 of b
    y="0"
    width="item 3 of b";
    top_right="$width";
    height="$full_height";
    strategy_3='click (button 1 of window 1 where subrole is "AXZoomButton")'
elif [ "$dimensions" = "half-left" ]; then
    x="0"
    y="0"
    width="(item 3 of b) / 2"; # top right of screen / 2
    top_right="(item 3 of b)"; # match top right of screen
    height="$full_height";
elif [ "$dimensions" = "half-right" ]; then
    x="(item 3 of b) / 2"
    y="0"
    width="(item 3 of b) / 2"; # top right of screen / 2
    top_right="(item 3 of b)"; # why is this not divided by 2? ¯\_(ツ)_/¯
    height="$full_height";
else
    x="0"
    y="0"
    width=`echo "$dimensions" | awk -F 'x' '{print $1}'`;
    top_right="$width";
    height=`echo "$dimensions" | awk -F 'x' '{print $2}'`;
fi

if [ "$height" = "" ]
then
    usage; exit
fi

# echo "{ $x, $y, $width, $height }"

# NB:
# 1. Setting the bounds, we must set the top-right x-coord of the window.
# 2. Setting width we must compute desired width from the screen bounds, but only set top left
# coord.
osascript <<EOF
try
    -- b = bounds of desktop
    tell application "Finder" to set b to bounds of window of desktop
    try
        tell application (path to frontmost application as text)
            set bounds of window 1 to { $x, $y, $top_right, $height }
            -- display notification "strategy 1"
        end tell
    on error
        tell application "System Events" to tell window 1 of (process 1 where it is frontmost)
            try
                set position to { $x, $y }
                -- set w to $b
                set size to { $width, $height }
                -- display notification "strategy 2: x:$x, y:$y, w:$w, h:$height"
            on error
                $strategy_3
                -- display notification "strategy 3"
            end try
        end tell
    end try
end try
EOF

# original full script:
# try
#     tell application "Finder" to set b to bounds of window of desktop
#     try
#         tell application (path to frontmost application as text)
#             set bounds of window 1 to {item 1 of b, 22, item 3 of b, item 4 of b}
# 		    display notification "strategy 1"
#         end tell
#     on error
#         tell application "System Events" to tell window 1 of (process 1 where it is frontmost)
#             try
#                 set position to {0, 22}
#                 set size to {item 3 of b, (item 4 of b) - 22}
#     		        display notification "strategy 2"
#             on error
#                 click (button 1 of window 1 where subrole is "AXZoomButton")
#     		        display notification "strategy 3"
#             end try
#         end tell
#     end try
# end try
