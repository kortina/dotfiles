#!/bin/sh
if [ $# -eq 0 ]; then

cat <<EOF
Usage: $0 [recording.mov]

Convert \`recording.mov\` to \`recording.gif\`

Compress to 85% resolution.

EOF
exit 1;

fi


compression="0.85"


# mov, a screen reording, for example
mov=$1
# recorded.mov will become recorded.gif
gif=`echo "$mov" | sed  -e 's/\.mov$/\.gif/g'`
# this will set $streams_stream_0_width and $streams_stream_0_height
eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height,width $mov)
# reduce dimensions by 15%
width=`echo "$streams_stream_0_width*$compression" | bc`

# generate a palette
palette="/tmp/palette.png"
filters="fps=10,scale=$width:-1:flags=bicubic"
ffmpeg -v warning -i $mov -vf "$filters,palettegen" -y $palette
# convert to gif
ffmpeg -v warning -i $mov -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $gif
