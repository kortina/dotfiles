#!/bin/bash
# modified via:
# https://cameronnokes.com/blog/how-to-convert-heic-image-files-to-jpg-in-bash-on-macos/

# 1
set -eu -o pipefail

# 2
count=$(find . -depth 1 -iname "*.heic" | wc -l | sed 's/[[:space:]]*//')
echo "converting $count files .heic or .HEIC files to .jpg"

# 3
magick mogrify -monitor -format jpg *.heic
magick mogrify -monitor -format jpg *.HEIC

# 4
echo "Remove .heic / .HEIC files? [y/n]"
read remove

# 5
if [[ "$remove" == "y" ]]; then
  find . -depth 1 -iname "*.heic" -delete
fi
