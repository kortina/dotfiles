#!/usr/bin/env bash

link=$1
cd $HOME/Downloads
yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4' "$1"