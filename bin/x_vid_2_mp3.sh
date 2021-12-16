#!/bin/sh
if [ $# -eq 0 ]; then

cat <<EOF
Usage: $0 [video.ext]

Convert \`video.ext\` to \`video.mp3\`

EOF
exit 1;

fi

# vid, a screen reording, for example
vid=$1

# vid.mov will become vid.mp3
mp3=`echo "$vid" | sed  -e 's/\..*$/\.mp3/g'`

# use ffmpeg to extract audio
ffmpeg -i "$vid" -q:a 0 -map a "$mp3"
