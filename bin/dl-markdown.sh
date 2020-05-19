#!/usr/bin/env bash
# Download URL, run through readability, convert to markdown.
# deps:
# ripgrep
# readability @ 0.1.0
# html2md @ 0.4.4
# X h2m @ 0.7.0

_dl_markdown() {
    url="$1"
    # echo "$url"
    fbase="dl-`date '+%Y.%m.%d.%H.%M.%S'`"
    fn="/tmp/$fbase"
    raw="$fn.raw.html"
    readable="$fn.readable.html"
    md="$fn.md"
    curl -s "$url" > "$raw" 2>/dev/null
    readability "$raw" >"$readable" 2>/dev/null
    html2md -g -i "$readable" > "$md"
    # extract title from raw html and slugify
    title="`rg --no-line-number -o '<title>(.*)</title>' $raw --replace '$1' | head -1 |  tr '\n' '-' | sed -e 's/[^[:alnum:]]/-/g' | tr -s '-' $lowercase | sed 's/[- \n]*$//g'`"
    # if we did not find a title, just use fbase
    [ -z "$title" ] && title="$fbase"
    # either way, add markdown ext
    title_md="$title.md"
    cp "$md" "$title_md"
    echo -e "Markdown at:\n$title_md"
}

# input URL should be EITHER:
# first arg to this script, OR:
# URL in STDIN
if [ $# = 0 ]
then
    while IFS= read -r line; do
        _dl_markdown "$line"
    done < /dev/stdin
    [[ {$line} ]] && _dl_markdown "$line" # read the final line (if no trailing newline)
    # see: https://stackoverflow.com/a/42631838/382912
else
    # echo "1: $1"
    _dl_markdown "$1"
fi
