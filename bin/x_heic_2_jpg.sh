#!/bin/bash
# modified via:
# https://cameronnokes.com/blog/how-to-convert-heic-image-files-to-jpg-in-bash-on-macos/

# 1
set -eu -o pipefail

# 2
count_H=$(find . -depth 1 -name "*.HEIC" | wc -l | sed 's/[[:space:]]*//')
echo "converting $count_H files .HEIC files to .jpg"
[[ "$count_H" == "0" ]] || magick mogrify -monitor -format jpg *.HEIC

count_h=$(find . -depth 1 -name "*.heic" | wc -l | sed 's/[[:space:]]*//')
echo "converting $count_h files .heic files to .jpg"
[[ "$count_h" == "0" ]] || magick mogrify -monitor -format jpg *.heic


# 4
echo "Remove .heic / .HEIC files? [y/n]"
read remove

# 5
if [[ "$remove" == "y" ]]; then
  find . -depth 1 -iname "*.heic" -delete
fi
