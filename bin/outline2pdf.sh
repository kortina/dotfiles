#!/usr/bin/env bash

# 1.5in L margin:
# https://screenwriting.io/what-is-standard-screenplay-format/

# ARGV[1]
# input filename
usage="outline2pdf.sh [input_filename] \nwill create a pdf on Desktop given a markdown or fountain file."
ifn="$1"
if [[ -z $ifn ]];
then
    echo -e "$usage"
    exit 1
fi

# Use the style sheet from this env var,
# or fallback to a default:
test -z $OUTLINE_CSS && OUTLINE_CSS="$HOME/Google-Drive/_notebook/_style.css"

# output filename (replace ext md|markdown|fountain with pdf)
ofn=`echo $ifn | sed 's/\.md$/.pdf/i' | sed 's/\.fountain$/.pdf/i' | sed 's/\.markdown$/.pdf/i'`
# just fn
ofn=`basename "$ofn"`
# on desktop
ofp="$HOME/Desktop/$ofn"

echo "----------"
echo -e "Create \n$ofp \nfrom \n$ifn"
echo "----------"

# --pdf-engine-opt="[page] of [topage]" \

pandoc \
--pdf-engine=wkhtmltopdf \
--pdf-engine-opt="--header-right" \
--pdf-engine-opt="[page]" \
--pdf-engine-opt="--header-font-name" \
--pdf-engine-opt="Courier" \
--pdf-engine-opt="--header-font-size" \
--pdf-engine-opt="10" \
--pdf-engine-opt="--header-spacing" \
--pdf-engine-opt="10" \
--pdf-engine-opt="-T" \
--pdf-engine-opt="1in" \
--pdf-engine-opt="-B" \
--pdf-engine-opt="1in" \
--pdf-engine-opt="-L" \
--pdf-engine-opt="1.5in" \
--pdf-engine-opt="-R" \
--pdf-engine-opt="1in" \
-c "$OUTLINE_CSS" \
"$ifn" -o "$ofp"