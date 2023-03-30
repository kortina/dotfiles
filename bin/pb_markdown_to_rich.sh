#!/usr/bin/env bash
# Convert the markdown from the clipboard to rich html
# (so you can paste into Gmail, Google Docs, etc)
pbpaste \
    | pandoc -f markdown -t html \
    | sed '1 s/^/<div style="font-family:Arial;">\n/' \
    | sed '$ s/$/\n<\/div>/' \
    | textutil -stdin -inputencoding utf-8 -format html -convert rtf -stdout \
    | pbcopy
