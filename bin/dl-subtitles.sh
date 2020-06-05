#!/usr/bin/env bash
# Download subtitles for a movie
# Usage:
#   dl-subtitles.sh "rush hour"
# deps:
# cd $HOME/src && git clone git@github.com:kortina/opensubs.git
# ripgrep

wd=`pwd`

_dl_subs() {
    title="$1"
    fn="`echo \"$title\" | head -1 |  tr '\n' '-' | sed -e 's/[^[:alnum:]]/-/g' | tr -s '-' $lowercase | sed 's/[- \n]*$//g'`"
    fn="$wd/$fn.srt"
    # echo "$title"
    # echo "$fn"

    cd $HOME/src/opensubs
    dl_file=`./node_modules/subtitler/bin/subtitler.bin.js "$title" \
        --lang eng -n 1 --download 2>&1 \
        | rg -o "Downloaded.*" | rg -o '>\s+(/.*)' --replace '$1'`
    mv $dl_file "$fn"
    echo -e "Subs at:\n$fn"
}

# input URL should be EITHER:
# first arg to this script, OR:
# URL in STDIN
if [ $# = 0 ]
then
    while IFS= read -r line; do
        _dl_subs "$line"
    done < /dev/stdin
    [[ {$line} ]] && _dl_subs "$line" # read the final line (if no trailing newline)
    # see: https://stackoverflow.com/a/42631838/382912
else
    # echo "1: $1"
    _dl_subs "$1"
fi
