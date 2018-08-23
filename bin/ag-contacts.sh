#!/usr/bin/env bash
# Look through directory of downloaded contact csvs
# and grab out all of the unique email addresses.

# export LC_CTYPE=C
ag -o --nofilename "[^\@:;,\'\"\n\>\<\s]+@[^\@:;,\'\"\n\>\<\s]+" \
    | perl -nle 'print if m{^[[:ascii:]]+$}' \
    | ag -v ".{300,}" \
    | ag -v "[^@]{50,}@" \
    | ag "\w" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/\+[^\@]+@/@/' \
    | ag "@[^\.]+\.[^\.]+" \
    | ag -v "(account|affiliate|assistly|auto|aws|bugs|commun|connection|contact|desk|dl-|document|ebay|\be?mail|error|feedback|founder|help|marketing|news|notifications|office|password|reply|sale|service|subscribe|subscription|support|update)[^\@]*@" \
    | ag -v "^(all|team)@" \
    | ag -v "@[^\@]*(group\.calendar|groups|mail\.asana|reply|resource\.calendar)" \
    | ag "^[a-z0-9]" \
    | sort | uniq