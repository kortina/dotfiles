#!/usr/bin/env bash

# ARGV[1]
# input filename
usage="x_highland_2_pdf.sh [input_filename] \nwill create a pdf on Desktop given a highland file."
if [[ -z "$1" ]];
then
    echo -e "$usage"
    exit 1
fi

fa_highland=`realpath "$1"`
echo "realpath for $1 is $fa_highland"
cd /tmp

bn=`basename "$fa_highland"`

fa_fountain="/tmp/$bn.x.fountain"
fa_pdf="$fa_fountain.pdf"


# generate the fountain from the highland:
x_highland_2_fountain.py "$fa_highland" --output="$fa_fountain"

# generate the pdf
set -v
afterwriting \
--config "$HOME/dotfiles/.afterwriting.config.json" \
--overwrite \
--source "$fa_fountain" \
--pdf "$fa_pdf"