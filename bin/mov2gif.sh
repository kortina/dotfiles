#!/bin/sh
# recordedmov, a screen reording, for example
recorded_mov=$1
# recorded.mov will become recorded.gif
out_gif=`echo "$recorded_mov" | sed  -e 's/\.mov$/\.gif/g'`
# this will set $streams_stream_0_width and $streams_stream_0_height
eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height,width $recorded_mov)
# reduce dimensions by 15%
width=`echo "$streams_stream_0_width*0.85" | bc`

# generate a palette
palette="/tmp/palette.png"
filters="fps=10,scale=$width:-1:flags=bicubic"
ffmpeg -v warning -i $recorded_mov -vf "$filters,palettegen" -y $palette
# convert to gif
ffmpeg -v warning -i $recorded_mov -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $out_gif
