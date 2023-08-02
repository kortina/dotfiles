#!/usr/bin/env bash
# Usage:
#   dl-thumbnail-youtube.sh [url]

lnk"$1"
 yt-dlp --skip-download  --write-thumbnail "$1"
