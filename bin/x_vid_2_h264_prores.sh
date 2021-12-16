#!/usr/bin/env bash
# input file should be first arg to this script
input="$1"
if [ "$input" = "" ]
then
  echo "Usage: $0 [file to convert to prores format]"
  exit
fi
# get the name of the file without the extension
fn="${input%.*}"
output="$fn.mov"
echo -e " input: $input\n fn: $fn\n output: $output"
set -v
ffmpeg -i "$input" -c:v h264 -c:a pcm_s16le "$output"
