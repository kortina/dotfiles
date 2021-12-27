#!/bin/sh
if [ $# -eq 0 ]; then

cat <<EOF
Usage: $0 [screenplay.fountain]

EOF
exit 1;

fi

# https://github.com/ifrost/afterwriting-labs/blob/master/docs/clients.md
command -v afterwriting >/dev/null 2>&1 || { echo "ERROR: npm install -g afterwriting";  exit 1; }
command -v qpdf >/dev/null 2>&1 || { echo "ERROR: brew install qpdf";  exit 1; }

# vid, a screen reording, for example
fp_screenplay=$1
bn_screenplay=`basename "$1"`
fp_pdf="/tmp/$bn_screenplay.pdf"

# echo "afterwriting --overwrite --source \"$fp_screenplay\" --pdf \"$fp_pdf\" 2>&1 > /dev/null"
afterwriting --overwrite --source "$fp_screenplay" --pdf "$fp_pdf" 2>&1 > /dev/null



words=`wc -w "$fp_screenplay" | tr -s ' ' | cut -d ' ' -f 2`
lines=`wc -l "$fp_screenplay" | tr -s ' ' | cut -d ' ' -f 2`
pages=`qpdf --show-npages "$fp_pdf"`
echo "-------------------"
echo "File:  $bn_screenplay"
echo "Words: $words"
echo "Lines: $lines"
echo "Pages: $pages"
echo "-------------------"