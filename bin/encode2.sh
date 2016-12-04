#!/bin/bash
# From: https://gist.github.com/yellowled/1439610

IN=$1
OUT=$2

echo "Start webm encoding"
ffmpeg -i $IN -f webm -vcodec libvpx -acodec libvorbis -ab 128000 -crf 22 -s 640x360 $OUT.webm \
    -hide_banner -nostdin

echo "Start mp4 encoding"
ffmpeg -i $IN -acodec aac -strict experimental -ac 2 -ab 128k -vcodec libx264 -preset slow -f mp4 -crf 22 -s 640x360 $OUT.mp4 \
    -hide_banner -nostdin

echo "Start ogg encoding"
if which ffmpeg2theora >/dev/null; then
    ffmpeg2theora $IN -o $OUT.ogv -x 640 -y 360 --videoquality 5 --audioquality 0  --frontend
fi
