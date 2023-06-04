#!/bin/sh
if [ $# -eq 0 ]; then

cat <<EOF
Usage: $0 [book.ext]

Convert \`book.ext\` to \`book.txt\`

EOF
exit 1;

fi

# book, eg, an epub
book=$1

# book.epub will become book.txt
txt=`echo "$book" | sed  -e 's/\..*$/\.txt/g'`

# use Calibre to convert
ebook-convert "$book" "$txt"