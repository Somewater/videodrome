#!/bin/bash
# From: https://github.com/chuyskywalker/easy-web-video-encode/blob/master/encode.sh

# Get the directory and filename
DIR=$(dirname "$1")
FILE=$(basename "$1")

# Go into the directory so the container will work locally
cd $DIR

# Temporarily install the actual encode script
# Gets "mounted into" the container with FFMPEG and tackles all the real encoding
IN=$1
OUT=$(echo $1 | sed 's/^\(.*\)\.[a-zA-Z0-9]*$/\1/')
echo "--- Encoding: $1"

VF="scale=-1:720"
# Count cores, more than one? Use many!
# Uses one less than total (recomendation for webm)
# Doesn't apply to x264 where 0 == auto (webm doesn't support that)
CORES=$(grep -c ^processor /proc/cpuinfo)
if [ "$CORES" -gt "1" ]; then
  CORES="$(($CORES - 1))"
fi
echo "--- Using $CORES threads for webm"
echo "--- webm, First Pass"
ffmpeg -i $IN \
    -hide_banner -loglevel error -stats \
    -codec:v libvpx -threads $CORES -slices 4 -quality good -cpu-used 0 -b:v 1000k -qmin 10 -qmax 42 -maxrate 1000k -bufsize 2000k -vf $VF \
    -an \
    -pass 1 \
    -f webm \
    -y /dev/null
echo "--- webm, Second Pass"
ffmpeg -i $IN \
    -hide_banner -loglevel error -stats \
    -codec:v libvpx -threads $CORES -slices 4 -quality good -cpu-used 0 -b:v 1000k -qmin 10 -qmax 42 -maxrate 1000k -bufsize 2000k -vf $VF \
    -codec:a libvorbis -b:a 128k \
    -pass 2 \
    -f webm \
    -y $OUT.webm
echo "--- x264, First Pass"
ffmpeg -i $IN \
    -hide_banner -loglevel error -stats \
    -codec:v libx264 -threads 0 -profile:v main -preset slow -b:v 1000k -maxrate 1000k -bufsize 2000k -vf $VF \
    -an \
    -pass 1 \
    -f mp4 \
    -y /dev/null
echo "--- x264, Second Pass"
ffmpeg -i $IN \
    -hide_banner -loglevel error -stats \
    -codec:v libx264 -threads 0 -profile:v main -preset slow -b:v 1000k -maxrate 1000k -bufsize 2000k -vf $VF \
    -codec:a libfdk_aac -b:a 128k \
    -pass 2 \
    -f mp4 \
    -y $OUT.mp4