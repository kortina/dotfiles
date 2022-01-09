#!/usr/bin/env bash
# Download URL, run through readability, convert to markdown.
# deps:
# ripgrep
# readability @ 0.1.0
# npm install readability-cli
# html2md @ 0.4.4
# X h2m @ 0.7.0
# brew install pandoc

command_guard()
{
    echo "check: $1"
    if ! command -v "$1" &> /dev/null ; then
        echo "$1 NOT FOUND";
        exit;
    fi
}

_dl_markdown() {
    url="$1"
    # echo "$url"
    fbase="dl-`date '+%Y.%m.%d.%H.%M.%S'`"
    fn="/tmp/$fbase"
    raw="$fn.raw.html"
    readable="$fn.readable.html"
    md="$fn.md"
    curl -s "$url" > "$raw" 2>/dev/null
    command_guard "readable"
    readable "$raw" >"$readable" # 2>/dev/null

    echo "$raw"
    echo "$readable"

    # html2md -g -i "$readable" > "$md"
    command_guard "pandoc"
    # markdown_type="markdown"
    markdown_type="commonmark" # https://pandoc.org/MANUAL.html
    pandoc -f html -t "$markdown_type" "$readable" -o "$md"
    # now, strip all the native html (div, etc) elements
    # via: https://stackoverflow.com/questions/53311148/remove-html-elements-inside-markdown
    pandoc --from=markdown --to=html "$md" | \
    pandoc --from=html --to="$markdown_type-raw_html" --output "$md"

    # extract title from raw html and slugify
    title="`rg --no-line-number -o '<title>(.*)</title>' $raw --replace '$1' | head -1 |  tr '\n' '-' | sed -e 's/[^[:alnum:]]/-/g' | tr -s '-' $lowercase | sed 's/[- \n]*$//g'`"
    # if we did not find a title, just use fbase
    [ -z "$title" ] && title="$fbase"
    # truncate to 128 chars
    title=`echo "$title" | cut -c1-128`
    # either way, add markdown ext
    title_md="$title.md"
    cp "$md" "$title_md"
    echo -e "\n-- via <$url>" >> "$title_md"
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
