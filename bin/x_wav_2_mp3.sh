#!/bin/sh
# https://stackoverflow.com/questions/3255674/convert-audio-files-to-mp3-using-ffmpeg
if [ $# -eq 0 ]; then

cat <<EOF
Usage: $0 [recording.wav]

Convert \`recording.wav\` to \`recording.mp3\`


EOF
exit 1;

fi

echo "INPUT:"
echo "$1"

f_wav=$1
f=`echo "${f_wav%.*}"`
f_mp3="$f.mp3"

set -v

ffmpeg -i "$f_wav" -vn -ar 44100 -ac 2 -b:a 192k "$f_mp3"

set +v

echo "OUTPUT:"
echo "$f_mp3"