#!/usr/bin/env bash
# osascript -e 'the clipboard as "RTF "' \
#     | perl -ne 'print chr foreach unpack(\"C*\", pack(\"H*\", substr(\$_,11,-3)))'
osascript -e 'the clipboard as «class RTF »' \
    | perl -ne 'print chr foreach unpack("C*",pack("H*",substr($_,11,-3)))'
