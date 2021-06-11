#!/usr/bin/env bash
# set -v
f="$1"
echo "$f"
echo "$f" | rg -i -q "\.png$" && pngquant "$f" && echo "optimized .png" && exit
echo "$f" | rg -i -q "\.(jpg|jpeg)$" && jpegoptim "$f" && echo "optimized .jpg" && exit
echo "did not match .png or .jpg or .jpeg"