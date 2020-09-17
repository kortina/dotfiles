#!/bin/bash
# modified via:
# https://cameronnokes.com/blog/how-to-convert-heic-image-files-to-jpg-in-bash-on-macos/

# 1
set -eu -o pipefail

# allow passing of a different extension (eg, HEIC) as arg1:
ARG1=${1:-heic}

ext="$ARG1"
# 2
count=$(find . -depth 1 -name "*.$ext" | wc -l | sed 's/[[:space:]]*//')
echo "converting $count files .$ext files to .jpg"

# 3
magick mogrify -monitor -format jpg *.$ext

# 4
echo "Remove .$ext files? [y/n]"
read remove

# 5
if [[ "$remove" == "y" ]]; then
  find . -depth 1 -name "*.$ext" -delete
fi
