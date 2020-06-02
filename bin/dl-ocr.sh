#!/usr/bin/env bash
# OCR text from an image URL

_ocr() {
    url="$1"
    echo "$url"
    tmp_in="/tmp/ocr-`date '+%Y.%m.%d.%H.%M.%S'`"
    tmp_out="$tmp_in-out"
    curl -s "$url" > "$tmp_in" 2>/dev/null
    tesseract "$tmp_in" "$tmp_out" 2>/dev/null
    cat "$tmp_out.txt"
}

# input URL should be EITHER:
# first arg to this script, OR:
# URL in STDIN
if [ $# = 0 ]
then
    while IFS= read -r line; do
        _ocr "$line"
    done < /dev/stdin
    [[ {$line} ]] && _ocr "$line" # read the final line (if no trailing newline)
    # see: https://stackoverflow.com/a/42631838/382912
else
    echo "1: $1"
    _ocr "$1"
fi
