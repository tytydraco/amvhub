#!/usr/bin/env bash
shopt -s globstar

WIDTH="160"
HEIGHT="128"
FPS="15"

if [[ -z "$1" ]]
then
  echo "No video file specified"
  exit 1
fi

OUTPUT_FILE="${1%.*}.amv"
ffmpeg \
    -i "$1" \
    -f "amv" \
    -vf "mpdecimate,scale=$WIDTH:$HEIGHT,crop=in_w:$HEIGHT" \
    -strict -1 \
    -r "$FPS" \
    -ac 1 \
    -ar 22050 \
    -block_size 1470 \
    -n \
    -qmin 3 \
    -qmax 3 \
    "$OUTPUT_FILE"
