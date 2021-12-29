#!/bin/sh
if [ $# -eq 0 ]; then

cat <<EOF
Usage: $0 [screenplay.fountain]

EOF
exit 1;

fi

# guards

# https://github.com/ifrost/afterwriting-labs/blob/master/docs/clients.md
command -v afterwriting >/dev/null 2>&1 || { echo "ERROR: npm install -g afterwriting";  exit 1; }
command -v qpdf >/dev/null 2>&1 || { echo "ERROR: brew install qpdf";  exit 1; }
command -v rg >/dev/null 2>&1 || { echo "ERROR: brew install rg";  exit 1; }


# files
fp_screenplay=$1
bn_screenplay=`basename "$1"`
fp_pdf="/tmp/$bn_screenplay.pdf"

# render a pdf in /tmp
afterwriting --overwrite --source "$fp_screenplay" --pdf "$fp_pdf" 2>&1 > /dev/null


words=`wc -w "$fp_screenplay" | tr -s ' ' | cut -d ' ' -f 2`
lines=`wc -l "$fp_screenplay" | tr -s ' ' | cut -d ' ' -f 2`
scenes=`rg --multiline "\n(INT|EXT)\." -o "$fp_screenplay" | wc -l | g -o "\d+"`
pages=`qpdf --show-npages "$fp_pdf"`

# commify

words=`LC_NUMERIC=en_US.UTF-8 printf "%'d\n" "$words"`
lines=`LC_NUMERIC=en_US.UTF-8 printf "%'d\n" "$lines"`
scenes=`LC_NUMERIC=en_US.UTF-8 printf "%'d\n" "$scenes"`
pages=`LC_NUMERIC=en_US.UTF-8 printf "%'d\n" "$pages"`

echo "-------------------"
echo "File:  $bn_screenplay"
echo "Words: $words"
echo "Lines: $lines"
echo "Pages: $pages"
echo "-------------------"